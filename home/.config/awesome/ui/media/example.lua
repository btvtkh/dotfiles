local awful = require("awful")
local media = require("ui.media").get_default()

awful.keyboard.append_global_keybinding(
	awful.key({ "Mod4" }, "k", function()
		if not media.visible then
			media.visible = true
		else
			media.visible = false
		end
	end)
)
