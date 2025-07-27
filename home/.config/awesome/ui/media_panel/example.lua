local awful = require("awful")
local media = require("ui.media_panel").get_default()

awful.keyboard.append_global_keybinding(
	awful.key({ "Mod4" }, "k", function()
		media:toggle()
	end)
)
