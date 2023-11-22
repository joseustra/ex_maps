local api = vim.api
local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

M.config = {
  create_mappings = true,
  mapping = "mtt",
}

local atom_pattern = "([%w|_]*):"
local string_pattern = '"([%w|%p]*)" =>'

local function atom_to_string(line)
  local replacement = '"%1" =>'

  return string.gsub(line, atom_pattern, replacement)
end

local function string_to_atom(line)
  local replacement = "%1:"

  return string.gsub(line, string_pattern, replacement)
end

local function replace(text)
  local lines = {}
  for line in text:gmatch("[^\n]+") do
    table.insert(lines, line)
  end

  for i, line in ipairs(lines) do
    if line:match(atom_pattern) then
      lines[i] = atom_to_string(line)
    else
      lines[i] = string_to_atom(line)
    end
  end

  return lines
end

local function get_node()
  local node = ts_utils.get_node_at_cursor()
  local parent = node:parent()

  while node:type() ~= "map" do
    node = parent
    parent = node:parent()
  end

  return node
end

M.toggle = function()
  local node = get_node()
  local start_row, start_col, end_row, end_col = node:range()
  local bufnr = vim.api.nvim_get_current_buf()

  local get_node_text = vim.treesitter.get_node_text or vim.treesitter.query.get_node_text
  local text = replace(get_node_text(node, bufnr))

  api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, text)
end

function M.setup(user_opts)
  M.config = vim.tbl_extend("force", M.config, user_opts or {})

  if M.config.create_mappings then
    local opts = { noremap = true, silent = true }

    api.nvim_set_keymap("n", M.config.mapping, ":lua require'ex_maps'.toggle()<CR>", opts)
  end
end

return M
