local M = {}

function M.create_markup(text, args)
	args = args or {}
	local font = args.font and "font='" .. args.font .. "' " or ""
	local size = args.size and "size='" .. args.size .. "' " or ""
	local style = args.style and "style='" .. args.style .. "' " or ""
	local weight = args.weight and "weight='" .. args.weight .. "' " or ""
	local stretch = args.stretch and "stretch='" .. args.stretch .. "' " or ""
	local font_scale = args.font_scale and "font_scale='" .. args.font_scale .. "' " or ""
	local underline = args.underline and "underline='" .. args.underline .. "' " or ""
	local overline = args.overline and "overline='" .. args.overline .. "' " or ""
	local strikethrough = args.strikethrough and "strikethrough='" .. args.strikethrough .. "' " or ""
	local alpha = args.alpha and "alpha='" .. args.alpha .. "' " or ""
	local fg = args.fg and "foreground='" .. args.fg .. "' " or ""
	local bg = args.bg and "background='" .. args.bg .. "'" or ""
	return "<span " .. font .. size .. style .. weight .. stretch .. font_scale ..
		underline .. overline .. strikethrough .. alpha .. fg .. bg .. ">" .. text .. "</span>"
end

function M.lua_escape(str)
	return str:gsub("[%[%]%(%)%.%-%+%?%*%^%$%%]", "%%%1")
end

return M
