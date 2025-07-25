local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local common = require("common")
local shape = require("lib.shape")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local bt_adapter = require("service.bluetooth").get_default()

local function create_device_widget(path, device)
	local ret = wibox.widget {
		widget = wibox.container.background,
		shape = shape.rrect(dpi(13)),
		forced_height = dpi(40),
		{
			widget = wibox.container.margin,
			margins = { left = dpi(15), right = dpi(15) },
			{
				layout = wibox.layout.align.horizontal,
				{
					widget = wibox.container.constraint,
					width = dpi(220),
					{
						id = "name",
						widget = wibox.widget.textbox
					}
				},
				nil,
				{
					widget = wibox.container.constraint,
					width = dpi(130),
					{
						id = "percentage",
						widget = wibox.widget.textbox
					}
				}
			}
		}
	}

	local wp = ret._private
	local name = ret:get_children_by_id("name")[1]
	local percentage = ret:get_children_by_id("percentage")[1]

	wp.device_path = path

	wp.on_connected = function(_, cnd)
		name:set_markup(
			(cnd and text_icons.check .. " " or "")
			.. (device:get_name() or device:get_address())
		)
	end

	wp.on_percentage = function(_, perc)
		percentage:set_markup(perc ~= nil and string.format("%.0f%%", perc) or "")
	end

	wp.on_mouse_enter = function(w)
		w:set_bg(beautiful.bg_urg)
	end

	wp.on_mouse_leave = function(w)
		w:set_bg(nil)
	end

	device:connect_signal("property::connected", wp.on_connected)
	device:connect_signal("property::percentage", wp.on_percentage)
	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	ret:buttons {
		awful.button({}, 1, function()
			if not device:get_connected() then
				device:connect()
			else
				device:disconnect()
			end
		end)
	}

	name:set_markup(
		(device:get_connected() and text_icons.check .. " " or "")
		.. (device:get_name() or device:get_address())
	)

	percentage:set_markup(
		device:get_percentage() and string.format("%.0f%%", device:get_percentage()) or ""
	)

	return ret
