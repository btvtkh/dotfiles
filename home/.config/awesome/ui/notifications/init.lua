local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local common = require("common")
local beautiful = require("beautiful")
local shape = require("lib.shape")
local ncr = naughty.notification_closed_reason
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib.string").create_markup

local function update_positions(self)
	if #self.popups > 0 then
		for i = 1, #self.popups do
			local screen = self._private.screen
			self.popups[i]:geometry({
				x = screen.workarea.x + screen.workarea.width
					- beautiful.notification_margins - self.popups[i].width,
				y = i > 1 and self.popups[i - 1].y
					+ self.popups[i - 1].height + beautiful.notification_spacing
					or screen.workarea.y + beautiful.notification_margins
			})
		end
	end
end

local function create_actions_widget(n)
	if #n.actions == 0 then return end

	local actions_widget = wibox.widget {
		widget = wibox.container.margin,
		margins = { top = dpi(5) },
		{
			id = "buttons-layout",
			layout = wibox.layout.flex.horizontal,
			spacing = dpi(5)
		}
	}

	local main_layout = actions_widget:get_children_by_id("buttons-layout")[1]
	for _, action in ipairs(n.actions) do
		main_layout:add(wibox.widget {
			widget = wibox.container.constraint,
			strategy = "max",
			height = dpi(40),
			common.button {
				label = action.name,
				margins = {
					left = dpi(10), right = dpi(10),
					top = dpi(5), bottom = dpi(5)
				},
				shape = shape.rrect(dpi(8)),
				buttons = {
					awful.button({}, 1, function()
						action:invoke()
					end)
				}
			}
		})
	end

	return actions_widget
end

local function create_notification_popup(self, n)
	local ret = awful.popup {
		type = "notification",
		screen = n.screen,
		visible = false,
		ontop = true,
		minimum_width = dpi(380),
		maximum_width = dpi(450),
		minimum_height = dpi(100),
		maximum_height = dpi(280),
		bg = "#00000000",
		placement = function() return { 0, 0 } end,
		widget = {
			widget = wibox.container.background,
			bg = beautiful.bg,
			fg = beautiful.fg,
			border_color = beautiful.border_color_normal,
			border_width = beautiful.border_width,
			shape = shape.rrect(dpi(20)),
			{
				widget = wibox.container.margin,
				margins = dpi(15),
				{
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(5),
					{
						layout = wibox.layout.align.horizontal,
						{
							widget = wibox.container.constraint,
							strategy = "max",
							width = dpi(150),
							height = dpi(25),
							{
								widget = wibox.widget.textbox,
								markup = create_markup(n.app_name, {
									fg = n.urgency == "critical" and beautiful.red or beautiful.fg
								})
							}
						},
						nil,
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = dpi(10),
							{
								widget = wibox.widget.textbox,
								markup = create_markup(os.date("%H:%M"), { fg = beautiful.fg_alt })
							},
							{
								id = "close",
								widget = wibox.widget.textbox,
								markup = create_markup(text_icons.cross, { fg = beautiful.red })
							}
						}
					},
					{
						widget = wibox.container.background,
						forced_width = 1,
						forced_height = beautiful.separator_thickness,
						{
							widget = wibox.widget.separator,
							orientation = "horizontal"
						}
					},
					{
						layout = wibox.layout.fixed.horizontal,
						buttons = {
							awful.button({}, 1, function()
								n:destroy(ncr.dismissed_by_user)
							end)
						},
						fill_space = true,
						spacing = dpi(10),
						{
							widget = wibox.container.constraint,
							strategy = "max",
							width = dpi(70),
							height = dpi(70),
							{
								widget = wibox.widget.imagebox,
								resize = true,
								halign = "center",
								valign = "top",
								clip_shape = shape.rrect(dpi(5)),
								image = n.icon
							}
						},
						{
							layout = wibox.layout.fixed.vertical,
							spacing = dpi(5),
							{
								widget = wibox.container.constraint,
								strategy = "max",
								height = dpi(25),
								{
									widget = wibox.widget.textbox,
									markup = n.title
								}
							},
							{
								widget = wibox.container.constraint,
								strategy = "max",
								height = dpi(70),
								{
									widget = wibox.widget.textbox,
									font = beautiful.font_h0,
									markup = n.text or n.massage
								}
							}
						}
					},
					create_actions_widget(n)
				}
			}
		}
	}

	local wp = ret._private
	local close = ret.widget:get_children_by_id("close")[1]

	wp.notification = n

	wp.display_timer = gtimer {
		timeout = beautiful.notification_timeout or 5,
		autostart = false,
		single_shot = true,
		call_now = false,
		callback = function()
			ret.visible = false
			for i, p in ipairs(self.popups) do
				if p == ret then
					table.remove(self.popups, i)
				end
			end
			wp.display_timer = nil
			ret = nil
		end
	}

	close:buttons {
		awful.button({}, 1, function()
			n:destroy(ncr.silent)
		end)
	}

	return ret
end

local function new(s)
	if not s then return end
	local ret = {}
	ret._private = {}
	local wp = ret._private

	ret.popups = {}
	wp.screen = s

	wp.on_added = function(n)
		if n.screen == wp.screen then
			local popup = create_notification_popup(ret, n)
			table.insert(ret.popups, 1, popup)
			popup.visible = true
			update_positions(ret)
			popup._private.display_timer:start()
		end
	end

	wp.on_destroyed = function(n)
		for i, popup in ipairs(ret.popups) do
			if popup.screen == n.screen and popup._private.notification == n then
				if popup._private.display_timer then
					popup._private.display_timer:stop()
					popup._private.display_timer = nil
				end
				popup.visible = false
				table.remove(ret.popups, i)
				popup = nil
				update_positions(ret)
			end
		end
	end

	naughty.connect_signal("destroyed", wp.on_destroyed)
	naughty.connect_signal("request::display", wp.on_added)

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
