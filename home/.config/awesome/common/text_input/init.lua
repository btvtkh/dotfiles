local utf8 = require("lua-utf8")
local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local Gdk = lgi.require("Gdk", "3.0")
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local gstring = require("gears.string")
local gcolor = require("gears.color")

local text_input = {}

local function create_markup(args)
	local text = args.text or ""
	local cursor_pos = args.cursor_pos or 1
	local selectall = args.selectall or false
	local placeholder = args.placeholder or ""
	local obscure = args.obscure or false
	local obscure_char = args.obscure_char or "*"
	local highlighter = args.highlighter or nil
	local cursor_char, spacer, text_start, text_end, markup

	if obscure and text ~= "" then
		text = utf8.gsub(text, "(.)", obscure_char)
	end

	if text == "" and placeholder ~= "" then
		text_start = ""
		cursor_char = gstring.xml_escape(utf8.sub(placeholder, cursor_pos, cursor_pos))
		text_end = gstring.xml_escape(utf8.sub(placeholder, 2))
		spacer = ""
	elseif selectall then
		text_start = ""
		cursor_char = text == "" and " " or gstring.xml_escape(text)
		text_end = ""
		spacer = " "
	elseif utf8.len(text) < cursor_pos then
		text_start = gstring.xml_escape(text)
		cursor_char = " "
		text_end = ""
		spacer = ""
	else
		text_start = gstring.xml_escape(utf8.sub(text, 1, cursor_pos - 1))
		cursor_char = gstring.xml_escape(utf8.sub(text, cursor_pos, cursor_pos))
		text_end = gstring.xml_escape(utf8.sub(text, cursor_pos + 1))
		spacer = " "
	end

	local cursor_bg = gcolor.ensure_pango_color(args.cursor_bg)
	local cursor_fg = gcolor.ensure_pango_color(args.cursor_fg)
	local placeholder_fg = gcolor.ensure_pango_color(args.placeholder_fg)

	if text ~= "" and highlighter then
		text_start, text_end = highlighter(text_start, text_end)
	end

	markup = text_start
		.. "<span foreground='" .. cursor_fg .. "' background='" .. cursor_bg ..  "'>" .. cursor_char .. "</span>"
		.. (text == "" and "<span foreground='" .. placeholder_fg .. "'>" .. text_end .. "</span>" or text_end)
		.. spacer

	return markup
end

local function run_keygrabber(self)
	local wp = self._private
	wp.keygrabber = awful.keygrabber.run(function(mods, key, event)
		local mod = {}
		for _, v in ipairs(mods) do
			mod[v] = true
		end

		if event ~= "press" then
			if wp.on_key_released then
				wp.on_key_released(self, mod, key)
			end
			return
		end

		if wp.on_key_pressed then
			wp.on_key_pressed(self, mod, key)
		end

		if mod.Control then
			if key == "a" then
				if wp.input ~= "" then
					wp.cursor_index = 1
					wp.selectall = true
				end
			elseif key == "c" then
				if wp.selectall then
					wp.clipboard:set_text(wp.input, -1)
					wp.cursor_index = utf8.len(wp.input) + 1
					wp.selectall = false
				end
			elseif key == "v" then
				wp.clipboard:request_text(function(_, text)
					if text then
						if wp.selectall then
							wp.input = text
							wp.selectall = false
						else
							wp.input = utf8.sub(wp.input, 1, wp.cursor_index - 1) ..
								text .. utf8.sub(wp.input, wp.cursor_index)
						end
						wp.cursor_index = wp.cursor_index + utf8.len(text)
						if wp.on_input_changed then
							wp.on_input_changed(self, wp.input)
						end
						self:update_textbox()
					end
				end)
			end
		else
			if key == "Escape" then
				wp.selectall = false
				self:unfocus()
			elseif key == "Return" then
				wp.selectall = false
				if wp.on_executed then
					wp.on_executed(self, wp.input)
				end
				self:unfocus()
			elseif key == "Home" then
				wp.selectall = false
				wp.cursor_index = 1
			elseif key == "End" then
				wp.selectall = false
				wp.cursor_index = utf8.len(wp.input) + 1
			elseif key == "Left" then
				wp.selectall = false
				if wp.cursor_index > 1 then
					wp.cursor_index = wp.cursor_index - 1
				end
			elseif key == "Right" then
				if wp.selectall then
					wp.selectall = false
					wp.cursor_index = utf8.len(wp.input) + 1
				elseif wp.cursor_index < utf8.len(wp.input) + 1 then
					wp.cursor_index = wp.cursor_index + 1
				end
			elseif key == "Delete" then
				if wp.selectall then
					wp.input = ""
					wp.selectall = false
					if wp.on_input_changed then
						wp.on_input_changed(self, wp.input)
					end
				elseif wp.cursor_index < utf8.len(wp.input) + 1 then
					wp.input = utf8.sub(wp.input, 1, wp.cursor_index - 1) ..
						utf8.sub(wp.input, wp.cursor_index + 1)
					if wp.on_input_changed then
						wp.on_input_changed(self, wp.input)
					end
				end
			elseif key == "BackSpace" then
				if wp.selectall then
					wp.input = ""
					wp.selectall = false
					if wp.on_input_changed then
						wp.on_input_changed(self, wp.input)
					end
				elseif wp.cursor_index > 1 then
					wp.input = utf8.sub(wp.input, 1, wp.cursor_index - 2) ..
						utf8.sub(wp.input, wp.cursor_index)
					wp.cursor_index = wp.cursor_index - 1
					if wp.on_input_changed then
						wp.on_input_changed(self, wp.input)
					end
				end
			elseif utf8.len(key) == 1 then
				if wp.selectall then
					wp.input = key
					wp.selectall = false
				else
					wp.input = utf8.sub(wp.input, 1, wp.cursor_index - 1) .. key ..
						utf8.sub(wp.input, wp.cursor_index)
					wp.cursor_index = wp.cursor_index + 1
				end
				if wp.on_input_changed then
					wp.on_input_changed(self, wp.input)
				end
			end
		end

		self:update_textbox()
	end)
