local astal = require("astal")
local Variable = astal.Variable
local bind = astal.bind
local App = require("astal.gtk3").App
local Widget = require("astal.gtk3").Widget
local Astal = require("astal.gtk3").Astal
local Anchor = Astal.WindowAnchor
local Gdk = require("astal.gtk3").Gdk
local Gtk = require("astal.gtk3").Gtk
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
	local current_page = Variable("main")

	local main_page = Widget.Box {
		name = "main",
		width_request = 450,
		height_request = 750,
		vertical = true,
		spacing = 8,
		NotificationList(),
		Gtk.Separator {
			visible = true
		},
		AudioSliders(),
		Widget.Box {
			spacing = 8,
			hexpand = true,
			WifiButton(function()
				current_page:set("wifi")
			end),
			BluetoothButton(function()
				current_page:set("bluetooth")
			end)
		}
	}

	local main_widget = Widget.Revealer {
		transition_type = "SLIDE_UP",
		Widget.Box {
			class_name = "mainbox",
			vexpand = false,
			Widget.Stack {
				transition_type = "SLIDE_LEFT_RIGHT",
				homogeneous = false,
				shown = bind(current_page),
				main_page,
				WifiPage(function()
					current_page:set("main")
				end),
				BluetoothPage(function()
					current_page:set("main")
				end)
			}
		}
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
			current_page:set("main")
			main_widget:set_reveal_child(true)
		end,
		on_hide = function ()
			main_widget:set_reveal_child(false)
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
				main_widget
			}
		}
	}
end
