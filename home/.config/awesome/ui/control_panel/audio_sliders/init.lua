local awful = require("awful")
local wibox = require("wibox")
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
			margins = {
				left = dpi(20), right = dpi(20),
				top = dpi(10), bottom = dpi(10)
			},
			{
				layout = wibox.layout.fixed.vertical,
				{
					layout = wibox.layout.fixed.horizontal,
					fill_space = true,
					spacing = dpi(20),
					{
						id = "speaker-icon",
						widget = wibox.widget.textbox,
						align = "center"
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
						id = "speaker-value",
						widget = wibox.widget.textbox,
						align = "center"
					}
				},
				{
					layout = wibox.layout.fixed.horizontal,
					fill_space = true,
					spacing = dpi(20),
					{
						id = "microphone-icon",
						widget = wibox.widget.textbox,
						align = "center"
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
						id = "microphone-value",
						widget = wibox.widget.textbox,
						align = "center"
					}
				}
			}
		}
	}

	local speaker_icon = ret:get_children_by_id("speaker-icon")[1]
	local speaker_slider = ret:get_children_by_id("speaker-slider")[1]
	local speaker_value = ret:get_children_by_id("speaker-value")[1]

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

	speaker_slider:connect_signal("property::value", function(_, new_value)
		speaker_value:set_markup(tostring(new_value * 5) .. "%")
		audio:set_default_sink_volume(new_value * 5)
	end)

	speaker_icon:buttons {
		awful.button({}, 1, function()
			audio:toggle_default_sink_mute()
			audio:get_default_sink_data()
		end)
	}

	local microphone_icon = ret:get_children_by_id("microphone-icon")[1]
	local microphone_slider = ret:get_children_by_id("microphone-slider")[1]
	local microphone_value = ret:get_children_by_id("microphone-value")[1]

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

	microphone_slider:connect_signal("property::value", function(_, new_value)
		microphone_value:set_markup(tostring(new_value * 5) .. "%")
		audio:set_default_source_volume(new_value * 5)
	end)

	microphone_icon:buttons {
		awful.button({}, 1, function()
			audio:toggle_default_source_mute()
			audio:get_default_source_data()
		end)
	}

	return ret
end

return setmetatable({
	new = new
}, {
	__call = new
})
