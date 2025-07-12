local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local common = require("common")
local dpi = beautiful.xresources.apply_dpi
local capi = { screen = screen }
local media_player = require("service.media_player").get_default()

local function us_to_hms(us)
	local total_s = us / 1000000
	local h = math.floor(total_s / 3600)
	local remaining_s = total_s % 3600
	local m = math.floor(remaining_s / 60)
	local s = remaining_s % 60

	return (h > 0 and string.format("%02d", math.floor(h)) .. ":" or "")
		.. string.format("%02d", math.floor(m)) .. ":"
		.. string.format("%02d", math.floor(s))
end

local function on_player_added(self, name)
	local player = media_player:get_player(name)
	local players_layout = self.widget:get_children_by_id("players-layout")[1]

	local player_widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		forced_width = dpi(450),
		shape = beautiful.rrect(dpi(10)),
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				layout = wibox.layout.fixed.horizontal,
				fill_space = true,
				spacing = dpi(10),
				{
					widget = wibox.container.background,
					shape = beautiful.rrect(dpi(6)),
					{
						id = "preview",
						widget = wibox.widget.imagebox,
						forced_width = 120,
						forced_height = 120,
						resize = true,
						halign = "center",
						valign = "center",
						horizontal_fit_policy = "cover",
						vertical_fit_policy = "cover"
					}
				},
				{
					widget = wibox.container.margin,
					margins = dpi(5),
					{
						layout = wibox.layout.align.vertical,
						{
							layout = wibox.layout.fixed.vertical,
							{
								widget = wibox.container.constraint,
								strategy = "max",
								height = dpi(25),
								{
									id = "title",
									widget = wibox.widget.textbox
								}
							},
							{
								widget = wibox.container.constraint,
								strategy = "max",
								height = dpi(20),
								{
									id = "artist",
									widget = wibox.widget.textbox,
									font = beautiful.font_h0
								}
							}
						},
						nil,
						{
							layout = wibox.layout.fixed.vertical,
							{
								layout = wibox.layout.flex.horizontal,
								{
									widget = wibox.container.place,
									halign = "left",
									{
										widget = wibox.container.background,
										fg = beautiful.fg_alt,
										{
											id = "position",
											widget = wibox.widget.textbox,
											font = beautiful.font_h0
										}
									}
								},
								{
									widget = wibox.container.place,
									halign = "center",
									{
										layout = wibox.layout.fixed.horizontal,
										spacing = dpi(5),
										{
											id = "previous",
											widget = common.hover_button {
												label = "",
												margins = dpi(4),
												shape = beautiful.rrect(dpi(6))
											}
										},
										{
											id = "play-pause",
											widget = common.hover_button {
												margins = dpi(4),
												shape = beautiful.rrect(dpi(6))
											}
										},
										{
											id = "next",
											widget = common.hover_button {
												label = "",
												margins = dpi(4),
												shape = beautiful.rrect(dpi(6))
											}
										}
									}
								},
								{
									widget = wibox.container.place,
									halign = "right",
									{
										widget = wibox.container.background,
										fg = beautiful.fg_alt,
										{
											id = "length",
											widget = wibox.widget.textbox,
											font = beautiful.font_h0
										}
									}
								}
							},
							{
								id = "slider-container",
								widget = wibox.container.margin,
								forced_height = dpi(20),
								{
									id = "timeline",
									widget = wibox.widget.slider,
									maximum = 100,
									bar_height = dpi(2),
									handle_width = dpi(20),
									handle_border_width = dpi(2),
									handle_margins = { top = dpi(7), bottom = dpi(7) },
									bar_color = beautiful.bg_urg,
									bar_active_color = beautiful.ac,
									handle_color = beautiful.bg_alt,
									handle_border_color = beautiful.ac,
									handle_shape = beautiful.crcl(5),
									bar_shape = beautiful.rbar()
								}
							}
						}
					}
				}
			}
		}
	}

	local preview_image = player_widget:get_children_by_id("preview")[1]
	local title_text = player_widget:get_children_by_id("title")[1]
	local artist_text = player_widget:get_children_by_id("artist")[1]
	local previous_button = player_widget:get_children_by_id("previous")[1]
	local play_pause_button = player_widget:get_children_by_id("play-pause")[1]
	local next_button = player_widget:get_children_by_id("next")[1]
	local position_text = player_widget:get_children_by_id("position")[1]
	local length_text = player_widget:get_children_by_id("length")[1]
	local timeline_slider = player_widget:get_children_by_id("timeline")[1]

	player_widget._private.player_name = name

	player_widget._private.timeline_timer = gtimer {
		timeout = 1,
		autostart = false,
		single_shot = false,
		call_now = false,
		callback = function()
			local length = player:get_metadata():get_length() or 1
			local position = player:get_position()

			position_text:set_markup(us_to_hms(position))
			timeline_slider:set_value(position/length*100)

			if player_widget._private.timeline_timer then
				player_widget._private.timeline_timer:again()
			end
		end
	}

	player_widget._private.on_metadata = function(_, metadata)
		local art_url = metadata:get_art_url()
		preview_image:set_image(art_url ~= nil and art_url ~= ""
			and string.gsub(art_url, "^file://", "") or os.getenv("HOME") .. "/Downloads/music.svg")

		local position = player:get_position() or 0
		local length = metadata:get_length() or 1
		position_text:set_markup(us_to_hms(position))
		length_text:set_markup(us_to_hms(length))
		timeline_slider:set_value(position/length*100)

		local title = metadata:get_title()
		title_text:set_markup(title ~= nil and title ~= "" and title or "untitled")

		local artist = metadata:get_artist()
		local artist_string = artist ~= nil and artist ~= {} and tostring(table.unpack(artist)) or nil
		artist_text:set_markup(artist_string ~= nil and artist_string ~= "" and artist_string or "unknown artist")

	end

	player_widget._private.on_playback_status = function(_, status)
		play_pause_button:set_label(status == "playing" and "" or "")

		if status ~= "playing" then
			player_widget._private.timeline_timer:stop()
		else
			player_widget._private.timeline_timer:start()
		end
	end

	player_widget._private.on_seeked = function(_, pos)
		local position = pos
		local length = player:get_metadata():get_length()
		position_text:set_markup(us_to_hms(position))
		length_text:set_markup(us_to_hms(length))
		timeline_slider:set_value(position/length*100)

		player_widget._private.timeline_timer:stop()
		if player:get_playback_status() == "playing" then
			player_widget._private.timeline_timer:start()
		end
	end

	player:connect_signal("property::metadata", player_widget._private.on_metadata)
	player:connect_signal("property::playback-status", player_widget._private.on_playback_status)
	player:connect_signal("seeked", player_widget._private.on_seeked)

	local art_url = player:get_metadata():get_art_url()
	preview_image:set_image(art_url ~= nil and art_url ~= ""
		and string.gsub(art_url, "^file://", "") or os.getenv("HOME") .. "/Downloads/music.svg")

	local title = player:get_metadata():get_title()
	title_text:set_markup(title ~= nil and title ~= "" and title or "untitled")

	local artist = player:get_metadata():get_artist()
	local artist_string = artist ~= nil and artist ~= {} and tostring(table.unpack(artist)) or nil
	artist_text:set_markup(artist_string ~= nil and artist_string ~= "" and artist_string or "unknown artist")

	local position = player:get_position() or 0
	local length = player:get_metadata():get_length() or 1
	position_text:set_markup(us_to_hms(position))
	length_text:set_markup(us_to_hms(length))
	timeline_slider:set_value(position/length*100)

	play_pause_button:set_label(player:get_playback_status() == "playing" and "" or "")

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

	timeline_slider:buttons {
		awful.button({}, 1, function()
			gtimer.delayed_call(function()
				player:set_position(
					player:get_metadata():get_track_id(),
					player:get_metadata():get_length()
					* timeline_slider:get_value()/100
				)
			end)
		end)
	}

	if player:get_playback_status() == "playing" then
		player_widget._private.timeline_timer:start()
	end

	if not players_layout.children[1]._private.player_name then
		players_layout:remove(1)
	end

	players_layout:insert(1, player_widget)
