local lgi = require("lgi")
local _NM_status, NM = pcall(function() return require("lgi").NM end)
local dbus_proxy = require("lib.dbus_proxy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local network = {}
local client = {}
local connection = {}
local wired = {}
local wireless = {}
local access_point = {}

network.NMState = {
	UNKNOWN = 0,
	ASLEEP = 10,
	DISCONNECTED = 20,
	DISCONNECTING = 30,
	CONNECTING = 40,
	CONNECTED_LOCAL = 50,
	CONNECTED_SITE = 60,
	CONNECTED_GLOBAL = 70,
}

network.DeviceType = {
	ETHERNET = 1,
	WIFI = 2,
}

network.DeviceState = {
	UNKNOWN = 0,
	UNMANAGED = 10,
	UNAVAILABLE = 20,
	DISCONNECTED = 30,
	PREPARE = 40,
	CONFIG = 50,
	NEED_AUTH = 60,
	IP_CONFIG = 70,
	IP_CHECK = 80,
	SECONDARIES = 90,
	ACTIVATED = 100,
	DEACTIVATING = 110,
	FAILED = 120,
}

function network.device_state_to_string(state)
	local device_state_to_string = {
		[0] = "Unknown",
		[10] = "Unmanaged",
		[20] = "Unavailable",
		[30] = "Disconnected",
		[40] = "Prepare",
		[50] = "Config",
		[60] = "Need Auth",
		[70] = "IP Config",
		[80] = "IP Check",
		[90] = "Secondaries",
		[100] = "Activated",
		[110] = "Deactivated",
		[120] = "Failed",
	}

	return device_state_to_string[state]
end

local function flags_to_security(flags, wpa_flags, rsn_flags)
	local str = ""
	if flags == 1 and wpa_flags == 0 and rsn_flags == 0 then
		str = str .. " WEP"
	end
	if wpa_flags ~= 0 then
		str = str .. " WPA1"
	end
	if not rsn_flags ~= 0 then
		str = str .. " WPA2"
	end
	if wpa_flags == 512 or rsn_flags == 512 then
		str = str .. " 802.1X"
	end

	return (str:gsub("^%s", ""))
end

local function generate_uuid()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	local uuid = string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
	return uuid
end

local function trim_string(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

local function create_ap_profile(ap, password, auto_connect)
	local s_con = {
		["uuid"] = lgi.GLib.Variant("s", generate_uuid()),
		["id"] = lgi.GLib.Variant("s", ap:get_ssid()),
		["type"] = lgi.GLib.Variant("s", "802-11-wireless"),
		["autoconnect"] = lgi.GLib.Variant("b", auto_connect),
	}

	local s_ip4 = {
		["method"] = lgi.GLib.Variant("s", "auto"),
	}

	local s_ip6 = {
		["method"] = lgi.GLib.Variant("s", "auto"),
	}

	local s_wifi = {
		["mode"] = lgi.GLib.Variant("s", "infrastructure"),
	}

	local s_wsec = {}
	if ap:get_security() ~= "" then
		if ap:get_security():match("WPA") ~= nil then
			s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "wpa-psk")
			s_wsec["auth-alg"] = lgi.GLib.Variant("s", "open")
			s_wsec["psk"] = lgi.GLib.Variant("s", trim_string(password))
		else
			s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "None")
			s_wsec["wep-key-type"] = lgi.GLib.Variant("s", NM.WepKeyType.PASSPHRASE)
			s_wsec["wep-key0"] = lgi.GLib.Variant("s", trim_string(password))
		end
	end

	return {
		["connection"] = s_con,
		["ipv4"] = s_ip4,
		["ipv6"] = s_ip6,
		["802-11-wireless"] = s_wifi,
		["802-11-wireless-security"] = s_wsec,
	}
end

local function create_connection_object(path)
	if not path or path == "/" then return end
	local connection_object = gobject {}
	gtable.crush(connection_object, connection, true)
	connection_object._private = {}
	connection_object._private.connection_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.freedesktop.NetworkManager",
		interface = "org.freedesktop.NetworkManager.Settings.Connection",
		path = path
	}

	return connection_object
end

local function create_access_point_object(path)
	if not path or path == "/" then return end
	local access_point_object = gobject {}
	gtable.crush(access_point_object, access_point, true)
	access_point_object._private = {}
	access_point_object._private.access_point_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.freedesktop.NetworkManager",
		interface = "org.freedesktop.NetworkManager.AccessPoint",
		path = path
	}

	return access_point_object
end

function client:get_state()
	return self._private.client_proxy.State
end

function client:get_networking_enabled()
	return self._private.client_proxy.NetworkingEnabled
end

function client:enable(state)
	if self._private.client_proxy.EnableAsync then
		self._private.client_proxy:EnableAsync(nil, {}, state)
	end
end

