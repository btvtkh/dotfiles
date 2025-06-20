local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local gshape = require("gears.shape")
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
	mist = ""
}

theme.red = "#F9AAB6"
theme.green = "#AAF9B0"
theme.yellow = "#F9F7AA"
theme.blue = "#A8C7FA"
theme.magenta = "#DCADF9"
theme.cyan = "#AAF3F9"
theme.orange = "#F9C5AA"
theme.bg = "#171719"
theme.bg_alt = "#252628"
theme.bg_urg = "#3A3A3D"
theme.fg_alt = "#6E6E72"
theme.fg = "#E5E7ED"
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

function theme.rrect(rad)
	return theme.rounded and function(cr, w, h)
		gshape.rounded_rect(cr, w, h, rad)
	end
end

function theme.rbar()
	return theme.rounded and function(cr, w, h)
		gshape.rounded_bar(cr, w, h)
	end
end

function theme.prrect(tl, tr, br, bl, rad)
	return theme.rounded and function(cr, w, h)
		gshape.partially_rounded_rect(cr, w, h, tl, tr, br, bl, rad)
	end
end

function theme.crcl(rad)
	return theme.rounded and function(cr, w, h)
		gshape.circle(cr, w, h, rad)
	end
end

return theme
