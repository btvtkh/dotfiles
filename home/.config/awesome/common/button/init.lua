local wibox = require("wibox")
local gtable = require("gears.table")
local beautiful = require("beautiful")

local button = {}

function button:set_label(label)
	self:get_children_by_id("label-role")[1]:set_markup(label)
end

function button:set_bg_normal(color)
	local wp = self._private
	wp.bg_normal = color
	self:set_bg(color)
end

function button:set_fg_normal(color)
	local wp = self._private
	wp.fg_normal = color
	self:set_fg(color)
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

	args.border_normal = args.border_color or beautiful.bg_urg
	args.border_hover = args.border_hover or beautiful.fg_alt
	args.bg_hover = args.bg_hover or beautiful.ac
	args.fg_hover = args.fg_hover or beautiful.bg
	args.bg_normal = args.bg_normal or beautiful.bg_alt
	args.fg_normal = args.fg_normal or beautiful.fg
	args.align = args.align or "center"
	args.font = args.font or beautiful.font
	args.label = args.label or ""

	local ret = wibox.widget {
		widget = wibox.container.background,
		shape = args.shape,
		buttons = args.buttons,
		forced_width = args.forced_width,
		forced_height = args.forced_height,
		border_width = args.border_width,
		border_color = args.border_color_normal,
		bg = args.bg_normal,
		fg = args.fg_normal,
		{
			widget = wibox.container.margin,
			margins = args.margins,
			{
				id = "label-role",
				widget = wibox.widget.textbox,
				font = args.font,
				align = args.align,
				markup = args.label
			}
		}
	}

	gtable.crush(ret._private, args)
	gtable.crush(ret, button, true)

	local wp = ret._private

	wp.on_mouse_enter = function(w)
		w:set_border_color(wp.border_hover)
		w:set_bg(wp.bg_hover)
		w:set_fg(wp.fg_hover)
	end

	wp.on_mouse_leave = function(w)
		w:set_border_color(wp.border_normal)
		w:set_bg(wp.bg_normal)
		w:set_fg(wp.fg_normal)
	end

	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	return ret
end

return setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })
