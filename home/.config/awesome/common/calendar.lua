local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local beautiful = require("beautiful")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi

local calendar = {}

local hebr_format = {
	[1] = 7,
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
	[7] = 6
}

local function wday_widget(self, index)
	local wp = self._private
	return wibox.widget {
		widget = wibox.container.background,
		fg = index >= 6 and wp.weekend_fg or wp.fg,
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_h0,
				markup = os.date("%a", os.time({
					year = 1,
					month = 1,
					day = index
				}))
			}
		}
	}
end

local function day_widget(self, day, is_current, is_another_month)
	local wp = self._private
	local fg_color = ((is_current and wp.current_day_fg) or
		(is_another_month and wp.another_month_fg)) or wp.day_fg
	local bg_color = ((is_current and wp.current_day_bg) or
		(is_another_month and wp.another_month_bg)) or wp.day_bg

	return wibox.widget {
		widget = wibox.container.background,
		fg = fg_color,
		bg = bg_color,
		shape = wp.day_shape,
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				widget = wibox.widget.textbox,
				align = "center",
				markup = day
			}
		}
	}
end

function calendar:set_date(date)
	local wp = self._private
	local days_layout = self:get_children_by_id("days_layout")[1]
	local title_textbox = self:get_children_by_id("title_textbox")[1]
	days_layout:reset()

	wp.date = date
	local curr_date = os.date("*t")
	local firstday = os.date("*t", os.time({
		year = date.year,
		month = date.month,
		day = 1
	}))
	local lastday = os.date("*t", os.time({
		year = date.year,
		month = date.month + 1,
		day = 0
	}))
	local month_count = lastday.day
	local month_start = not wp.sun_start and hebr_format[firstday.wday] or firstday.wday
	local rows = math.max(5, math.min(6, 5 - (36 - (month_start + month_count))))
	local month_prev_lastday = os.date("*t", os.time({
		year = date.year,
		month = date.month,
		day = 0
	})).day
	local month_prev_count = month_start - 1
	local month_next_count = rows*7 - lastday.day - month_prev_count

	title_textbox:set_markup(os.date("%B, %Y", os.time(date)))

	for day = month_prev_lastday - (month_prev_count - 1), month_prev_lastday, 1 do
		days_layout:add(day_widget(self, day, false, true))
	end

	for day = 1, month_count, 1 do
		local is_current = day == curr_date.day and date.month == curr_date.month and date.year == curr_date.year
		days_layout:add(day_widget(self, day, is_current, false))
	end

	for day = 1, month_next_count, 1 do
		days_layout:add(day_widget(self, day, false, true))
	end
end

function calendar:inc(dir)
	local wp = self._private
	local new_calendar_month = wp.date.month + dir
	self:set_date({
		year = wp.date.year,
		month = new_calendar_month,
		day = wp.date.day
	})
end

function calendar:set_current_date()
	self:set_date(os.date("*t"))
end

local function new(args)
	args = args or {}
	local widget

	widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = args.shape,
		{
			widget = wibox.container.margin,
			margins = args.margins or dpi(20),
			{
				layout = wibox.layout.fixed.vertical,
				{
					layout = wibox.layout.align.horizontal,
					{
						id = "title_background",
						widget = wibox.container.background,
						buttons = {
							awful.button({}, 1, function()
								widget:set_current_date()
							end)
						},
						{
							id = "title_textbox",
							widget = wibox.widget.textbox,
							align = "center"
						}
					},
					nil,
					{
						widget = wibox.layout.fixed.horizontal,
						spacing = dpi(20),
						{
							id = "dec_button",
							widget = wibox.container.background,
							buttons = {
								awful.button({}, 1, function()
									widget:inc(-1)
								end)
							},
							{
								widget = wibox.widget.textbox,
								markup = text_icons.arrow_up
							}
						},
						{
							id = "inc_button",
							widget = wibox.container.background,
							buttons = {
								awful.button({}, 1, function()
									widget:inc(1)
								end)
							},
							{
								widget = wibox.widget.textbox,
								markup = text_icons.arrow_down
							}
						}
					}
				},
				{
					id = "wdays_layout",
					layout = wibox.layout.flex.horizontal
				},
				{
					id = "days_layout",
					layout = wibox.layout.grid,
					forced_num_cols = 7,
					expand = true,
					forced_height = dpi(230)
				}
			}
		}
	}

	gtable.crush(widget, calendar, true)

	local wp = widget._private
	widget._private.sun_start = args.sun_start
	widget._private.margins = args.margins
	widget._private.shape = args.shape
	widget._private.day_shape = args.day_shape
	widget._private.bg = args.bg or beautiful.bg_alt
	widget._private.day_fg = args.day_fg or beautiful.fg
	widget._private.day_bg = args.day_bg or beautiful.bg_alt
	widget._private.current_day_fg = args.current_day_fg or beautiful.bg
	widget._private.current_day_bg = args.current_day_bg or beautiful.ac
	widget._private.current_month_fg = args.current_month_fg or beautiful.fg
	widget._private.current_month_bg = args.current_month_bg or beautiful.bg_alt
	widget._private.another_month_fg = args.another_month_fg or beautiful.fg_alt
	widget._private.another_month_bg = args.another_month_bg or beautiful.bg_alt
	widget._private.weekend_fg = args.weekend_fg or beautiful.red

	local wdays_layout = widget:get_children_by_id("wdays_layout")[1]

	for i = 1, 7 do
		wdays_layout:add(wp.sun_start and wday_widget(widget, hebr_format[i]) or wday_widget(widget, i))
	end

	local title_background = widget:get_children_by_id("title_background")[1]
	local dec_button = widget:get_children_by_id("dec_button")[1]
	local inc_button = widget:get_children_by_id("inc_button")[1]

	for _, item in ipairs({
		title_background,
		dec_button,
		inc_button
	}) do
		item:connect_signal("mouse::enter", function(w)
			w:set_fg(beautiful.ac)
		end)
		item:connect_signal("mouse::leave", function(w)
			w:set_fg(beautiful.fg)
		end)
		item:connect_signal("button::press", function(w)
			w:set_fg(beautiful.fg)
		end)
	end

	widget:set_current_date()

	return widget
end

return setmetatable(calendar, {
	__call = function(_, ...)
		return new(...)
	end
})
