local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local shape = require("lib.shape")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local bt_adapter = require("service.bluetooth").get_default()

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		forced_height = dpi(60),
		bg = beautiful.bg_alt,
		fg = beautiful.fg,
		shape = shape.rrect(dpi(13)),
		{
			widget = wibox.container.margin,
			margins = { left = dpi(15) },
			{
				layout = wibox.layout.align.horizontal,
				{
					id = "label-background",
					widget = wibox.container.background,
					forced_width = dpi(150),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(15),
						{
							widget = wibox.widget.textbox,
							markup = text_icons.bluetooth
						},
						{
							widget = wibox.container.place,
							valign = "center",
							{
								layout = wibox.layout.fixed.vertical,
								{
									id = "label",
									widget = wibox.widget.textbox,
									markup = "Bluetooth"
								},
								{
									id = "description",
									widget = wibox.widget.textbox,
									font = beautiful.font_h0
								}
							}
						}
					}
				},
				nil,
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.container.margin,
						margins = { top = dpi(15), bottom = dpi(15) },
						{
							id = "separator",
							widget = wibox.widget.separator,
							forced_height = 1,
							forced_width = beautiful.separator_thickness,
							orientation = "vertical"
						}
					},
					{
						id = "reveal-button",
						widget = wibox.container.background,
						forced_width = dpi(45),
						{
							widget = wibox.widget.textbox,
							align = "center",
							markup = text_icons.arrow_right
						}
					}
				}
			}
		}
	}

	local wp = ret._private
	local label_background = ret:get_children_by_id("label-background")[1]
	local description = ret:get_children_by_id("description")[1]
	local separator = ret:get_children_by_id("separator")[1]

	wp.on_powered = function(_, powered)
		if powered then
			ret:set_bg(beautiful.ac)
			ret:set_fg(beautiful.bg)
			separator:set_color(beautiful.bg)
			description:set_markup("Enabled")
		else
			ret:set_bg(beautiful.bg_alt)
			ret:set_fg(beautiful.fg)
			separator:set_color(beautiful.bg_urg)
			description:set_markup("Disabled")
		end
	end

	wp.on_mouse_enter = function()
		if not bt_adapter:get_powered() then
			ret:set_bg(beautiful.bg_urg)
			separator:set_color(beautiful.fg_alt)
		end
	end

	wp.on_mouse_leave = function()
		if not bt_adapter:get_powered() then
			ret:set_bg(beautiful.bg_alt)
			separator:set_color(beautiful.bg_urg)
		end
	end

	bt_adapter:connect_signal("property::powered", wp.on_powered)
	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	label_background:buttons {
		awful.button({}, 1, function()
			bt_adapter:set_powered(not bt_adapter:get_powered())
		end)
	}

	wp.on_powered(nil, bt_adapter:get_powered())

	return ret
end

return setmetatable({ new = new }, { __call = new })
