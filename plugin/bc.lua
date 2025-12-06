-- bc.nvim - Simple calculator plugin using bc for markdown files

-- Detect formatting: returns { has_dollar = bool, has_commas = bool, scale = number }
local function detect_format(expr)
  local has_dollar = expr:match("%$") ~= nil
  local has_commas = expr:match("%d,") ~= nil

  -- Determine scale for bc
  local scale = 0
  if has_dollar then
    -- Currency always gets 2 decimal places
    scale = 2
  else
    -- Find max decimal places in any number in the expression
    for decimals in expr:gmatch("%.(%d+)") do
      if #decimals > scale then
        scale = #decimals
      end
    end
  end

  return {
    has_dollar = has_dollar,
    has_commas = has_commas,
    scale = scale,
  }
end

-- Strip financial formatting for bc
local function strip_format(expr)
  local stripped = expr:gsub("%$", "")
  stripped = stripped:gsub(",", "")
  return stripped
end

-- Add commas to a number string
local function add_commas(num_str)
  -- Split into integer and decimal parts
  local int_part, dec_part = num_str:match("^(-?%d+)(%.?%d*)$")
  if not int_part then
    return num_str
  end

  -- Add commas to integer part (from right to left)
  local formatted = ""
  local count = 0
  for i = #int_part, 1, -1 do
    local c = int_part:sub(i, i)
    if c:match("%d") then
      count = count + 1
      if count > 3 and count % 3 == 1 then
        formatted = "," .. formatted
      end
    end
    formatted = c .. formatted
  end

  return formatted .. dec_part
end

-- Apply formatting to result based on detected format
local function apply_format(result, fmt)
  local formatted = result

  -- Ensure proper decimal places for currency
  if fmt.has_dollar and fmt.scale == 2 then
    -- Make sure we have exactly 2 decimal places
    if not formatted:match("%.") then
      formatted = formatted .. ".00"
    elseif formatted:match("%.$") then
      formatted = formatted .. "00"
    elseif formatted:match("%.%d$") then
      formatted = formatted .. "0"
    end
  end

  if fmt.has_commas then
    formatted = add_commas(formatted)
  end

  if fmt.has_dollar then
    formatted = "$" .. formatted
  end

  return formatted
end

local function evaluate_bc()
  -- Check if we're in a markdown or telekasten file
  local ft = vim.bo.filetype
  if ft ~= 'markdown' and ft ~= 'telekasten' then
    vim.notify("Bc command only works in markdown/telekasten files", vim.log.levels.WARN)
    return
  end

  -- Get the visual selection marks
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local start_col = vim.fn.col("'<")
  local end_col = vim.fn.col("'>")

  -- Get the selected text
  local lines = vim.fn.getline(start_line, end_line)

  if #lines == 0 then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  -- Extract the exact selection
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    -- Multi-line selection (unlikely for math, but handle it)
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  local expression = table.concat(lines, " ")

  -- Clean up the expression
  expression = expression:gsub("^%s+", ""):gsub("%s+$", "")

  -- Detect financial formatting before stripping
  local fmt = detect_format(expression)

  -- Strip formatting for bc
  local bc_expr = strip_format(expression)

  -- Prepend scale if needed for decimal results
  if fmt.scale > 0 then
    bc_expr = "scale=" .. fmt.scale .. "; " .. bc_expr
  end

  -- Execute bc
  local handle = io.popen("echo '" .. bc_expr .. "' | bc 2>&1")
  if not handle then
    vim.notify("Failed to execute bc", vim.log.levels.ERROR)
    return
  end

  local result = handle:read("*a")
  handle:close()

  -- Trim whitespace from result
  result = result:gsub("^%s+", ""):gsub("%s+$", "")

  -- Check if bc returned an error
  if result:match("error") or result == "" then
    vim.notify("bc error: " .. result, vim.log.levels.ERROR)
    return
  end

  -- Apply formatting to result
  local formatted_result = apply_format(result, fmt)

  -- Replace the selection with expression = result
  local replacement = expression .. " = " .. formatted_result

  -- Get the line content and replace the selected portion
  local line = vim.fn.getline(start_line)
  local before = string.sub(line, 1, start_col - 1)
  local after = string.sub(line, end_col + 1)
  local new_line = before .. replacement .. after

  vim.fn.setline(start_line, new_line)

  -- Delete additional lines if it was a multi-line selection
  if end_line > start_line then
    vim.cmd(string.format("%d,%dd", start_line + 1, end_line))
  end
end

-- Create the :Bc command (only available with visual range)
vim.api.nvim_create_user_command('Bc', evaluate_bc, {
  range = true,
  desc = "Evaluate visual selection with bc and append result (markdown/telekasten)"
})
