local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local adapter = require("service.bluetooth").get_default()

local function on_powered(self, powered)
	local separator = self:get_children_by_id("separator")[1]
	local description = self:get_children_by_id("description")[1]

	if powered then
		self:set_bg(beautiful.ac)
		self:set_fg(beautiful.bg)
		separator:set_color(beautiful.bg)
		description:set_markup("Enabled")
	else
		self:set_bg(beautiful.bg_alt)
		self:set_fg(beautiful.fg)
		separator:set_color(beautiful.bg_urg)
		description:set_markup("Disabled")
	end
end

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		forced_height = dpi(60),
		bg = beautiful.bg_alt,
		fg = beautiful.fg,
		shape = beautiful.rrect(dpi(10)),
		{
			widget = wibox.container.margin,
			margins = { left = dpi(15) },
			{
				layout = wibox.layout.align.horizontal,
				{
					id = "label-background",
					widget = wibox.container.background,
					forced_width = dpi(150),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(15),
						{
							widget = wibox.widget.textbox,
							markup = text_icons.bluetooth
						},
						{
							widget = wibox.container.place,
							valign = "center",
							{
								layout = wibox.layout.fixed.vertical,
								{
									id = "label",
									widget = wibox.widget.textbox,
									markup = "Bluetooth"
								},
								{
									id = "description",
									widget = wibox.widget.textbox,
									font = beautiful.font_h0
								}
							}
						}
					}
				},
				nil,
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.container.margin,
						forced_height = 1,
						forced_width = beautiful.separator_thickness,
						margins = { top = dpi(12), bottom = dpi(12) },
						{
							id = "separator",
							widget = wibox.widget.separator,
							orientation = "vertical"
						}
					},
					{
						id = "reveal-button",
						widget = wibox.container.background,
						forced_width = dpi(45),
						{
							widget = wibox.widget.textbox,
							align = "center",
							markup = text_icons.arrow_right
						}
					}
				}
			}
		}
	}

	local label_background = ret:get_children_by_id("label-background")[1]
	label_background:buttons {
		awful.button({}, 1, function()
			adapter:set_powered(not adapter:get_powered())
		end)
	}

	local separator = ret:get_children_by_id("separator")[1]
	ret:connect_signal("mouse::enter", function()
		if not adapter:get_powered() then
			ret:set_bg(beautiful.bg_urg)
			separator:set_color(beautiful.fg_alt)
		end
	end)

	ret:connect_signal("mouse::leave", function()
		if not adapter:get_powered() then
			ret:set_bg(beautiful.bg_alt)
			separator:set_color(beautiful.bg_urg)
		end
	end)

	adapter:connect_signal("property::powered", function(_, powered)
		on_powered(ret, powered)
	end)

	on_powered(ret, adapter:get_powered())

	return ret
end

return setmetatable({
	new = new
}, {
	__call = new
})
