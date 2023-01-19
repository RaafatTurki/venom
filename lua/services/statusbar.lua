--- defines statusbar and winbar components.
-- @module statusbar
local M = {}

M.components = {}

M.setup = U.Service({{FT.PLUGIN, "heirline.nvim"}}, function()
  local utils = require 'heirline/utils'
  local conditions = require 'heirline/conditions'

  local align = { provider = "%=" }
  local space = { provider = " " }

  M.components.vimode = {
    init = function(self)
      self.mode = vim.fn.mode(1)
      if not self.once then
        vim.api.nvim_create_autocmd("ModeChanged", { command = 'redrawstatus' })
        self.once = true
      end
    end,
    static = {
      mode_hls = {
        n       = 'ModeNormal',
        i       = 'ModeInsert',
        v       = 'ModeVisual',
        V       = 'ModeVisual',
        ['\22'] = "ModeVisual",
        c       = 'ModeControl',
        s       = 'ModeSelect',
        S       = 'ModeSelect',
        ['\19'] = "ModeSelect",
        R       = 'ModeControl',
        r       = 'ModeControl',
        ['!']   = 'ModeNormal',
        t       = 'ModeTerminal',
      }
    },
    provider = function(self)
      return U.get_mode_name()
    end,
    hl = function(self)
      local mode = self.mode:sub(1, 1)
      return self.mode_hls[mode]
    end,
    update = 'ModeChanged',
  }

  M.components.fileinfo = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    {
      init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ':e')
        self.icon, self.icon_color = require 'nvim-web-devicons'.get_icon_color(filename, extension, { default = true })
      end,
      provider = function(self)
        return self.icon and (self.icon .. ' ')
      end,
      hl = function(self)
        return { fg = self.icon_color }
      end
    },
    {
      provider = function(self)
        -- first, trim the pattern relative to the current directory. For other
        -- options, see :h filename-modifers
        local filename = vim.fn.fnamemodify(self.filename, ":.")
        if filename == "" then return "[No Name]" end
        -- now, if the filename would occupy more than 1/4th of the available
        -- space, we trim the file path to its initials
        -- See Flexible Components section below for dynamic truncation
        if not conditions.width_percent_below(#filename, 0.25) then
          filename = vim.fn.pathshorten(filename)
        end
        return filename
      end,
      hl = 'Normal'
    },
    {
      provider = function() if vim.bo.modified then return ' •' end end,
      hl = 'DiffAdd'
    },
    {
      -- 
      provider = function() if (not vim.bo.modifiable) or vim.bo.readonly then return ' ' end end,
      hl = "ErrorMsg"
    },
  }

  M.components.gitinfo = {
    init = function(self)
      ---@diagnostic disable-next-line: undefined-field
      self.status_dict = vim.b.gitsigns_status_dict
      -- self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    hl = "GitSignsDelete",
    condition = conditions.is_git_repo,
    {
      provider = function(self)
        if self.status_dict.head ~= '' then
          return ' ' .. self.status_dict.head .. ' '
        end
      end
    },
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return count > 0 and ("+" .. count)
      end,
      hl = "GitSignsAdd",
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and ("~" .. count)
      end,
      hl = "GitSignsChange",
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and ("-" .. count)
      end,
      hl = "GitSignsDelete",
    },
  }

  M.components.navic_simple = {
    {
      condition = function()
        return require 'nvim-navic'.is_available()
      end,
      provider = require 'nvim-navic'.get_location,
      hl = 'Folded',
      update = 'CursorMoved'
    },
  }

  M.components.navic = {
    condition = require("nvim-navic").is_available,
    static = {
      -- create a type highlight map
      type_hl = {
        File = "Directory",
        Module = "@include",
        Namespace = "@namespace",
        Package = "@include",
        Class = "@structure",
        Method = "@method",
        Property = "@property",
        Field = "@field",
        Constructor = "@constructor",
        Enum = "@field",
        Interface = "@type",
        Function = "@function",
        Variable = "@variable",
        Constant = "@constant",
        String = "@string",
        Number = "@number",
        Boolean = "@boolean",
        Array = "@field",
        Object = "@type",
        Key = "@keyword",
        Null = "@comment",
        EnumMember = "@field",
        Struct = "@structure",
        Event = "@keyword",
        Operator = "@operator",
        TypeParameter = "@type",
      },
      -- bit operation dark magic, see below...
      enc = function(line, col, winnr)
        return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
      end,
      -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
      dec = function(c)
        local line = bit.rshift(c, 16)
        local col = bit.band(bit.rshift(c, 6), 1023)
        local winnr = bit.band(c, 63)
        return line, col, winnr
      end
    },
    init = function(self)
      local data = require("nvim-navic").get_data() or {}
      local children = {}
      -- create a child for each level
      for i, d in ipairs(data) do
        -- encode line and column numbers into a single integer
        local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
        local child = {
          {
            provider = d.icon,
            hl = self.type_hl[d.type],
          },
          {
            -- escape `%`s (elixir) and buggy default separators
            provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ''),
            -- highlight icon only or location name as well
            -- hl = self.type_hl[d.type],
            on_click = {
              -- pass the encoded position through minwid
              minwid = pos,
              callback = function(_, minwid)
                -- decode
                local line, col, winnr = self.dec(minwid)
                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
              end,
              name = "heirline_navic",
            },
          },
        }
        -- add a separator only if needed
        if #data > 1 and i < #data then
          table.insert(child, {
            provider = " > ",
            -- hl = { fg = 'bright_fg' },
            hl = 'Folded',
          })
        end
        table.insert(children, child)
      end
      -- instantiate the new child, overwriting the previous one
      self.child = self:new(children, 1)
    end,
    -- evaluate the children containing navic components
    provider = function(self)
      return self.child:eval()
    end,
    hl = 'NonText',
    update = 'CursorMoved'
  }

  M.components.snippetinfo = {
    condition = function()
      if Features:has(FT.PLUGIN, 'LuaSnip') then 
        return require 'luasnip'.jumpable()
      end
      return false
    end,
    provider = function()
      local forward = require 'luasnip'.jumpable(1) and '' or ''
      local backward = require 'luasnip'.jumpable(-1) and '' or ''
      return backward .. Icons.item_kinds.Snippet .. forward
    end,
    hl = 'CmpItemKindSnippet',
  }

  M.components.spellinfo = {
    condition = function()
      return vim.wo.spell
    end,
    provider = Icons.item_kinds.Text,
  }

  M.components.rootinfo = {
    condition = function()
      return vim.env['USER'] == 'root'
    end,
    provider = 'ROOT',
    hl = 'ErrorMsg',
  }

  M.components.diaginfo = {
    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    static = {
      error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
      warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
      info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
      hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
    },
    update = { "DiagnosticChanged", "BufEnter" },
    condition = conditions.has_diagnostics,
    {
      provider = function(self)
        return self.errors > 0 and (self.error_icon .. self.errors .. " ")
      end,
      hl = 'DiagnosticError',
    },
    {
      provider = function(self)
        return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
      end,
      hl = 'DiagnosticWarn',
    },
    {
      provider = function(self)
        return self.info > 0 and (self.info_icon .. self.info .. " ")
      end,
      hl = 'DiagnosticInfo',
    },
    {
      provider = function(self)
        return self.hints > 0 and (self.hint_icon .. self.hints)
      end,
      hl = 'DiagnosticHint',
    },
  }

  M.components.lspinfo = {
    condition = conditions.lsp_attached,
    provider = function()
      local servers = {}
      local res = ''
      for i, server in pairs(vim.lsp.buf_get_clients(0)) do
        if servers[server.name] == nil then
          servers[server.name] = {
            count = 1
          }
        else
          local count = servers[server.name].count
          servers[server.name].count = count + 1
        end
      end
      for server_name, server in pairs(servers) do
        -- state_icon = ''
        -- ⏳ 
        if server.count > 1 then
          res = res .. '  ' .. server.count
        end
        res = res .. ' ' .. server_name
        -- if (i ~= #servers) then res = res .. ' ' end
      end
      return res
    end,
    -- update = {'LspAttach', 'LspDetach', 'User LspProgressUpdate'},
    hl       = 'Folded',
  }

  M.components.sessioninfo = {
    condition = function() return Sessions.get_current() end,
    provider = function()
      return ' ' .. Sessions.get_current()
    end,
    hl = 'WarningMsg',
  }

  M.components.filetype = {
    provider = function()
      return vim.bo.filetype
    end,
    hl = 'Comment'
  }

  M.components.fileencoding = {
    condition = function(self)
      return self.enc ~= 'utf-8'
    end,
    init = function(self)
      self.enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
    end,
    provider = function(self)
      return self.enc:upper()
    end,
  }

  M.components.fileformat = {
    condition = function(self)
      return self.fmt ~= 'unix'
    end,
    init = function(self)
      self.fmt = vim.bo.fileformat
    end,
    provider = function(self)
      return self.fmt:upper()
    end,
  }

  M.components.ruler = {
    provider = function(self)
      -- local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      -- local total_lines = vim.api.nvim_buf_line_count(0)
      -- local percentage = math.floor(((curr_line-1) / (total_lines-1)) * 100)
      -- return string.format("%5s", percentage..'%%')
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local curr_col = vim.api.nvim_win_get_cursor(0)[2]
      return string.format("%s:%s", curr_line, curr_col)
    end,
    hl = 'Comment',
    update = 'CursorMoved',
  }

  M.components.helpfilename = {
    condition = function()
      return vim.bo.buftype == "help"
    end,
    {
      provider = ' ',
      hl = 'Todo',
    },
    {
      provider = function()
        local filename = vim.api.nvim_buf_get_name(0)
        return vim.fn.fnamemodify(filename, ":t")
      end,
    },
  }

  M.components.terminalname = {
    condition = function()
      return vim.bo.buftype == "terminal"
    end,
    {
      provider = ' ',
      -- 
      hl = 'Type'
    },
    {
      provider = function()
        local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
        return tname
      end,
    },
  }

  M.components.indentinfo = {
    provider = function()
      local indent_type = vim.o.expandtab and 'S' or 'T'
      local indent_width = vim.o.shiftwidth .. ':' .. vim.o.tabstop .. ':' .. vim.o.softtabstop
      if vim.o.shiftwidth == vim.o.tabstop and vim.o.tabstop == vim.o.softtabstop then indent_width = tostring(vim.o
        .shiftwidth) end
      return indent_type .. ':' .. indent_width
    end,
    hl = 'Comment',
  }

  M.components.searchinfo = {
    condition = function()
      return vim.v.hlsearch == 1
    end,
    provider = function()
      local search = vim.fn.searchcount({ maxcount = 0 })
      local current, total
      if search.incomplete > 0 then
        current = '?'
        total = '?'
      else
        current = search.current
        total = search.total
      end
      return ' ' .. current .. '/' .. total
    end
  }

  M.components.macros = {
    init = function(self)
      self.reg_recording = vim.fn.reg_recording()
    end,
    condition = function()
      return vim.fn.reg_recording() ~= ''
    end,
    provider = function (self)
      return '' .. ' ' .. self.reg_recording
    end,
    hl = 'Error',
  }

  -- TODO: abstract into a generic indicators system
  M.components.texlab_status = {
    condition = function()
      local util = require 'lspconfig.util'
      local client = util.get_active_client_by_name(0, 'texlab')
      return client ~= nil
    end,
    provider = function()
      return ''
    end,
    hl = function()
      local build_status_hls = vim.tbl_add_reverse_lookup {
        DiffAdd = 0,
        ErrorMsg = 1,
        WarningMsg = 2,
        Folded = 3,
      }
      return build_status_hls[Lang.texab_build_status]
    end
  }

  local component_opts = {
    left = {
      left_pad = { provider = '' },
      right_pad = { provider = ' ' },
    },
    middle = {
      left_pad = { provider = ' ' },
      right_pad = { provider = ' ' },
    },
    right = {
      left_pad = { provider = ' ' },
      right_pad = { provider = '' },
    },
  }


  local default_statusline = {
    condition = function()
      return vim.bo.buftype == ''
    end,
    M.components.vimode,
    M.components.fileinfo,
    M.components.gitinfo,
    align,
    M.components.texlab_status,
    M.components.snippetinfo,
    M.components.spellinfo,
    M.components.rootinfo,
    M.components.diaginfo,
    M.components.lspinfo,
    M.components.filetype,
    M.components.fileencoding,
    M.components.fileformat,
    M.components.indentinfo,
    M.components.searchinfo,
    M.components.sessioninfo,
    M.components.macros,
    M.components.ruler,
  }

  local special_statusline = {
    condition = function()
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix" },
        filetype = { "^git.*", "fugitive", "NvimTree" },
      })
    end,
    M.components.vimode,
    M.components.helpfilename,
    align,
    M.components.rootinfo,
    M.components.filetype,
    M.components.searchinfo,
    M.components.sessioninfo,
    -- M.components.ruler,
  }

  local terminal_statusline = {
    condition = function()
      return conditions.buffer_matches {
        buftype = { "terminal" },
        filetype = { "toggleterm" },
      }
    end,
    M.components.vimode,
    M.components.terminalname,
    align,
    M.components.rootinfo,
    M.components.filetype,
    M.components.searchinfo,
    M.components.sessioninfo,
  }

  local statuslines = {
    fallthrough = false,
    default_statusline,
    -- special_statusline,
    -- terminal_statusline,
  }


  local default_winbar = {
    condition = function()
      return vim.bo.buftype == ''
    end,
    space,
    M.components.navic,
    align,
    -- M.components.gitinfo(component_opts.middle),
  }

  local special_winbar = {
    condition = function()
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix" },
        filetype = { "^git.*", "fugitive", "NvimTree" },
      })
    end,
    space,
    align,
  }

  local terminal_winbar = {
    condition = function()
      return conditions.buffer_matches {
        buftype = { "terminal" },
        filetype = { "toggleterm" },
      }
    end,
    space,
    align,
  }

  local winbars = {
    fallthrough = false,
    default_winbar,
    special_winbar,
    terminal_winbar,
  }


  local tabline_offset = {
    condition = function(self)
      local win = vim.api.nvim_tabpage_list_wins(0)[1]
      local bufnr = vim.api.nvim_win_get_buf(win)
      self.winid = win

      local ft_to_title = {
        ['neo-tree'] = "File Explorer",
        ['NvimTree'] = "File Explorer",
      }

      for ft, title in pairs(ft_to_title) do
        if vim.bo[bufnr].filetype == ft then
          self.title = title
          return true
        end
      end
    end,
    provider = function(self)
      local title = self.title
      local width = vim.api.nvim_win_get_width(self.winid)
      local pad = math.ceil((width - #title) / 2)
      return string.rep(" ", pad) .. title .. string.rep(" ", pad)
    end,
    hl = function(self)
      if vim.api.nvim_get_current_win() == self.winid then
        return "TablineSel"
      else
        return "Tabline"
      end
    end,
  }

  local buffer_abstract = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      self.is_loaded = vim.api.nvim_buf_is_loaded(self.bufnr)
    end,
    hl = function(self)
      return self.is_active and 'TablineSel' or 'Tabline'
    end,
    on_click = {
      callback = function(_, minwid, _, button)
        if (button == "m") then -- close on mouse middle click
          vim.api.nvim_buf_delete(minwid, { force = false })
        else
          vim.api.nvim_win_set_buf(0, minwid)
        end
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = "heirline_tabline_buffer_callback",
    },
    -- buffer label
    {
      provider = function(self)
        if self.bufnr == nil then return end
        -- return tostring(self.bufnr) .. ". "
        return (Buffers.buf_get_label_from_bufnr(self.bufnr) or '') .. ' '
      end,
      hl = "ErrorMsg",
    },
    -- icon
    {
      init = function(self)
        if vim.api.nvim_buf_get_option(self.bufnr, 'buftype') == 'terminal' then
          self.icon = ' '
          self.icon_color = utils.get_highlight('Type').fg
        else
          local filename = self.filename
          local extension = vim.fn.fnamemodify(filename, ':e')
          self.icon, self.icon_color = require 'nvim-web-devicons'.get_icon_color(filename, extension, { default = true })
        end
      end,
      provider = function(self)
        return self.icon and (self.icon .. ' ')
      end,
      hl = function(self)
        return { fg = self.icon_color }
      end
    },
    -- buffer name
    {
      provider = function(self)
        -- self.filename will be defined later, just keep looking at the example!
        local filename = self.filename
        filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
        return filename
      end,
      hl = function(self)
        return { underline = self.is_active or self.is_visible, strikethrough = not self.is_loaded }
      end,
    },
    -- indicators
    {
      {
        condition = function(self) return vim.api.nvim_buf_get_option(self.bufnr, 'modified') end,
        provider = ' •',
        hl = 'DiffAdd',
      },
      {
        condition = function(self)
          -- return (not vim.api.nvim_buf_get_option(self.bufnr, "modifiable") or vim.api.nvim_buf_get_option(self.bufnr, "readonly")) and not vim.api.nvim_buf_get_option(self.bufnr, 'buftype') == 'terminal'
          return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable") or
              vim.api.nvim_buf_get_option(self.bufnr, "readonly")
        end,
        provider = ' ',
        hl = 'ErrorMsg',
      },
    },
  }

  local bufferline = {
    utils.make_buflist(utils.surround({ ' ', ' ' }, nil, buffer_abstract), { provider = '' }, { provider = '' })
  }

  local tabpage_abstract = {
    provider = function(self)
      return "%" .. self.tabnr .. "T " .. self.tabnr .. " %T"
    end,
    hl = function(self)
      if not self.is_active then
        return "TabLine"
      else
        return "TabLineSel"
      end
    end,
  }

  local tabpages = {
    condition = function()
      return #vim.api.nvim_list_tabpages() >= 2
    end,
    align,
    utils.make_tablist(tabpage_abstract),
  }

  local tabline = { tabline_offset, bufferline, tabpages }

  require 'heirline'.setup {
    statusline = statuslines,
    tabline = tabline,
    winbar = winbars,
    -- statuscolumn = {}
  }

end)

return M
