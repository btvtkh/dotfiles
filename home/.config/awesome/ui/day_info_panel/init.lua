local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local common = require("common")
local dpi = beautiful.xresources.apply_dpi
local capi = { screen = screen }
local weather_applet = require("ui.day_info_panel.weather_applet")

local day_info = {}

function day_info:show()
	local wp = self._private
	if wp.shown then return end
	wp.shown = true
	self.visible = true
	self.widget:get_children_by_id("calendar")[1]:set_current_date()
	self:emit_signal("property::shown", wp.shown)
end

function day_info:hide()
	local wp = self._private
	if not wp.shown then return end
	wp.shown = false
	self.visible = false
	self:emit_signal("property::shown", wp.shown)
end

function day_info:toggle()
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
		bg = "#00000000",
		placement = function(d)
			awful.placement.bottom_right(d, {
				honor_workarea = true,
				margins = beautiful.useless_gap
			})
		end,
		widget = wibox.widget {
			widget = wibox.container.background,
			bg = beautiful.bg,
			border_width = beautiful.border_width,
			border_color = beautiful.border_color_normal,
			shape = beautiful.rrect(dpi(20)),
			{
				widget = wibox.container.margin,
				margins = dpi(12),
				{
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(6),
					weather_applet(),
					{
						id = "calendar",
						widget = common.calendar {
							sun_start = false,
							shape = beautiful.rrect(dpi(10)),
							day_shape = beautiful.rrect(dpi(8))
						}
					}
				}
			}
		}
	}

	gtable.crush(ret, day_info, true)
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
