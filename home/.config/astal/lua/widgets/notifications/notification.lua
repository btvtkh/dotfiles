local Widget = require("astal.gtk3").Widget
local Gtk = require("astal.gtk3").Gtk
local Astal = require("astal.gtk3").Astal
local map = require("lua.lib").map
local time = require("lua.lib").time
local file_exists = require("lua.lib").file_exists

local function is_icon(icon)
	return Astal.Icon.lookup_icon(icon) ~= nil
end

return function(n, setup)
	local header = Widget.Box {
		class_name = "header",
		Widget.Label {
			class_name = "app-name",
			halign = "START",
			ellipsize = "END",
			label = n.app_name or "Unknown"
		},
		Widget.Label {
			class_name = "time",
			hexpand = true,
			halign = "END",
			label = time(n.time)
		},
		Widget.Button {
			class_name = "dismiss-button",
			on_clicked = function()
				n:dismiss()
			end,
			Widget.Icon {
				icon = "window-close-symbolic"
			}
		}
	}

	local content = Widget.Box {
		class_name = "content",
		(n.image and file_exists(n.image)) and Widget.Box {
			valign = "START",
			class_name = "image",
			css = string.format("background-image: url('%s')", n.image),
		},
		n.image and is_icon(n.image) and Widget.Box {
			valign = "START",
			class_name = "icon-image",
			Widget.Icon {
				icon = n.image,
				hexpand = true,
				vexpand = true,
				halign = "CENTER",
				valign = "CENTER"
			},
		},
		Widget.Box {
			vertical = true,
			Widget.Label {
				class_name = "summary",
				halign = "START",
				ellipsize = "END",
				xalign = 0,
				label = n.summary
			},
			Widget.Label {
				class_name = "body",
				use_markup = true,
				wrap = true,
				wrap_mode = "CHAR",
				halign = "START",
				justify = "FILL",
				ellipsize = "END",
				xalign = 0,
				lines = 4,
				label = n.body
			}
		}
	}

	return Widget.Box {
		class_name = string.format("notification %s", string.lower(n.urgency)),
		setup = setup,
		vertical = true,
		header,
		Gtk.Separator {
			visible = true
		},
		content,
		#n.actions > 0 and Widget.Box {
			class_name = "actions",
			map(n.actions, function(action)
				return Widget.Button {
					class_name = "action-button",
					hexpand = true,
					on_clicked = function()
						return n:invoke(action.id)
					end,
					Widget.Label {
						label = action.label,
						halign = "CENTER",
						ellipsize = "END",
						max_width_chars = 15,
						hexpand = true
					}
				}
			end)
		}
	}
end
