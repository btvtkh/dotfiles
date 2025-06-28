vim.wo.number = true
vim.wo.relativenumber = true
vim.g.did_load_filetypes = 1
vim.g.formatoptions = "qrn1"
vim.opt.showmode = false
vim.opt.updatetime = 100
vim.wo.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.wrap = true
vim.wo.linebreak = true
vim.opt.virtualedit = "block"
vim.opt.undofile = true
vim.opt.shell = "/bin/sh"

-- Mouse
vim.opt.mouse = "a"
vim.opt.mousefocus = true

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Shorter messages
vim.opt.shortmess:append("c")

-- Indent Settings
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Fillchars
vim.opt.fillchars = {
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	fold = "·",
	eob = " ",
	diff = "-",
	msgsep = "━",
	foldopen = "-",
	foldsep = "│",
	foldclose = "+"
}

-- Listchars
vim.opt.list = true
vim.opt.listchars = {
	space = "⋅",
	tab = "--",
}

-- Diagnostics
vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = false,
})

-- Colors --
vim.opt.termguicolors = true
vim.cmd.colorscheme("astel")
