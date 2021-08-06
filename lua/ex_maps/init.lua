local api = vim.api

local M = {}

M.config = {
	create_mappings = true,
	line_mapping = "mtt",
	operator_mapping = "mt",
}

local atom_pattern = '(%S*):'
local string_pattern = '\"(.+)\"(%s=>)'

function M.operator(mode)
	local line1, line2

  if not mode then
    line1 = api.nvim_win_get_cursor(0)[1]
    line2 = line1
  elseif mode:match("[vV]") then
    line1 = api.nvim_buf_get_mark(0, "<")[1]
    line2 = api.nvim_buf_get_mark(0, ">")[1]
  else
    line1 = api.nvim_buf_get_mark(0, "[")[1]
    line2 = api.nvim_buf_get_mark(0, "]")[1]
  end

	M.toggle(line1, line2)
end

local function atom_to_string(line)
	local replacement =	"\"%1\" =>"

	return string.gsub(line, atom_pattern, replacement)
end

local function string_to_atom(line)
	local replacement = "%1:"

	return string.gsub(line, string_pattern, replacement)
end

local function replace(startline, endline)
	local lines = api.nvim_buf_get_lines(0, startline-1, endline, false)
	if not lines then return end

	for i, line in ipairs(lines) do
		if line:match(atom_pattern) then
			lines[i] = atom_to_string(line)
		else
			lines[i] = string_to_atom(line)
		end
	end

	api.nvim_buf_set_lines(0, startline-1, endline, false, lines)
end

function M.toggle(line1, line2)
	replace(line1, line2)
end

function M.setup(user_opts)
  M.config = vim.tbl_extend('force', M.config, user_opts or {})

  local vim_func = [[
  function! MapOperator(type) abort
    let reg_save = @@
    execute "lua require('ex_maps').operator('" . a:type. "')"
    let @@ = reg_save
  endfunction
  ]]
  vim.api.nvim_call_function("execute", {vim_func})
  vim.api.nvim_command("command! -range MapToggle lua require('ex_maps').toggle(<line1>, <line2>)")

  if M.config.create_mappings then
    local opts = {noremap = true, silent = true}

    api.nvim_set_keymap("n", M.config.line_mapping, "<Cmd>set operatorfunc=MapOperator<CR>g@l", opts)
    api.nvim_set_keymap("n", M.config.operator_mapping, "<Cmd>set operatorfunc=MapOperator<CR>g@", opts)
    api.nvim_set_keymap("v", M.config.operator_mapping, ":<C-u>call MapOperator(visualmode())<CR>", opts)
  end
end

return M
