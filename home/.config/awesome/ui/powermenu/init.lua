local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local shape = require("lib.shape")
local gtable = require("gears.table")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local capi = { awesome = awesome, screen = screen }

local powermenu = {}

local keys = {
	up = { "Up" },
	down = { "Down" },
	left = { "Left" },
	right = { "Right" },
	exec = { "Return" },
	close = { "Escape" }
}

local function run_keygrabber(self)
	local wp = self._private
	wp.keygrabber = awful.keygrabber.run(function(_, key, event)
		if event ~= "press" then return end
		if gtable.hasitem(keys.up, key) then
			self:next()
			self:update_elements()
		elseif gtable.hasitem(keys.down, key) then
			self:back()
			self:update_elements()
		elseif gtable.hasitem(keys.left, key) then
			self:back()
			self:update_elements()
		elseif gtable.hasitem(keys.right, key) then
			self:next()
			self:update_elements()
		elseif gtable.hasitem(keys.exec, key) then
			wp.elements[wp.select_index].exec()
		elseif gtable.hasitem(keys.close, key) then
			self:hide()
		end
	end)
end

function powermenu:next()
	local wp = self._private
	if wp.select_index ~= #wp.elements then
		wp.select_index = wp.select_index + 1
	else
		wp.select_index = 1
	end
end

function powermenu:back()
	local wp = self._private
	if wp.select_index ~= 1 then
		wp.select_index = wp.select_index - 1
	else
		wp.select_index = #wp.elements
	end
end

function powermenu:update_elements()
	local wp = self._private
	local elements_container = self.widget:get_children_by_id("elements-container")[1]
	elements_container:reset()

	for i, element in ipairs(wp.elements) do
		local element_widget = wibox.widget {
			widget = wibox.container.background,
			forced_width = dpi(120),
			forced_height = dpi(120),
			shape = shape.rrect(dpi(20)),
			buttons = {
				awful.button({}, 1, function()
					if wp.select_index == i then
						element.exec()
					else
						wp.select_index = i
						self:update_elements()
					end
				end)
			},
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_h3,
				markup = element.icon
			}
		}

		if i == wp.select_index then
			element_widget:set_bg(element.color)
			element_widget:set_fg(beautiful.bg)
		else
			element_widget:connect_signal("mouse::enter", function(w)
				w:set_bg(beautiful.bg_urg)
			end)

			element_widget:connect_signal("mouse::leave", function(w)
				w:set_bg(nil)
			end)
		end

		elements_container:add(element_widget)
	end
end

function powermenu:show()
	if self.visible then return end
	local wp = self._private
	wp.select_index = 1
	self:update_elements()
	run_keygrabber(self)
	self.visible = true
	self:emit_signal("property::visible", self.visible)
end

function powermenu:hide()
	if not self.visible then return end
	local wp = self._private
	awful.keygrabber.stop(wp.keygrabber)
	wp.select_index = 1
	self.visible = false
	self:emit_signal("property::visible", self.visible)
end

function powermenu:toggle()
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
		placement = awful.placement.centered,
		widget = {
			widget = wibox.container.background,
			bg = beautiful.bg,
			border_width = beautiful.border_width,
			border_color = beautiful.border_color_normal,
			shape = shape.rrect(dpi(32)),
			{
				widget = wibox.container.margin,
				margins = dpi(12),
				{
					id = "elements-container",
					spacing = dpi(4),
					layout = wibox.layout.fixed.horizontal
				}
			}
		}
	}

	gtable.crush(ret, powermenu, true)
	local wp = ret._private

	wp.elements = {
		{
			exec = function()
				awful.spawn("poweroff")
			end,
			icon = text_icons.poweroff,
			color = beautiful.red
		},
		{
			exec = function()
				awful.spawn("reboot")
			end,
			icon = text_icons.reboot,
			color = beautiful.yellow
		},
		{
			exec = function()
				capi.awesome.quit()
			end,
			icon = text_icons.exit,
			color = beautiful.green
		}
	}

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
