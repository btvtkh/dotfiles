local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local common = require("common")
local shape = require("lib.shape")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client }
local menu = require("ui.menu").get_default()
awful.titlebar.enable_tooltip = false

local function new(c)
	if c.requests_no_titlebar then return end

	local ret = awful.titlebar(c, {
		size = dpi(35),
		position = "top"
	})

	local close_button = common.button {
		margins = dpi(3),
		bg_normal = c.active and beautiful.red or beautiful.bg_urg,
		bg_hover = c.active and beautiful.red or beautiful.bg_urg,
		fg_normal = "#00000000",
		fg_hover = beautiful.bg,
		shape = shape.crcl(),
		font = beautiful.font_h0,
		label = text_icons.cross
	}

	local max_button = common.button {
		margins = dpi(3),
		bg_normal = c.active and beautiful.yellow or beautiful.bg_urg,
		bg_hover = c.active and beautiful.yellow or beautiful.bg_urg,
		fg_normal = "#00000000",
		fg_hover = beautiful.bg,
		shape = shape.crcl(),
		font = beautiful.font_h0,
		label = c.maximized and text_icons.shrink or text_icons.stretch
	}

	local min_button = common.button {
		margins = dpi(3),
		bg_normal = c.active and beautiful.green or beautiful.bg_urg,
		bg_hover = c.active and beautiful.green or beautiful.bg_urg,
		fg_normal = "#00000000",
		fg_hover = beautiful.bg,
		shape = shape.crcl(),
		font = beautiful.font_h0,
		label = text_icons.dash
	}

	c:connect_signal("property::maximized", function()
		max_button:set_fg("#00000000")

		if c.maximized then
			max_button:set_label(text_icons.shrink)
		else
			max_button:set_label(text_icons.stretch)
		end
	end)

	c:connect_signal("property::minimized", function()
		min_button:set_fg("#00000000")
	end)

	c:connect_signal("property::active", function()
		close_button:set_bg_normal(c.active and beautiful.red or beautiful.bg_urg)
		close_button:set_bg_hover(c.active and beautiful.red or beautiful.bg_urg)
		max_button:set_bg_normal(c.active and beautiful.yellow or beautiful.bg_urg)
		max_button:set_bg_hover(c.active and beautiful.yellow or beautiful.bg_urg)
		min_button:set_bg_normal(c.active and beautiful.green or beautiful.bg_urg)
		min_button:set_bg_hover(c.active and beautiful.green or beautiful.bg_urg)

		if c.active then
			close_button:set_bg(beautiful.red)
			max_button:set_bg(beautiful.yellow)
			min_button:set_bg(beautiful.green)
		else
			close_button:set_bg(beautiful.bg_urg)
			max_button:set_bg(beautiful.bg_urg)
			min_button:set_bg(beautiful.bg_urg)
		end
	end)

	close_button:buttons {
		awful.button({}, 1, function()
			c:kill()
		end)
	}

	max_button:buttons {
		awful.button({}, 1, function()
			c.maximized = not c.maximized
			c:raise()
		end)
	}

	min_button:buttons {
		awful.button({}, 1, function()
			gtimer.delayed_call(function()
				c.minimized = true
			end)
		end)
	}

	local buttons = {
		awful.button({}, 1, function()
			capi.client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
		awful.button({}, 2, function()
			menu:toggle_client_menu(c)
		end),
		awful.button({}, 3, function()
			capi.client.focus = c
			c:raise()
			awful.mouse.client.resize(c)
		end)
	}

	ret:setup {
		layout = wibox.layout.align.horizontal,
		{
			widget = wibox.container.background,
			buttons = buttons
		},
		{
			widget = wibox.container.background,
			buttons = buttons
		},
		{
			widget = wibox.container.margin,
			margins = dpi(9),
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(9),
				min_button,
				max_button,
				close_button
			}
		}
	}

	return ret
end

return setmetatable(
	{ new = new },
	{
		__call = function (_, ...)
			return new(...)
		end
	}
)
