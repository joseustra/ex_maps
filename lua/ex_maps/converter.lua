local M = {}

-- Patterns to handle different map key syntaxes
local atom_pattern = "([%w_][%w_]*[%?!]?):"
local string_pattern = '"([^"]*)" =>'
local string_colon_pattern = '"([^"]*)": '
local quoted_atom_pattern = ':"([^"]*)"'

local function atom_to_string(line)
  -- Handle regular atoms (name: -> "name" =>)
  local result = string.gsub(line, atom_pattern, '"%1" =>')

  -- Handle quoted atoms (:"atom" -> "atom" =>)
  result = string.gsub(result, quoted_atom_pattern, '"%1" =>')

  return result
end

local function string_to_atom(line)
  -- Convert string keys with arrows to atoms ("name" => -> name:)
  local result = string.gsub(line, string_pattern, function(capture)
    -- Check if the captured string is a valid atom (alphanumeric, underscore, ?, !)
    if capture:match("^[%w_][%w_]*[%?!]?$") then
      return capture .. ":"
    else
      -- Use quoted atom syntax for invalid atom names (contains hyphens, spaces, etc.)
      return '"' .. capture .. '":'
    end
  end)

  -- Convert string keys with colons to atoms ("name": -> name:)
  result = string.gsub(result, string_colon_pattern, function(capture)
    -- Check if the captured string is a valid atom (alphanumeric, underscore, ?, !)
    if capture:match("^[%w_][%w_]*[%?!]?$") then
      return capture .. ": "
    else
      -- Use quoted atom syntax for invalid atom names (contains hyphens, spaces, etc.)
      return '"' .. capture .. '": '
    end
  end)

  return result
end

local function string_colon_to_arrow(line)
  -- Convert string keys with colons to arrow syntax ("name": -> "name" =>)
  return string.gsub(line, string_colon_pattern, '"%1" => ')
end

local function has_atom_syntax(line)
  return line:match(atom_pattern) ~= nil or line:match(quoted_atom_pattern) ~= nil
end

local function has_string_syntax(line)
  return line:match(string_pattern) ~= nil
end

local function has_string_colon_syntax(line)
  return line:match(string_colon_pattern) ~= nil
end

local function split_text(text)
  local lines = {}

  -- Handle text that might not end with newline
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end

  -- Remove the last empty line if it was added by our newline trick
  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines)
  end

  return lines
end

-- Main conversion function that toggles between atom and string syntax
function M.toggle_map_syntax(text)
  local lines = split_text(text)
  local changed = false

  for i, line in ipairs(lines) do
    if has_atom_syntax(line) then
      lines[i] = atom_to_string(line)
      changed = true
    elseif has_string_syntax(line) then
      lines[i] = string_to_atom(line)
      changed = true
    elseif has_string_colon_syntax(line) then
      lines[i] = string_colon_to_arrow(line)
      changed = true
    end
  end

  return lines, changed
end

return M
