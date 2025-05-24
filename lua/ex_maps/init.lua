local api = vim.api
local ts_utils = require("nvim-treesitter.ts_utils")
local converter = require("ex_maps.converter")

local M = {}

M.config = {
  create_mappings = true,
  mapping = "mtt",
}

local function find_map_node()
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

local function is_elixir_buffer()
  local filetype = vim.bo.filetype
  return filetype == "elixir" or filetype == "eelixir"
end

local function get_node_text_safe(node, bufnr)
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

M.toggle = function()
  -- Check if we're in an Elixir file
  if not is_elixir_buffer() then
    vim.notify("ex_maps: This command only works in Elixir files", vim.log.levels.WARN)
    return
  end

  -- Check if treesitter is available
  local has_treesitter, _ = pcall(require, "nvim-treesitter")
  if not has_treesitter then
    vim.notify("ex_maps: nvim-treesitter is required", vim.log.levels.ERROR)
    return
  end

  local node, error_msg = find_map_node()
  if not node then
    vim.notify("ex_maps: " .. error_msg, vim.log.levels.WARN)
    return
  end

  local start_row, start_col, end_row, end_col = node:range()
  local bufnr = vim.api.nvim_get_current_buf()

  local success, original_text = pcall(get_node_text_safe, node, bufnr)
  if not success then
    vim.notify("ex_maps: Failed to get node text: " .. tostring(original_text), vim.log.levels.ERROR)
    return
  end

  local new_lines, changed = converter.toggle_map_syntax(original_text)

  if not changed then
    vim.notify("ex_maps: No convertible syntax found in map", vim.log.levels.INFO)
    return
  end

  -- Apply the changes
  local success_set = pcall(api.nvim_buf_set_text, bufnr, start_row, start_col, end_row, end_col, new_lines)
  if not success_set then
    vim.notify("ex_maps: Failed to apply changes", vim.log.levels.ERROR)
    return
  end

  vim.notify("ex_maps: Map syntax converted successfully", vim.log.levels.INFO)
end

function M.setup(user_opts)
  M.config = vim.tbl_extend("force", M.config, user_opts or {})

  if M.config.create_mappings then
    local opts = { noremap = true, silent = true, desc = "Toggle Elixir map syntax" }
    vim.keymap.set("n", M.config.mapping, ":lua require'ex_maps'.toggle()<CR>", opts)
  end
end

return M
