local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local common = require("common")
local dpi = beautiful.xresources.apply_dpi
local capi = { screen = screen }
local media_player = require("service.media_player").get_default()

local function on_player_added(self, name)
	local player = media_player:get_player(name)
	local players_layout = self.widget:get_children_by_id("players-layout")[1]

	local player_widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		{
			layout = wibox.layout.fixed.horizontal,
			fill_space = true,
			spacing = dpi(5),
			--[[
			{
				widget = wibox.container.constraint,
				strategy = "max",
				width = dpi(90),
				height = dpi(90),
				{
					id = "track-preview",
					widget = wibox.widget.imagebox,
					resize = true,
					halign = "center",
					valign = "center",
					horizontal_fit_policy = "cover",
					vertical_fit_policy = "cover"
				}
			},
			]]
			{
				layout = wibox.layout.fixed.vertical,
				{
					id = "track-title",
					widget = wibox.widget.textbox
				},
				{
					id = "track-artist",
					widget = wibox.widget.textbox
				},
				--{
				--	id = "track-slider",
				--	widget = wibox.widget.slider
				--},
				{
					layout = wibox.layout.flex.horizontal,
					spacing = dpi(5),
					{
						id = "previous-button",
						widget = common.hover_button {
							label = "prev",
							bg_normal = beautiful.bg_urg
						}
					},
					{
						id = "play-pause-button",
						widget = common.hover_button {
							label = "play/pause",
							bg_normal = beautiful.bg_urg
						}
					},
					{
						id = "next-button",
						widget = common.hover_button {
							label = "next",
							bg_normal = beautiful.bg_urg
						}
					}
				}
			}
		}
	}

	--local preview = player_widget:get_children_by_id("track-preview")[1]
	local title = player_widget:get_children_by_id("track-title")[1]
	local artist = player_widget:get_children_by_id("track-artist")[1]
	local previous_button = player_widget:get_children_by_id("previous-button")[1]
	local play_pause_button = player_widget:get_children_by_id("play-pause-button")[1]
	local next_button = player_widget:get_children_by_id("next-button")[1]

	player_widget._private.player_name = name

	player_widget._private.on_metadata = function(_, metadata)
		--preview:set_image(metadata:get_art_url())
		title:set_markup(metadata:get_title())
		artist:set_markup(tostring(table.unpack(metadata:get_artist())))
	end

	player_widget._private.on_playback_status = function(_, status)
		play_pause_button:set_label(status == "playing" and "pause" or "play")
	end

	player:connect_signal("property::metadata", player_widget._private.on_metadata)
	player:connect_signal("property::playback-status", player_widget._private.on_playback_status)

	--preview:set_image(player:get_metadata():get_art_url())
	title:set_markup(player:get_metadata():get_title())
	artist:set_markup(tostring(table.unpack(player:get_metadata():get_artist())))
	play_pause_button:set_label(player:get_playback_status() == "playing" and "pause" or "play")

	previous_button:buttons {
		awful.button({}, 1, function()
			player:previous()
		end)
	}

	play_pause_button:buttons {
		awful.button({}, 1, function()
			player:play_pause()
		end)
	}

	next_button:buttons {
		awful.button({}, 1, function()
			player:next()
		end)
	}

	players_layout:insert(1, player_widget)
end

local function on_player_removed(self, name)
	local player = media_player:get_player(name)
	local players_layout = self.widget:get_children_by_id("players-layout")[1]

	for _, player_widget in ipairs(players_layout.children) do
		if player_widget._private.player_name == name then
			player:disconnect_signal("property::metadata", player_widget._private.on_metadata)
			player:disconnect_signal("property::playback-status", player_widget._private.on_playback_status)
			player_widget:get_children_by_id("previous-button")[1]:clear_mouse_signals()
			player_widget:get_children_by_id("play-pause-button")[1]:clear_mouse_signals()
			player_widget:get_children_by_id("next-button")[1]:clear_mouse_signals()
			players_layout:remove_widgets(player_widget)
		end
	end
end

local function new()
	local ret = awful.popup {
		visible = false,
		ontop = true,
		type = "dock",
		screen = capi.screen.primary,
		placement = function() return { 0, 0 } end,
		bg = "#00000000",
		widget = {
			widget = wibox.container.background,
			bg = beautiful.bg,
			border_width = beautiful.border_width,
			border_color = beautiful.border_color_normal,
			forced_width = dpi(500),
			forced_height = dpi(250),
			{
				widget = wibox.container.margin,
				margins = dpi(10),
				{
					id = "players-layout",
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(10)
				}
			}
		}
	}

	media_player:connect_signal("player-added", function(_, name)
		on_player_added(ret, name)
	end)

	media_player:connect_signal("player-removed", function(_, name)
		on_player_removed(ret, name)
	end)

	for name, _ in pairs(media_player:get_players()) do
		on_player_added(ret, name)
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

return { get_default = get_default }
