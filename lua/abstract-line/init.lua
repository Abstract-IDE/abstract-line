local M = {}

local configs = require("abstract-line.configs")
local components = require("abstract-line.components")

function AbstractLine()
	local filetype = vim.bo.filetype

	if vim.tbl_contains(configs.exclude_filetypes, filetype) then
		-- a hack to make statusline line invisiable on alpha
		if filetype == "alpha" then
			local c = "--------------------------------------"
			for _ = 1, 4 do
				c = c .. c
			end
			return "%#AbstractlinePsedostring#" .. c .. "%*"
		end
		return "%f"
	end

	return table.concat({
		-- ━━━━━━━━━━━━━━━━❰ LEFT ❱━━━━━━━━━━━━━━━━ --
		components.vim_mode(),
		components.splitter(""),
		components.file_info(),
		components.splitter(""),
		components.get_filesize(),
		components.virtualenv_status(),
		components.git_status(),

		-- ━━━━━━━━━━━━━━━❰ MIDDLE ❱━━━━━━━━━━━━━━━ --
		"%=",
		components.lsp_provider(),

		-- ━━━━━━━━━━━━━━━━❰ RIGHT ❱━━━━━━━━━━━━━━━ --
		"%=",
		components.search_info(),
		"%#Abstractline#",
		components.line_info(),
		"%*",
	})
end

function M.setup()
	configs.highlight.init_highlight(true)

	vim.api.nvim_create_augroup("AbstractLineAutoGroup", { clear = true })
	vim.api.nvim_create_autocmd({
		"BufWinEnter",
		"BufWinLeave",
		"BufWritePost",
		"CursorHold",
		"CursorHoldI",
		"CursorMoved",
		"CursorMovedI",
		"FileWritePost",
		"FocusGained",
		"FocusLost",
		"TabEnter",
		"TabNewEntered",
		"VimResized",
		"WinClosed",
		"WinEnter",
		"WinLeave",
		"WinNew",
		"WinScrolled",
	}, {
		desc = "Load AbstractLine",
		pattern = "*",
		group = "AbstractLineAutoGroup",
		callback = function()
			configs.highlight.init_highlight(false)
			pcall(vim.api.nvim_set_option_value, "statusline", AbstractLine(), { scope = "local" })
		end,
	})
end

return M
