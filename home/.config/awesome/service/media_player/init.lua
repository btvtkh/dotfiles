local DBusProxy = require("lib.dbus_proxy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local media_player = {}
local player = {}
local metadata = {}

function media_player:get_players()
	return self.players
end

function media_player:get_player(name)
	return self.players[name]
end

function media_player:match_players(match)
	local p = {}
	for n, o in pairs(self.players) do
		if n:match(match) then
			table.insert(p, o)
		end
	end
	return p
end

function player:next()
	self._private.player_proxy:NextAsync(nil, {})
end

function player:previous()
	self._private.player_proxy:PreviousAsync(nil, {})
end

function player:play()
	self._private.player_proxy:PlayAsync(nil, {})
end

function player:pause()
	self._private.player_proxy:PauseAsync(nil, {})
end

function player:play_pause()
	self._private.player_proxy:PlayPauseAsync(nil, {})
end

function player:get_playback_status()
	return string.lower(self._private.player_proxy.PlaybackStatus)
end

function player:get_metadata()
	return setmetatable(
		self._private.player_proxy.Metadata,
		{ __index = metadata }
	)
end

function player:get_can_go_next()
	return self._private.player_proxy.CanGoNext
end

function player:get_can_go_previous()
	return self._private.player_proxy.CanGoPrevious
end

function player:get_can_play()
	return self._private.player_proxy.CanPlay
end

function player:get_can_pause()
	return self._private.player_proxy.CanPause
end

function metadata:get_track_id()
	return self["mpris:trackid"]
end

function metadata:get_title()
	return self["xesam:title"]
end

function metadata:get_album()
	return self["xesam:album"]
end

function metadata:get_artist()
	return self["xesam:artist"]
end


function metadata:get_art_url()
	return string.gsub(self["mpris:artUrl"], "^file://", "")
end

function metadata:get_url()
	return self["xesam:url"]
end

function metadata:get_length()
	return self["mpris:length"]
end

local function new_player(name)
	local ret = gobject {}
	gtable.crush(ret, player, true)
	ret._private = {}

	ret._private.player_proxy = DBusProxy.Proxy:new {
		bus = DBusProxy.Bus.SESSION,
		name = name,
		path = "/org/mpris/MediaPlayer2",
		interface = "org.mpris.MediaPlayer2.Player"
	}

	ret._private.properties_proxy = DBusProxy.Proxy:new {
		bus = DBusProxy.Bus.SESSION,
		name = name,
		path = "/org/mpris/MediaPlayer2",
		interface = "org.freedesktop.DBus.Properties"
	}

	ret._private.properties_proxy:connect_signal("PropertiesChanged", function(_, _, props)
		if props.Metadata ~= nil then
			ret:emit_signal("property::metadata", setmetatable(
				props.Metadata,
				{ __index = metadata }
			))
		end
		if props.PlaybackStatus ~= nil then
			ret:emit_signal("property::playback-status", string.lower(props.PlaybackStatus))
		end
	end)

	ret._private.player_proxy:connect_signal("Seeked", function(_, pos)
		ret:emit_signal("seeked", pos)
	end)

	return ret
end

local function new()
	local ret = gobject {}
	gtable.crush(ret, media_player, true)
	ret._private = {}

	ret._private.names_proxy = DBusProxy.Proxy:new {
		bus = DBusProxy.Bus.SESSION,
		name = "org.freedesktop.DBus",
		path = "/org/freedesktop/DBus",
		interface = "org.freedesktop.DBus"
	}

	ret.players = {}
	if ret._private.names_proxy then
		ret._private.names_proxy:connect_signal("NameOwnerChanged", function(_, name, old_owner, new_owner)
			if name:match("org%.mpris%.MediaPlayer2%.%w+") then
				if old_owner == "" and new_owner ~= "" then
					ret.players[name] = new_player(name)
					ret:emit_signal("player-added", name)
				elseif old_owner ~= "" and new_owner == "" then
					ret:emit_signal("player-removed", name)
					ret.players[name] = nil
				end
			end
		end)

		for _, name in ipairs(ret._private.names_proxy:ListNames()) do
			if name:match("org%.mpris%.MediaPlayer2%.%w+") then
				ret.players[name] = new_player(name)
			end
		end
	end

	return ret
end

local instance = nil
local function get_default()
	if not instance then
		instance = new()
	end
	return instance
end

return {
	get_default = get_default
}