end

local function on_player_removed(self, name)
	local player = media_player:get_player(name)
	local players_layout = self.widget:get_children_by_id("players-layout")[1]

	for _, player_widget in ipairs(players_layout.children) do
		if player_widget._private.player_name == name then
			player:disconnect_signal("property::metadata", player_widget._private.on_metadata)
			player:disconnect_signal("property::playback-status", player_widget._private.on_playback_status)
			player:disconnect_signal("seeked", player_widget._private.on_seeked)
			player_widget._private.timeline_timer:stop()
			player_widget._private.timeline_timer = nil

			players_layout:remove_widgets(player_widget)

			if #players_layout.children == 0 then
				players_layout:add(wibox.widget {
					widget = wibox.container.background,
					forced_width = dpi(300),
					forced_height = dpi(100),
					fg = beautiful.fg_alt,
					{
						widget = wibox.widget.textbox,
						align = "center",
						font = beautiful.font_h2,
						text = "Nothing playing"
					}
				})
			end
		end
	end
end

local function new()
	local ret = awful.popup {
		visible = false,
		ontop = true,
		type = "dock",
		screen = capi.screen.primary,
		placement = function(d)
			awful.placement.bottom_right(d, {
				honor_workarea = true,
				margins = beautiful.useless_gap
			})
		end,
		bg = "#00000000",
		widget = {
			widget = wibox.container.background,
			bg = beautiful.bg,
			border_width = beautiful.border_width,
			border_color = beautiful.border_color_normal,
			shape = beautiful.rrect(dpi(20)),
			{
				widget = wibox.container.margin,
				margins = dpi(10),
				{
					id = "players-layout",
					layout = wibox.layout.stack,
					top_only = true,
					{
						widget = wibox.container.background,
						forced_width = dpi(300),
						forced_height = dpi(100),
						fg = beautiful.fg_alt,
						{
							widget = wibox.widget.textbox,
							align = "center",
							font = beautiful.font_h2,
							text = "Nothing playing"
						}
					}
				}
			}
		}
	}

	local players_layout = ret.widget:get_children_by_id("players-layout")[1]

	players_layout:buttons {
		awful.button({}, 4, function()
			if #players_layout.children > 1 then
				players_layout:raise(#players_layout.children)
			end
		end),
		awful.button({}, 5, function()
			if #players_layout.children > 1 then
				players_layout:add(players_layout.children[1])
				players_layout:remove(1)
			end
		end)
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
