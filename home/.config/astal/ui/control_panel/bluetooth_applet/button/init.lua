local Widget = require("astal.gtk3").Widget
local Gtk = require("astal.gtk3").Gtk

return function(args)
	args = args or {}

	return Widget.Box {
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
			on_clicked = args.on_arrow_button_clicked,
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
end
