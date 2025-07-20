local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local common = require("common")
local shape = require("lib.shape")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local network = require("service.network")
local nm_client = network.get_default()

local wifi_page = {}

local function create_ap_widget(self, ap)
	local ret = wibox.widget {
		widget = wibox.container.background,
		shape = shape.rrect(dpi(10)),
		{
			widget = wibox.container.margin,
			forced_height = dpi(50),
			margins = dpi(15),
			{
				layout = wibox.layout.align.horizontal,
				{
					widget = wibox.container.constraint,
					width = dpi(250),
					{
						id = "name",
						widget = wibox.widget.textbox
					}
				},
				nil,
				{
					id = "strength",
					widget = wibox.widget.textbox
				}
			}
		}
	}

	local wp = ret._private
	local name = ret:get_children_by_id("name")[1]
	local strength = ret:get_children_by_id("strength")[1]
	local ap_ssid = ap:get_ssid()
	local ap_strength = ap:get_strength()
	local is_active = ap:get_path() == nm_client.wireless:get_active_access_point_path()

	wp.is_active = is_active

	wp.on_mouse_enter = function()
		ret:set_bg(beautiful.bg_urg)
	end

	wp.on_mouse_leave = function()
		ret:set_bg(nil)
	end

	ret:connect_signal("mouse::enter", wp.on_mouse_enter)
	ret:connect_signal("mouse::leave", wp.on_mouse_leave)

	ret:buttons {
		awful.button({}, 1, function()
			self:open_ap_menu(ap)
		end)
	}

	name:set_markup(is_active and text_icons.check .. " " .. ap_ssid or ap_ssid)

	strength:set_markup(
		ap_strength > 70 and "▂▄▆█"
		or ap_strength > 45 and "▂▄▆"
		or ap_strength > 20 and "▂▄"
		or "▂"
	)

	return ret
end

function wifi_page:open_ap_menu(ap)
	local wp = self._private
	local aps_layout = self:get_children_by_id("access-points-layout")[1]
	local close_button = wp.ap_menu:get_children_by_id("close-button")[1]
	local title = wp.ap_menu:get_children_by_id("title")[1]
	local password_widget = wp.ap_menu:get_children_by_id("password-widget")[1]
	local password_input = wp.ap_menu:get_children_by_id("password-input")[1]
	local connect_disconnect_button = wp.ap_menu:get_children_by_id("connect-disconnect-button")[1]

	local obscure = true
	local auto_connect = true

	close_button:buttons {
		awful.button({}, 1, function()
			self:close_ap_menu()
		end)
	}

	title:set_markup(ap:get_ssid())

	if ap:get_path() ~= nm_client.wireless:get_active_access_point_path() then
		local obscure_icon = wp.ap_menu:get_children_by_id("obscure-icon")[1]
		local auto_connect_icon = wp.ap_menu:get_children_by_id("auto-connect-icon")[1]

		obscure_icon:set_markup(text_icons.eye_off)
		obscure_icon:buttons {
			awful.button({}, 1, function()
				obscure = not obscure
				password_input:set_obscure(obscure)
				obscure_icon:set_markup(obscure and text_icons.eye_off or text_icons.eye_on)
			end)
		}

		auto_connect_icon:set_markup(text_icons.check_on)
		auto_connect_icon:buttons {
			awful.button({}, 1, function()
				auto_connect = not auto_connect
				auto_connect_icon:set_markup(auto_connect and text_icons.check_on or text_icons.check_off)
			end)
		}

		connect_disconnect_button:set_label("Connect")
		connect_disconnect_button:buttons {
			awful.button({}, 1, function()
				nm_client:connect_access_point(ap, password_input:get_input(), auto_connect)
				self:close_ap_menu()
			end)
		}

		password_input:on_focused(function()
			password_input:set_input("")
			password_input:set_cursor_index(1)
		end)

		password_input:on_unfocused(function()
			self:close_ap_menu()
		end)

		password_input:on_executed(function(_, input)
			nm_client:connect_access_point(ap, input, auto_connect)
			self:close_ap_menu()
		end)

		password_widget.visible = true
		password_input:focus()
	else
		connect_disconnect_button:set_label("Disconnect")
		connect_disconnect_button:buttons {
			awful.button({}, 1, function()
				nm_client:disconnect_active_access_point()
				self:close_ap_menu()
			end)
		}

		password_widget.visible = false
	end

	aps_layout:reset()
	aps_layout:add(wp.ap_menu)
