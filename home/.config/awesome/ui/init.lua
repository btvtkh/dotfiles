local awful = require("awful")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local user = require("user")
local capi = { screen = screen, client = client }
local titlebar = require("ui.titlebar")
local wallpaper = require("ui.wallpaper")
local bar = require("ui.bar")
local notifications = require("ui.notifications")
local menu = require("ui.menu").get_default()
local launcher = require("ui.launcher").get_default()
local powermenu = require("ui.powermenu").get_default()
local control_panel = require("ui.control_panel").get_default()
local day_info_panel = require("ui.day_info_panel").get_default()

local function on_primary_bar_visible()
	if control_panel.visible == true then
		gtimer.delayed_call(function()
			awful.placement.bottom_right(control_panel, {
				honor_workarea = true,
				margins = beautiful.useless_gap
			})
		end)
	end

	if day_info_panel.visible == true then
		gtimer.delayed_call(function()
			awful.placement.bottom_right(day_info_panel, {
				honor_workarea = true,
				margins = beautiful.useless_gap
			})
		end)
	end

	if launcher.visible == true then
		gtimer.delayed_call(function()
			awful.placement.bottom_left(launcher, {
				honor_workarea = true,
				margins = beautiful.useless_gap
			})
		end)
	end
end

awful.screen.connect_for_each_screen(function(s)
	if s == capi.screen.primary then
		s.bar = bar.create_primary(s)
		s.bar:connect_signal("property::visible", on_primary_bar_visible)
	else
		s.bar = bar.create_secondary(s)
	end

	s.notifications = notifications(s)

	s.wallpaper = wallpaper(s)

	if user.wallpaper then
		s.wallpaper:set_image(user.wallpaper)
	end
end)

capi.client.connect_signal("request::titlebars", function(c)
	titlebar(c)
end)

powermenu:connect_signal("property::shown", function(_, shown)
	if shown == true then
		launcher:hide()
		control_panel:hide()
		day_info_panel:hide()
		menu:hide()
	end
end)

launcher:connect_signal("property::shown", function(_, shown)
	if shown == true then
		powermenu:hide()
		menu:hide()
	end
end)

control_panel:connect_signal("property::shown", function(_, shown)
	if shown == true then
		powermenu:hide()
		day_info_panel:hide()
		menu:hide()
	end
end)

day_info_panel:connect_signal("property::shown", function(_, shown)
	if shown == true then
		powermenu:hide()
		control_panel:hide()
		menu:hide()
	end
end)

local function click_hideaway()
	menu:hide()
	launcher:hide()
	powermenu:hide()
	control_panel:hide()
	day_info_panel:hide()
end

capi.client.connect_signal("request::manage", function(c)
	c:connect_signal("button::press", click_hideaway)
end)

capi.client.connect_signal("request::unmanage", function(c)
	c:disconnect_signal("button::press", click_hideaway)
end)

awful.mouse.append_global_mousebinding(
	awful.button({}, 1, click_hideaway)
)

require("ui.notifications.screenshots")
