local awful = require("awful")
local capi = { tag = tag }

capi.tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts {
		awful.layout.suit.floating,
		awful.layout.suit.tile,
	}
end)

awful.screen.connect_for_each_screen(function(s)
	awful.tag({ "tag-1", "tag-2", "tag-3", "tag-4", "tag-5" }, s, awful.layout.layouts[1])
end)
