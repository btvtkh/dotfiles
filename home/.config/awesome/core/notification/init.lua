local naughty = require("naughty")
local rnotification = require("ruled.notification")
local ncr = naughty.notification_closed_reason
local capi = { awesome = awesome }

rnotification.connect_signal("request::rules", function()
	rnotification.append_rule {
		id = "global",
		rule = {},
		properties = {
			timeout = 0
		}
	}
end)

capi.awesome.connect_signal("exit", function()
	naughty.destroy_all_notifications(nil, ncr.silent)
end)
