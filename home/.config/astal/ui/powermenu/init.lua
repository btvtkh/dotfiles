local astal = require("astal")
local AstalHyprland = astal.require("AstalHyprland")
local App = require("astal.gtk3").App
local Widget = require("astal.gtk3").Widget
local Astal = require("astal.gtk3").Astal
local Gdk = require("astal.gtk3").Gdk
local Anchor = Astal.WindowAnchor

local function hide()
	local powermenu = App:get_window("Powermenu")
	if powermenu then powermenu:hide() end
end

return function()
	local hyprland = AstalHyprland.get_default()

	local mainbox = Widget.Box {
		class_name = "mainbox",
		vexpand = false,
		spacing = 5,
		Widget.Button {
			on_clicked = function()
				hyprland:dispatch("exec", "poweroff")
			end,
			Widget.Icon {
				icon = "system-shutdown-symbolic"
			}
		},
		Widget.Button {
			on_clicked = function()
				hyprland:dispatch("exec", "reboot")
			end,
			Widget.Icon {
				icon = "system-reboot-symbolic"
			}
		},
		Widget.Button {
			on_clicked = function()
				hyprland:dispatch("exit", "")
			end,
			Widget.Icon {
				icon = "system-log-out-symbolic"
			}
		},
	}

	local revealer = Widget.Revealer {
		transition_type = "SLIDE_UP",
		mainbox
	}

	return Widget.Window {
		application = App,
		name = "Powermenu",
		class_name = "powermenu",
		anchor = Anchor.BOTTOM + Anchor.RIGHT + Anchor.TOP + Anchor.LEFT,
		exclusivity = "IGNORE",
		keymode = "ON_DEMAND",
		visible = false,
		on_key_press_event = function(self, event)
			if event.keyval == Gdk.KEY_Escape then
				self:hide()
			end
		end,
		on_show = function()
			revealer:set_reveal_child(true)
			mainbox:get_children()[1]:grab_focus()
		end,
		on_hide = function()
			revealer:set_reveal_child(false)
		end,
		setup = function(self)
			self:hook(App, "window-toggled", function(_, w)
				if w:get_visible() and (
					w:get_name() == "Launcher"
					or w:get_name() == "Control-panel"
				) then
					hide()
				end
			end)
		end,
		Widget.CenterBox {
			Widget.EventBox {
				hexpand = true,
				on_click = hide
			},
			Widget.CenterBox {
				vertical = true,
				Widget.EventBox {
					vexpand = true,
					on_click = hide
				},
				revealer,
				Widget.EventBox {
					vexpand = true,
					on_click = hide
				}
			},
			Widget.EventBox {
				hexpand = true,
				on_click = hide
			}
		}
	}
end
