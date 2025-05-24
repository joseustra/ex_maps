local api = vim.api
local converter = require("ex_maps.converter")
local nodes = require("ex_maps.nodes")

local M = {}

M.config = {
  create_mappings = true,
  mapping = "mtt",
}


M.toggle = function()
  -- Check if we're in an Elixir file
  if not nodes.is_elixir_buffer() then
    vim.notify("ex_maps: This command only works in Elixir files", vim.log.levels.WARN)
    return
  end

  -- Check if treesitter is available
  local has_treesitter, _ = pcall(require, "nvim-treesitter")
  if not has_treesitter then
    vim.notify("ex_maps: nvim-treesitter is required", vim.log.levels.ERROR)
    return
  end

  local node, error_msg = nodes.find_map_node()
  if not node then
    vim.notify("ex_maps: " .. error_msg, vim.log.levels.WARN)
    return
  end

  local start_row, start_col, end_row, end_col = node:range()
  local bufnr = vim.api.nvim_get_current_buf()

  local success, original_text = pcall(nodes.get_node_text_safe, node, bufnr)
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
  if nodes.apply_changes(node, bufnr, new_lines) then
    vim.notify("ex_maps: Map syntax converted successfully", vim.log.levels.INFO)
  end
end

function M.setup(user_opts)
  M.config = vim.tbl_extend("force", M.config, user_opts or {})

  if M.config.create_mappings then
    local opts = { noremap = true, silent = true, desc = "Toggle Elixir map syntax" }
    vim.keymap.set("n", M.config.mapping, ":lua require'ex_maps'.toggle()<CR>", opts)
  end
end

return M
