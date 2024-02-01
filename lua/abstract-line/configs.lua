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
		fg = "#757575",
		bg = "#041a1a",
	},

	init_highlight = function(initial)
		local fg = M.highlight.colors.fg
		local bg = M.highlight.colors.bg
		local global_bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
		local mode_color = M.highlight.colors.mode
		local editor_bg =  vim.api.nvim_get_hl(0, { name = "Normal" }).bg

		local mode = vim.api.nvim_exec("echo mode()", true) -- get mode (normal/insert/visual/command)
		local icon_color = funcs.get_filetype_icon().icon_color

		sethighlight(0, "AbstractlineFilenameIcon", { fg = icon_color, bg = bg })
		sethighlight(0, "AbstractlineMode", {
			fg = mode_color[mode] and mode_color[mode] or mode_color.other,
			bg = global_bg,
			bold = true,
		})

		-- above highlights are dynamic so they be loaded eveytime.
		if not initial then
			return
		end

		sethighlight(0, "Abstractline", { fg = fg, bg = bg })
		sethighlight(0, "AbstractlineFilemodify", { fg = "#ff0000", bg = bg })
		sethighlight(0, "AbstractlineFilename", { fg = fg, bg = bg, italic = true })
		sethighlight(0, "AbstractlineFilesize", { fg = fg, bg = global_bg })
		sethighlight(0, "AbstractlineGit", { fg = "#913500", bg = global_bg, bold = true })
		sethighlight(0, "AbstractlineGitAdded", { fg = "#3e682a", bg = global_bg, bold = true })
		sethighlight(0, "AbstractlineGitChanged", { fg = "#913500", bg = global_bg, bold = true })
		sethighlight(0, "AbstractlineGitRemoved", { fg = "#bd1919", bg = global_bg, bold = true })
		sethighlight(0, "AbstractlineLSPDiagError", { fg = "#a81818", bg = global_bg })
		sethighlight(0, "AbstractlineLSPDiagHint", { fg = "#336481", bg = global_bg })
		sethighlight(0, "AbstractlineLSPDiagInfo", { fg = "#812900", bg = global_bg })
		sethighlight(0, "AbstractlineLSPDiagWarn", { fg = "#5d5d00", bg = global_bg })
		sethighlight(0, "AbstractlineLsprovidername", { fg = "#757575", bg = global_bg })
		sethighlight(0, "AbstractlinePsedostring", { fg = editor_bg, bg = editor_bg})
		sethighlight(0, "AbstractlineSearch", { fg = "#abab18", bg = global_bg })
		sethighlight(0, "AbstractlineSplitter", { fg = bg, bg = global_bg })
		sethighlight(0, "AbstractlineVirtualEnv", { fg = "#b44200", bg = global_bg, bold = true })
	end,
}

return M
