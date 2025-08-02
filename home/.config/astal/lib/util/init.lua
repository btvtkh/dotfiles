local astal = require("astal")
local GLib = astal.require("GLib")

local M = {}

function M.time(time, format)
	format = format or "%H:%M"
	return GLib.DateTime.new_from_unix_local(time):format(format)
end

return M
