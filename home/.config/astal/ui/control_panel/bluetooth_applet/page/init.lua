local Widget = require("astal.gtk3").Widget

return function(on_clicked)
	return Widget.Box {
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
				on_clicked = on_clicked,
				Widget.Icon {
					icon = "arrow-left",
				}
			}
		}
	}
end
