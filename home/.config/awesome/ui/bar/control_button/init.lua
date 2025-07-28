local awful = require("awful")
local beautiful = require("beautiful")
local common = require("common")
local shape = require("lib.shape")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local Control_panel = require("ui.control_panel")

return function()
	return common.button {
		buttons = {
			awful.button({}, 1, function()
				Control_panel.get_default():toggle()
			end)
		},
		forced_width = dpi(31),
		bg_normal = beautiful.bg_alt,
		bg_hover = beautiful.bg_urg,
		fg_normal = beautiful.fg,
		fg_hover = beautiful.fg,
		shape = shape.rrect(dpi(8)),
		label = text_icons.sliders,
	}
end
