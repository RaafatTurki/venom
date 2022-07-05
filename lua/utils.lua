--- defines various utility functions used throughout the entire codebase.
-- @module utils
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
--- checks if file exists
function M.is_file_exists(path)
  local ok, err, code = os.rename(path, path)
  if not ok then
    -- Permission denied, but it exists
    if code == 13 then return true end
  end
  return ok, err
end
--- checks if table has a value
function M.has_value(tbl, target_value)
  for _, value in pairs(tbl) do if value == target_value then return true end end
  return false
end
--- checks if table has a key
function M.has_key(tbl, target_key)
  for key, _ in pairs(tbl) do if key == target_key then return true end end
  return false
end
-- returns joined array into string
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
  local fh = assert(io.open(path, "wb"))
  fh:write(content)
  fh:flush()
  fh:close()
end
--- reads file content
function M.file_read(path)
  local fh = assert(io.open(path, "rb"))
  local content = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
  fh:close()
  return content
end
--- reads file content as lines (empty table if file not found)
function M.file_read_lines(path)
  if not M.is_file_exists(path) then return {} end
  local lines = {}
  for line in io.lines(path) do 
    lines[#lines + 1] = line
  end
  return lines
end


-- Neovim Utils
--- calls a vim function
function M.call(func_name, ...)
  local args = {}
  for i = 1, select('#', ...), 1 do
    local arg = select(i, ...)
    table.insert(args, arg)
  end
  return vim.api.nvim_call_function(func_name, args)
end
--- creates an auto group
function M.create_augroup(autocmd, name)
  name = name or 'end'
  vim.api.nvim_exec('augroup '..name..' \nautocmd!\n'..autocmd..'\naugroup end', false)
end
--- creates an auto command and it's auto group
function M.create_au(group, event, pattern, cmd_or_fn, extra_auto_cmd_opts, extra_auto_group_opts)
  if type(group) == 'string' then
    group = vim.api.nvim_create_augroup(group, extra_auto_group_opts)
  end

  local auto_cmd_opts = {
    group = group,
    pattern = pattern,
  }

  auto_cmd_opts = vim.tbl_deep_extend('force', extra_auto_cmd_opts or {}, auto_cmd_opts)

  if type(cmd_or_fn) == 'function' then
    auto_cmd_opts.callback = cmd_or_fn
  elseif type(cmd_or_fn) == 'string' then
    auto_cmd_opts.command = cmd_or_fn
  end

  vim.api.nvim_create_autocmd(event, auto_cmd_opts)
end
--- replaces terminal codes with internal representation
function M.term_codes_esc(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end
--- inserts text at cursor position. TODO: WIP
function M.insert_text(txt)
  -- vim.cmd('startinsert')
  -- vim.cmd('stopinsert')
  vim.cmd('normal a'..txt)
end
--- returns current vim mode name
function M.get_mode_name()
  local mode_names = {
    n = "N",
    no = "N?",
    nov = "N?",
    noV = "N?",
    ["no\22"] = "N?",
    niI = "Ni",
    niR = "Nr",
    niV = "Nv",
    nt = "Nt",
    v = "V",
    vs = "Vs",
    V = "V_",
    Vs = "Vs",
    ["\22"] = "^V",
    ["\22s"] = "^V",
    s = "S",
    S = "S_",
    ["\19"] = "^S",
    i = "I",
    ic = "Ic",
    ix = "Ix",
    R = "R",
    Rc = "Rc",
    Rx = "Rx",
    Rv = "Rv",
    Rvc = "Rv",
    Rvx = "Rv",
    c = "C",
    cv = "Ex",
    r = "...",
    rm = "M",
    ["r?"] = "?",
    ["!"] = "!",
    t = "T",
  }
  return mode_names[vim.fn.mode()]
end
--- checks if there are characters right before the cursor position
function M.has_words_before()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
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
--- returns a single input char
function M.get_char_input() return vim.fn.nr2char(vim.fn.getchar()) end
--- clears the command prompt
function M.clear_prompt() vim.api.nvim_command('normal! :') end
--- returns a string with the current indentation type and width
function M.get_indent_settings_str()
  local indent_type = vim.o.expandtab and 'S' or 'T'
  local indent_width = vim.o.shiftwidth..':'..vim.o.tabstop..':'..vim.o.softtabstop
  if vim.o.shiftwidth == vim.o.tabstop and vim.o.tabstop == vim.o.softtabstop then indent_width = vim.o.shiftwidth end
  return indent_type..':'..indent_width
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


-- Object Based Utils (stateless)
--- returns a date object
function M.date()
  return {
    now = function(self, pattern)
      pattern = pattern or "%Y-%m-%d_%X"
      return os.date(pattern, os.time())
    end
  }
end
--- returns a highlight object from a vim highlight name
function M.hi(hlname)
  local hl = vim.api.nvim_get_hl_by_name(hlname, true)
  local t = {}
  t.fg = M.to_hex(hl.foreground)
  t.bg = M.to_hex(hl.background)
  t.sp = M.to_hex(hl.special)
  t.style = "none,"
  if hl.underline then t.style = t.style .. "underline" end
  if hl.undercurl then t.style = t.style .. "undercurl" end
  if hl.bold then t.style = t.style .. "bold" end
  if hl.italic then t.style = t.style .. "italic" end
  if hl.reverse then t.style = t.style .. "reverse" end
  if hl.nocombine then t.style = t.style .. "nocombine" end
  return t
end
--- returns a global var object
function M.gvar(name)
  return {
    get = function(self) return vim.g[name] end,
    set = function(self, val) vim.g[name] = val end,
  }
end
--- retuens a key object
function M.key(modes, lhs, rhs, opts)
  return {
    map = function(self)
      opts = opts or { noremap = true, silent = true }
      vim.keymap.set(modes, lhs, rhs, opts)
    end,
    remap = function(self) end,
    unmap = function(self) end,
  }
end
--- returns a cursor position object
function M.curpos()
  return {
    get = function(self) return M.call('getcurpos') end,
    set = function(self, pos) M.call('setpos', '.', pos) end,
    set_coords = function(self, coords)
      local pos = self.get_pos()
      self.set_pos {pos[1], coords[1]+1, coords[2]+1, pos[4]}
    end,
  }
end
--- returns a user object
function M.user()
  return {
    get = function(self) return os.getenv('USER') end,
    is_root = function(self) return (self.get() == 'root') end,
  }
end
--- returns a file name object
function M.fn()
  return {
    ext = function(self, fn)
      local match = fn:match("^.+(%..+)$")
      return match and match:sub(2) or ""
      -- if match ~= nil then
      --   return match:sub(2)
      -- else
      --   return ""
      -- end
    end
  }
end
--- service invoke wrapper with self
function M.service_invoker(service)
  return function(...) return service(...) end
end

-- local function new(class, ...)
--   local inst = {}
--   setmetatable(inst, { __index = class }) 
--   if (class.init) then class.init(inst, ...) end
--   return inst
-- end
--
-- ---@class Rect
-- local Rect = {}
--
-- ---@return Rect
-- function Rect:new(...) return new(self, ...) end
--
-- function Rect:init(w, h)
--   self.w = w
--   self.h = h
--   self.points = {}
-- end
--
-- function Rect:getArea()
--   return self.w * self.h
-- end
--
-- r1 = Rect:new(10, 20)
-- print(r1.w)
-- print(r1.h)
-- print(r1:getArea())

-- Class Based Utils (statefull)
--- action class
function M.Event()
  return setmetatable(
    {
      listeners = {},
      new = function(self) return self end,
      sub = function(self, listener) table.insert(self.listeners, listener) end,
      sub_front = function(self, listener) table.insert(self.listeners, 1, listener) end,
      invoke = function(self, ...)
        for _, listener in pairs(self.listeners) do
          if type(listener) == 'string' then vim.cmd(listener)
          elseif type(listener) == 'function' then listener(...) end
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
      -- TODO: abstract feature name stitching into venom.features.str_to_tbl and venom.features.tbl_to_str
      require = function(self, feature_type, feature_name) table.insert(self.required_features, feature_type..':'..feature_name) return self end,
      provide = function(self, feature_type, feature_name) table.insert(self.provided_features, feature_type..':'..feature_name) return self end,
      invoke = function(self, ...)
        local can_be_invoked = true
        local missing_features = {}
        -- check for all required features
        for _, required_feature in pairs(self.required_features) do
          if (not venom.features:has_str(required_feature)) then
            can_be_invoked = false
            table.insert(missing_features, required_feature)
          end
        end
        if (can_be_invoked) then
          local return_value = self.callback(...)
          -- add all provided features
          for _, provided_feature in pairs(self.provided_features) do
            venom.features:add_str(provided_feature)
          end
          return return_value
        else
          log.warn("missing features: "..table.concat(missing_features, ' / '), { stack_lvl_off = 1 })
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
--- lsp server config class
function M.LspServerConfig()
  return {
    name = "",
    opts = {},
    tags = {},
    events = {
      on_attach = M.Event():new(),
    },
    tag = function(self, server_tag) table.insert(self.tags, server_tag) return self end,
    new = function(self, name, opts)
      self.name = name
      self.opts = opts or {}
      return self
    end,
  }
end

return M
