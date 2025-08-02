local astal = require("astal")
local GLib = astal.require("GLib")

local M = {}

function M.src(path)
	local str = debug.getinfo(2, "S").source:sub(2)
	local src = str:match("(.*/)") or str:match("(.*\\)") or "./"
	return src .. path
end

function M.exists(path)
	return GLib.file_test(path, "EXISTS")
end

return M