end

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(8),
			{
				widget = wibox.container.background,
				forced_height = dpi(400),
				forced_width = dpi(400),
				{
					id = "devices-layout",
					layout = wibox.layout.overflow.vertical,
					scrollbar_enabled = false,
					step = 40,
					spacing = dpi(3)
				}
			},
			{
				widget = wibox.container.background,
				forced_height = dpi(45),
				bg = beautiful.bg_alt,
				shape = shape.rrect(dpi(13)),
				{
					widget = wibox.container.margin,
					margins = dpi(5),
					{
						layout = wibox.layout.align.horizontal,
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = beautiful.separator_thickness + dpi(2),
							spacing_widget = {
								widget = wibox.container.margin,
								margins = { top = dpi(10), bottom = dpi(10) },
								{
									widget = wibox.widget.separator,
									orientation = "vertical"
								}
							},
							{
								id = "bottombar-close-button",
								widget = common.button {
									label = text_icons.arrow_left,
									forced_width = dpi(35),
									forced_height = dpi(35),
									shape = shape.rrect(dpi(8))
								}
							},
							{
								id = "bottombar-discover-button",
								widget = common.button {
									label = text_icons.search,
									forced_width = dpi(35),
									forced_height = dpi(35),
									shape = shape.rrect(dpi(8))
								}
							}
						},
						nil,
						{
							widget = wibox.container.margin,
							forced_width = dpi(60),
							margins = dpi(5),
							{
								widget = wibox.container.place,
								halign = "center",
								{
									id = "bottombar-toggle-switch",
									widget = common.switch,
									trough_color = beautiful.fg_alt,
									slider_color = beautiful.bg_alt,
									slider_margins = dpi(4),
									trough_shape = shape.rbar(),
									slider_shape = shape.rbar()
								}
							}
						}
					}
				}
			}
		}
	}

	local wp = ret._private
	local devices_layout = ret:get_children_by_id("devices-layout")[1]
	local bottombar_toggle_switch = ret:get_children_by_id("bottombar-toggle-switch")[1]
	local bottombar_discover_button = ret:get_children_by_id("bottombar-discover-button")[1]

	wp.on_device_added = function(_, path, device)
		local device_widget = create_device_widget(path, device)

		if #devices_layout.children == 1
		and not devices_layout.children[1]._private.device_path then
			devices_layout:reset()
		else
			for _, old_device_widget in ipairs(devices_layout.children) do
				if old_device_widget._private.device_path == path then
					devices_layout:remove_widgets(old_device_widget)
				end
			end
		end

		if device:get_connected() then
			devices_layout:insert(1, device_widget)
		else
			devices_layout:add(device_widget)
		end
	end

	wp.on_device_removed = function(_, path, device)
		for _, device_widget in ipairs(devices_layout.children) do
			if device_widget._private.device_path == path then
				device:disconnect_signal("property::connected", device_widget._private.on_connected)
				device:disconnect_signal("property::percentage", device_widget._private.on_percentage)
				devices_layout:remove_widgets(device_widget)
			end
		end

		if #devices_layout.children == 0 then
			devices_layout:add(wibox.widget {
				widget = wibox.container.background,
				fg = beautiful.fg_alt,
				forced_height = dpi(400),
				{
					widget = wibox.widget.textbox,
					align = "center",
					font = beautiful.font_h2,
					markup = text_icons.wait
				}
			})
		end
	end

	wp.on_discovering = function(_, discovering)
		bottombar_discover_button:set_fg_normal(discovering and beautiful.fg_alt or beautiful.fg)
		bottombar_discover_button:set_bg_hover(discovering and beautiful.fg_alt or beautiful.ac)
		bottombar_discover_button:set_fg(discovering and beautiful.fg_alt or beautiful.fg)
		bottombar_discover_button:set_bg(beautiful.bg_alt)
	end

	wp.on_powered = function(_, powered)
		wp.on_discovering(nil, bt_adapter:get_discovering())
		bottombar_toggle_switch:set_checked(powered)

		if powered then
			devices_layout:reset()
			devices_layout:add(wibox.widget {
				widget = wibox.container.background,
				fg = beautiful.fg_alt,
				forced_height = dpi(400),
				{
					widget = wibox.widget.textbox,
					align = "center",
					font = beautiful.font_h2,
					markup = text_icons.wait
				}
			})

			for path, device in pairs(bt_adapter:get_devices()) do
				wp.on_device_added(nil, path, device)
			end

			bt_adapter:start_discovery()
		else
			bottombar_discover_button:set_fg(beautiful.fg)
			bottombar_discover_button:set_bg(beautiful.bg_alt)
			devices_layout:reset()
			devices_layout:add(wibox.widget {
				widget = wibox.container.background,
				fg = beautiful.fg_alt,
				forced_height = dpi(400),
				{
					widget = wibox.widget.textbox,
					align = "center",
					font = beautiful.font_h2,
					markup = "Bluetooth disabled"
				}
			})
		end
	end

	bt_adapter:connect_signal("device-added", wp.on_device_added)
	bt_adapter:connect_signal("device-removed", wp.on_device_removed)
	bt_adapter:connect_signal("property::discovering", wp.on_discovering)
	bt_adapter:connect_signal("property::powered", wp.on_powered)

	bottombar_toggle_switch:buttons {
		awful.button({}, 1, function()
			bt_adapter:set_powered(not bt_adapter:get_powered())
		end)
	}

	bottombar_discover_button:buttons {
		awful.button({}, 1, function()
			if bt_adapter:get_powered() then
				if bt_adapter:get_discovering() then
					bt_adapter:stop_discovery()
				else
					bt_adapter:start_discovery()
				end
			end
		end)
	}

	wp.on_powered(nil, bt_adapter:get_powered())

	return ret
end

return setmetatable({ new = new }, { __call = new })
