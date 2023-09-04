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
  if (delimiter == nil) then delimiter = ' ' end
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

-- Neovim Utils
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
function M.get_mode_hi()
  mode_hls = {
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

--- trashes a file
function M.trash_file(file_path, trash_cmd)
  local exec_cmd = {}

  if trash_cmd and vim.fn.executable(trash_cmd[1]) == 1 then
    M.tbl_merge(exec_cmd, trash_cmd)
  elseif vim.fn.executable('gio') == 1 then
    M.tbl_merge(exec_cmd, { 'gio', 'trash' })
  elseif vim.fn.executable('trash') == 1 then
    M.tbl_merge(exec_cmd, { 'trash' })
  else
    log.warn("no trashing utility present")
  end

  table.insert(exec_cmd, vim.fn.fnameescape(file_path))

  -- local proc_exit_code = 0
  -- vim.fn.jobstart(exec_cmd, {
  --   on_exit = function(job_id, exit_code, event_type)
  --     proc_exit_code = exit_code
  --   end
  -- })
  vim.fn.system(exec_cmd)
end

-- Stateful Utils
-- feature list class
function M.FeatureList()
  return setmetatable(
    {
      list = {},
      new = function(self) return self end,
      add = function(self, feat_type, feat_name) table.insert(self.list, feat_type .. ":" .. feat_name) end,
      add_str = function(self, feat_str) table.insert(self.list, feat_str) end,
      has = function(self, feat_type, feat_name) return vim.tbl_contains(self.list, feat_type .. ":" .. feat_name) end,
      has_str = function(self, feat_str) return vim.tbl_contains(self.list, feat_str) end,
      stitch = function(self, feat_type, feat_name) return feat_type .. ':' .. feat_name end,
      unstitch = function(self, feat)
        local feat_tbl = vim.split(feat, ':')
        if #feat_tbl == 2 then return feat_tbl end
        log.err('invalid feature', { stack_level_offset = 2 })
        return nil
      end,
    },
    {}
  )
end

--- @enum feat
feat = {
  PLUGIN = "PLUGIN",
  CONF = "CONF",
  KEY = "KEY",
  LANG = "LANG",
  LSP = "LSP",
  DAP = "DAP",
  SESSION = "SESSION",
}

--- event class
function M.Event(event_name)
  return setmetatable(
    {
      event_name = event_name,
      subscribers = {},
      new = function(self)
        vim.api.nvim_create_autocmd('User', {
          group = vim.api.nvim_create_augroup(self.event_name, {}),
          pattern = { self.event_name },
          callback = function() self:invoke() end
        })
        return self
      end,
      sub = function(self, subscriber) table.insert(self.subscribers, subscriber) end,
      -- sub_front = function(self, subscriber) table.insert(self.subscribers, 1, subscriber) end,
      invoke = function(self)
        for _, subscribers in pairs(self.subscribers) do
          if type(subscribers) == 'string' then vim.cmd(subscribers)
          elseif type(subscribers) == 'function' then subscribers() end
        end
      end,
      wrap = function(self) return function() return self:invoke() end end
    },
    {
      __call = function(self)
        return self:invoke()
      end
    }
  )
end

--- returns a service function
function M.service(...)
  local argc = select("#", ...)
  local prov_feats, req_feats, callback

  if argc == 1 then
    callback = ...
  elseif argc == 2 then
    req_feats, callback = ...
  elseif argc == 3 then
    prov_feats, req_feats, callback = ...
  end

  prov_feats = prov_feats or {}
  req_feats = req_feats or {}
  callback = callback or function(...) log.warn("empty service callback called", { stack_level_offset = 2 }) end

  return function(...)
    -- ensure required features
    for _, req_feat in pairs(req_feats) do
      if (not feat_list:has(req_feat[1], req_feat[2])) then
        log.warn("missing feature: " .. table.concat(req_feat, ' / '), { stack_level_offset = 1 })
        return
      end
    end

    -- invoke callback
    local return_val = callback(...)

    -- add provided features
    for _, prov_feat in pairs(prov_feats) do
      feat_list:add(prov_feat[1], prov_feat[2])
    end
    return return_val
  end
end

-- vim.cmd [[autocmd User MyPlugin lua log('got MyPlugin event')]]

return M
