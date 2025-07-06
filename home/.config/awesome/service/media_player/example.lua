local awful = require("awful")
local nuaghty = require("naughty")
local media_player = require("service.media_player").get_default()

local function on_metadata_changed(_, data)
	nuaghty.notification {
		app_name = "awesome",
		title = "mpris metadata",
		--icon = data:get_art_url(),
		text = string.format(
			"%s\n%s",
			data:get_title(),
			tostring(table.unpack(data:get_artist()))
		)
	}
end

media_player:connect_signal("player-added", function(_, name)
	nuaghty.notification {
		app_name = "Awesome",
		title = "player added",
		text = name
	}

	local player = media_player:get_player(name)
	player:connect_signal("property::metadata", on_metadata_changed)
end)

media_player:connect_signal("player-removed", function(_, name)
	nuaghty.notification {
		app_name = "Awesome",
		title = "player removed",
		text = name
	}

	local player = media_player:get_player(name)
	player:disconnect_signal("property::metadata", on_metadata_changed)
end)

for name, player in pairs(media_player:get_players()) do
	nuaghty.notification {
		app_name = "Awesome",
		title = "player listed",
		text = name
	}
	player:connect_signal("property::metadata", on_metadata_changed)
end

awful.keyboard.append_global_keybinding(
	awful.key({ "Mod4" }, "p", function()
		local player = media_player:match_players("firefox")[1]
		if player then
			player:next()
		end
	end)
)

awful.keyboard.append_global_keybinding(
	awful.key({ "Mod4" }, "o", function()
		local player = media_player:match_players("firefox")[1]
		if player then
			player:previous()
		end
	end)
)
