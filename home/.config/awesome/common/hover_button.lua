local wibox = require("wibox")
local gtable = require("gears.table")
local beautiful = require("beautiful")

local button = {}

function button:set_text(text)
	self:get_children_by_id("text_comp")[1]:set_markup(text)
end

function button:set_bg_normal(color)
	local wp = self._private
	wp.bg_normal = color
end

function button:set_fg_normal(color)
	local wp = self._private
	wp.fg_normal = color
end

function button:set_bg_hover(color)
	local wp = self._private
	wp.bg_hover = color
end

function button:set_fg_hover(color)
	local wp = self._private
	wp.fg_hover = color
end

local function new(args)
	args = args or {}
	local widget

	widget = wibox.widget {
		widget = wibox.container.background,
		shape = args.shape,
		buttons = args.buttons,
		forced_width = args.forced_width,
		forced_height = args.forced_height,
		border_width = args.border_width or 0,
		border_color = args.border_color or
			beautiful.bg_urg or "#3d3d3d",
		bg = args.bg_normal or
			beautiful.bg_alt or "#272727",
		fg = args.fg_normal or
			beautiful.fg or "#ffffff",
		{
			widget = wibox.container.margin,
			margins = args.margins or 0,
			{
				id = "text_comp",
				widget = wibox.widget.textbox,
				font = args.font or beautiful.font,
				align = args.align or "center",
				markup = args.markup or args.text or ""
			}
		}
	}

	gtable.crush(widget, button, true)

	local wp = widget._private
	wp.border_normal = args.border_color or
		beautiful.bg_urg or "#3d3d3d"
	wp.border_hover = args.border_hover or
		beautiful.fg_alt or "#ffffff"
	wp.bg_hover = args.bg_hover or
		beautiful.ac or "#bcbcbc"
	wp.fg_hover = args.fg_hover or
		beautiful.bg or "#000000"
	wp.bg_normal = args.bg_normal or
		beautiful.bg_alt or "#272727"
	wp.fg_normal = args.fg_normal or
		beautiful.fg or "#ffffff"

	widget:connect_signal("mouse::enter", function(w)
		w:set_border_color(wp.border_hover)
		w:set_bg(wp.bg_hover)
		w:set_fg(wp.fg_hover)
	end)

	widget:connect_signal("mouse::leave", function(w)
		w:set_border_color(wp.border_normal)
		w:set_bg(wp.bg_normal)
		w:set_fg(wp.fg_normal)
	end)

	widget:connect_signal("button::press", function(w)
		w:set_border_color(wp.border_normal)
		w:set_bg(wp.bg_normal)
		w:set_fg(wp.fg_normal)
	end)

	return widget
end

return setmetatable(button, {
	__call = function(_, ...)
		return new(...)
	end
})
