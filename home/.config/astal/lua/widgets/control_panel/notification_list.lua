local astal = require("astal")
local AstalNotifd = astal.require("AstalNotifd")
local Widget = require("astal.gtk3").Widget
local varlist = require("lua.lib").varlist
local Notification = require("lua.widgets.notifications.notification")

return function()
	local notifd = AstalNotifd.get_default()
	local notif_list = varlist({})

	for _, n in ipairs(notifd:get_notifications()) do
		notif_list.insert(Notification(n, function(self)
			self:hook(n, "resolved", function()
				notif_list.remove(self)
			end)
		end))
	end

	notifd.on_notified = function(_, id)
		local n = notifd:get_notification(id)
		notif_list.insert(1, Notification(n, function(self)
			self:hook(n, "resolved", function()
				notif_list.remove(self)
			end)
		end))
	end

	return Widget.Box {
		class_name = "notification-list",
		vertical = true,
		spacing = 8,
		Widget.Box {
			class_name = "header",
			Widget.Label {
				class_name = "title",
				label = notif_list():as(function(l)
					return "Notifications " ..
						(#l > 0 and "(" .. tostring(#l) .. ")" or "")
				end)
			},
			Widget.Box {
				hexpand = true,
				halign = "END",
				Widget.Button {
					class_name = "clear-button",
					on_clicked = function()
						for _, n in ipairs(notifd:get_notifications()) do
							n:dismiss()
						end
					end,
					Widget.Icon {
						icon = "trash-symbolic"
					}
				}
			}
		},
		Widget.Scrollable {
			vexpand = true,
			Widget.Box {
				vertical = true,
				spacing = 8,
				notif_list(),
				Widget.Box {
					class_name = "empty-massage",
					expand = true,
					halign = "CENTER",
					valign = "CENTER",
					visible = notif_list():as(function(v)
						return #v == 0
					end),
					Widget.Label {
						label = "No notifications"
					}
				}
			}
		}
	}
end
