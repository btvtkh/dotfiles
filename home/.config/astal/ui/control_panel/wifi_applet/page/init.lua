local Widget = require("astal.gtk3").Widget
local Gtk = require("astal.gtk3").Gtk
local astalify = require("astal.gtk3").astalify

local Separator = astalify(Gtk.Separator)

return function(args)
	args = args or {}

	return Widget.Box {
		class_name = "wifi-page",
		name = "Wifi-page",
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
			hexpand = true,
			Widget.Box {
				hexpand = true,
				halign = "START",
				Widget.Button {
					class_name = "close-button",
					on_clicked = args.on_close_button_clicked,
					Widget.Icon {
						icon = "pan-start-symbolic",
					}
				},
				Separator(),
				Widget.Button {
					class_name = "refresh-button",
					Widget.Icon {
						icon = "view-refresh-symbolic"
					}
				}
			},
			Widget.Box {
				halign = "END",
				Widget.Switch {
					class_name = "toggle-switch"
				}
			}
		}
	}
end
