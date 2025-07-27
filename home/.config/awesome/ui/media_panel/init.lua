local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local gtable = require("gears.table")
local beautiful = require("beautiful")
local common = require("common")
local shape = require("lib.shape")
local dpi = beautiful.xresources.apply_dpi
local text_icons = beautiful.text_icons
local capi = { screen = screen }
local media_player = require("service.media_player").get_default()

local media = {}

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

local function create_player_widget(self, name, player)
	local player_widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		forced_width = dpi(450),
		shape = shape.rrect(dpi(13)),
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				layout = wibox.layout.fixed.horizontal,
				fill_space = true,
				spacing = dpi(10),
				{
					widget = wibox.container.background,
					shape = shape.rrect(dpi(6)),
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
											widget = common.button {
												margins = dpi(4),
												shape = shape.rrect(dpi(6)),
												bg_normal = nil,
												bg_hover = beautiful.bg_urg,
												fg_hover = beautiful.fg,
												label = text_icons.go_previous,
											}
										},
										{
											id = "play-pause",
											widget = common.button {
												margins = dpi(4),
												shape = shape.rrect(dpi(6)),
												bg_normal = nil,
												bg_hover = beautiful.bg_urg,
												fg_hover = beautiful.fg
											}
										},
										{
											id = "next",
											widget = common.button {
												margins = dpi(4),
												shape = shape.rrect(dpi(6)),
												bg_normal = nil,
												bg_hover = beautiful.bg_urg,
												fg_hover = beautiful.fg,
												label = text_icons.go_next
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
								widget = wibox.container.margin,
								forced_height = dpi(20),
								{
									id = "timeline",
									widget = common.scale,
									trough_margins = dpi(9),
									trough_color = beautiful.bg_urg,
									trough_shape = shape.rbar(),
									highlight_margins = dpi(9),
									highlight_color = beautiful.ac,
									highlight_shape = shape.rbar(),
									slider_margins = dpi(4),
									slider_border_width = dpi(2),
									slider_color = beautiful.bg_alt,
									slider_border_color = beautiful.ac,
									slider_shape = shape.rbar()
								}
							}
						}
					}
				}
			}
		}
	}

	local wp = player_widget._private
	local preview_image = player_widget:get_children_by_id("preview")[1]
	local title_text = player_widget:get_children_by_id("title")[1]
	local artist_text = player_widget:get_children_by_id("artist")[1]
	local previous_button = player_widget:get_children_by_id("previous")[1]
	local play_pause_button = player_widget:get_children_by_id("play-pause")[1]
	local next_button = player_widget:get_children_by_id("next")[1]
	local position_text = player_widget:get_children_by_id("position")[1]
	local length_text = player_widget:get_children_by_id("length")[1]
	local timeline_slider = player_widget:get_children_by_id("timeline")[1]

	wp.player_name = name

	wp.timeline_timer = gtimer {
		timeout = 1,
		autostart = false,
		single_shot = false,
		call_now = false,
		callback = function()
			local length = player:get_metadata():get_length() or 1
			local position = player:get_position()

			position_text:set_markup(us_to_hms(position))

			if not timeline_slider:get_is_dragging() then
				timeline_slider:set_value(position/length*100)
			end

			if wp.timeline_timer then
				wp.timeline_timer:again()
			end
		end
	}

	wp.on_metadata = function(_, metadata)
		local art_url = metadata:get_art_url()
		preview_image:set_image(art_url ~= nil and art_url ~= ""
			and string.gsub(art_url, "^file://", "") or os.getenv("HOME") .. "/Downloads/music.svg")

		local position = player:get_position() or 0
		local length = metadata:get_length() or 1
		position_text:set_markup(us_to_hms(position))
		length_text:set_markup(us_to_hms(length))

		if not timeline_slider:get_is_dragging() then
			timeline_slider:set_value(position/length*100)
		end

		local title = metadata:get_title()
		title_text:set_markup(title ~= nil and title ~= "" and title or "untitled")

		local artist = metadata:get_artist()
		local artist_string = artist ~= nil and artist ~= {} and tostring(table.unpack(artist)) or nil
		artist_text:set_markup(artist_string ~= nil and artist_string ~= "" and artist_string or "unknown artist")
	end

	wp.on_playback_status = function(_, status)
		play_pause_button:set_label(status == "playing" and text_icons.pause or text_icons.play)

		if self.visible then
			if status ~= "playing" then
				wp.timeline_timer:stop()
			else
				wp.timeline_timer:start()
			end
		end
	end

	wp.on_seeked = function(_, pos)
		local position = pos
		local length = player:get_metadata():get_length()
		position_text:set_markup(us_to_hms(position))
		length_text:set_markup(us_to_hms(length))

		if not timeline_slider:get_is_dragging() then
			timeline_slider:set_value(position/length*100)
		end

		if self.visible then
			wp.timeline_timer:stop()
			if player:get_playback_status() == "playing" then
				wp.timeline_timer:start()
			end
		end
	end

	wp.on_timeline_slider_dragging_stopped = function()
		player:set_position(
			player:get_metadata():get_track_id(),
			player:get_metadata():get_length() * timeline_slider:get_value()/100
		)
	end

	player:connect_signal("property::metadata", wp.on_metadata)
	player:connect_signal("property::playback-status", wp.on_playback_status)
	player:connect_signal("seeked", wp.on_seeked)

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

	play_pause_button:set_label(player:get_playback_status() == "playing" and text_icons.pause or text_icons.play)

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

	timeline_slider:connect_signal("dragging-stopped", wp.on_timeline_slider_dragging_stopped)

	if self.visible then
		if player:get_playback_status() == "playing" then
			wp.timeline_timer:start()
		end
	end

	return player_widget
