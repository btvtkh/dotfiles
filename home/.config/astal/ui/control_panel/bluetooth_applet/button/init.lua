local Widget = require("astal.gtk3").Widget
local Gtk = require("astal.gtk3").Gtk
local astalify = require("astal.gtk3").astalify

local Separator = astalify(Gtk.Separator)

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
				Separator(),
				Widget.Icon {
					icon = "pan-end-symbolic"
				}
			}
		}
	}
end
