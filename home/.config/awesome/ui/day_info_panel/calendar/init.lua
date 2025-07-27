local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local beautiful = require("beautiful")
local common = require("common")
local shape = require("lib.shape")
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

local function wday_widget(index)
	return wibox.widget {
		widget = wibox.container.background,
		fg = index >= 6 and beautiful.red or beautiful.fg,
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

local function day_widget(day, is_current, is_another_month)
	local fg_color = ((is_current and beautiful.bg) or (is_another_month and beautiful.fg_alt)) or beautiful.fg
	local bg_color = is_current and beautiful.ac or nil

	return wibox.widget {
		widget = wibox.container.background,
		fg = fg_color,
		bg = bg_color,
		shape = shape.rrect(dpi(6)),
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
	local days_layout = self:get_children_by_id("days-layout")[1]
	local year_button = self:get_children_by_id("year-button")[1]
	days_layout:reset()

	wp.date = date

	local curr_date = os.date("*t")
	local firstday = os.date("*t", os.time({ year = date.year, month = date.month, day = 1 }))
	local lastday = os.date("*t", os.time({ year = date.year, month = date.month + 1, day = 0 }))
	local month_count = lastday.day
	local month_start = not wp.sun_start and hebr_format[firstday.wday] or firstday.wday
	local rows = math.max(5, math.min(6, 5 - (36 - (month_start + month_count))))
	local month_prev_lastday = os.date("*t", os.time({ year = date.year, month = date.month, day = 0 })).day
	local month_prev_count = month_start - 1
	local month_next_count = rows*7 - lastday.day - month_prev_count

	for day = month_prev_lastday - (month_prev_count - 1), month_prev_lastday, 1 do
		days_layout:add(day_widget(day, false, true))
	end

	for day = 1, month_count, 1 do
		local is_current = day == curr_date.day and date.month == curr_date.month and date.year == curr_date.year
		days_layout:add(day_widget(day, is_current, false))
	end

	for day = 1, month_next_count, 1 do
		days_layout:add(day_widget(day, false, true))
	end

	year_button:set_label(os.date("%B, %Y", os.time(date)))
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

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = shape.rrect(dpi(13)),
		{
			widget = wibox.container.margin,
			margins = dpi(15),
			{
				layout = wibox.layout.fixed.vertical,
				{
					layout = wibox.layout.align.horizontal,
					{
						id = "year-button",
						widget = common.button {
							forced_height = dpi(30),
							shape = shape.rrect(dpi(6)),
							margins = { left = dpi(7), right = dpi(7) },
							bg_normal = nil,
							bg_hover = beautiful.bg_urg,
							fg_normal = beautiful.fg,
							fg_hover = beautiful.fg
						}
					},
					nil,
					{
						widget = wibox.layout.fixed.horizontal,
						spacing = dpi(5),
						{
							id = "dec-button",
							widget = common.button {
								forced_width = dpi(30),
								forced_height = dpi(30),
								shape = shape.rrect(dpi(6)),
								bg_normal = nil,
								bg_hover = beautiful.bg_urg,
								fg_normal = beautiful.fg,
								fg_hover = beautiful.fg,
								label = text_icons.arrow_left
							}
						},
						{
							id = "inc-button",
							widget = common.button {
								forced_width = dpi(30),
								forced_height = dpi(30),
								shape = shape.rrect(dpi(6)),
								bg_normal = nil,
								bg_hover = beautiful.bg_urg,
								fg_normal = beautiful.fg,
								fg_hover = beautiful.fg,
								label = text_icons.arrow_right
							}
						}
					}
				},
				{
					id = "wdays-layout",
					layout = wibox.layout.flex.horizontal
				},
				{
					id = "days-layout",
					layout = wibox.layout.grid,
					forced_num_cols = 7,
					expand = true,
					forced_height = dpi(230)
				}
			}
		}
	}

	gtable.crush(ret, calendar, true)

	local wp = ret._private
	local wdays_layout = ret:get_children_by_id("wdays-layout")[1]
	local year_button = ret:get_children_by_id("year-button")[1]
	local dec_button = ret:get_children_by_id("dec-button")[1]
	local inc_button = ret:get_children_by_id("inc-button")[1]

	wp.sun_start = false

	for i = 1, 7 do
		wdays_layout:add(wp.sun_start and wday_widget(hebr_format[i]) or wday_widget(i))
	end

	year_button:buttons {
		awful.button({}, 1, function()
			ret:set_current_date()
		end)
	}

	dec_button:buttons {
		awful.button({}, 1, function()
			ret:inc(-1)
		end)
	}

	inc_button:buttons {
		awful.button({}, 1, function()
			ret:inc(1)
		end)
	}

	ret:set_current_date()

	return ret
end

return setmetatable({ new = new }, { __call = new })
