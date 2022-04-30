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
    local f = io.open(path, 'r')
    if f ~= nil then io.close(f) return true else return false end
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


-- Object Based Utils
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


-- Class Based Utils
--- action class
function M.Action()
  return {
    commands = {},
    new = function(self) return self end,
    subscribe = function(self, cmd) table.insert(self.commands, cmd) end,
    invoke = function(self)
      for _, cmd in pairs(self.commands) do
        if type(cmd) == 'string' then vim.cmd(cmd)
        elseif type(cmd) == 'function' then cmd() end
      end
    end
  }
end
--- service class
function M.Service()
  return {
    new = function(self, cb)
      self.callback = cb
      return self
    end,
    -- provide = function(self, feature_type, feature_name) table.insert(venom.features:add(feature_type, feature_name)) return self end,
    -- TODO: abstract feature name stitching into venom.features.str_to_tbl and venom.features.tbl_to_str
    require = function(self, feature_type, feature_name) table.insert(self.required_features, feature_type..':'..feature_name) return self end,
    provide = function(self, feature_type, feature_name) table.insert(self.provided_features, feature_type..':'..feature_name) return self end,
    invoke = function(self, ...)
      local can_be_invoked = true
      -- check for all required features
      for _, required_feature in pairs(self.required_features) do
        if (not venom.features:has_str(required_feature)) then can_be_invoked = false end
      end
      if (can_be_invoked) then
        local return_value = self.callback(...)
        -- add all provided features
        for _, provided_feature in pairs(self.provided_features) do
          venom.features:add_str(provided_feature)
        end
        return return_value
      else
        log("not all required features satisfied", LL.WARN)
      end
    end,
    required_features = {},
    provided_features = {},
    callback = function(self, ...) log("empty service callback called", LL.WARN) end,
  }
end
--- lsp server config class
function M.LspServerConfig()
  return {
    name = "",
    opts = {},
    tags = {},
    tag = function(self, server_tag) table.insert(self.tags, server_tag) return self end,
    new = function(self, name, opts)
      self.name = name
      self.opts = opts or {}
      return self
    end,
  }
end

return M
