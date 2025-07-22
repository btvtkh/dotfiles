local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local common = require("common")
local shape = require("lib.shape")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local audio = require("service.audio").get_default()

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = shape.rrect(dpi(13)),
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
						widget = common.button {
							forced_width = dpi(40),
							forced_height = dpi(40),
							shape = shape.rrect(dpi(8)),
							fg_hover = beautiful.fg,
							bg_hover = beautiful.bg_urg
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
							handle_border_width = dpi(2),
							handle_margins = { top = dpi(9), bottom = dpi(9) },
							bar_color = beautiful.bg_urg,
							handle_color = beautiful.bg_alt,
							handle_border_color = beautiful.ac,
							handle_shape = shape.crcl(9),
							bar_shape = shape.rbar()
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
						widget = common.button {
							forced_width = dpi(40),
							forced_height = dpi(40),
							shape = shape.rrect(dpi(8)),
							fg_hover = beautiful.fg,
							bg_hover = beautiful.bg_urg
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
							handle_border_width = dpi(2),
							handle_margins = { top = dpi(9), bottom = dpi(9) },
							bar_color = beautiful.bg_urg,
							handle_color = beautiful.bg_alt,
							handle_border_color = beautiful.ac,
							handle_shape = shape.crcl(9),
							bar_shape = shape.rbar()
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

	local wp = ret._private
	local speaker_mute_button = ret:get_children_by_id("speaker-mute-button")[1]
	local speaker_slider = ret:get_children_by_id("speaker-slider")[1]
	local speaker_value_text = ret:get_children_by_id("speaker-volume-value")[1]
	local microphone_mute_button = ret:get_children_by_id("microphone-mute-button")[1]
	local microphone_slider = ret:get_children_by_id("microphone-slider")[1]
	local microphone_value_text = ret:get_children_by_id("microphone-volume-value")[1]

	wp.on_sink_volume = function(_, val)
		speaker_slider:set_value(tonumber(val) / 5)
		speaker_value_text:set_markup(val .. "%")
	end

	wp.on_sink_mute = function(_, mute)
		if mute then
			speaker_mute_button:set_label(text_icons.vol_off)
			speaker_slider:set_bar_active_color(beautiful.fg_alt)
			speaker_slider:set_handle_border_color(beautiful.fg_alt)
		else
			speaker_mute_button:set_label(text_icons.vol_on)
			speaker_slider:set_bar_active_color(beautiful.ac)
			speaker_slider:set_handle_border_color(beautiful.ac)
		end
	end

	wp.on_source_volume = function(_, val)
		microphone_slider:set_value(tonumber(val) / 5)
		microphone_value_text:set_markup(val .. "%")
	end

	wp.on_source_mute = function(_, mute)
		if mute then
			microphone_mute_button:set_label(text_icons.mic_off)
			microphone_slider:set_bar_active_color(beautiful.fg_alt)
			microphone_slider:set_handle_border_color(beautiful.fg_alt)
		else
			microphone_mute_button:set_label(text_icons.mic_on)
			microphone_slider:set_bar_active_color(beautiful.ac)
			microphone_slider:set_handle_border_color(beautiful.ac)
		end
	end

	audio:connect_signal("default-sink::volume", wp.on_sink_volume)
	audio:connect_signal("default-sink::mute", wp.on_sink_mute)
	audio:connect_signal("default-source::volume", wp.on_source_volume)
	audio:connect_signal("default-source::mute", wp.on_source_mute)

	speaker_slider:buttons {
		awful.button({}, 1, function()
			gtimer.delayed_call(function()
				speaker_value_text:set_markup(tostring(speaker_slider:get_value() * 5) .. "%")
				audio:set_default_sink_volume(speaker_slider:get_value() * 5)
			end)
		end)
	}

	speaker_mute_button:buttons {
		awful.button({}, 1, function()
			audio:toggle_default_sink_mute()
			audio:get_default_sink_data()
		end)
	}

	microphone_slider:buttons {
		awful.button({}, 1, function()
			gtimer.delayed_call(function()
				microphone_value_text:set_markup(tostring(microphone_slider:get_value() * 5) .. "%")
				audio:set_default_source_volume(microphone_slider:get_value() * 5)
			end)
		end)
	}

	microphone_mute_button:buttons {
		awful.button({}, 1, function()
			audio:toggle_default_source_mute()
			audio:get_default_source_data()
		end)
	}

	return ret
end

return setmetatable({ new = new }, { __call = new })
