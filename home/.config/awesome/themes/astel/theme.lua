local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local gcolor = require("gears.color")
local dpi = beautiful.xresources.apply_dpi

local theme_name = "astel"
local theme_path = gfs.get_configuration_dir() .. "/themes/" .. theme_name .. "/"
local icons_path = theme_path .. "icons/"

local theme = {}

theme.font_name = "JetBrains Mono NL Slashed"
theme.font_h0 = theme.font_name .. " " .. tostring(dpi(9))
theme.font_h1 = theme.font_name .. " " .. tostring(dpi(13))
theme.font_h2 = theme.font_name .. " " .. tostring(dpi(19))
theme.font_h3 = theme.font_name .. " " .. tostring(dpi(26))
theme.font = theme.font_h1

theme.text_icons = {
	eye_on = "",
	eye_off = "",
	check_on = "",
	check_off = "",
	switch_on = "",
	switch_off = "",
	vol_on = "",
	vol_off = "",
	mic_on = "",
	mic_off = "",
	bell_on = "",
	bell_off = "",
	lock_on = "",
	lock_off = "",
	arrow_left = "",
	arrow_right = "",
	arrow_up = "",
	arrow_down = "",
	dash = "",
	cross = "",
	check = "",
	stretch = "",
	shrink = "",
	gear = "",
	sliders = "",
	wait = "",
	poweroff = "",
	reboot = "",
	exit = "",
	menu = "",
	trash = "",
	calendar = "",
	wifi = "",
	bluetooth = "",
	search = "",
	home = "",
	image = "",
	sun = "",
	moon = "",
	wind = "",
	thermometer = "",
	droplet = "",
	no_cloud = "",
	cloud = "",
	rain = "",
	shower_rain = "",
	thunder = "",
	snow = "",
	mist = "",
	play = "",
	pause = "",
	go_next = "",
	go_previous = ""
}

theme.red = "#F9AEAE"
theme.green = "#B3F9B3"
theme.yellow = "#F9F7B1"
theme.blue = "#A8C7FA"
theme.magenta = "#DFB6F9"
theme.cyan = "#B6F4F9"
theme.orange = "#F9C9B1"
theme.bg = "#121212"
theme.bg_alt = "#212121"
theme.bg_urg = "#414141"
theme.fg_alt = "#767676"
theme.fg = "#E6E6E6"
theme.ac = theme.blue

theme.rounded = true

theme.border_width = dpi(1)
theme.separator_thickness = dpi(1)
theme.useless_gap = dpi(5)

theme.separator_color = theme.bg_urg
theme.bg_normal = theme.bg
theme.fg_normal = theme.fg
theme.border_color_normal = theme.bg_urg
theme.border_color_active = theme.ac

theme.titlebar_bg_normal = theme.bg
theme.titlebar_bg_focus = theme.bg
theme.titlebar_bg_urgent = theme.bg
theme.titlebar_fg_normal = theme.fg_alt
theme.titlebar_fg_focus = theme.fg
theme.titlebar_fg_urgent = theme.red

theme.notification_margins = dpi(30)
theme.notification_spacing = dpi(10)
theme.notification_timeout = 5

theme.menu_submenu = theme.text_icons.arrow_right .. " "
theme.menu_bg_normal = theme.bg
theme.menu_fg_normal = theme.fg
theme.menu_bg_focus = theme.ac
theme.menu_fg_focus = theme.bg
theme.menu_border_width = theme.border_width
theme.menu_border_color = theme.border_color

theme.layout_floating = gcolor.recolor_image(icons_path .. "layout_floating.png", theme.fg)
theme.layout_tile = gcolor.recolor_image(icons_path .. "layout_tile.png", theme.fg)

theme.systray_icon_spacing = dpi(6)
theme.bg_systray = theme.bg_alt

return theme
