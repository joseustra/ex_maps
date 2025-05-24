local api = vim.api
local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

function M.find_map_node()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return nil, "No node found at cursor"
  end

  local current = node
  local max_iterations = 20 -- Prevent infinite loops
  local iterations = 0

  while current and iterations < max_iterations do
    if current:type() == "map" then
      return current, nil
    end
    current = current:parent()
    iterations = iterations + 1
  end

  return nil, "No map found at cursor position"
end

function M.is_elixir_buffer()
  local filetype = vim.bo.filetype
  return filetype == "elixir" or filetype == "eelixir"
end

function M.get_node_text_safe(node, bufnr)
  -- Try different API versions
  local get_node_text = vim.treesitter.get_node_text
  if get_node_text then
    return get_node_text(node, bufnr)
  end

  -- Fallback for older versions
  get_node_text = vim.treesitter.query.get_node_text
  if get_node_text then
    return get_node_text(node, bufnr)
  end

  -- Manual fallback
  local start_row, start_col, end_row, end_col = node:range()
  local lines = api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
  return table.concat(lines, "\n")
end

-- Apply changes to a node
function M.apply_changes(node, bufnr, new_lines)
  local start_row, start_col, end_row, end_col = node:range()
  
  local success = pcall(api.nvim_buf_set_text, bufnr, start_row, start_col, end_row, end_col, new_lines)
  if not success then
    vim.notify("ex_maps: Failed to apply changes", vim.log.levels.ERROR)
    return false
  end
  
  return true
end

return M
