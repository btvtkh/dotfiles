local awful = require("awful")
local naughty = require("naughty")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local user = require("user")
local has_common = require("lib").has_common
local capi = { screen = screen, client = client }
local titlebar = require("ui.titlebar")
local wallpaper = require("ui.wallpaper")
local bar = require("ui.bar")
local menu = require("ui.menu").get_default()
local notification = require("ui.notification").get_default()
local launcher = require("ui.launcher").get_default()
local powermenu = require("ui.powermenu").get_default()
local control_panel = require("ui.control_panel").get_default()
local day_info_panel = require("ui.day_info_panel").get_default()

local function set_wibar_hideaway(wibar)
	if not wibar then return end

	local function on_client_manage(client)
		local focused_screen = awful.screen.focused({ client = true })

		if wibar.screen == focused_screen
		and has_common(client:tags(), focused_screen.selected_tags) then
			if client.fullscreen then
				wibar.visible = false
			else
				wibar.visible = true
			end
		end
	end

	local function on_client_unmanage(client)
		local focused_screen = awful.screen.focused({ client = true })

		if wibar.screen == focused_screen then
			if client.fullscreen then
				wibar.visible = true
			end
		end
	end

	capi.client.connect_signal("request::manage", on_client_manage)
	capi.client.connect_signal("focus", on_client_manage)
	capi.client.connect_signal("property::fullscreen", on_client_manage)

	capi.client.connect_signal("request::unmanage", on_client_unmanage)
	capi.client.connect_signal("unfocus", on_client_unmanage)
	capi.client.connect_signal("property::minimized", on_client_unmanage)
end

capi.screen.connect_signal("request::desktop_decoration", function(s)
	if s == capi.screen.primary then
		s.bar = bar.create_primary(s)
		s.bar:connect_signal("property::visible", function()
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
		end)
	else
		s.bar = bar.create_secondary(s)
	end

	set_wibar_hideaway(s.bar)
end)

capi.screen.connect_signal("request::wallpaper", function(s)
	s.wallpaper = wallpaper(s)

	if user.wallpaper then
		s.wallpaper:set_image(user.wallpaper)
	end
end)

capi.client.connect_signal("request::titlebars", function(c)
	titlebar(c)
end)

naughty.connect_signal("request::display", function(n)
	notification.display(n)
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

awful.mouse.append_global_mousebinding(
	awful.button({}, 1, click_hideaway)
)

capi.client.connect_signal("request::manage", function(c)
	c:connect_signal("button::press", click_hideaway)
end)
