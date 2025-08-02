local astal = require("astal")
local Variable = astal.Variable
local bind = astal.bind
local App = require("astal.gtk3").App
local Widget = require("astal.gtk3").Widget
local Astal = require("astal.gtk3").Astal
local Anchor = Astal.WindowAnchor
local Gdk = require("astal.gtk3").Gdk
local Gtk = require("astal.gtk3").Gtk
local astalify = require("astal.gtk3").astalify

local Separator = astalify(Gtk.Separator)
local NotificationList = require("ui.control_panel.notification_list")
local AudioSliders = require("ui.control_panel.audio_sliders")
local WifiButton = require("ui.control_panel.wifi_applet.button")
local WifiPage = require("ui.control_panel.wifi_applet.page")
local BluetoothButton = require("ui.control_panel.bluetooth_applet.button")
local BluetoothPage = require("ui.control_panel.bluetooth_applet.page")


local function hide()
	local panel = App:get_window("Control-panel")
	if panel then panel:hide() end
end

return function()
	local current_page = Variable("Main-page")

	local main_page = Widget.Box {
		name = "Main-page",
		width_request = 450,
		height_request = 750,
		vertical = true,
		spacing = 8,
		NotificationList(),
		Separator(),
		AudioSliders(),
		Widget.Box {
			spacing = 8,
			hexpand = true,
			WifiButton {
				on_arrow_button_clicked = function()
					current_page:set("Wifi-page")
				end
			},
			BluetoothButton {
				on_arrow_button_clicked = function()
					current_page:set("Bluetooth-page")
				end
			}
		}
	}

	local mainbox = Widget.Box {
		class_name = "mainbox",
		vexpand = false,
		Widget.Stack {
			transition_type = "SLIDE_LEFT_RIGHT",
			homogeneous = false,
			shown = bind(current_page),
			main_page,
			WifiPage {
				on_close_button_clicked = function()
					current_page:set("Main-page")
				end
			},
			BluetoothPage {
				on_close_button_clicked = function()
					current_page:set("Main-page")
				end
			}
		}
	}

	local revealer = Widget.Revealer {
		transition_type = "SLIDE_UP",
		mainbox
	}

	return Widget.Window {
		application = App,
		name = "Control-panel",
		class_name = "control-panel",
		anchor = Anchor.BOTTOM + Anchor.RIGHT + Anchor.TOP + Anchor.LEFT,
		exclusivity = "NORMAL",
		keymode = "ON_DEMAND",
		visible = false,
		on_key_press_event = function(self, event)
			if event.keyval == Gdk.KEY_Escape then
				self:hide()
			end
		end,
		on_show = function()
			current_page:set("Main-page")
			revealer:set_reveal_child(true)
		end,
		on_hide = function ()
			revealer:set_reveal_child(false)
		end,
		setup = function(self)
			self:hook(App, "window-toggled", function(_, w)
				if w:get_visible() and w:get_name() == "Powermenu" then
					hide()
				end
			end)
		end,
		Widget.Box {
			Widget.EventBox {
				expand = true,
				on_click = hide
			},
			Widget.Box {
				hexpand = false,
				vertical = true,
				Widget.EventBox {
					vexpand = true,
					on_click = hide,
				},
				revealer
			}
		}
	}
end
