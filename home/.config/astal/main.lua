pcall(require, "luarocks.loader")
package.path = ".config/astal/?.lua;.config/astal/?/init.lua;" .. package.path

local astal = require("astal")
local App = require("astal.gtk3").App
local src = require("lib").src
local Bar = require("ui.bar")
local Notifications = require("ui.notifications")
local Launcher = require("ui.launcher")
local ControlPanel = require("ui.control_panel")

local scss = src("index.scss")
local css = "/tmp/astal-style.css"
astal.exec("sass " .. scss .. " " .. css)

App:start {
	instance_name = "astal-lua",
	css = css,
	main = function()
		for _, monitor in pairs(App.monitors) do
			Bar(monitor)
			Notifications(monitor)
		end
		Launcher()
		ControlPanel()
	end
}
