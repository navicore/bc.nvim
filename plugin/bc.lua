-- bc.nvim - Simple calculator plugin using bc for markdown files

local function evaluate_bc()
  -- Check if we're in a markdown file
  if vim.bo.filetype ~= 'markdown' then
    vim.notify("Bc command only works in markdown files", vim.log.levels.WARN)
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

  -- Execute bc
  local handle = io.popen("echo '" .. expression .. "' | bc 2>&1")
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

  -- Replace the selection with expression = result
  local replacement = expression .. " = " .. result

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
  desc = "Evaluate visual selection with bc and append result (markdown only)"
})
