local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local dpi = beautiful.xresources.apply_dpi
local capi = { screen = screen }
local notification_list = require("ui.control_panel.notification_list")
local audio_sliders = require("ui.control_panel.audio_sliders")
local wifi_button = require("ui.control_panel.wifi_applet.button")
local wifi_page = require("ui.control_panel.wifi_applet.page")
local bluetooth_button = require("ui.control_panel.bluetooth_applet.button")
local bluetooth_page = require("ui.control_panel.bluetooth_applet.page")
local audio = require("service.audio").get_default()

local control_panel = {}

function control_panel:setup_wifi_page()
	local wp = self._private
	local main_layout = self.widget:get_children_by_id("main-layout")[1]
	main_layout:reset()
	main_layout:add(wp.wifi_page)
end

function control_panel:setup_bluetooth_page()
	local wp = self._private
	local main_layout = self.widget:get_children_by_id("main-layout")[1]
	main_layout:reset()
	main_layout:add(wp.bluetooth_page)
end

function control_panel:setup_main_page()
	local wp = self._private
	local main_layout = self.widget:get_children_by_id("main-layout")[1]
	main_layout:reset()
	main_layout:add(
		wp.notification_list,
		wibox.widget {
			widget = wibox.container.background,
			forced_width = 1,
			forced_height = beautiful.separator_thickness,
			{
				widget = wibox.widget.separator,
				orientation = "horizontal"
			}
		},
		wp.audio_sliders,
		wibox.widget {
			layout = wibox.layout.flex.horizontal,
			spacing = dpi(6),
			wp.wifi_button,
			wp.bluetooth_button
		}
	)
end

function control_panel:show()
	local wp = self._private
	if wp.shown then return end
	wp.shown = true
	audio:get_default_sink_data()
	audio:get_default_source_data()
	self:setup_main_page()
	self.visible = true
	self:emit_signal("property::shown", wp.shown)
end

function control_panel:hide()
	local wp = self._private
	if not wp.shown then return end
	wp.shown = false
	wp.wifi_page:close_ap_menu()
	self.visible = false
	self:emit_signal("property::shown", wp.shown)
end

function control_panel:toggle()
	if not self.visible then
		self:show()
	else
		self:hide()
	end
end

local function new()
	local ret = awful.popup {
		visible = false,
		ontop = true,
		type = "dock",
		screen = capi.screen.primary,
		bg = "#00000000",
		placement = function(d)
			awful.placement.bottom_right(d, {
				honor_workarea = true,
				margins = beautiful.useless_gap
			})
		end,
		widget = {
			widget = wibox.container.background,
			bg = beautiful.bg,
			border_width = beautiful.border_width,
			border_color = beautiful.border_color_normal,
			shape = beautiful.rrect(dpi(22)),
			{
				widget = wibox.container.margin,
				margins = dpi(12),
				{
					id = "main-layout",
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(6)
				}
			}
		}
	}

	gtable.crush(ret, control_panel, true)
	local wp = ret._private

	wp.notification_list = notification_list()
	wp.audio_sliders = audio_sliders()
	wp.wifi_button = wifi_button()
	wp.wifi_page = wifi_page()
	wp.bluetooth_button = bluetooth_button()
	wp.bluetooth_page = bluetooth_page()

	wp.wifi_button:get_children_by_id("reveal-button")[1]:buttons {
		awful.button({}, 1, function()
			ret:setup_wifi_page()
		end)
	}

	wp.wifi_page:get_children_by_id("bottombar-close-button")[1]:buttons {
		awful.button({}, 1, function()
			ret:setup_main_page()
		end)
	}

	wp.bluetooth_button:get_children_by_id("reveal-button")[1]:buttons {
		awful.button({}, 1, function()
			ret:setup_bluetooth_page()
		end)
	}

	wp.bluetooth_page:get_children_by_id("bottombar-close-button")[1]:buttons {
		awful.button({}, 1, function()
			ret:setup_main_page()
		end)
	}

	return ret
end

local instance = nil
local function get_default()
	if not instance then
		instance = new()
	end
	return instance
end

return { get_default = get_default }
