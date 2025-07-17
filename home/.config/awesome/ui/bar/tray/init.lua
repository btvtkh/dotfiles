local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local shape = require("lib.shape")
local dpi = beautiful.xresources.apply_dpi
local text_icons = beautiful.text_icons

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = shape.rrect(dpi(8)),
		{
			widget = wibox.container.margin,
			margins = { left = dpi(8), right = dpi(8) },
			{
				id = "items-layout",
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(8),
				{
					id = "reveal-button",
					widget = wibox.widget.textbox,
					markup = text_icons.arrow_left
				}
			}
		}
	}

	local wp = ret._private
	local items_layout = ret:get_children_by_id("items-layout")[1]
	local reveal_button = ret:get_children_by_id("reveal-button")[1]

	wp.tray_visible = false

	wp.tray = wibox.widget {
		widget = wibox.container.margin,
		margins = { top = dpi(4), bottom = dpi(4) },
		{
			widget = wibox.widget.systray
		}
	}

	wp.on_mouse_enter = function()
		beautiful.bg_systray = beautiful.bg_urg
		ret:set_bg(beautiful.bg_urg)
	end

	wp.on_mouse_leave = function()
		beautiful.bg_systray = beautiful.bg_alt
		ret:set_bg(beautiful.bg_alt)
	end

	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	reveal_button:buttons {
		awful.button({}, 1, function()
			wp.tray_visible = not wp.tray_visible
			reveal_button:set_markup(wp.tray_visible and text_icons.arrow_right or text_icons.arrow_left)
			if wp.tray_visible then
				items_layout:insert(2, wp.tray)
			else
				items_layout:remove_widgets(wp.tray)
			end
		end)
	}

	return ret
end

return setmetatable({ new = new }, { __call = new })
