-- lua/tabdiff.lua
local M = {}

local function set_buf_opt(buf, name, value)
	vim.api.nvim_set_option_value(name, value, { buf = buf })
end

local function get_tab_current_buf(tabnr)
	local tabs = vim.api.nvim_list_tabpages()
	local tab = tabs[tabnr]
	local win = vim.api.nvim_tabpage_get_win(tab)
	return vim.api.nvim_win_get_buf(win)
end

local function buf_to_lines(buf)
	return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

local function make_scratch_from_lines(lines, name)
	local b = vim.api.nvim_create_buf(false, true) -- listed=false, scratch=true
	vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)

	set_buf_opt(b, "buftype", "nofile")
	set_buf_opt(b, "bufhidden", "wipe")
	set_buf_opt(b, "swapfile", false)
	set_buf_opt(b, "modifiable", false)

	pcall(vim.api.nvim_buf_set_name, b, name)
	return b
end

function M.tabdiff()
	local tabs = vim.api.nvim_list_tabpages()
	if #tabs < 2 then
		error("Tabdiff: need at least 2 tabpages (tab 1 and tab 2).")
	end

	local buf1 = get_tab_current_buf(1)
	local buf2 = get_tab_current_buf(2)

	local s1 = make_scratch_from_lines(buf_to_lines(buf1), "tabdiff://tab1")
	local s2 = make_scratch_from_lines(buf_to_lines(buf2), "tabdiff://tab2")

	-- New (third) tab with a diff split
	vim.cmd("tabnew")
	vim.api.nvim_win_set_buf(0, s1)
	vim.cmd("diffthis")

	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, s2)
	vim.cmd("diffthis")

	vim.cmd("setlocal number")
	vim.cmd("setlocal norelativenumber")
end

function M.setup()
	vim.api.nvim_create_user_command("Tabdiff", function()
		M.tabdiff()
	end, {})
end

return M
