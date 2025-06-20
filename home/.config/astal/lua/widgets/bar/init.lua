local astal = require("astal")
local Variable = astal.Variable
local bind = astal.bind
local GLib = astal.require("GLib")
local AstalHyprland = astal.require("AstalHyprland")
local AstalTray = astal.require("AstalTray")
local App = require("astal.gtk3").App
local Widget = require("astal.gtk3").Widget
local Astal = require("astal.gtk3").Astal
local map = require("lua.lib").map

local function LauncherButton()
	return Widget.Button {
		class_name = "launcher-button",
		on_clicked = function()
			local launcher = App:get_window("Launcher")
			if launcher then
				if not launcher:get_visible() then
					launcher:show()
				else
					launcher:hide()
				end
			end
		end,
		Widget.Icon {
			icon = "search-symbolic"
		}
	}
end

local function Workspaces()
	local hyprland = AstalHyprland.get_default()

	return Widget.Box {
		class_name = "workspaces",
		spacing = 3,
		bind(hyprland, "workspaces"):as(function(ws)
			table.sort(ws, function(a, b) return a.id < b.id end)
			return map(ws, function(w)
				return not (w.id >= -99 and w.id <= -2) and Widget.Button {
					class_name = bind(hyprland, "focused-workspace"):as(function(fw)
						return "workspace" .. (fw == w and " focused" or "")
					end),
					on_clicked = function()
						if w ~= hyprland:get_focused_workspace() then
							w:focus()
						end
					end,
					Widget.Label {
						label = bind(w, "id"):as(function(id)
							return type(id) == "number" and string.format("%.0f", id) or id
						end)
					}
				}
			end)
		end)
	}
end

local function Clients()
	local hyprland = AstalHyprland.get_default()

	return Widget.Box {
		class_name = "clients",
		spacing = 6,
		expand = false,
		bind(hyprland, "clients"):as(function(cs)
			return map(cs, function(c)
				local c_class = c:get_initial_class()
				return Widget.Button {
					class_name = bind(hyprland, "focused-client"):as(function(fc)
						return "client" .. (fc == c and " focused" or "" )
					end),
					visible = bind(hyprland, "focused-workspace"):as(function(fw)
						return fw == c:get_workspace()
					end),
					on_click = function(_, event)
						if event.button == "PRIMARY" then
							if c ~= hyprland:get_focused_client() then
								c:focus()
							end
							if c:get_floating() then
								hyprland:dispatch("alterzorder", "top, " .. c:get_address())
							end
						elseif event.button == "MIDDLE" then
							c:kill()
						end
					end,
					setup = function(self)
						self:hook(c, "moved-to", function(_, ws)
							self:set_visible(ws == hyprland:get_focused_workspace())
						end)
					end,
					Widget.Label {
						max_width_chars = 15,
						ellipsize = "END",
						label = (c_class ~= nil and c_class ~= "") and c_class or "untitled"
					}
				}
			end)
		end)
	}
end

local function KbLayout()
	local hyprland = AstalHyprland.get_default()
	local layout_name = Variable("En")

	return Widget.Box {
		class_name = "kblayout",
		setup = function(self)
			self:hook(hyprland, "keyboard-layout", function(_, _, lt)
				local lt_name = (lt:match("English") and "En") or
					(lt:match("Russian") and "Ru") or "??"
				layout_name:set(lt_name)
			end)
		end,
		Widget.Label {
			label = layout_name()
		}
	}
end

local function SysTray()
	local tray = AstalTray.get_default()
	local tray_visibility = Variable()

	return Widget.Box {
		class_name = "systray",
		Widget.Button {
			class_name = "reveal-button",
			on_clicked = function()
				tray_visibility:set(not tray_visibility:get())
			end,
			Widget.Icon {
				icon = bind(tray_visibility):as(function(v)
					return v and "arrow-right" or "arrow-left"
				end)
			}
		},
		Widget.Revealer {
			reveal_child = bind(tray_visibility),
			transition_type = "SLIDE_LEFT",
			Widget.Box {
				bind(tray, "items"):as(function(items)
					return map(items, function(item)
						return Widget.MenuButton {
							class_name = "item",
							tooltip_markup = bind(item, "tooltip_markup"),
							use_popover = false,
							menu_model = bind(item, "menu-model"),
							action_group = bind(item, "action-group"):as(function(ag)
								return { "dbusmenu", ag }
							end),
							Widget.Icon {
								gicon = bind(item, "gicon")
							}
						}
					end)
				end)
			}
		}
	}
end

local function Time(format)
	local time = Variable(""):poll(1000, function()
		return GLib.DateTime.new_now_local():format(format)
	end)

	return Widget.Box {
		class_name = "time",
		Widget.Label {
			on_destroy = function()
				time:drop()
			end,
			label = time(),
		}
	}
end

local function ControlPanelButton()
	return Widget.Button {
		class_name = "control-panel-button",
		on_clicked = function()
			local panel = App:get_window("Control-panel")
			if panel then
				if not panel:get_visible() then
					panel:show()
				else
					panel:hide()
				end
			end
		end,
		Widget.Icon {
			icon = "multimedia-equalizer-symbolic"
		}
	}
end

return function(gdkmonitor)
	local Anchor = Astal.WindowAnchor
	return Widget.Window {
		gdkmonitor = gdkmonitor,
		name = "Bar",
		class_name = "bar",
		anchor = Anchor.BOTTOM + Anchor.LEFT + Anchor.RIGHT,
		exclusivity = "EXCLUSIVE",
		Widget.Box {
			class_name = "mainbox",
			spacing = 6,
			Widget.Box {
				hexpand = true,
				halign = "START",
				spacing = 6,
				LauncherButton(),
				Workspaces(),
				Clients()
			},
			Widget.Box {
				halign = "END",
				spacing = 6,
				SysTray(),
				KbLayout(),
				Time("%d %b, %a - %H:%M"),
				ControlPanelButton()
			}
		}
	}
end