end

function wifi_page:close_ap_menu()
	local wp = self._private
	local aps_layout = self:get_children_by_id("access-points-layout")[1]
	local password_input = wp.ap_menu:get_children_by_id("password-input")[1]

	if nm_client:get_wireless_enabled() then
		password_input:unfocus()
		password_input:set_obscure(true)
		aps_layout:reset()
		for _, ap_widget in ipairs(wp.ap_widgets) do
			if ap_widget._private.is_active then
				aps_layout:insert(1, ap_widget)
			else
				aps_layout:add(ap_widget)
			end
		end
	end
end

function wifi_page:refresh()
	local wp = self._private
	wp.on_ap_list(nil, nil, nm_client.wireless:get_access_points())
	nm_client.wireless:request_scan()
end

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(8),
			{
				widget = wibox.container.background,
				forced_height = dpi(400),
				forced_width = dpi(400),
				{
					id = "access-points-layout",
					layout = wibox.layout.overflow.vertical,
					scrollbar_enabled = false,
					step = 40,
					spacing = dpi(3)
				}
			},
			{
				widget = wibox.container.background,
				forced_height = dpi(50),
				bg = beautiful.bg_alt,
				shape = shape.rrect(dpi(10)),
				{
					layout = wibox.layout.align.horizontal,
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.separator_thickness + dpi(2),
						spacing_widget = {
							widget = wibox.container.margin,
							margins = { top = dpi(12), bottom = dpi(12) },
							{
								widget = wibox.widget.separator,
								orientation = "vertical"
							}
						},
						{
							id = "bottombar-close-button",
							widget = common.button {
								label = text_icons.arrow_left,
								forced_width = dpi(50),
								forced_height = dpi(50),
								shape = shape.rrect(dpi(10))
							}
						},
						{
							id = "bottombar-refresh-button",
							widget = common.button {
								label = text_icons.reboot,
								forced_width = dpi(50),
								forced_height = dpi(50),
								shape = shape.rrect(dpi(10))
							}
						}
					},
					nil,
					{
						widget = wibox.container.margin,
						margins = { right = dpi(12) },
						{
							widget = wibox.container.place,
							halign = "center",
							{
								id = "bottombar-toggle-switch",
								widget = common.switch {
									forced_width = dpi(40),
									forced_height = dpi(22),
								}
							}
						}
					}
				}
			}
		}
	}

	gtable.crush(ret, wifi_page, true)
	local wp = ret._private

	wp.ap_widgets = {}

	wp.ap_menu = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		forced_height = dpi(400),
		{
			widget = wibox.container.margin,
			margins = dpi(15),
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(15),
				{
					id = "close-button",
					widget = wibox.widget.textbox,
					markup = text_icons.arrow_left
				},
				{
					id = "title",
					widget = wibox.widget.textbox
				}
			}
		},
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(15),
			{
				id = "password-widget",
				widget = wibox.container.background,
				bg = beautiful.bg_alt,
				shape = shape.rrect(dpi(10)),
				{
					widget = wibox.container.margin,
					margins = dpi(15),
					{
						layout = wibox.layout.fixed.vertical,
						spacing = dpi(10),
						{
							widget = wibox.container.margin,
							margins = { left = dpi(10), right = dpi(10) },
							{
								layout = wibox.layout.align.horizontal,
								{
									widget = wibox.container.constraint,
									forced_width = dpi(310),
									strategy = "max",
									height = dpi(25),
									{
										id = "password-input",
										widget = common.text_input {
											placeholder = "Password",
											cursor_bg = beautiful.fg,
											cursor_fg = beautiful.bg,
											placeholder_fg = beautiful.fg_alt,
											obscure = true
										}
									}
								},
								nil,
								{
									id = "obscure-icon",
									widget = wibox.widget.textbox
								}
							}
						},
						{
							widget = wibox.container.background,
							forced_width = 1,
							forced_height = beautiful.separator_thickness,
							{
								widget = wibox.widget.separator,
								orientation = "horizontal"
							}
						},
						{
							widget = wibox.container.margin,
							margins = { left = dpi(10), right = dpi(10) },
							{
								layout = wibox.layout.align.horizontal,
								{
									widget = wibox.widget.textbox,
									markup = "Auto connect"
								},
								nil,
								{
									id = "auto-connect-icon",
									widget = wibox.widget.textbox
								}
							}
						}
					}
				}
			},
			{
				id = "connect-disconnect-button",
				widget = common.button {
					margins = dpi(10),
					shape = shape.rrect(dpi(10))
				}
			}
		}
	}

	local aps_layout = ret:get_children_by_id("access-points-layout")[1]
	local bottombar_toggle_switch = ret:get_children_by_id("bottombar-toggle-switch")[1]
	local bottombar_refresh_button = ret:get_children_by_id("bottombar-refresh-button")[1]
	local password_input = wp.ap_menu:get_children_by_id("password-input")[1]

	wp.on_wireless_enabled = function(_, enabled)
		bottombar_toggle_switch:set_checked(enabled)

		if enabled then
			aps_layout:reset()
			aps_layout:add(wibox.widget {
				widget = wibox.container.background,
				fg = beautiful.fg_alt,
				forced_height = dpi(400),
				{
					widget = wibox.widget.textbox,
					align = "center",
					font = beautiful.font_h2,
					markup = text_icons.wait
				}
			})
		else
			wp.ap_widgets = {}
			aps_layout:reset()

			aps_layout:add(wibox.widget {
				widget = wibox.container.background,
				fg = beautiful.fg_alt,
				forced_height = dpi(400),
				{
					widget = wibox.widget.textbox,
					align = "center",
					font = beautiful.font_h2,
					markup = "Wifi Disabled"
				}
			})

			password_input:unfocus()
		end
	end

	wp.on_ap_list = function(_, _, aps)
		wp.ap_widgets = {}

		for _, ap in pairs(aps) do
			if ap:get_ssid() ~= nil then
				local ap_widget = create_ap_widget(ret, ap)
				table.insert(wp.ap_widgets, ap_widget)
			end
		end

		if aps_layout.children[1] ~= wp.ap_menu and #wp.ap_widgets ~= 0 then
			aps_layout:reset()
			for _, ap_widget in ipairs(wp.ap_widgets) do
				if ap_widget._private.is_active then
					aps_layout:insert(1, ap_widget)
				else
					aps_layout:add(ap_widget)
				end
			end
		end
	end

	wp.on_wireless_state = function(_, state)
		if state == network.DeviceState.ACTIVATED
		or state == network.DeviceState.DISCONNECTED then
			wp.on_ap_list(nil, nil, nm_client.wireless:get_access_points())
		end
	end

	nm_client.wireless:connect_signal("property::access-points", wp.on_ap_list)
	nm_client.wireless:connect_signal("property::state", wp.on_wireless_state)
	nm_client:connect_signal("property::wireless-enabled", wp.on_wireless_enabled)

	bottombar_toggle_switch:buttons {
		awful.button({}, 1, function()
			nm_client:set_wireless_enabled(not nm_client:get_wireless_enabled())
		end)
	}

	bottombar_refresh_button:buttons {
		awful.button({}, 1, function()
			if nm_client:get_wireless_enabled() then
				ret:refresh()
			end
		end)
	}

	wp.on_wireless_enabled(nil, nm_client:get_wireless_enabled())
	wp.on_wireless_state(nil, nm_client.wireless:get_state())

	return ret
end

return setmetatable({ new = new }, { __call = new })
