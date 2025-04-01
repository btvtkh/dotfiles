local H = {}

function H.set_colors(p)
	local theme = {
		-- base highlights
		Normal = { fg = p.fg, bg = p.bg },
		NormalNC = { fg = p.fg, bg = p.bg },
		SignColumn = { fg = p.bg },
		FoldColumn = { fg = p.fg_alt },
		VertSplit = { fg = p.bg_alt },
		WinSeparator = { fg = p.bg_alt },
		Folded = { fg = p.fg },
		EndOfBuffer = { fg = p.bg_alt },
		ColorColumn = { bg = p.bg_alt },
		Conceal = { fg = p.fg_alt },
		QuickFixLine = { bg = p.bg },
		Terminal = { fg = p.fg, bg = p.bg },
		Directory = { fg = p.blue },
		ErrorMsg = { fg = p.red },
		WarningMsg = { fg = p.yellow },
		ModeMsg = { fg = p.fg },
		MoreMsg = { fg = p.fg },
		MsgArea = { fg = p.fg, bg = p.bg },
		MsgSeparator = { fg = p.bg_alt, bg = p.bg },
		Title = { fg = p.cyan },
		Question = { fg = p.cyan },
		IncSearch = { fg = p.bg, bg = p.magenta },
		Search = { fg = p.bg, bg = p.yellow },
		CurSearch = { fg = p.bg, bg = p.orange },
		Visual = { fg = p.bg, bg = p.ac },
		Substitute = { fg = p.bg, bg = p.magenta },
		VisualNOS = { fg = p.bg, bg = p.fg },
		Cursor = { fg = p.fg, bg = p.fg },
		CursorColumn = { bg = p.bg_alt },
		CursorIM = { fg = p.fg, bg = p.fg },
		CursorLine = { bg = p.bg_alt },
		CursorLineNr = { fg = p.ac },
		lCursor = { fg = p.fg, bg = p.fg },
		LineNr = { fg = p.fg_alt },
		TermCursor = { fg = p.fg, bg = p.fg },
		TermCursorNC = { fg = p.fg, bg = p.fg },
		DiffAdd = { fg = p.green },
		DiffChange = { fg = p.yellow },
		DiffDelete = { fg = p.red },
		DiffText = { fg = p.fg },
		MatchParen = { fg = p.yellow, bg = p.bg_urg },
		NonText = { fg = p.fg_alt },
		SpecialKey = { fg = p.fg_alt },
		Whitespace = { fg = p.bg_alt },
		Pmenu = { fg = p.fg, bg = p.bg_alt },
		PmenuSbar = { bg = p.bg_urg },
		PmenuSel = { fg = p.bg, bg = p.ac },
		PmenuThumb = { bg = p.ac },
		WildMenu = { fg = p.fg, bg = p.bg_alt },
		NormalFloat = { fg = p.fg, bg = p.bg_alt },
		TabLine = { fg = p.fg, bg = p.bg },
		TabLineFill = { fg = p.fg, bg = p.bg },
		TabLineSel = { fg = p.ac, bg = p.bg },
		StatusLine = { fg = p.fg, bg = p.bg },
		StatusLineNC = { bg = p.bg, fg = p.bg },
		SpellBad = { fg = p.red },
		SpellCap = { fg = p.blue },
		SpellLocal = { fg = p.cyan },
		SpellRare = { fg = p.magenta },
		FloatShadow = { fg = p.none, bg = p.none },
		FloatShadowThrough = { fg = p.none, bg = p.none },

		-- syntax
		Boolean = { fg = p.orange },
		Character = { fg = p.orange },
		Conditional = { fg = p.magenta },
		Constant = { fg = p.orange },
		Debug = { fg = p.yellow },
		Define = { fg = p.red },
		Error = { fg = p.red },
		Exception = { fg = p.magenta },
		Float = { fg = p.yellow },
		FloatBorder = { fg = p.fg_alt },
		Function = { fg = p.blue },
		Include = { fg = p.red },
		Keyword = { fg = p.red },
		Label = { fg = p.magenta },
		Macro = { fg = p.magenta },
		Number = { fg = p.yellow },
		Operator = { fg = p.red },
		PreCondit = { fg = p.magenta },
		PreProc = { fg = p.cyan },
		Repeat = { fg = p.magenta },
		Special = { fg = p.orange },
		SpecialChar = { fg = p.orange },
		Statement = { fg = p.blue },
		StorageClass = { fg = p.red },
		String = { fg = p.green },
		Structure = { fg = p.red },
		Tag = { fg = p.red },
		Type = { fg = p.red },
		Typedef = { fg = p.red },
		Variable = { fg = p.blue },
		Comment = { fg = p.fg_alt },
		SpecialComment = { fg = p.fg_alt },
		Todo = { fg = p.fg_alt },
		Delimiter = { fg = p.fg },
		Identifier = { fg = p.fg },
		Ignore = { fg = p.fg },
		Underlined = { underline = true },
		DiagnosticError = { fg = p.red },
		DiagnosticHint = { fg = p.cyan },
		DiagnosticInfo = { fg = p.blue },
		DiagnosticWarn = { fg = p.yellow },
		DiagnosticOk = { fg = p.green },
		diffAdded = { fg = p.blue },
		diffChanged = { fg = p.yellow },
		diffFile = { fg = p.fg },
		diffIndexLine = { fg = p.fg },
		diffLine = { fg = p.fg },
		diffNewFile = { fg = p.magenta },
		diffOldFile = { fg = p.orange },
		diffRemoved = { fg = p.red },
		Added = { fg =  p.green },
		Changed = { fg = p.cyan },
		Removed = { fg = p.red },

		-- nvim-treesitter: https://github.com/nvim-treesitter/nvim-treesitter
		["@attribute"] = { fg = p.blue },
		["@boolean"] = { fg = p.orange },
		["@character"] = { fg = p.orange },
		["@comment"] = { fg = p.fg_alt },
		["@conditional"] = { fg = p.magenta },
		["@constant"] = { fg = p.fg },
		["@constant.builtin"] = { fg = p.orange },
		["@constant.macro"] = { fg = p.orange },
		["@constructor"] = { fg = p.blue },
		["@diff.delta"] = { fg = p.cyan },
		["@diff.minus"] = { fg = p.red },
		["@diff.plus"] = { fg = p.green },
		["@exception"] = { fg = p.magenta },
		["@field"] = { fg = p.cyan },
		["@float"] = { fg = p.yellow },
		["@function"] = { fg = p.blue },
		["@function.builtin"] = { fg = p.blue },
		["@function.macro"] = { fg = p.blue },
		["@include"] = { fg = p.magenta },
		["@keyword"] = { fg = p.red },
		["@keyword.conditional"] = { fg = p.magenta },
		["@keyword.exception"] = { fg = p.magenta },
		["@keyword.function"] = { fg = p.red },
		["@keyword.import"] = { fg = p.magenta },
		["@keyword.operator"] = { fg = p.red },
		["@keyword.return"] = { fg = p.red },
		["@keyword.repeat"] = { fg = p.magenta },
		["@label"] = { fg = p.cyan },
		["@method"] = { fg = p.blue },
		["@namespace"] = { fg = p.cyan },
		["@number"] = { fg = p.yellow },
		["@operator"] = { fg = p.red },
		["@parameter"] = { fg = p.yellow },
		["@parameter.reference"] = { fg = p.yellow },
		["@property"] = { fg = p.cyan },
		["@punctuation.bracket"] = { fg = p.fg },
		["@punctuation.delimiter"] = { fg = p.fg },
		["@punctuation.special"] = { fg = p.fg },
		["@repeat"] = { fg = p.magenta },
		["@string"] = { fg = p.green },
		["@string.escape"] = { fg = p.orange },
		["@string.regex"] = { fg = p.orange },
		["@string.special"] = { fg = p.orange },
		["@symbol"] = { fg = p.orange },
		["@tag"] = { fg = p.red },
		["@tag.attribute"] = { fg = p.yellow },
		["@tag.delimiter"] = { fg = p.blue },
		["@type"] = { fg = p.red },
		["@type.builtin"] = { fg = p.red },
		["@variable"] = { fg = p.fg },
		["@variable.builtin"] = { fg = p.fg },
		["@text"] = { fg = p.fg },

		-- LSP semantic tokens
		["@lsp.type.comment"] = { link = "@comment" },
		["@lsp.type.enum"] = { link = "@type" },
		["@lsp.type.interface"] = { link = "Identifier" },
		["@lsp.type.keyword"] = { link = "@keyword" },
		["@lsp.type.namespace"] = { link = "@namespace" },
		["@lsp.type.parameter"] = { link = "@parameter" },
		["@lsp.type.property"] = { link = "@property" },
		["@lsp.type.variable"] = {}, -- use treesitter styles for regular variables
		["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
		["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
		["@lsp.typemod.operator.injected"] = { link = "@operator" },
		["@lsp.typemod.string.injected"] = { link = "@string" },
		["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
		["@lsp.typemod.variable.injected"] = { link = "@variable" },

		-- indent-blankline.nvim: https://github.com/lukas-reineke/indent-blankline.nvim
		IndentBlanklineChar = { fg = p.bg_alt },

		-- bufferline.nvim: https://github.com/akinsho/bufferline.nvim
		BufferLineFill = { fg = p.bg, bg = p.bg },
		BufferLineIndicatorSelected = { fg = p.ac },

		-- nvim-tree.lua: https://github.com/nvim-tree/nvim-tree.lua
		NvimTreeEmptyFolderName = { fg = p.fg_alt },
		NvimTreeEndOfBuffer = { fg = p.fg, bg = p.bg },
		NvimTreeEndOfBufferNC = { fg = p.fg, bg = p.bg },
		NvimTreeFolderIcon = { fg = p.fg, bg = p.bg },
		NvimTreeFolderName = { fg = p.fg },
		NvimTreeGitDeleted = { fg = p.red },
		NvimTreeGitDirty = { fg = p.red },
		NvimTreeGitNew = { fg = p.blue },
		NvimTreeImageFile = { fg = p.fg_alt },
		NvimTreeIndentMarker = { fg = p.ac },
		NvimTreeNormal = { fg = p.fg, bg = p.bg },
		NvimTreeNormalNC = { fg = p.fg, bg = p.bg },
		NvimTreeOpenedFolderName = { fg = p.ac },
		NvimTreeRootFolder = { fg = p.fg_alt },
		NvimTreeSpecialFile = { fg = p.red },
		NvimTreeStatusLineNC = { bg = p.bg, fg = p.bg },
		NvimTreeSymlink = { fg = p.blue },
		NvimTreeVertSplit = { fg = p.fg_alt, bg = p.bg },
		NvimTreeWindowPicker = { fg = p.red, bg = p.bg_alt },

		-- gitsigns: https://github.com/lewis6991/gitsigns.nvim
		GitSignsAdd = { fg = p.green },
		GitSignsChange = { fg = p.yellow },
		GitSignsDelete = { fg = p.red },

		-- telescope.nvim: https://github.com/nvim-telescope/telescope.nvim
		TelescopeBorder = { fg = p.bg_alt, bg = p.bg_alt },
		TelescopeNormal = { fg = p.fg, bg = p.bg_alt },
		TelescopeSelection = { fg = p.fg, bg = p.bg_urg },
		TelescopeMatching = { fg = p.bg, bg = p.ac },
		TelescopePromptNormal = { fg = p.fg, bg = p.bg_urg },
		TelescopePromptTitle = { fg = p.ac, bg = p.bg_urg },
		TelescopePromptBorder = { fg = p.bg_urg, bg = p.bg_urg },
		TelescopePreviewTitle = { fg = p.fg_alt, bg = p.bg_alt },
		TelescopePreviewBorder = { fg = p.bg_alt, bg = p.bg_alt },
		TelescopeResultsTitle = { fg = p.fg_alt, bg = p.bg_alt },
		TelescopeResultsBorder = { fg = p.bg_alt, bg = p.bg_alt },

		-- hop.nvim
		HopNextKey = { fg = p.yellow },
		HopNextKey1 = { fg = p.orange },
		HopNextKey2 = { fg = p.red },
		HopUnmatched = { fg = p.fg_alt },
		HopCursor = { bg = p.fg },
		HopPreview = { fg = p.magenta }
	}

	vim.g.terminal_color_0 = p.bg
	vim.g.terminal_color_1 = p.red
	vim.g.terminal_color_2 = p.green
	vim.g.terminal_color_3 = p.yellow
	vim.g.terminal_color_4 = p.blue
	vim.g.terminal_color_5 = p.magenta
	vim.g.terminal_color_6 = p.cyan
	vim.g.terminal_color_7 = p.fg
	vim.g.terminal_color_8 = p.fg_alt
	vim.g.terminal_color_9 = p.red
	vim.g.terminal_color_10 = p.green
	vim.g.terminal_color_11 = p.yellow
	vim.g.terminal_color_12 = p.blue
	vim.g.terminal_color_13 = p.magenta
	vim.g.terminal_color_14 = p.cyan
	vim.g.terminal_color_15 = p.fg

	return theme
end

return H
