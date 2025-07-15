local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client }
local mod = "Mod4"

local function new(s)
	local ret = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		{
			widget = wibox.container.margin,
			margins = dpi(4),
			{
				id = "taglist",
				widget = awful.widget.taglist {
					screen = s,
					filter = awful.widget.taglist.filter.all,
					buttons = {
						awful.button({}, 1, function(t)
							t:view_only()
						end),
						awful.button({}, 3, function(t)
							awful.tag.viewtoggle(t)
						end),
						awful.button({}, 4, function(t)
							awful.tag.viewprev(t.screen)
						end),
						awful.button({}, 5, function(t)
							awful.tag.viewnext(t.screen)
						end),
						awful.button({ mod }, 1, function(t)
							if capi.client.focus then
								capi.client.focus:move_to_tag(t)
							end
						end),
						awful.button({ mod }, 3, function(t)
							if capi.client.focus then
								capi.client.focus:toggle_tag(t)
							end
						end),
					},
					layout = {
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(2)
					},
					widget_template = {
						id = "t-background",
						widget = wibox.container.background,
						shape = beautiful.rrect(dpi(5)),
						{
							widget = wibox.container.margin,
							margins = { left = dpi(7), right = dpi(7) },
							{
								id = "t-label",
								widget = wibox.widget.textbox,
								align = "center"
							}
						}
					}
				}
			}
		}
	}

	local taglist = ret:get_children_by_id("taglist")[1]

	taglist.widget_template.create_callback = function(tw, t)
		local wp = tw._private
		local t_background = tw:get_children_by_id("t-background")[1]
		local t_label = tw:get_children_by_id("t-label")[1]

		wp.on_mouse_enter = function()
			if not t.selected then
				t_background:set_bg(beautiful.bg_urg)
			end
		end

		wp.on_mouse_leave = function()
			if not t.selected then
				t_background:set_bg(nil)
			end
		end

		tw:connect_signal("mouse::enter", wp.on_mouse_enter)
		tw:connect_signal("mouse::leave", wp.on_mouse_leave)

		t_label:set_markup(t.index)

		if t.selected then
			t_background:set_bg(beautiful.ac)
			t_background:set_fg(beautiful.bg)
		elseif #t:clients() > 0 then
			t_background:set_bg(nil)
			t_background:set_fg(beautiful.fg)
		else
			t_background:set_bg(nil)
			t_background:set_fg(beautiful.fg_alt)
		end

		for _, c in ipairs(t:clients()) do
			if c.urgent then
				t_background:set_fg(beautiful.red)
				break
			end
		end
	end

	taglist.widget_template.update_callback = function(tw, t)
		local t_background = tw:get_children_by_id("t-background")[1]
		local t_label = tw:get_children_by_id("t-label")[1]

		t_label:set_markup(t.index)

		if t.selected then
			t_background:set_bg(beautiful.ac)
			t_background:set_fg(beautiful.bg)
		elseif #t:clients() > 0 then
			t_background:set_bg(nil)
			t_background:set_fg(beautiful.fg)
		else
			t_background:set_bg(nil)
			t_background:set_fg(beautiful.fg_alt)
		end

		for _, c in ipairs(t:clients()) do
			if c.urgent then
				t_background:set_fg(beautiful.red)
				break
			end
		end
	end

	return ret
end

return setmetatable(
	{ new = new },
	{
		__call = function(_, ...)
			return new(...)
		end
	}
)
