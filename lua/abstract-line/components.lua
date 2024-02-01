local M = {}

local funcs = require("abstract-line.funcs")

function M.splitter(icon)
	return "%#AbstractlineSplitter#" .. icon .. "%*"
end

function M.vim_mode()
	local mode = vim.api.nvim_get_mode().mode
	mode = string.upper(mode)
	return " " .. "%#AbstractlineMode#" .. mode .. "%*" .. " "
end

function M.file_info()
	local modified_flag = ""
	local readonly_flag = ""
	if vim.bo.modified then
		modified_flag = "● "
	end
	if vim.bo.readonly then
		readonly_flag = "🔒"
	end

	local file_name = vim.api.nvim_buf_get_name(0)
	local file = readonly_flag .. vim.fn.pathshorten(vim.fn.fnamemodify(file_name, ":~:."))

	local fileicon = funcs.get_filetype_icon()
	if fileicon then
		local icon_filetype = "%#AbstractlineFilenameIcon#" .. fileicon.icon .. " " .. "%*"
		file = "%#AbstractlineFilename#" .. " " .. file .. " " .. icon_filetype .. "%*"
	end

	return file .. "%#AbstractlineFilemodify#" .. modified_flag .. "%*"
end

function M.virtualenv_status()
	local _, name_with_path = pcall(os.getenv, "VIRTUAL_ENV")
	if name_with_path == nil then
		return ""
	end
	local venv = {}
	for match in (name_with_path .. "/"):gmatch("(.-)" .. "/") do
		table.insert(venv, match)
	end
	return "%#AbstractlineVirtualEnv#" .. "" .. venv[#venv] .. "%*"
end

function M.git_status()
	local head = vim.b.gitsigns_head or ""
	if head == "" then
		return ""
	end
	local git_signs = vim.b.gitsigns_status_dict
	local icon = " "
	local sign_added = ""
	local sign_changed = ""
	local sign_removed = ""

	if git_signs then
		local sa = git_signs["added"] or 0
		local sr = git_signs["removed"] or 0
		local sc = git_signs["changed"] or 0

		if sa > 0 then
			sign_added = "%#AbstractlineGitAdded#" .. "+" .. tostring(sa) .. "%*"
		end
		if sc > 0 then
			sign_changed = "%#AbstractlineGitChanged#" .. "~" .. tostring(sc) .. "%*"
		end
		if sr > 0 then
			sign_removed = "%#AbstractlineGitRemoved#" .. "-" .. tostring(sr) .. "%*"
		end
	end
	local signs = sign_added .. sign_changed .. sign_removed
	local result = "%#AbstractlineGit#" .. icon .. head .. "%*"
	if signs ~= "" then
		result = result .. "" .. signs
	end
	return " " .. result
end

function M.get_filesize()
	-- https://github.com/echasnovski/mini.nvim/blob/793d40f807b3c0f959f19d15cc2fe814dc16938b/lua/mini/statusline.lua#L553
	local size = vim.fn.getfsize(vim.fn.getreg("%"))
	local result
	if size < 1 then
		result = string.format("%dB ", 0)
	elseif size < 1024 then
		result = string.format("%dB ", size)
	elseif size < 1048576 then
		result = string.format("%.2fK ", size / 1024)
	else
		result = string.format("%.2fM ", size / 1048576)
	end
	return " " .. "%#AbstractlineFilesize#" .. result .. "%*"
end

function M.search_info()
	-- thanks: https://github.com/nvim-lualine/lualine.nvim/issues/186#issuecomment-1170637440
	local final = ""
	local hlsearch = vim.api.nvim_get_vvar("hlsearch")
	if hlsearch == nil then
		goto empty
	end
	if hlsearch == 1 then
		local result = vim.fn.searchcount({ maxcount = 999, timeout = 1000 })
		local total = result.total
		if total == nil then
			goto empty
		end
		if total > 0 then
			local search_string = vim.fn.getreg("/")
			final = string.format("%s %d/%d", search_string, result.current, total)
		end
	end
	::empty::
	return "%#AbstractlineSearch#" .. final .. "%*" .. " "
end

function M.line_info()
	local loc = vim.api.nvim_buf_line_count(0) -- total lines of code in current file
	local line_col = vim.fn.col(".")
	local curr_line_num = vim.api.nvim_win_get_cursor(0)[1]
	if curr_line_num == nil then
		return
	end

	local loc_percentage = math.ceil((100 * curr_line_num) / loc)
	return string.format("  %2d%%%%(%d) ℂ%2d", loc_percentage, loc, line_col)
end

function M.lsp_diagnostics_count()
	local diagnostic = vim.diagnostic

	local error = diagnostic.severity.ERROR
	local warn = diagnostic.severity.WARN
	local info = diagnostic.severity.INFO
	local hint = diagnostic.severity.HINT

	local count_error = vim.tbl_count(diagnostic.get(0, error and { severity = error }))
	local count_warn = vim.tbl_count(diagnostic.get(0, warn and { severity = warn }))
	local count_info = vim.tbl_count(diagnostic.get(0, info and { severity = info }))
	local count_hint = vim.tbl_count(diagnostic.get(0, hint and { severity = hint }))

	return {
		count_error = count_error,
		count_warn = count_warn,
		count_info = count_info,
		count_hint = count_hint,
	}
end

function M.lsp_provider()
	local msg = ""
	local clients = vim.lsp.get_active_clients()
	if next(clients) == nil then
		return msg
	end

	local lsp_diag = M.lsp_diagnostics_count()
	local count_error = lsp_diag.count_error
	local count_warn = lsp_diag.count_warn
	local count_info = lsp_diag.count_info
	local count_hint = lsp_diag.count_hint
	local sign_added, sign_changed, sign_removed, sign_hint = "", "", "", ""

	if count_error > 0 then
		sign_added = "%#AbstractlineLSPDiagError#" .. "  " .. tostring(count_error) .. "%*"
	end
	if count_warn > 0 then
		sign_changed = "%#AbstractlineLSPDiagWarn#" .. "  " .. tostring(count_warn) .. "%*"
	end
	if count_info > 0 then
		sign_removed = "%#AbstractlineLSPDiagInfo#" .. "  " .. tostring(count_info) .. "%*"
	end
	if count_hint > 0 then
		sign_hint = "%#AbstractlineLSPDiagHint#" .. " " .. tostring(count_hint) .. "%*"
	end

	-- local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
	-- for _, client in ipairs(clients) do
	-- 	local filetypes = client.config.filetypes
	-- 	if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
	-- 		if client.name ~= "null-ls" then
	-- 			local sign_count = sign_added .. sign_changed .. sign_removed .. sign_hint
	-- 			local msg1 = sign_count .. " " .. "%#AbstractlineLsprovidername#" .. "  " .. "%*"
	-- 			msg = msg1 .. "%#AbstractlineLsprovidername#" .. client.name .. "%*"
	-- 			goto final
	-- 		end
	-- 	end
	-- end
	local _clients = {}
	for _, client in pairs(clients) do
		if client.name ~= "null-ls" then
			_clients[#_clients + 1] = client.name
		end
	end

	local sign_count = sign_added .. sign_changed .. sign_removed .. sign_hint
	local msg1 = sign_count .. " " .. "%#AbstractlineLsprovidername#" .. "  " .. "%*"
	msg = msg1 .. "%#AbstractlineLsprovidername#" .. table.concat(_clients, "+") .. "%*"

	::final::
	return msg
end

return M
