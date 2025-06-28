local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local common = require("common")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client }
local menu = require("ui.menu").get_default()
local launcher = require("ui.launcher").get_default()
local control_panel = require("ui.control_panel").get_default()
local day_info_panel = require("ui.day_info_panel").get_default()
local modkey = "Mod4"

local bar = {}

local function launcher_button()
	return common.hover_button {
		buttons = {
			awful.button({}, 1, function()
				launcher:toggle()
			end)
		},
		forced_width = dpi(31),
		bg_normal = beautiful.bg_alt,
		bg_hover = beautiful.bg_urg,
		fg_normal = beautiful.fg,
		fg_hover = beautiful.fg,
		shape = beautiful.rrect(dpi(8)),
		label = text_icons.menu,
	}
end

local function control_panel_button()
	return common.hover_button {
		buttons = {
			awful.button({}, 1, function()
				control_panel:toggle()
			end)
		},
		forced_width = dpi(31),
		bg_normal = beautiful.bg_alt,
		bg_hover = beautiful.bg_urg,
		fg_normal = beautiful.fg,
		fg_hover = beautiful.fg,
		shape = beautiful.rrect(dpi(8)),
		label = text_icons.sliders,
	}
end

local function time()
	local widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		buttons = {
			awful.button({}, 1, function()
				day_info_panel:toggle()
			end)
		},
		{
			widget = wibox.container.margin,
			margins = { left = dpi(8), right = dpi(8) },
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(8),
				{
					widget = wibox.widget.textclock,
					format = "%d %b, %a"
				},
				{
					widget = wibox.container.margin,
					forced_height = 1,
					forced_width = beautiful.separator_thickness,
					margins = { top = dpi(6), bottom = dpi(6) },
					{
						id = "separator",
						widget = wibox.widget.separator,
						orientation = "vertical"
					}
				},
				{
					widget = wibox.widget.textclock,
					format = "%H:%M"
				}
			}
		}
	}

	widget:connect_signal("mouse::enter", function(w)
		w:set_bg(beautiful.bg_urg)
		w:get_children_by_id("separator")[1]:set_color(beautiful.fg_alt)
	end)

	widget:connect_signal("mouse::leave", function(w)
		w:set_bg(beautiful.bg_alt)
		w:get_children_by_id("separator")[1]:set_color(beautiful.bg_urg)
	end)

	return widget
end

local function tray()
	local visibility = false

	local systray = wibox.widget {
		widget = wibox.container.margin,
		margins = { top = dpi(4), bottom = dpi(4) },
		{
			widget = wibox.widget.systray
		}
	}

	local widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		{
			widget = wibox.container.margin,
			margins = { left = dpi(8), right = dpi(8) },
			{
				id = "items-layout",
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(8),
				{
					id = "reveal-button",
					widget = wibox.widget.textbox,
					markup = text_icons.arrow_left
				}
			}
		}
	}

	local items_layout = widget:get_children_by_id("items-layout")[1]
	local reveal_button = widget:get_children_by_id("reveal-button")[1]

	reveal_button:buttons {
		awful.button({}, 1, function()
			if not visibility then
				visibility = true
				items_layout:insert(2, systray)
				reveal_button:set_markup(text_icons.arrow_right)
			else
				visibility = false
				items_layout:remove(2)
				reveal_button:set_markup(text_icons.arrow_left)
			end
		end)
	}

	widget:connect_signal("mouse::enter", function(w)
		beautiful.bg_systray = beautiful.bg_urg
		w:set_bg(beautiful.bg_urg)
	end)

	widget:connect_signal("mouse::leave", function(w)
		beautiful.bg_systray = beautiful.bg_alt
		w:set_bg(beautiful.bg_alt)
	end)

	return widget
end

local function kblayout()
	local widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		{
			widget = awful.widget.keyboardlayout {}
		}
	}

	widget:connect_signal("mouse::enter", function(w)
		w:set_bg(beautiful.bg_urg)
	end)

	widget:connect_signal("mouse::leave", function(w)
		w:set_bg(beautiful.bg_alt)
	end)

	return widget
end

local function layoutbox(s)
	local widget = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		buttons = {
			awful.button({ }, 1, function()
				awful.layout.inc(1)
			end)
		},
		{
			widget = wibox.container.margin,
			margins = dpi(7),
			{
				widget = awful.widget.layoutbox {
					screen = s
				}
			}
		}
	}

	widget:connect_signal("mouse::enter", function(w)
		w:set_bg(beautiful.bg_urg)
	end)

	widget:connect_signal("mouse::leave", function(w)
		w:set_bg(beautiful.bg_alt)
	end)

	return widget
end

