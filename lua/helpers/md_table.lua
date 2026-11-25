-- this essentially "pretty prints" a markdown table (visual range, or table under cursor)
-- it pads every cell to its column width and honors :-- :-: --: alignment markers

local M = {}


-- parsing
local function split_row(line)
  local s = vim.trim(line):gsub("^|", "")
  if s:sub(-1) == "|" and s:sub(-2, -2) ~= "\\" then s = s:sub(1, -2) end

  -- NOTE: split on unescaped pipes only, `\|` stays part of the cell
  local cells, cur, i = {}, {}, 1
  while i <= #s do
    local c = s:sub(i, i)
    if c == "\\" and i < #s then
      table.insert(cur, s:sub(i, i + 1))
      i = i + 2
    elseif c == "|" then
      table.insert(cells, vim.trim(table.concat(cur)))
      cur = {}
      i = i + 1
    else
      table.insert(cur, c)
      i = i + 1
    end
  end
  table.insert(cells, vim.trim(table.concat(cur)))

  return cells
end

local function is_separator(cells)
  for _, c in ipairs(cells) do
    if not c:match("^:?%-+:?$") then return false end
  end
  return true
end

local function alignment_of(cell)
  local l, r = cell:sub(1, 1) == ":", cell:sub(-1) == ":"
  if l and r then return "center" end
  if r then return "right" end
  if l then return "left" end
  return "none"
end


-- rendering
local function pad(text, width, align)
  local gap = width - vim.fn.strdisplaywidth(text)
  if align == "right" then return (" "):rep(gap) .. text end
  if align == "center" then
    local l = math.floor(gap / 2)
    return (" "):rep(l) .. text .. (" "):rep(gap - l)
  end
  return text .. (" "):rep(gap)
end

local function separator_cell(width, align)
  if align == "left" then return ":" .. ("-"):rep(width - 1) end
  if align == "right" then return ("-"):rep(width - 1) .. ":" end
  if align == "center" then return ":" .. ("-"):rep(width - 2) .. ":" end
  return ("-"):rep(width)
end

function M.format_lines(lines)
  local indent = lines[1]:match("^%s*")

  local rows = vim.tbl_map(split_row, lines)

  -- NOTE: first row is always the header. this inserts a separator if the table has none
  local aligns = {}
  if rows[2] and is_separator(rows[2]) then
    aligns = vim.tbl_map(alignment_of, table.remove(rows, 2))
  end

  local ncols = 0
  for _, row in ipairs(rows) do ncols = math.max(ncols, #row) end

  local widths = {}
  for j = 1, ncols do
    aligns[j] = aligns[j] or "none"
    widths[j] = 3
    for _, row in ipairs(rows) do
      row[j] = row[j] or ""
      widths[j] = math.max(widths[j], vim.fn.strdisplaywidth(row[j]))
    end
  end

  local function render(cells)
    return indent .. "| " .. table.concat(cells, " | ") .. " |"
  end

  local out = {}
  for i, row in ipairs(rows) do
    local cells = {}
    for j = 1, ncols do cells[j] = pad(row[j], widths[j], aligns[j]) end
    table.insert(out, render(cells))

    if i == 1 then
      local sep = {}
      for j = 1, ncols do sep[j] = separator_cell(widths[j], aligns[j]) end
      table.insert(out, render(sep))
    end
  end

  return out
end


-- range helpers
local function is_table_line(line)
  return line:find("|", 1, true) ~= nil
end

local function table_around_cursor(buf)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local last = vim.api.nvim_buf_line_count(buf)
  local function line_at(n) return vim.api.nvim_buf_get_lines(buf, n - 1, n, true)[1] end

  if not is_table_line(line_at(cur)) then return nil end

  local s, e = cur, cur
  while s > 1 and is_table_line(line_at(s - 1)) do s = s - 1 end
  while e < last and is_table_line(line_at(e + 1)) do e = e + 1 end
  return s, e
end


function M.format_range(buf, start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, true)

  -- ignore blank lines caught at the edges of the selection
  while #lines > 0 and vim.trim(lines[1]) == "" do
    table.remove(lines, 1)
    start_line = start_line + 1
  end
  while #lines > 0 and vim.trim(lines[#lines]) == "" do
    table.remove(lines)
    end_line = end_line - 1
  end

  if #lines == 0 then
    vim.notify("MDTable: no table in range", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_buf_set_lines(buf, start_line - 1, end_line, true, M.format_lines(lines))
end

vim.api.nvim_create_user_command("MDTable", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  if opts.range > 0 then
    return M.format_range(buf, opts.line1, opts.line2)
  end

  local start_line, end_line = table_around_cursor(buf)
  if not start_line then
    vim.notify("MDTable: cursor is not on a table", vim.log.levels.WARN)
    return
  end

  M.format_range(buf, start_line, end_line)
end, { range = true, desc = "Pretty-print the markdown table in range / under cursor" })


return M
