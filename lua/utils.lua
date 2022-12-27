--- defines various utility functions and classes.
-- @module utils
log = require 'logger'.log

local M = {}

-- Lua Utils
--- converts argument to hex format.
function M.to_hex(n) if n then return string.format("#%06x", n) end end
--- generates a sequence
function M.seq(min, max, sep, step)
  step = step or 1
  local res = ""
  for i = min, max, step do
    res = res..i
    if (i ~= max) then res = res..sep end
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
    str = str..arr[i]
    if (i < #arr) then str = str..delimiter end
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


-- Neovim Utils
--- returns current vim mode name
function M.get_mode_name()
  local mode_names = {
    n         = "No",
    no        = "N?",
    nov       = "N?",
    noV       = "N?",
    ["no\22"] = "N?",
    niI       = "Ni",
    niR       = "Nr",
    niV       = "Nv",
    nt        = "Nt",
    v         = "Vi",
    vs        = "Vs",
    V         = "V_",
    Vs        = "Vs",
    ["\22"]   = "^V",
    ["\22s"]  = "^V",
    s         = "Se",
    S         = "S_",
    ["\19"]   = "^S",
    i         = "In",
    ic        = "Ic",
    ix        = "Ix",
    R         = "Re",
    Rc        = "Rc",
    Rx        = "Rx",
    Rv        = "Rv",
    Rvc       = "Rv",
    Rvx       = "Rv",
    c         = "Co",
    cv        = "Ex",
    r         = "..",
    rm        = "M.",
    ["r?"]    = "??",
    ["!"]     = "!!",
    t         = "Te",
  }
  return mode_names[vim.fn.mode()]
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
  return true and M.confirm(msg, {'Yes', 'No'}) == 1 or false
end
--- moves cursor position if the jump file is the current buffer if not then print jump location
-- TODO: abort if jump line or column is out of range
function M.request_jump(target_path, line, col)
  target_path = vim.fs.normalize(target_path)
  local buf_path = vim.fs.normalize(vim.fn.expand('%:p'))
  if (target_path == buf_path) then
    vim.api.nvim_win_set_cursor(0, { line, col })
    print('jumping to '..tostring(line)..':'..tostring(col))
  else
    print('jump attempt to '..tostring(line)..':'.. tostring(col)..' in '..vim.fs.basename(target_path))
  end
end
-- TODO: make into a mode switching utility
-- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), '', true)



-- Class Based Utils (statefull)
function M.FeatureList()
  return setmetatable(
    {
      list = {},
      new = function(self) return self end,
      add = function(self, feature_type, feature_name) table.insert(self.list, feature_type..":"..feature_name) end,
      add_str = function(self, feature_str) table.insert(self.list, feature_str) end,
      has = function(self, feature_type, feature_name) return vim.tbl_contains(self.list, feature_type..":"..feature_name) end,
      has_str = function(self, feature_str) return vim.tbl_contains(self.list, feature_str) end,
      stitch = function(self, feature_type, feature_name) return feature_type .. ':' .. feature_name end,
      unstitch = function(self, feature)
        local feat_tbl = vim.split(feature, ':')
        if #feat_tbl == 2 then return feat_tbl end
      end,
    },
    {}
  )
end
--- event class
function M.Event()
  return setmetatable(
    {
      subscribers = {},
      new = function(self) return self end,
      sub = function(self, subscriber) table.insert(self.subscribers, subscriber) end,
      sub_front = function(self, subscriber) table.insert(self.subscribers, 1, subscriber) end,
      invoke = function(self, ...)
        for _, subscribers in pairs(self.subscribers) do
          if type(subscribers) == 'string' then vim.cmd(subscribers)
          elseif type(subscribers) == 'function' then subscribers(...) end
        end
      end,
      wrap = function(self) return function(...) return self:invoke(...) end end
    },
    {
      __call = function(self, ...)
        return self:invoke(...)
      end
    }
  )
end
--- service class
function M.Service()
  return setmetatable(
    {
      required_features = {},
      provided_features = {},
      callback = function(self, ...) log.warn("empty service callback called") end,
      new = function(self, cb)
        self.callback = cb
        return self
      end,
      require = function(self, feature_type, feature_name) table.insert(self.required_features, { feature_type, feature_name }) return self end,
      provide = function(self, feature_type, feature_name) table.insert(self.provided_features, { feature_type, feature_name }) return self end,
      invoke = function(self, ...)
        local can_be_invoked = true
        local missing_features = {}
        -- check for all required features
        for _, required_feature in pairs(self.required_features) do
          if (not venom.features:has(required_feature[1], required_feature[2])) then
            can_be_invoked = false
            table.insert(missing_features, required_feature)
          end
        end
        if (can_be_invoked) then
          local return_value = self.callback(...)
          -- add all provided features
          for _, provided_feature in pairs(self.provided_features) do
            venom.features:add(provided_feature[1], provided_feature[2])
          end
          return return_value
        else
          for _, missing_feature in pairs(missing_features) do
            log.warn("missing feature: "..table.concat(missing_feature, ' / '), { stack_lvl_off = 1 })
          end
        end
      end,
      wrap = function(self) return function(...) return self:invoke(...) end end
    },
    {
      __call = function(self, ...)
        return self:invoke(...)
      end
    }
  )
end

return M