local function taglist(s)
	local taglist_widget = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = {
			awful.button({}, 1, function(t)
				t:view_only()
			end),
			awful.button({}, 3, function(t)
				awful.tag.viewtoggle(t)
			end),
			awful.button({}, 4, function(t)
				awful.tag.viewprev(t.screen)
			end),
			awful.button({}, 5, function(t)
				awful.tag.viewnext(t.screen)
			end),
			awful.button({ modkey }, 1, function(t)
				if capi.client.focus then
					capi.client.focus:move_to_tag(t)
				end
			end),
			awful.button({ modkey }, 3, function(t)
				if capi.client.focus then
					capi.client.focus:toggle_tag(t)
				end
			end),
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(2)
		},
		widget_template = {
			id = "t-background",
			widget = wibox.container.background,
			shape = beautiful.rrect(dpi(5)),
			{
				widget = wibox.container.margin,
				margins = { left = dpi(7), right = dpi(7) },
				{
					id = "t-text",
					widget = wibox.widget.textbox,
					align = "center"
				}
			}
		}
	}

	local function t_callback(tw, t)
		local t_background = tw:get_children_by_id("t-background")[1]
		local t_text = tw:get_children_by_id("t-text")[1]

		t_text.markup = t.index

		if t.selected then
			t_background:set_bg(beautiful.ac)
			t_background:set_fg(beautiful.bg)
		elseif #t:clients() > 0 then
			t_background:set_bg(beautiful.bg_alt)
			t_background:set_fg(beautiful.fg)
		else
			t_background:set_bg(beautiful.bg_alt)
			t_background:set_fg(beautiful.fg_alt)
		end

		for _, c in ipairs(t:clients()) do
			if c.urgent then
				t_background:set_fg(beautiful.red)
				break
			end
		end
	end

	taglist_widget.widget_template.create_callback = function(tw, t)
		t_callback(tw, t)
		local t_background = tw:get_children_by_id("t-background")[1]

		tw:connect_signal("mouse::enter", function()
			if not t.selected then
				t_background:set_bg(beautiful.bg_urg)
			end
		end)

		tw:connect_signal("mouse::leave", function()
			if not t.selected then
				t_background:set_bg(beautiful.bg_alt)
			end
		end)
	end

	taglist_widget.widget_template.update_callback = function(tw, t)
		t_callback(tw, t)
	end

	return wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.bg_alt,
		shape = beautiful.rrect(dpi(8)),
		{
			widget = wibox.container.margin,
			margins = dpi(4),
			{
				widget = taglist_widget
			}
		}
	}
end

local function tasklist(s)
	local tasklist_widget = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({ }, 1, function(c)
				c:activate { context = "tasklist", action = "toggle_minimization" }
				menu:hide()
			end),
			awful.button({ }, 3, function(c)
				menu:toggle_client_menu(c)
			end)
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
		},
		widget_template = {
			id = "c-background",
			widget = wibox.container.background,
			shape = beautiful.rrect(dpi(8)),
			{
				layout = wibox.layout.stack,
				{
					widget = wibox.container.margin,
					margins = { left = dpi(8), right = dpi(8) },
					{
						widget = wibox.container.constraint,
						strategy = "max",
						width = dpi(150),
						{
							id = "c-text",
							widget = wibox.widget.textbox,
							align = "center"
						}
					}
				},
				{
					layout = wibox.layout.align.vertical,
					nil,
					nil,
					{
						widget = wibox.container.margin,
						margins = { left = dpi(12), right = dpi(12) },
						{
							id = "c-pointer",
							widget = wibox.container.background,
							shape = beautiful.prrect(true, true, false, false, dpi(2)),
							bg = beautiful.ac
						}
					}
				}
			}
		}
	}

	local function c_callback(tw, c)
		local c_background = tw:get_children_by_id("c-background")[1]
		local c_pointer = tw:get_children_by_id("c-pointer")[1]
		local c_text = tw:get_children_by_id("c-text")[1]

		c_text:set_markup((c.class ~= nil and c.class ~= "") and c.class or "untitled")
		c_background:set_bg(beautiful.bg_alt)

		if c.minimized then
			c_background:set_fg(beautiful.fg_alt)
		else
			c_background:set_fg(beautiful.fg)
		end

		if c.active then
			c_pointer:set_forced_height(dpi(3))
		else
			c_pointer:set_forced_height(0)
		end
	end

	tasklist_widget.widget_template.create_callback = function(tw, c)
		c_callback(tw, c)

		tw:connect_signal("mouse::enter", function(w)
			w:set_bg(beautiful.bg_urg)
		end)

		tw:connect_signal("mouse::leave", function(w)
			w:set_bg(beautiful.bg_alt)
		end)
	end

	tasklist_widget.widget_template.update_callback = function(tw, c)
		c_callback(tw, c)
	end

	return tasklist_widget
end

function bar.create_secondary(s)
	return awful.wibar {
		position = "bottom",
		ontop = true,
		screen = s,
		height = dpi(45),
		bg = "#00000000",
		widget = {
			widget = wibox.container.background,
			bg = beautiful.border_color_normal,
			{
				widget = wibox.container.margin,
				margins = { top = beautiful.border_width },
				{
					widget = wibox.container.background,
					bg = beautiful.bg,
					fg = beautiful.fg,
					{
						layout = wibox.layout.fixed.horizontal,
						{
							widget = wibox.container.margin,
							margins = dpi(7),
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = dpi(5),
								--layoutbox(s),
								taglist(s),
								tasklist(s)
							}
						}
					}
				}
			}
		}
	}
end

function bar.create_primary(s)
	return awful.wibar {
		position = "bottom",
		ontop = true,
		screen = s,
		height = dpi(45),
		bg = "#00000000",
		widget = {
			widget = wibox.container.background,
			bg = beautiful.border_color_normal,
			{
				widget = wibox.container.margin,
				margins = { top = beautiful.border_width },
				{
					widget = wibox.container.background,
					bg = beautiful.bg,
					fg = beautiful.fg,
					{
						layout = wibox.layout.align.horizontal,
						nil,
						{
							widget = wibox.container.margin,
							margins = dpi(7),
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = dpi(5),
								launcher_button(),
								--layoutbox(s),
								taglist(s),
								tasklist(s)
							}
						},
						{
							widget = wibox.container.margin,
							margins = {
								top = dpi(7), bottom = dpi(7),
								left = 0, right = dpi(7)
							},
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = dpi(5),
								tray(),
								kblayout(),
								time(),
								control_panel_button()
							}
						}
					}
				}
			}
		}
	}
end

return bar
