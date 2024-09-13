local M = {}

-- Lua Utils
--- converts argument to hex format.
function M.to_hex(n) if n then return string.format("#%06x", n) end end

--- generates a sequence
function M.seq(min, max, sep, step)
  step = step or 1
  local res = ""
  for i = min, max, step do
    res = res .. i
    if (i ~= max) then res = res .. sep end
  end
  return res
end

--- checks if number is within min - max range
function M.is_within_range(n, min, max) return ((n >= min) and (n <= max)) end

--- returns joined array into string
function M.join(arr, delimiter)
  delimiter = delimiter or ' '
  local str = ""
  for i, v in ipairs(arr) do
    str = str .. arr[i]
    if (i < #arr) then str = str .. delimiter end
  end
  return str
end

--- writes content to file
function M.file_write(path, content)
  path = vim.fs.normalize(path)
  local fh = assert(io.open(path, "wb"))
  fh:write(content)
  fh:flush()
  fh:close()
end

--- reads file content
function M.file_read(path)
  path = vim.fs.normalize(path)
  local fh = assert(io.open(path, "rb"))
  local content = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
  fh:close()
  return content
end

--- deletes a file
function M.file_del(path)
  local success, error_message = os.remove(path)

  if success then
    return true
  else
    log.err("error deleting file: " .. error_message)
    return false
  end
end

--- renames a file
function M.file_rename(path, new_file_name)
  local old_file_path = path
  local path_arr = vim.split(path, '/')
  path_arr[#path_arr] = new_file_name
  local new_file_path = table.concat(path_arr, '/')

  local success, error_message = os.rename(old_file_path, new_file_path)

  if success then
    return true
  else
    log.err("error renaming file: " .. error_message)
    return false
  end
end

--- gets absolute path from a relative one
function M.get_absolute_path(rel_path)
  return vim.fn.fnamemodify(rel_path, ':p')
end

--- gets relative path from an absolute one
function M.get_relative_path(abs_path)
  return vim.fn.fnamemodify(abs_path, ':.')
end

--- returns boolean if a file exists or not
function M.is_file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'file'
end

--- returns boolean if a directory exists or not
function M.is_dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'directory'
end

--- returns array of file_names within a path
function M.scan_dir(path)
  local res = {}
  handle, _ = vim.loop.fs_scandir(path)
  if not handle then return {} end
  file_name, _ = vim.loop.fs_scandir_next(handle)
  while file_name do
    table.insert(res, file_name)
    file_name, _ = vim.loop.fs_scandir_next(handle)
  end
  return res
end

--- returns the intersection of 2 flat tables
function M.tbl_intersect(tbl1, tbl2)
  local intersection = {}

  for _, v1 in pairs(tbl1) do
    for _, v2 in pairs(tbl2) do
      if v1 == v2 then table.insert(intersection, v1) end
    end
  end
  return intersection
end

--- returns the union of 2 flat tables with not repeats
function M.tbl_union(tbl1, tbl2)
  local result = {}
  local hash = {}
  for _, v in pairs(tbl1) do
    if not hash[v] then
      table.insert(result, v)
      hash[v] = true
    end
  end
  for _, v in pairs(tbl2) do
    if not hash[v] then
      table.insert(result, v)
      hash[v] = true
    end
  end
  return result
end

--- returns the merge of 2 flat tables
function M.tbl_merge(tbl1, tbl2)
  for i = 1, #tbl2 do
    table.insert(tbl1, tbl2[i])
  end
  return tbl1
end

--- returns the reverse of a table
function M.tbl_reverse(tbl)
  for i = 1, math.floor(#tbl / 2) do
    local j = #tbl - i + 1
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

--- returns the string left padded
function M.str_pad(str, width, char, right_side)
  right_side = right_side or false
  local pad_len = width - #str

  if pad_len > 0 then
    if not right_side then
      return string.rep(char, pad_len) .. str
    else
      return str .. string.rep(char, pad_len)
    end
  else
    return str
  end
end

--- returns current git branch name
function M.get_curr_git_branch()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  if branch == "" then return nil end
  return branch
end


-- Neovim Utils
--- returns the extmarks of the current line within a specific namespace
M.get_lnum_extmark_signs = function(ns, trim, lnum)
  trim = trim or false
  lnum = lnum and lnum-1 or vim.v.lnum-1

  local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, {lnum, 0}, {lnum, 0}, { type = "sign", details = true })
  local signs = {}

  if extmarks then
    signs = vim.tbl_map(function(extmark)
      -- extmark[4] is sign data
      local sign = extmark[4]
      if sign then

        if trim and sign.sign_text and #sign.sign_text > 1 then
          -- trim the last character
          sign.sign_text = sign.sign_text:sub(1, -2)
        end

        return sign
      end
    end, extmarks)
  end

  return signs
end

--- returns the (strongest) severity level of the current line diagnostics (nil if none)
M.get_lnum_diag_severity = function()
  diagnostics = vim.diagnostic.get(0, { lnum = vim.v.lnum - 1 })

  local severity_level = nil

  for i, diag in ipairs(diagnostics) do
    if severity_level == nil then
      severity_level = diag.severity
    else if diag.severity < severity_level then
        severity_level = diag.severity
      end
    end
  end

  return severity_level
end

--- return if a file size is considered huge
function M.is_file_huge(file_path)
  -- local huge_buffer_size = 1000000 -- 1MB
  local huge_buffer_size = 100000 -- 100KB

  local size = vim.fn.getfsize(file_path)
  return size > huge_buffer_size

  -- local ok, stats = pcall(vim.loop.fs_stat, file_path)
  -- if ok and stats then return stats.size > huge_buffer_size end
end

--- return if a buffer size is considered huge
function M.is_buf_huge(buf)
  local fname = vim.api.nvim_buf_get_name(buf)

  if #fname <= 0 then
    return false
  end

  return M.is_file_huge(vim.api.nvim_buf_get_name(buf))
end

--- returns current vim mode name
function M.get_mode_name()
  local mode_names = {
    n         = "no",
    no        = "n?",
    nov       = "n?",
    noV       = "n?",
    ["no\22"] = "n?",
    niI       = "ni",
    niR       = "nr",
    niV       = "nv",
    nt        = "nt",
    v         = "vi",
    vs        = "vs",
    V         = "v_",
    Vs        = "vs",
    ["\22"]   = "^V",
    ["\22s"]  = "^V",
    s         = "se",
    S         = "s_",
    ["\19"]   = "^S",
    i         = "in",
    ic        = "ic",
    ix        = "ix",
    R         = "re",
    Rc        = "rc",
    Rx        = "rx",
    Rv        = "rv",
    Rvc       = "rv",
    Rvx       = "rv",
    c         = "co",
    cv        = "ex",
    r         = "..",
    rm        = "m.",
    ["r?"]    = "??",
    ["!"]     = "!!",
    t         = "te",
  }
  return mode_names[vim.api.nvim_get_mode().mode]
end

--- returns current vim mode highlight
function M.get_mode_hl()
  local mode_hls = {
    n       = 'NormalMode',
    i       = 'InsertMode',
    v       = 'VisualMode',
    V       = 'VisualMode',
    ['\22'] = 'VisualMode',
    c       = 'CommandMode',
    s       = 'SelectMode',
    S       = 'SelectMode',
    ['\19'] = "SelectMode",
    R       = 'ControlMode',
    r       = 'ControlMode',
    ['!']   = 'NormalMode',
    t       = 'TerminalMode',
  }

  return mode_hls[vim.api.nvim_get_mode().mode]
end

--- returns cursor line number/s
function M.get_cursor_pos()
  local _, ls, cs = unpack(vim.fn.getpos('v'))
  local _, le, ce = unpack(vim.fn.getpos('.'))
  return ls, cs, le, ce
end

--- returns cursor line text
function M.get_cursor_text()
  local ls, cs, le, ce = M.get_cursor_pos()
  return vim.api.nvim_buf_get_text(0, ls-1, cs-1, le-1, ce, {})
end

--- returns hilight group name or fallback
function M.get_hl_fallback(group, fallback)
  if vim.fn.hlexists(group) == 1 then
    return group
  else
    return fallback
  end
end

--- returns a table containing the lsp changes counts from an lsp result
function M.count_lsp_res_changes(lsp_res)
  local count = { instances = 0, files = 0 }
  if (lsp_res.documentChanges) then
    for _, changed_file in pairs(lsp_res.documentChanges) do
      count.files = count.files + 1
      count.instances = count.instances + #changed_file.edits
    end
  elseif (lsp_res.changes) then
    for _, changed_file in pairs(lsp_res.changes) do
      count.instances = count.instances + #changed_file
      count.files = count.files + 1
    end
  end
  return count
end

--- clears the command prompt
function M.clear_prompt() vim.cmd([[echo '' | redraw]]) end

--- changes the guifont by a step, with min and max bounds
function M.change_guifont_size(amount, min, max, is_amount_delta)
  is_amount_delta = is_amount_delta or false
  vim.opt.guifont = string.gsub(vim.opt.guifont._value, ":h(%d+)", function(n)
    local size = amount
    if is_amount_delta then size = n + amount end
    if size < min then size = min elseif size > max then size = max end
    return string.format(":h%d", size)
  end)
end

--- returns nth field of a segmented string (much like unix cut) (omit field to return full array, fields <= 0 count from the end)
function M.cut(str, delimiter, field)
  delimiter = delimiter or ' '
  local arr = vim.split(str, delimiter)
  if (field ~= nil) then
    if (field > 0) then return arr[field] else return arr[#arr + field] end
  else
    return arr
  end
end

--- prompts a multiple choice confirmation prompt
function M.confirm(msg, choices)
  choices = M.join(choices, '\n')
  local ok, answer = pcall(vim.fn.confirm, msg, choices)
  if ok then return answer end
end

--- prompts a yes/no confirmation prompt
function M.confirm_yes_no(msg)
  return true and M.confirm(msg, { 'Yes', 'No' }) == 1 or false
end

--- moves cursor position if the jump file is the current buffer if not then print jump location
-- TODO: abort if jump line or column is out of range
function M.request_jump(target_path, line, col)
  target_path = vim.fs.normalize(target_path)
  local buf_path = vim.fs.normalize(vim.fn.expand('%:p'))
  if (target_path == buf_path) then
    vim.api.nvim_win_set_cursor(0, { line, col })
    print('jumping to ' .. tostring(line) .. ':' .. tostring(col))
  else
    print('jump attempt to ' .. tostring(line) .. ':' .. tostring(col) .. ' in ' .. vim.fs.basename(target_path))
  end
end
return M
