local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local common = require("common")
local shape = require("lib.shape")
local text_icons = beautiful.text_icons
local has_common = require("lib.table").has_common
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client }
local Client_list = require("ui.bar.client_list")
local Tag_list = require("ui.bar.tag_list")
local Tray = require("ui.bar.tray")
local Time = require("ui.bar.time")
local Kb_layout = require("ui.bar.kb_layout")
local launcher = require("ui.launcher").get_default()
local control_panel = require("ui.control_panel").get_default()

local bar = {}

local function Launcher_button()
	return common.button {
		buttons = {
			awful.button({}, 1, function()
				launcher:toggle()
			end)
		},
		forced_width = dpi(31),
		bg_normal = beautiful.bg_alt,
		bg_hover = beautiful.bg_urg,
		fg_normal = beautiful.fg,
		fg_hover = beautiful.fg,
		shape = shape.rrect(dpi(8)),
		label = text_icons.menu,
	}
end

local function Control_panel_button()
	return common.button {
		buttons = {
			awful.button({}, 1, function()
				control_panel:toggle()
			end)
		},
		forced_width = dpi(31),
		bg_normal = beautiful.bg_alt,
		bg_hover = beautiful.bg_urg,
		fg_normal = beautiful.fg,
		fg_hover = beautiful.fg,
		shape = shape.rrect(dpi(8)),
		label = text_icons.sliders,
	}
end

function bar.create_secondary(s)
	local ret = awful.wibar {
		position = "bottom",
		ontop = true,
		screen = s,
		height = dpi(45),
		bg = "#00000000",
		widget = {
			widget = wibox.container.background,
			bg = beautiful.border_color_normal,
			{
				widget = wibox.container.margin,
				margins = { top = beautiful.border_width },
				{
					widget = wibox.container.background,
					bg = beautiful.bg,
					fg = beautiful.fg,
					{
						layout = wibox.layout.fixed.horizontal,
						{
							widget = wibox.container.margin,
							margins = dpi(7),
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = dpi(5),
								Tag_list(s),
								Client_list(s)
							}
						}
					}
				}
			}
		}
	}

	local wp = ret._private

	wp.on_client_manage = function(c)
		local focused_screen = awful.screen.focused({ client = true })

		if ret.screen == focused_screen
		and has_common(c:tags(), focused_screen.selected_tags) then
			if c.fullscreen then
				ret.visible = false
			else
				ret.visible = true
			end
		end
	end

	wp.on_client_unmanage = function(c)
		local focused_screen = awful.screen.focused({ client = true })

		if ret.screen == focused_screen then
			if c.fullscreen then
				ret.visible = true
			end
		end
	end

	capi.client.connect_signal("request::manage", wp.on_client_manage)
	capi.client.connect_signal("focus", wp.on_client_manage)
	capi.client.connect_signal("property::fullscreen", wp.on_client_manage)

	capi.client.connect_signal("request::unmanage", wp.on_client_unmanage)
	capi.client.connect_signal("unfocus", wp.on_client_unmanage)
	capi.client.connect_signal("property::minimized", wp.on_client_unmanage)

	return ret
end

function bar.create_primary(s)
	local ret = awful.wibar {
		position = "bottom",
		ontop = true,
		screen = s,
		height = dpi(45),
		bg = "#00000000",
		widget = {
			widget = wibox.container.background,
			bg = beautiful.border_color_normal,
			{
				widget = wibox.container.margin,
				margins = { top = beautiful.border_width },
				{
					widget = wibox.container.background,
					bg = beautiful.bg,
					fg = beautiful.fg,
					{
						layout = wibox.layout.align.horizontal,
						nil,
						{
							widget = wibox.container.margin,
							margins = dpi(7),
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = dpi(5),
								Launcher_button(),
								Tag_list(s),
								Client_list(s)
							}
						},
						{
							widget = wibox.container.margin,
							margins = {
								top = dpi(7), bottom = dpi(7),
								left = 0, right = dpi(7)
							},
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = dpi(5),
								Tray(),
								Kb_layout(),
								Time(),
								Control_panel_button()
							}
						}
					}
				}
			}
		}
	}

	local wp = ret._private

	wp.on_client_manage = function(c)
		local focused_screen = awful.screen.focused({ client = true })

		if ret.screen == focused_screen
		and has_common(c:tags(), focused_screen.selected_tags) then
			if c.fullscreen then
				ret.visible = false
			else
				ret.visible = true
			end
		end
	end

	wp.on_client_unmanage = function(c)
		local focused_screen = awful.screen.focused({ client = true })

		if ret.screen == focused_screen then
			if c.fullscreen then
				ret.visible = true
			end
		end
	end

	capi.client.connect_signal("request::manage", wp.on_client_manage)
	capi.client.connect_signal("focus", wp.on_client_manage)
	capi.client.connect_signal("property::fullscreen", wp.on_client_manage)

	capi.client.connect_signal("request::unmanage", wp.on_client_unmanage)
	capi.client.connect_signal("unfocus", wp.on_client_unmanage)
	capi.client.connect_signal("property::minimized", wp.on_client_unmanage)

	return ret
end

return bar
