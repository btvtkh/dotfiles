local lgi = require("lgi")
local dbus_proxy = require("external.dbus_proxy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local adapter = {}
local device = {}

local function create_device_object(path)
	if not path or path == "/" then return end
	local device_object = gobject {}
	gtable.crush(device_object, device, true)
	device_object._private = {}

	device_object._private.device_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.bluez",
		interface = "org.bluez.Device1",
		path = path
	}

	device_object._private.battery_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.bluez",
		interface = "org.bluez.Battery1",
		path = path
	}

	device_object._private.properties_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.bluez",
		interface = "org.freedesktop.DBus.Properties",
		path = path
	}

	device_object._private.properties_proxy:connect_signal("PropertiesChanged", function(_, _, props)
		if props.Connected ~= nil then
			device_object:emit_signal("property::connected", props.Connected)
		end
		if props.Paired ~= nil then
			device_object:emit_signal("property::paired", props.Paired)
		end
		if props.Trusted ~= nil then
			device_object:emit_signal("property::trusted", props.Trusted)
		end
		if props.Percentage ~= nil then
			device_object:emit_signal("property::percentage", props.Percentage)
		end
	end)

	return device_object
end

function adapter:set_powered(state)
	if self._private.adapter_proxy.SetAsync then
		self._private.adapter_proxy:SetAsync(
			nil,
			{},
			self._private.adapter_proxy.interface,
			"Powered",
			lgi.GLib.Variant("b", state)
		)
		self._private.adapter_proxy.Powered = {
			signature = "b",
			value = state
		}
	end
end

function adapter:get_powered()
	return self._private.adapter_proxy.Powered
end

function adapter:start_discovery()
	if not self._private.adapter_proxy then return end
	if self._private.adapter_proxy.Discovering ~= true then
		self._private.adapter_proxy:StartDiscoveryAsync(nil, {})
	end
end

function adapter:stop_discovery()
	if not self._private.adapter_proxy then return end
	if self._private.adapter_proxy.Discovering == true then
		self._private.adapter_proxy:StopDiscoveryAsync(nil, {})
	end
end

function adapter:get_discovering()
	return self._private.adapter_proxy.Discovering
end

function adapter:get_devices()
	return self.devices
end

function adapter:get_device(path)
	return self.devices[path]
end

function device:connect()
	if self._private.device_proxy.Connected ~= true then
		self._private.device_proxy:ConnectAsync(nil, {})
	end
end

function device:disconnect()
	if self._private.device_proxy.Connected == true then
		self._private.device_proxy:DisconnectAsync(nil, {})
	end
end

function device:pair()
	if self._private.device_proxy.Paired ~= true then
		self._private.device_proxy:PairAsync(nil, {})
	end
end

function device:cancel_pairing()
	if self._private.device_proxy.Paired == true then
		self._private.device_proxy:CancelPairingAsync(nil, {})
	end
end

function device:set_trusted(trusted)
	self._private.device_proxy:SetAsync(
		nil,
		{},
		self._private.device_proxy.interface,
		"Trusted",
		lgi.GLib.Variant("b", trusted)
	)
	self._private.device_proxy.Trusted = {
		signature = "b",
		value = trusted
	}
end

function device:get_connected()
	return self._private.device_proxy.Connected
end

function device:get_paired()
	return self._private.device_proxy.Paired
end

function device:get_trusted()
	return self._private.device_proxy.Trusted
end

function device:get_name()
	return self._private.device_proxy.Name
end

function device:get_icon()
	return self._private.device_proxy.Icon
end

function device:get_address()
	return self._private.device_proxy.Address
end

function device:get_percentage()
	return self._private.battery_proxy.Percentage
end

function device:get_path()
	return self._private.device_proxy.object_path
end

local function new()
	local ret = gobject {}
	gtable.crush(ret, adapter, true)
	ret._private = {}

	ret._private.object_manager_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.bluez",
		interface = "org.freedesktop.DBus.ObjectManager",
		path = "/"
	}

	if ret._private.object_manager_proxy then
		ret._private.adapter_proxy = dbus_proxy.Proxy:new {
			bus = dbus_proxy.Bus.SYSTEM,
			name = "org.bluez",
			interface = "org.bluez.Adapter1",
			path = "/org/bluez/hci0"
		}

		ret._private.properties_proxy = dbus_proxy.Proxy:new {
			bus = dbus_proxy.Bus.SYSTEM,
			name = "org.bluez",
			interface = "org.freedesktop.DBus.Properties",
			path = "/org/bluez/hci0"
		}

		ret._private.properties_proxy:connect_signal("PropertiesChanged", function(_, _, props)
			if props.Powered ~= nil then
				ret:emit_signal("property::powered", props.Powered)
			end
			if props.Discovering ~= nil then
				ret:emit_signal("property::discovering", props.Discovering)
			end
		end)

		ret.devices = {}
		ret._private.object_manager_proxy:connect_signal("InterfacesAdded", function(_, path)
			if path:match("^/org/bluez/hci0/dev_%w%w_%w%w_%w%w_%w%w_%w%w_%w%w$") then
				ret.devices[path] = create_device_object(path)
				ret:emit_signal("device-added", path)
			end
		end)

		ret._private.object_manager_proxy:connect_signal("InterfacesRemoved", function(_, path)
			if path:match("^/org/bluez/hci0/dev_%w%w_%w%w_%w%w_%w%w_%w%w_%w%w$")then
				ret.devices[path] = nil
				ret:emit_signal("device-removed", path)
			end
		end)

		if ret._private.object_manager_proxy.GetManagedObjects then
			local object_paths = ret._private.object_manager_proxy:GetManagedObjects()
			for path, _ in pairs(object_paths) do
				if path:match("^/org/bluez/hci0/dev_%w%w_%w%w_%w%w_%w%w_%w%w_%w%w$") then
					ret.devices[path] = create_device_object(path)
				end
			end
		end
	end

	return ret
end

local instance = nil
local function get_default()
	if not instance then
		instance = new()
	end
	return instance
end

return {
	get_default = get_default
}
