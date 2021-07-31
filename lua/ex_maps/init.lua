local function visual_selection_range()
	local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
	local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
	if csrow < cerow or (csrow == cerow and cscol <= cecol) then
		return csrow, cscol - 1, cerow, cecol
	else
		return cerow, cecol - 1, csrow, cscol
	end
end

local function replace(pattern, replacement)
	local startline, _, endline, _ = visual_selection_range()

	local lines = vim.api.nvim_buf_get_lines(0, startline-1, endline, false)

	for i, line in ipairs(lines) do
		local new_line = string.gsub(line, pattern, replacement)

		local current_line = startline-2+i
		local next_line = current_line+1

		vim.api.nvim_buf_set_lines(0, current_line, next_line, false, {new_line})
	end
end

local function atom_to_string(_)
	local pattern = '(%s+)(.+):'
	local replacement =	"%1\"%2\" =>"

	replace(pattern, replacement)
end

local function string_to_atom(_)
	local pattern = '\"(.+)\"(%s=>)'
	local replacement = "%1:"

	replace(pattern, replacement)
end

return {
	atom_to_string = atom_to_string,
	string_to_atom = string_to_atom
}

