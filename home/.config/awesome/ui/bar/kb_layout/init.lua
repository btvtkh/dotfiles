local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local shape = require("lib.shape")
local dpi = beautiful.xresources.apply_dpi

return function()
	local ret = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = shape.rrect(dpi(8)),
		{
			widget = awful.widget.keyboardlayout {}
		}
	}

	local wp = ret._private

	wp.on_mouse_enter = function()
		ret:set_bg(beautiful.bg_urg)
	end

	wp.on_mouse_leave = function()
		ret:set_bg(beautiful.bg_alt)
	end

	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	return ret
end
