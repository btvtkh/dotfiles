local awful = require("awful")
local players = require("ui.players_panel").get_default()

awful.keyboard.append_global_keybinding(
	awful.key({ "Mod4" }, "k", function()
		if not players.visible then
			awful.placement.bottom_right(players, {
				honor_workarea = true,
				margins = 5
			})
			players.visible = true
		else
			players.visible = false
		end
	end)
)
