local Variable = require("astal").Variable
local Gtk = require("astal.gtk3").Gtk

local M = {}

function M.map(array, func)
	local new_arr = {}
	for i, v in ipairs(array) do
		new_arr[i] = func(v, i)
	end
	return new_arr
end

function M.varlist(initial)
	local list = initial
	local var = Variable()

	local function var_set()
		local arr = {}
		for _, value in pairs(list) do
			table.insert(arr, value)
		end
		var:set(arr)
	end

	var_set()

	return setmetatable({
		insert = function(pos, item)
			if item then
				table.insert(list, pos, item)
			else
				table.insert(list, pos)
			end
			var_set()
		end,
		remove = function(item)
			for i, v in ipairs(list) do
				if v == item then
					if Gtk.Widget:is_type_of(v) then
						v:destroy()
					end
					table.remove(list, i)
				end
			end
			var_set()
		end,
		get = function()
			return var:get()
		end,
		subscribe = function(callback)
			return var:subscribe(callback)
		end
	}, {
		__call = function()
			return var()
		end
	})
end

return M
