local M = {}

function M.lua_escape(str)
	return str:gsub("[%[%]%(%)%.%-%+%?%*%%]", "%%%1")
end

return M
