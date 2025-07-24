local awful = require("awful")
local wibox = require("wibox")
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
						forced_width = dpi(330),
						forced_height = dpi(40),
						{
							id = "speaker-slider",
							widget = common.scale,
							trough_height = dpi(2),
							trough_color = beautiful.bg_urg,
							trough_shape = shape.rbar(),
							highlight_height = dpi(2),
							highlight_margins = dpi(8),
							highlight_shape = shape.rbar(),
							slider_color = beautiful.bg_alt,
							slider_border_width = dpi(2),
							slider_border_color = beautiful.ac,
							slider_margins = beautiful.rounded and 0 or dpi(10),
							slider_shape = shape.crcl(9)
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
						forced_width = dpi(330),
						forced_height = dpi(40),
						{
							id = "microphone-slider",
							widget = common.scale,
							trough_height = dpi(2),
							trough_color = beautiful.bg_urg,
							trough_shape = shape.rbar(),
							highlight_height = dpi(2),
							highlight_shape = shape.rbar(),
							slider_color = beautiful.bg_alt,
							slider_border_width = dpi(2),
							slider_border_color = beautiful.ac,
							slider_margins = beautiful.rounded and 0 or dpi(10),
							slider_shape = shape.crcl(9)
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
		speaker_slider:set_value(tonumber(val))
		speaker_value_text:set_markup(val .. "%")
	end

	wp.on_sink_mute = function(_, mute)
		if mute then
			speaker_mute_button:set_label(text_icons.vol_off)
			speaker_slider:set_highlight_color(beautiful.fg_alt)
			speaker_slider:set_slider_border_color(beautiful.fg_alt)
		else
			speaker_mute_button:set_label(text_icons.vol_on)
			speaker_slider:set_highlight_color(beautiful.ac)
			speaker_slider:set_slider_border_color(beautiful.ac)
		end
	end

	wp.on_speaker_slider_value = function()
		speaker_value_text:set_markup(tostring(speaker_slider:get_value()) .. "%")
	end

	wp.on_speaker_slider_dragging_stopped = function()
		audio:set_default_sink_volume(speaker_slider:get_value())
	end

	wp.on_source_volume = function(_, val)
		microphone_slider:set_value(tonumber(val))
		microphone_value_text:set_markup(val .. "%")
	end

	wp.on_source_mute = function(_, mute)
		if mute then
			microphone_mute_button:set_label(text_icons.mic_off)
			microphone_slider:set_highlight_color(beautiful.fg_alt)
			microphone_slider:set_slider_border_color(beautiful.fg_alt)
		else
			microphone_mute_button:set_label(text_icons.mic_on)
			microphone_slider:set_highlight_color(beautiful.ac)
			microphone_slider:set_slider_border_color(beautiful.ac)
		end
	end

	wp.on_microphone_slider_value = function()
		microphone_value_text:set_markup(tostring(microphone_slider:get_value()) .. "%")
	end

	wp.on_microphone_slider_dragging_stopped = function()
		audio:set_default_source_volume(microphone_slider:get_value())
	end

	audio:connect_signal("default-sink::volume", wp.on_sink_volume)
	audio:connect_signal("default-sink::mute", wp.on_sink_mute)
	audio:connect_signal("default-source::volume", wp.on_source_volume)
	audio:connect_signal("default-source::mute", wp.on_source_mute)

	speaker_slider:connect_signal("property::value", wp.on_speaker_slider_value)
	speaker_slider:connect_signal("dragging-stopped", wp.on_speaker_slider_dragging_stopped)
	microphone_slider:connect_signal("property::value", wp.on_microphone_slider_value)
	microphone_slider:connect_signal("dragging-stopped", wp.on_microphone_slider_dragging_stopped)

	speaker_mute_button:buttons {
		awful.button({}, 1, function()
			audio:toggle_default_sink_mute()
			audio:get_default_sink_data()
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
