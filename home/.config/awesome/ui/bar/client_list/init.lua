local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local shape = require("lib.shape")
local dpi = beautiful.xresources.apply_dpi
local menu = require("ui.menu").get_default()

return function(s)
	local ret = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({}, 1, function(c)
				c:activate { context = "tasklist", action = "toggle_minimization" }
				menu:hide()
			end),
			awful.button({}, 3, function(c)
				menu:toggle_client_menu(c)
			end)
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
		},
		widget_template = {
			id = "c-background",
			widget = wibox.container.background,
			shape = shape.rrect(dpi(8)),
			{
				layout = wibox.layout.stack,
				{
					widget = wibox.container.margin,
					margins = { left = dpi(8), right = dpi(8) },
					{
						widget = wibox.container.constraint,
						strategy = "max",
						width = dpi(150),
						{
							id = "c-label",
							widget = wibox.widget.textbox,
							align = "center"
						}
					}
				},
				{
					layout = wibox.layout.align.vertical,
					nil,
					nil,
					{
						widget = wibox.container.margin,
						margins = { left = dpi(12), right = dpi(12) },
						{
							id = "c-pointer",
							widget = wibox.container.background,
							shape = shape.prrect(true, true, false, false, dpi(2)),
							bg = beautiful.ac
						}
					}
				}
			}
		}
	}

	ret.widget_template.create_callback = function(cw, c)
		local wp = cw._private
		local c_background = cw:get_children_by_id("c-background")[1]
		local c_pointer = cw:get_children_by_id("c-pointer")[1]
		local c_label = cw:get_children_by_id("c-label")[1]

		wp.on_mouse_enter = function(w)
			w:set_bg(beautiful.bg_urg)
		end

		wp.on_mouse_leave = function(w)
			w:set_bg(beautiful.bg_alt)
		end

		cw:connect_signal("mouse::enter", wp.on_mouse_enter)
		cw:connect_signal("mouse::leave", wp.on_mouse_leave)

		c_label:set_markup((c.class ~= nil and c.class ~= "") and c.class or "untitled")
		c_background:set_bg(beautiful.bg_alt)

		if c.minimized then
			c_background:set_fg(beautiful.fg_alt)
		else
			c_background:set_fg(beautiful.fg)
		end

		if c.active then
			c_pointer:set_forced_height(dpi(3))
		else
			c_pointer:set_forced_height(0)
		end
	end

	ret.widget_template.update_callback = function(cw, c)
		local c_background = cw:get_children_by_id("c-background")[1]
		local c_pointer = cw:get_children_by_id("c-pointer")[1]
		local c_label = cw:get_children_by_id("c-label")[1]

		c_label:set_markup((c.class ~= nil and c.class ~= "") and c.class or "untitled")
		c_background:set_bg(beautiful.bg_alt)

		if c.minimized then
			c_background:set_fg(beautiful.fg_alt)
		else
			c_background:set_fg(beautiful.fg)
		end

		if c.active then
			c_pointer:set_forced_height(dpi(3))
		else
			c_pointer:set_forced_height(0)
		end
	end

	return ret
end
