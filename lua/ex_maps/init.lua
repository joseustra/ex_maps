-- local M = { }

-- return M
--

local function visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow, cscol - 1, cerow, cecol
  else
    return cerow, cecol - 1, csrow, cscol
  end
end

local function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function printName(_)
	local startline, _, endline, _ = visual_selection_range()
	local atom_pattern = "^(.+):"

	local lines = vim.api.nvim_buf_get_lines(0, startline-1, endline, false)

	for i, line in ipairs(lines) do
		local new_line = string.gsub(trim(line), atom_pattern, "\"%1\" =>")

		local current_line = startline-2+i
		local next_line = current_line+1

		vim.api.nvim_buf_set_lines(0, current_line, next_line, false, {new_line})
	end
end

return {
	printName = printName
}

