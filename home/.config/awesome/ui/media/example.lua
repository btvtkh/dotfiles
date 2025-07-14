local awful = require("awful")
local players = require("ui.media").get_default()

awful.keyboard.append_global_keybinding(
	awful.key({ "Mod4" }, "k", function()
		if not players.visible then
			players.visible = true
		else
			players.visible = false
		end
	end)
)
