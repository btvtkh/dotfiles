local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local audio = require("service.audio").get_default()

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(10)),
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(2),
				{
					layout = wibox.layout.fixed.horizontal,
					fill_space = true,
					spacing = dpi(10),
					{
						id = "speaker-mute-button",
						widget = wibox.container.background,
							forced_width = dpi(40),
							forced_height = dpi(40),
							shape = beautiful.rrect(dpi(8)),
							{
								widget = wibox.container.place,
								halign = "center",
								valign = "center",
								{
									id = "speaker-mute-button-icon",
									widget = wibox.widget.textbox
								}
							}
					},
					{
						widget = wibox.container.background,
						forced_width = dpi(310),
						forced_height = dpi(40),
						{
							id = "speaker-slider",
							widget = wibox.widget.slider,
							maximum = 20,
							bar_height = dpi(2),
							handle_width = dpi(20),
							handle_border_width = dpi(2),
							handle_margins = { top = dpi(7), bottom = dpi(7) },
							bar_color = beautiful.bg_urg,
							handle_color = beautiful.bg_alt,
							handle_border_color = beautiful.ac,
							handle_shape = beautiful.crcl(9),
							bar_shape = beautiful.rbar()
						}
					},
					{
						id = "speaker-volume-value",
						widget = wibox.widget.textbox,
						align = "center"
					}
				},
				{
					layout = wibox.layout.fixed.horizontal,
					fill_space = true,
					spacing = dpi(10),
					{
						id = "microphone-mute-button",
						widget = wibox.container.background,
							forced_width = dpi(40),
							forced_height = dpi(40),
							shape = beautiful.rrect(dpi(8)),
							{
								widget = wibox.container.place,
								halign = "center",
								valign = "center",
								{
									id = "microphone-mute-button-icon",
									widget = wibox.widget.textbox
								}
							}
					},
					{
						widget = wibox.container.background,
						forced_width = dpi(310),
						forced_height = dpi(40),
						{
							id = "microphone-slider",
							widget = wibox.widget.slider,
							maximum = 20,
							bar_height = dpi(2),
							handle_width = dpi(20),
							handle_border_width = dpi(2),
							handle_margins = { top = dpi(7), bottom = dpi(7) },
							bar_color = beautiful.bg_urg,
							handle_color = beautiful.bg_alt,
							handle_border_color = beautiful.ac,
							handle_shape = beautiful.crcl(9),
							bar_shape = beautiful.rbar()
						}
					},
					{
						id = "microphone-volume-value",
						widget = wibox.widget.textbox,
						align = "center"
					}
				}
			}
		}
	}

	local speaker_mute = ret:get_children_by_id("speaker-mute-button")[1]
	local speaker_icon = ret:get_children_by_id("speaker-mute-button-icon")[1]
	local speaker_slider = ret:get_children_by_id("speaker-slider")[1]
	local speaker_value = ret:get_children_by_id("speaker-volume-value")[1]

	audio:connect_signal("default-sink::volume", function(_, val)
		speaker_slider:set_value(tonumber(val) / 5)
		speaker_value:set_markup(val .. "%")
	end)

	audio:connect_signal("default-sink::mute", function(_, mute)
		if mute then
			speaker_icon:set_markup(text_icons.vol_off)
			speaker_slider:set_bar_active_color(beautiful.fg_alt)
			speaker_slider:set_handle_border_color(beautiful.fg_alt)
		else
			speaker_icon:set_markup(text_icons.vol_on)
			speaker_slider:set_bar_active_color(beautiful.ac)
			speaker_slider:set_handle_border_color(beautiful.ac)
		end
	end)

	speaker_slider:buttons {
		awful.button({}, 1, function()
			gtimer.delayed_call(function()
				speaker_value:set_markup(tostring(speaker_slider:get_value() * 5) .. "%")
				audio:set_default_sink_volume(speaker_slider:get_value() * 5)
			end)
		end)
	}

	speaker_mute:connect_signal("mouse::enter", function()
		speaker_mute:set_bg(beautiful.bg_urg)
	end)

	speaker_mute:connect_signal("mouse::leave", function()
		speaker_mute:set_bg(nil)
	end)

	speaker_mute:buttons {
		awful.button({}, 1, function()
			audio:toggle_default_sink_mute()
			audio:get_default_sink_data()
		end)
	}

	local microphone_mute = ret:get_children_by_id("microphone-mute-button")[1]
	local microphone_icon = ret:get_children_by_id("microphone-mute-button-icon")[1]
	local microphone_slider = ret:get_children_by_id("microphone-slider")[1]
	local microphone_value = ret:get_children_by_id("microphone-volume-value")[1]

	audio:connect_signal("default-source::volume", function(_, val)
		microphone_slider:set_value(tonumber(val) / 5)
		microphone_value:set_markup(val .. "%")
	end)

	audio:connect_signal("default-source::mute", function(_, mute)
		if mute then
			microphone_icon:set_markup(text_icons.mic_off)
			microphone_slider:set_bar_active_color(beautiful.fg_alt)
			microphone_slider:set_handle_border_color(beautiful.fg_alt)
		else
			microphone_icon:set_markup(text_icons.mic_on)
			microphone_slider:set_bar_active_color(beautiful.ac)
			microphone_slider:set_handle_border_color(beautiful.ac)
		end
	end)

	microphone_slider:buttons {
		awful.button({}, 1, function()
			gtimer.delayed_call(function()
				microphone_value:set_markup(tostring(microphone_slider:get_value() * 5) .. "%")
				audio:set_default_source_volume(microphone_slider:get_value() * 5)
			end)
		end)
	}

	microphone_mute:connect_signal("mouse::enter", function()
		microphone_mute:set_bg(beautiful.bg_urg)
	end)

	microphone_mute:connect_signal("mouse::leave", function()
		microphone_mute:set_bg(nil)
	end)

	microphone_mute:buttons {
		awful.button({}, 1, function()
			audio:toggle_default_source_mute()
			audio:get_default_source_data()
		end)
	}

	return ret
end

return setmetatable({ new = new }, { __call = new })
