local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local common = require("common")
local text_icons = beautiful.text_icons
local ncr = naughty.notification_closed_reason
local dpi = beautiful.xresources.apply_dpi
local create_markup = require("lib").create_markup

local notification_list = {}

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
					bg_normal = beautiful.bg_urg,
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

local function create_notification_widget(n)
	local widget = wibox.widget {
		is_notification = true,
		widget = wibox.container.constraint,
		strategy = "max",
		height = 260,
		{
			widget = wibox.container.background,
			bg = beautiful.bg_alt,
			shape = beautiful.rrect(dpi(10)),
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
								height = dpi(80),
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

	local close = widget:get_children_by_id("close")[1]
	close:buttons {
		awful.button({}, 1, function()
			n:destroy(ncr.silent)
		end)
	}

	return widget
end

local function remove_notification(self, w)
	local notifs_layout = self:get_children_by_id("notifications-layout")[1]
	notifs_layout:remove_widgets(w)
	if #notifs_layout.children == 0 then
		notifs_layout:insert(1, wibox.widget {
			widget = wibox.container.background,
			fg = beautiful.fg_alt,
			forced_height = dpi(560),
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_h2,
				markup = "No notifications"
			}
		})
	end
	self:update_count()
end

local function add_notification(self, n)
	if not n then return end
	local notifs_layout = self:get_children_by_id("notifications-layout")[1]
	local new_notification_widget = create_notification_widget(n)
	if #notifs_layout.children == 1 and not notifs_layout.children[1].is_notification then
		notifs_layout:reset()
	end
	notifs_layout:insert(1, new_notification_widget)
	n:connect_signal("destroyed", function()
		remove_notification(self, new_notification_widget)
	end)
	self:update_count()
end

function notification_list:clear_notifications()
	local notifs_layout = self:get_children_by_id("notifications-layout")[1]
	notifs_layout:reset()
	notifs_layout:insert(1, wibox.widget {
		widget = wibox.container.background,
		fg = beautiful.fg_alt,
		forced_height = dpi(560),
		{
			widget = wibox.widget.textbox,
			align = "center",
			font = beautiful.font_h2,
			markup = "No notifications"
		}
	})
	self:update_count()
	naughty.destroy_all_notifications(nil, ncr.silent)
end

function notification_list:update_count()
	local notifs_layout = self:get_children_by_id("notifications-layout")[1]
	local notifs_title = self:get_children_by_id("notifications-title")[1]
	if #notifs_layout.children > 0 and notifs_layout.children[1].is_notification then
		notifs_title:set_markup(string.format(
			"Notifications (%s)",
			#notifs_layout.children
		))
	else
		notifs_title:set_markup("Notifications")
	end
end

function notification_list:toggle_dnd()
	local wp = self._private
	wp.dnd_mode = not wp.dnd_mode
	if wp.dnd_mode then
		naughty.suspend()
	else
		naughty.resume()
	end
end

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		forced_height = dpi(50) + dpi(560),
		forced_width = dpi(450),
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(6),
			{
				widget = wibox.container.background,
				forced_height = dpi(40),
				{
					layout = wibox.layout.align.horizontal,
					{
						widget = wibox.container.margin,
						margins = { left = dpi(7) },
						{
							id = "notifications-title",
							widget = wibox.widget.textbox,
							align = "center",
							markup = "Notifications"
						}
					},
					nil,
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.separator_thickness + dpi(2),
						spacing_widget = {
							widget = wibox.container.margin,
							margins = { top = dpi(8), bottom = dpi(8) },
							{
								widget = wibox.widget.separator,
								orientation = "vertical"
							}
						},
						{
							id = "dnd-button",
							widget = common.hover_button {
								label = text_icons.bell_on,
								bg_normal = beautiful.bg,
								margins = { right = dpi(11), left = dpi(11) },
								shape = beautiful.rrect(dpi(10))
							}
						},
						{
							id = "clear-button",
							widget = common.hover_button {
								label = text_icons.trash,
								fg_normal = beautiful.red,
								bg_normal = beautiful.bg,
								bg_hover = beautiful.red,
								margins = { right = dpi(11), left = dpi(11) },
								shape = beautiful.rrect(dpi(10))
							}
						}
					}
				}
			},
			{
				id = "notifications-layout",
				layout = wibox.layout.overflow.vertical,
				scrollbar_enabled = false,
				step = 80,
				spacing = dpi(6)
			}
		}
	}

	gtable.crush(ret, notification_list, true)
	local wp = ret._private

	wp.dnd_mode = false

	local dnd_button = ret:get_children_by_id("dnd-button")[1]
	dnd_button:buttons {
		awful.button({}, 1, function()
			ret:toggle_dnd()
			if wp.dnd_mode then
				dnd_button:set_label(text_icons.bell_off)
			else
				dnd_button:set_label(text_icons.bell_on)
			end
		end)
	}

	local clear_button = ret:get_children_by_id("clear-button")[1]
	clear_button:buttons {
		awful.button({}, 1, function()
			ret:clear_notifications()
		end)
	}

	local notifs_layout = ret:get_children_by_id("notifications-layout")[1]
	notifs_layout:insert(1, wibox.widget {
		widget = wibox.container.background,
		fg = beautiful.fg_alt,
		forced_height = dpi(560),
		{
			widget = wibox.widget.textbox,
			align = "center",
			font = beautiful.font_h2,
			markup = "No notifications"
		}
	})

	naughty.connect_signal("request::display", function(n)
		add_notification(ret, n)
	end)

	return ret
end

return setmetatable({
	new = new
}, {
	__call = new
})