end

function text_input:update_textbox()
	local wp = self._private
	self:set_markup(create_markup {
		text = wp.input,
		cursor_pos = wp.cursor_index,
		selectall = wp.selectall,
		obscure = wp.obscure,
		cursor_bg = wp.cursor_bg,
		cursor_fg = wp.cursor_fg,
		placeholder_fg = wp.placeholder_fg,
		obscure_char = wp.obscure_char,
		placeholder = wp.placeholder,
		highlighter = wp.highlighter
	})
end

function text_input:get_focused()
	return self._private.focused
end

function text_input:focus()
	local wp = self._private
	if wp.focused then return end
	wp.focused = true
	run_keygrabber(self)
	self:update_textbox()
	if wp.on_focused then
		wp.on_focused(self)
	end
end

function text_input:unfocus()
	local wp = self._private
	if not wp.focused then return end
	wp.focused = false
	awful.keygrabber.stop(wp.keygrabber)
	if wp.on_unfocused then
		wp.on_unfocused(self)
	end
end

function text_input:get_input()
	return self._private.input
end

function text_input:set_input(input)
	self._private.input = input
	self:update_textbox()
end

function text_input:get_cursor_index()
	return self._private.cursor_index
end

function text_input:set_cursor_index(index)
	local wp = self._private
	wp.cursor_index = math.max(math.min(utf8.len(wp.input), index), 1)
	self:update_textbox()
end

function text_input:get_selectall()
	return self._private.selectall
end

function text_input:set_selectall(selectall)
	self._private.selectall = selectall
	self:update_textbox()
end

function text_input:get_obscure()
	return self._private.obscure
end

function text_input:set_obscure(obscure)
	self._private.obscure = obscure
	self:update_textbox()
end

function text_input:on_focused(callback)
	self._private.on_focused = callback
end

function text_input:on_unfocused(callback)
	self._private.on_unfocused = callback
end

function text_input:on_input_changed(callback)
	self._private.on_input_changed = callback
end

function text_input:on_executed(callback)
	self._private.on_executed = callback
end

function text_input:on_key_pressed(callback)
	self._private.on_key_pressed = callback
end

function text_input:on_key_released(callback)
	self._private.on_key_released = callback
end

local function new(args)
	args = args or {}
	local ret = wibox.widget {
		widget = wibox.widget.textbox,
		font = args.font,
		halign = args.halign,
		valign = args.valign,
		wrap = args.wrap,
		justify = args.justify,
		ellipsize = args.ellipsize or "start"
	}

	gtable.crush(ret, text_input, true)
	local wp = ret._private

	wp.focused = false

	wp.input = ""
	wp.cursor_index = 1
	wp.selectall = false
	wp.obscure = args.obscure or false
	wp.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)

	wp.placeholder = args.placeholder or ""
	wp.obscure_char = args.obscure_char or "*"
	wp.cursor_bg = args.cursor_bg or "#ffffff"
	wp.cursor_fg = args.cursor_fg or "#000000"
	wp.placeholder_fg = args.placeholder_fg or "#373737"
	wp.highlighter = args.highlighter
	wp.on_focused = args.on_focused
	wp.on_unfocused = args.on_unfocused
	wp.on_input_changed = args.on_input_changed
	wp.on_executed = args.on_executed
	wp.on_key_pressed = args.on_key_pressed
	wp.on_key_released = args.on_key_released

	return ret
end

return setmetatable({
	new = new
}, {
	__call = function(_, ...)
		return new(...)
	end
})
