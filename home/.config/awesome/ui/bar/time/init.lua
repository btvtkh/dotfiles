local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local day_info_panel = require("ui.day_info_panel").get_default()

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		buttons = {
			awful.button({}, 1, function()
				day_info_panel:toggle()
			end)
		},
		{
			widget = wibox.container.margin,
			margins = { left = dpi(8), right = dpi(8) },
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(8),
				{
					widget = wibox.widget.textclock,
					format = "%d %b, %a"
				},
				{
					widget = wibox.container.margin,
					forced_height = 1,
					forced_width = beautiful.separator_thickness,
					margins = { top = dpi(6), bottom = dpi(6) },
					{
						id = "separator",
						widget = wibox.widget.separator,
						orientation = "vertical"
					}
				},
				{
					widget = wibox.widget.textclock,
					format = "%H:%M"
				}
			}
		}
	}

	local wp = ret._private
	local separator = ret:get_children_by_id("separator")[1]

	wp.on_mouse_enter = function()
		ret:set_bg(beautiful.bg_urg)
		separator:set_color(beautiful.fg_alt)
	end

	wp.on_mouse_leave = function()
		ret:set_bg(beautiful.bg_alt)
		separator:set_color(beautiful.bg_urg)
	end

	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	return ret
end

return setmetatable({ new = new }, { __call = new })
