local astal = require("astal")
local Variable = astal.Variable
local bind = astal.bind
local App = require("astal.gtk3").App
local Widget = require("astal.gtk3").Widget
local Astal = require("astal.gtk3").Astal
local Anchor = Astal.WindowAnchor
local Gdk = require("astal.gtk3").Gdk
local Gtk = require("astal.gtk3").Gtk
local NotificationList = require("lua.widgets.control_panel.notification_list")
local AudioSliders = require("lua.widgets.control_panel.audio_sliders")

local function hide()
	local panel = App:get_window("Control-panel")
	if panel then panel:hide() end
end

return function()
	local current_page = Variable("main")

	local wifi_button = Widget.Box {
		class_name = "wifi-button",
		hexpand = true,
		Widget.Button {
			class_name = "toggle-button",
			Widget.Box {
				hexpand = true,
				Widget.Icon {
					icon = "network-wireless-symbolic"
				},
				Widget.Label {
					width_chars = 15,
					xalign = 0,
					justify = "FILL",
					halign = "START",
					label = "Wifi"
				}
			}
		},
		Widget.Button {
			class_name = "arrow-button",
			on_clicked = function()
				current_page:set("wifi")
			end,
			Widget.Box {
				Gtk.Separator {
					visible = true
				},
				Widget.Icon {
					icon = "arrow-right"
				}
			}
		}
	}

	local wifi_page = Widget.Box {
		name = "wifi",
		width_request = 400,
		height_request = 450,
		vertical = true,
		Widget.Box {
			expand = true,
			halign = "CENTER",
			valign = "CENTER",
			Widget.Label {
				label = "Wifi (WIP)"
			}
		},
		Widget.Box {
			class_name = "bottombar",
			Widget.Button {
				on_clicked = function()
					current_page:set("main")
				end,
				Widget.Icon {
					icon = "arrow-left",
				}
			}
		}
	}

	local bluetooth_button = Widget.Box {
		class_name = "wifi-button",
		hexpand = true,
		Widget.Button {
			class_name = "toggle-button",
			Widget.Box {
				hexpand = true,
				Widget.Icon {
					icon = "bluetooth-symbolic"
				},
				Widget.Label {
					width_chars = 15,
					xalign = 0,
					justify = "FILL",
					halign = "START",
					label = "Bluetooth"
				}
			}
		},
		Widget.Button {
			class_name = "arrow-button",
			on_clicked = function()
				current_page:set("bluetooth")
			end,
			Widget.Box {
				Gtk.Separator {
					visible = true
				},
				Widget.Icon {
					icon = "arrow-right"
				}
			}
		}
	}

	local bluetooth_page = Widget.Box {
		name = "bluetooth",
		width_request = 400,
		height_request = 450,
		vertical = true,
		Widget.Box {
			expand = true,
			halign = "CENTER",
			valign = "CENTER",
			Widget.Label {
				label = "Bluetooth (WIP)"
			}
		},
		Widget.Box {
			class_name = "bottombar",
			Widget.Button {
				on_clicked = function()
					current_page:set("main")
				end,
				Widget.Icon {
					icon = "arrow-left",
				}
			}
		}
	}

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
			wifi_button,
			bluetooth_button
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
				main_page,
				wifi_page,
				bluetooth_page,
				shown = bind(current_page)
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
