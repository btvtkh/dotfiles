local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local common = require("common")
local beautiful = require("beautiful")
local ncr = naughty.notification_closed_reason
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib").create_markup
local remove_nonindex = require("lib").remove_nonindex

local notifications = {}

local function update_positions(screen)
	if #screen.notifications > 0 then
		for i = 1, #screen.notifications do
			screen.notifications[i]:geometry({
				x = screen.workarea.x + screen.workarea.width
					- beautiful.notification_margins - screen.notifications[i].width,
				y = i > 1 and screen.notifications[i - 1].y
					+ screen.notifications[i - 1].height + beautiful.notification_spacing
					or screen.workarea.y + beautiful.notification_margins
			})
		end
	end
end

local function add_popup(popup, screen)
	if not popup then return end
	table.insert(screen.notifications, 1, popup)
	popup.visible = true
	update_positions(screen)
end

local function remove_popup(popup, screen)
	if not popup then return end
	remove_nonindex(screen.notifications, popup)
	popup.visible = false
	popup = nil
	update_positions(screen)
end

local function create_actions_widget(n)
	if #n.actions == 0 then return nil end

	local actions_widget = wibox.widget {
		widget = wibox.container.margin,
		margins = { top = dpi(5) },
		{
			id = "main-layout",
			layout = wibox.layout.flex.horizontal,
			spacing = dpi(5)
		}
	}

	local main_layout = actions_widget:get_children_by_id("main-layout")[1]
	for _, action in ipairs(n.actions) do
		main_layout:add(wibox.widget {
			widget = wibox.container.constraint,
			strategy = "max",
			height = dpi(40),
			{
				widget = common.hover_button {
					label = action.name,
					margins = {
						left = dpi(10), right = dpi(10),
						top = dpi(5), bottom = dpi(5)
					},
					shape = beautiful.rrect(dpi(8)),
					buttons = {
						awful.button({}, 1, function()
							action:invoke()
						end)
					}
				}
			}
		})
	end

	return actions_widget
end

local function create_notification_popup(n)
	local popup_widget = awful.popup {
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
			shape = beautiful.rrect(dpi(20)),
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
								clip_shape = beautiful.rrect(dpi(5)),
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

	local close = popup_widget.widget:get_children_by_id("close")[1]
	close:buttons {
		awful.button({}, 1, function()
			n:destroy(ncr.silent)
		end)
	}

	return popup_widget
end

function notifications.display(n)
	if not n then return end
	local notification_popup = create_notification_popup(n)
	local display_timer = gtimer {
		timeout = beautiful.notification_timeout or 5,
		callback = function()
			remove_popup(notification_popup, n.screen)
		end
	}

	n:connect_signal("destroyed", function()
		display_timer:stop()
		display_timer = nil
		remove_popup(notification_popup, n.screen)
	end)

	add_popup(notification_popup, n.screen)

	if display_timer then
		display_timer:start()
	end
end

local function new()
	local ret = {}
	gtable.crush(ret, notifications, true)

	awful.screen.connect_for_each_screen(function(s)
		s.notifications = {}
	end)

	require("ui.notification.screenshots")
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
