local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local shape = require("lib.shape")
local dpi = beautiful.xresources.apply_dpi

local switch = {}

function switch:get_checked()
	return self._private.checked
end

function switch:set_checked(checked)
	local wp = self._private
	local handle_layout = self:get_children_by_id("handle-layout")[1]
	local handle_container = self:get_children_by_id("handle-container")[1]
	local handle_background = self:get_children_by_id("handle-background")[1]

	wp.checked = checked

	handle_layout:move_widget(handle_container, function(g, a)
		return {
			x = checked and a.parent.width - g.width or 0,
			y = 0
		}
	end)

	self:set_bg(wp.checked and wp.bg_checked or wp.bg_normal)
	handle_background:set_bg(wp.checked and wp.handle_bg_checked or wp.handle_bg_normal)
end

local function new(args)
	args = args or {}

	local ret = wibox.widget {
		widget = wibox.container.background,
		buttons = args.buttons,
		forced_width = args.forced_width or dpi(50),
		forced_height = args.forced_height or dpi(25),
		shape = args.shape or shape.rbar(),
		{
			id = "handle-layout",
			layout = wibox.layout.manual,
			{
				id = "handle-container",
				point = { x = 0, y = 0 },
				widget = wibox.container.margin,
				margins = args.margins or dpi(2),
				{
					widget = wibox.container.place,
					content_fill_vertical = true,
					{
						id = "handle-background",
						widget = wibox.container.background,
						forced_width = (args.forced_height or dpi(25)) - (args.margins or dpi(2))*2,
						shape = args.handle_shape or shape.crcl()
					}
				}
			}
		}
	}

	gtable.crush(ret, switch, true)
	local wp = ret._private
	local handle_background = ret:get_children_by_id("handle-background")[1]

	wp.checked = args.checked or false

	wp.bg_normal = args.bg_normal or beautiful.bg_urg
	wp.bg_hover = args.bg_hover or beautiful.fg_alt
	wp.bg_checked = args.bg_checked or beautiful.ac
	wp.handle_bg_normal = args.handle_bg_normal or beautiful.bg_alt
	wp.handle_bg_hover = args.handle_bg_hover or beautiful.bg_alt
	wp.handle_bg_checked = args.handle_bg_checked or beautiful.bg_alt

	wp.on_mouse_enter = function()
		ret:set_bg(wp.bg_hover)
		handle_background:set_bg(wp.handle_bg_hover)
	end

	wp.on_mouse_leave = function()
		ret:set_bg(wp.checked and wp.bg_checked or wp.bg_normal)
		handle_background:set_bg(wp.checked and wp.handle_bg_checked or wp.handle_bg_normal)
	end

	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	ret:set_bg(wp.checked and wp.bg_checked or wp.bg_normal)
	handle_background:set_bg(wp.checked and wp.handle_bg_checked or wp.handle_bg_normal)

	return ret
end

return setmetatable(
	{ new = new },
	{
		__call = function(_, ...)
			return new(...)
		end
	}
)