function client:get_wireless_enabled()
	return self._private.client_proxy.WirelessEnabled
end

function client:set_wireless_enabled(state)
	if state == true and self:get_networking_enabled() ~= true then
		self:enable(true)
	end

	if self._private.client_proxy.SetAsync then
		self._private.client_proxy:SetAsync(
			nil,
			{},
			self._private.client_proxy.interface,
			"WirelessEnabled",
			lgi.GLib.Variant("b", state)
		)
		self._private.client_proxy.WirelessEnabled = {
			signature = "b",
			value = state
		}
	end
end

function client:get_connections()
	return self.connections
end

function client:get_connection(path)
	return self.connections[path]
end

function client:connect_access_point(ap, password, auto_connect)
	if not ap then return end
	password = password or ""
	auto_connect = auto_connect or true

	local profile = create_ap_profile(ap, password, auto_connect)

	local ap_connections = {}
	for _, con in pairs(self.connections) do
		if string.find(con:get_filename(), ap:get_ssid()) then
			table.insert(ap_connections, con)
		end
	end

	if #ap_connections == 0 then
		self._private.client_proxy:AddAndActivateConnectionAsync(
			nil,
			{},
			profile,
			self.wireless._private.device_proxy.object_path,
			ap._private.access_point_proxy.object_path
		)
	else
		ap_connections[1]._private.connection_proxy:UpdateAsync(
			nil,
			{},
			profile
		)
		self._private.client_proxy:ActivateConnectionAsync(
			nil,
			{},
			ap_connections[1]._private.connection_proxy.object_path,
			self.wireless._private.device_proxy.object_path,
			ap._private.access_point_proxy.object_path
		)
	end
end

function client:disconnect_active_access_point()
	self._private.client_proxy:DeactivateConnectionAsync(
		nil,
		{},
		self.wireless._private.device_proxy.ActiveConnection
	)
end

function connection:get_filename()
	return self._private.connection_proxy.Filename
end

function connection:get_path()
	return self._private.connection_proxy.object_path
end

function wired:get_hw_address()
	if self._private.device_proxy then
		return self._private.device_proxy.HwAddress
	end
end

function wired:get_state()
	if self._private.device_proxy then
		return self._private.device_proxy.State
	end
end

function wireless:get_hw_address()
	if self._private.device_proxy then
		return self._private.device_proxy.HwAddress
	end
end

function wireless:get_state()
	if self._private.device_proxy then
		return self._private.device_proxy.State
	end
end

function wireless:get_access_points()
	return self.access_points
end

function wireless:get_access_point(path)
	return self.access_points[path]
end

function wireless:get_active_access_point()
	return self:get_access_point(self._private.wireless_proxy.ActiveAccessPoint)
end

function wireless:request_scan()
	if self._private.wireless_proxy then
		self._private.wireless_proxy:RequestScanAsync(nil, {}, {})
	end
end

function access_point:get_ssid()
	return NM.utils_ssid_to_utf8(self._private.access_point_proxy.Ssid)
end

function access_point:get_hw_address()
	return self._private.access_point_proxy.HwAddress
end

function access_point:get_security()
	return flags_to_security(
		self._private.access_point_proxy.Flags,
		self._private.access_point_proxy.WpaFlags,
		self._private.access_point_proxy.RsnFlags
	)
end

function access_point:get_strength()
	return self._private.access_point_proxy.Strength
end

function access_point:get_path()
	return self._private.access_point_proxy.object_path
end

local function new()
	local ret = gobject {}
	gtable.crush(ret, client, true)
	ret._private = {}

	ret._private.client_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.freedesktop.NetworkManager",
		interface = "org.freedesktop.NetworkManager",
		path = "/org/freedesktop/NetworkManager"
	}

	ret._private.client_properties_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.freedesktop.NetworkManager",
		interface = "org.freedesktop.DBus.Properties",
		path = "/org/freedesktop/NetworkManager"
	}

	ret._private.settings_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.freedesktop.NetworkManager",
		interface = "org.freedesktop.NetworkManager.Settings",
		path = "/org/freedesktop/NetworkManager/Settings"
	}

	ret._private.settings_properties_proxy = dbus_proxy.Proxy:new {
		bus = dbus_proxy.Bus.SYSTEM,
		name = "org.freedesktop.NetworkManager",
		interface = "org.freedesktop.DBus.Properties",
		path = "/org/freedesktop/NetworkManager/Settings"
	}

	ret._private.client_proxy:connect_signal("StateChanged", function(_, state)
		ret:emit_signal("property::state", state)
	end)

	ret._private.client_properties_proxy:connect_signal("PropertiesChanged", function(_, _, props)
		if props.NetworkingEnabled ~= nil then
			ret:emit_signal("property::networking-enabled", props.NetworkingEnabled)
		end
		if props.WirelessEnabled ~= nil then
			ret:emit_signal("property::wireless-enabled", props.WirelessEnabled)
		end
	end)

	ret.connections = {}
	ret._private.settings_proxy:connect_signal("NewConnection", function(_, path)
		local connection_object = create_connection_object(path)
		ret.connections[path] = connection_object
		ret:emit_signal("connection-added", path)
	end)

	ret._private.settings_proxy:connect_signal("ConnectionRemoved", function(_, path)
		ret.connections[path] = nil
		ret:emit_signal("connection-removed", path)
	end)

	local connection_paths = ret._private.settings_proxy:ListConnections()
	for _, connection_path in ipairs(connection_paths) do
		local connection_object = create_connection_object(connection_path)
		ret.connections[connection_path] = connection_object
	end

	ret._private.settings_properties_proxy:connect_signal("PropertiesChanged", function(_, _, props)
		if props.Connections ~= nil then
			ret:emit_signal("property::connections", props.Connections)
		end
	end)

	ret.wired = gobject {}
	gtable.crush(ret.wired, wired, true)
	ret.wired._private = {}

	ret.wireless = gobject {}
	gtable.crush(ret.wireless, wireless, true)
	ret.wireless._private = {}

	local device_paths = ret._private.client_proxy:GetDevices()
	for _, device_path in ipairs(device_paths) do
		local device_proxy = dbus_proxy.Proxy:new {
			bus = dbus_proxy.Bus.SYSTEM,
			name = "org.freedesktop.NetworkManager",
			interface = "org.freedesktop.NetworkManager.Device",
			path = device_path
		}

		if device_proxy then
			if device_proxy.DeviceType == network.DeviceType.ETHERNET then
				ret.wired._private.device_proxy = device_proxy
				ret.wired._private.wired_proxy = dbus_proxy.Proxy:new {
					bus = dbus_proxy.Bus.SYSTEM,
					name = "org.freedesktop.NetworkManager",
					interface = "org.freedesktop.NetworkManager.Device.Wired",
					path = device_path,
				}
			elseif device_proxy.DeviceType == network.DeviceType.WIFI then
				ret.wireless._private.device_proxy = device_proxy
				ret.wireless._private.wireless_proxy = dbus_proxy.Proxy:new {
					bus = dbus_proxy.Bus.SYSTEM,
					name = "org.freedesktop.NetworkManager",
					interface = "org.freedesktop.NetworkManager.Device.Wireless",
					path = device_path,
				}

				ret.wireless._private.properties_proxy = dbus_proxy.Proxy:new {
					bus = dbus_proxy.Bus.SYSTEM,
					name = "org.freedesktop.NetworkManager",
					interface = "org.freedesktop.DBus.Properties",
					path = device_path
				}
			end
		end
	end

	if ret.wired._private.device_proxy then
		ret.wired._private.device_proxy:connect_signal("StateChanged", function(_, new_state, old_state, reason)
			ret.wired:emit_signal("property::state", new_state, old_state, reason)
		end)
	end

	if ret.wireless._private.device_proxy then
		ret.wireless._private.device_proxy:connect_signal("StateChanged", function(_, new_state, old_state, reason)
			ret.wireless:emit_signal("property::state", new_state, old_state, reason)
		end)
	end

	ret.wireless.access_points = {}
	if ret.wireless._private.wireless_proxy then
		ret.wireless._private.wireless_proxy:connect_signal("AccessPointAdded", function(_, path)
			local access_point_object = create_access_point_object(path)
			ret.wireless.access_points[path] = access_point_object
			ret.wireless:emit_signal("access-point-added", path)
		end)

		ret.wireless._private.wireless_proxy:connect_signal("AccessPointRemoved", function(_, path)
			ret.wireless.access_points[path] = nil
			ret.wireless:emit_signal("access-point-removed", path)
		end)

		local access_point_paths = ret.wireless._private.wireless_proxy:GetAccessPoints()
		for _, access_point_path in ipairs(access_point_paths) do
			local access_point_object = create_access_point_object(access_point_path)
			if access_point_object then
				ret.wireless.access_points[access_point_path] = access_point_object
			end
		end
	end

	if ret.wireless._private.properties_proxy then
		ret.wireless._private.properties_proxy:connect_signal("PropertiesChanged", function(_, _, props)
			if props.AccessPoints ~= nil then
				ret.wireless:emit_signal("property::access-points", props.AccessPoints)
			end
			if props.ActiveAccessPoint ~= nil then
				ret.wireless:emit_signal("property::active-access-point", props.ActiveAccessPoint)
			end
		end)
	end

	return ret
end

local instance = nil
local function get_default()
	if not instance then
		if not _NM_status or not NM then
			instance = gobject {}
		else
			instance = new()
		end
	end
	return instance
end

return setmetatable({
	get_default = get_default
}, {
	__index = network
})
