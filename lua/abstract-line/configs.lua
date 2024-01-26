local M = {}

local funcs = require("abstract-line.funcs")
local sethighlight = vim.api.nvim_set_hl

M.exclude_filetypes = {
	"NvimTree",
	"Outline",
	"TelescopePrompt",
	"Trouble",
	"neo-tree",
	"alpha",
	"dashboard",
	"lir",
	"neogitstatus",
	"packer",
	"spectre_panel",
	"startify",
	"toggleterm",
}

M.highlight = {

	default = true,
	colors = {
		mode = {
			C = "#ffaa00",
			R = "#fd4848",
			i = "#fd4848",
			n = "#178c94",
			v = "#d1d1d1",
			V = "#d1d1d1",
			["^V"] = "#d1d1d1",
			other = "#ffaa00",
		},
		fg = "#b7b7b7",
		bg = "#072b2c",
		global = "#141414",
	},

	init_highlight = function(initial)
		local fg = M.highlight.colors.fg
		local bg = M.highlight.colors.bg
		local global_color = M.highlight.colors.global
		local mode_color = M.highlight.colors.mode

		local mode = vim.api.nvim_exec("echo mode()", true) -- get mode (normal/insert/visual/command)
		local icon_color = funcs.get_filetype_icon().icon_color

		sethighlight(0, "AbstractlineFilenameIcon", { fg = icon_color, bg = bg })
		sethighlight(0, "AbstractlineMode", {
			fg = mode_color[mode] and mode_color[mode] or mode_color.other,
			bg = global_color,
			bold = true,
		})

		-- above highlights are dynamic so they be loaded eveytime.
		if not initial then
			return
		end

		sethighlight(0, "Abstractline", { fg = fg, bg = bg })
		sethighlight(0, "AbstractlineFilemodify", { fg = "#ff0000", bg = bg })
		sethighlight(0, "AbstractlineFilename", { fg = fg, bg = bg, italic = true })
		sethighlight(0, "AbstractlineFilesize", { fg = fg, bg = global_color })
		sethighlight(0, "AbstractlineGit", { fg = "#b44200", bg = global_color, bold = true })
		sethighlight(0, "AbstractlineGitAdded", { fg = "#4c7f33", bg = global_color, bold = true })
		sethighlight(0, "AbstractlineGitChanged", { fg = "#985401", bg = global_color, bold = true })
		sethighlight(0, "AbstractlineGitRemoved", { fg = "#d10000", bg = global_color, bold = true })
		sethighlight(0, "AbstractlineLSPDiagError", { fg = "#a81818", bg = global_color })
		sethighlight(0, "AbstractlineLSPDiagHint", { fg = "#336481", bg = global_color })
		sethighlight(0, "AbstractlineLSPDiagInfo", { fg = "#812900", bg = global_color })
		sethighlight(0, "AbstractlineLSPDiagWarn", { fg = "#5d5d00", bg = global_color })
		sethighlight(0, "AbstractlineLsprovider", { fg = fg, bg = global_color })
		sethighlight(0, "AbstractlineLsprovidername", { fg = "#51A0CF", bg = global_color })
		sethighlight(0, "AbstractlinePsedostring", { fg = "#060606", bg = "#060606" })
		sethighlight(0, "AbstractlineSearch", { fg = "#abab18", bg = global_color })
		sethighlight(0, "AbstractlineSplitter", { fg = bg, bg = global_color })
		sethighlight(0, "AbstractlineVirtualEnv", { fg = "#b44200", bg = global_color, bold = true })
	end,
}

return M
