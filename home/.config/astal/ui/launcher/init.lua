local utf8 = require("lua-utf8")
local astal = require("astal")
local Variable = astal.Variable
local bind = astal.bind
local Gio = astal.require("Gio")
local AstalHyprland = astal.require("AstalHyprland")
local App = require("astal.gtk3").App
local Widget = require("astal.gtk3").Widget
local Astal = require("astal.gtk3").Astal
local Anchor = Astal.WindowAnchor
local Gdk = require("astal.gtk3").Gdk
local map = require("lib.table").map
local lua_escape = require("lib.string").lua_escape

local function launch_app(app)
	if not app then return end
	local hyprland = AstalHyprland.get_default()
	local desktop_app_info = Gio.DesktopAppInfo.new(Gio.AppInfo.get_id(app))
	local term_needed = Gio.DesktopAppInfo.get_string(desktop_app_info, "Terminal") == "true" and true or false
	local term = Gio.AppInfo.get_default_for_uri_scheme('terminal')

	hyprland:dispatch(
		"exec",
		term_needed and
			term and string.format("%s -e %s", term:get_executable(), app:get_executable())
		or
			string.match(app:get_executable(), "^env") and
				string.gsub(app:get_commandline(), "%%%a", "")
			or
				app:get_executable()
	)
end

local function filter_apps(apps, query)
	query = lua_escape(query)
	local filtered = {}
	local filtered_any = {}

	for _, app in ipairs(apps) do
		if app:should_show() then
			local name_match = utf8.lower(utf8.sub(app:get_name(), 1, utf8.len(query))) == utf8.lower(query)
			local name_match_any = utf8.match(utf8.lower(app:get_name()), utf8.lower(query))
			local exec_match_any = utf8.match(utf8.lower(app:get_executable()), utf8.lower(query))

			if name_match then
				table.insert(filtered, app)
			elseif name_match_any or exec_match_any then
				table.insert(filtered_any, app)
			end
		end
	end

	table.sort(filtered, function(a, b)
		return utf8.lower(a:get_name()) < utf8.lower(b:get_name())
	end)

	table.sort(filtered_any, function(a, b)
		return utf8.lower(a:get_name()) < utf8.lower(b:get_name())
	end)

	for i = 1, #filtered_any do
		filtered[#filtered + 1] = filtered_any[i]
	end

	return filtered
end

local function hide()
	local launcher = App:get_window("Launcher")
	if launcher then launcher:hide() end
end

local function AppButton(app)
	return Widget.Button {
		class_name = "app-button",
		on_clicked = function()
			launch_app(app)
			hide()
		end,
		Widget.Box {
			vertical = true,
			Widget.Label {
				class_name = "name",
				xalign = 0,
				ellipsize = "END",
				label = app:get_name()
			},
			Widget.Label {
				class_name = "description",
				xalign = 0,
				ellipsize = "END",
				label = app:get_description()
			}
		}
	}
end

return function()
	local apps = {}
	local app_list = Variable({})

	local on_enter = function()
		local first_app = app_list:get()[1]
		if first_app then
			launch_app(first_app)
			hide()
		end
	end

	local entry = Widget.Entry {
		placeholder_text = "Search...",
		on_changed = function(self)
			app_list:set(filter_apps(apps, self:get_text()))
		end,
		on_activate = on_enter
	}

	local scrollable = Widget.Scrollable {
		vexpand = true,
		height_request = 375,
		Widget.Box {
			vertical = true,
			spacing = 3,
			bind(app_list):as(function(list)
				return map(list, function(app)
					return AppButton(app)
				end)
			end),
			Widget.Box {
				class_name = "not-found",
				halign = "CENTER",
				valign = "CENTER",
				vexpand = true,
				visible = bind(app_list):as(function(list)
					return #list == 0
				end),
				Widget.Label {
					label = "No match found"
				}
			}
		}
	}

	local mainbox = Widget.Box {
		class_name = "mainbox",
		vertical = true,
		vexpand = false,
		width_request = 400,
		entry,
		scrollable
	}

	local revealer = Widget.Revealer {
		transition_type = "SLIDE_UP",
		mainbox
	}

	return Widget.Window {
		application = App,
		name = "Launcher",
		class_name = "launcher",
		anchor = Anchor.BOTTOM + Anchor.RIGHT + Anchor.TOP + Anchor.LEFT,
		exclusivity = "NORMAL",
		keymode = "ON_DEMAND",
		visible = false,
		on_key_press_event = function(self, event)
			if event.keyval == Gdk.KEY_Escape then
				self:hide()
			end
		end,
		on_show = function()
			apps = Gio.AppInfo.get_all()
			app_list:set(filter_apps(apps, ""))
			entry:set_text("")
			entry:set_position(-1)
			entry:select_region(0, -1)
			entry:grab_focus()
			scrollable:get_vadjustment():set_value(scrollable:get_vadjustment():get_lower())
			revealer:set_reveal_child(true)
		end,
		on_hide = function()
			revealer:set_reveal_child(false)
		end,
		setup = function(self)
			self:hook(App, "window-toggled", function(_, w)
				if w:get_visible() and w:get_name() == "Powermenu" then
					hide()
				end
			end)
		end,
		Widget.Box {
			Widget.Box {
				hexpand = false,
				vertical = true,
				Widget.EventBox {
					vexpand = true,
					on_click = hide,
				},
				revealer
			},
			Widget.EventBox {
				expand = true,
				on_click = hide
			}
		}
	}
end