end

function media:show()
	if self.visible then return end
	local players_layout = self.widget:get_children_by_id("players-layout")[1]
	for _, player_widget in ipairs(players_layout.children) do
		local pp = player_widget._private
		if pp.player_name then
			local player = media_player:get_player(pp.player_name)
			local position_text = player_widget:get_children_by_id("position")[1]
			local length_text = player_widget:get_children_by_id("length")[1]
			local timeline_slider = player_widget:get_children_by_id("timeline")[1]

			local position = player:get_position() or 0
			local length = player:get_metadata():get_length() or 1
			position_text:set_markup(us_to_hms(position))
			length_text:set_markup(us_to_hms(length))
			timeline_slider:set_value(position/length*100)

			if player:get_playback_status() == "playing" then
				pp.timeline_timer:start()
			end
		end
	end
	self.visible = true
	self:emit_signal("property::visible", self.visible)
end

function media:hide()
	if not self.visible then return end
	local players_layout = self.widget:get_children_by_id("players-layout")[1]
	for _, player_widget in ipairs(players_layout.children) do
		local pp = player_widget._private
		if pp.player_name then
			pp.timeline_timer:stop()
		end
	end
	self.visible = false
	self:emit_signal("property::visible", self.visible)
end

function media:toggle()
	if not self.visible then
		self:show()
	else
		self:hide()
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
			shape = shape.rrect(dpi(23)),
			{
				widget = wibox.container.margin,
				margins = dpi(10),
				{
					layout = wibox.layout.stack,
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
					},
					{
						id = "players-switcher",
						widget = wibox.container.place,
						visible = false,
						halign = "right",
						valign = "top",
						{
							widget = wibox.container.margin,
							margins = dpi(6),
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = dpi(3),
								{
									id = "previous-player-button",
									widget = common.button {
										forced_width = dpi(20),
										forced_height = dpi(20),
										shape = shape.rrect(6),
										bg_normal = beautiful.bg_urg,
										font = beautiful.font_h0,
										label = text_icons.arrow_left
									}
								},
								{
									id = "next-player-button",
									widget = common.button {
										forced_width = dpi(20),
										forced_height = dpi(20),
										shape = shape.rrect(6),
										bg_normal = beautiful.bg_urg,
										font = beautiful.font_h0,
										label = text_icons.arrow_right
									}
								}
							}
						}
					}
				}
			}
		}
	}

	gtable.crush(ret, media, true)
	local wp = ret._private
	local players_layout = ret.widget:get_children_by_id("players-layout")[1]
	local players_switcher = ret.widget:get_children_by_id("players-switcher")[1]
	local previous_player_button = ret.widget:get_children_by_id("previous-player-button")[1]
	local next_player_button = ret.widget:get_children_by_id("next-player-button")[1]

	wp.on_player_added = function(_, name, player)
		if not players_layout.children[1]._private.player_name then
			players_layout:remove(1)
		end

		players_layout:insert(1, create_player_widget(ret, name, player))

		if #players_layout.children > 1 then
			players_switcher:set_visible(true)
		end
	end

	wp.on_player_removed = function(_, name, player)
		for _, player_widget in ipairs(players_layout.children) do
			if player_widget._private.player_name == name then
				player:disconnect_signal("property::metadata", player_widget._private.on_metadata)
				player:disconnect_signal("property::playback-status", player_widget._private.on_playback_status)
				player:disconnect_signal("seeked", player_widget._private.on_seeked)
				player_widget._private.timeline_timer:stop()
				player_widget._private.timeline_timer = nil

				players_layout:remove_widgets(player_widget)

				if #players_layout.children <= 1 then
					players_switcher:set_visible(false)
				end

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

	media_player:connect_signal("player-added", wp.on_player_added)
	media_player:connect_signal("player-removed", wp.on_player_removed)

	for name, player in pairs(media_player:get_players()) do
		wp.on_player_added(nil, name, player)
	end

	previous_player_button:buttons {
		awful.button({}, 1, function()
			if #players_layout.children > 1 then
				players_layout:add(players_layout.children[1])
				players_layout:remove(1)
			end
		end)
	}

	next_player_button:buttons {
		awful.button({}, 1, function()
			if #players_layout.children > 1 then
				players_layout:raise(#players_layout.children)
			end
		end)
	}

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
