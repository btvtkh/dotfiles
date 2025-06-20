local astal = require("astal")
local timeout = astal.timeout
local AstalNotifd = astal.require("AstalNotifd")
local Widget = require("astal.gtk3").Widget
local Astal = require("astal.gtk3").Astal
local Anchor = Astal.WindowAnchor
local varlist = require("lua.lib").varlist
local Notification = require("lua.widgets.notifications.notification")

local TIMEOUT_DELAY = 5000

return function(gdkmonitor)
	local notifd = AstalNotifd.get_default()
	local notif_list = varlist({})

	notifd.on_notified = function(_, id)
		local n = notifd:get_notification(id)

		notif_list.insert(1, Notification(n, function(self)
			self:hook(n, "resolved", function()
				notif_list.remove(self)
			end)

			timeout(TIMEOUT_DELAY, function()
				notif_list.remove(self)
			end)
		end))
	end

	return Widget.Window {
		gdkmonitor = gdkmonitor,
		name = "Notifications",
		class_name = "notifications",
		anchor = Anchor.TOP + Anchor.RIGHT,
		Widget.Box {
			vertical = true,
			notif_list()
		}
	}
end
