local M = {}

M.components = {}

M.setup = service({{FT.PLUGIN, "heirline.nvim"}}, function()
  local utils = require 'heirline/utils'
  local conditions = require 'heirline/conditions'

  local align = { provider = "%=" }
  local space = { provider = " " }

  local function hi_finalize(hi)
    if type(hi) == 'string' then hi = utils.get_highlight(hi) end
    return vim.tbl_deep_extend('force', hi, utils.get_highlight('StatusLine'))
  end

  local function space_statusline_components(statusline)
    for i, comp in ipairs(statusline) do
      local surrounds = { ' ', ' ' }
      if i == 1 then
        surrounds = { '', ' ' }
      elseif i == #statusline then
        surrounds = { ' ', '' }
      end
      local new_comp = utils.surround(surrounds, nil, comp)
      new_comp.init = comp.init
      new_comp.condition = comp.condition
      -- comp.condition = nil
      statusline[i] = new_comp
    end
    return statusline
  end


  -- NOTE: custom made make_buflist so it integrates with the Buffers module
  -- TODO: simplify into something more bare bones
  local NTABLINES = 0

  local function get_bufs()
    local res = {}
    for i, buffer in ipairs(Buffers.buflist) do
      table.insert(res, buffer.bufnr)
    end
    return res
  end

  local function bufs_in_tab(tabpage)
    tabpage = tabpage or 0
    local buf_set = {}
    local wins = vim.api.nvim_tabpage_list_wins(tabpage)
    for _, winid in ipairs(wins) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      buf_set[bufnr] = true
    end
    return buf_set
  end

  local function make_buflist(buffer_component, left_trunc, right_trunc, buf_func)
    buf_func = buf_func or get_bufs

    left_trunc = left_trunc or {
      provider = "<",
    }

    right_trunc = right_trunc or {
      provider = ">",
    }

    NTABLINES = NTABLINES + 1
    left_trunc.on_click = {
      callback = function(self)
        self._buflist[1]._cur_page = self._cur_page - 1
        self._buflist[1]._force_page = true
        vim.cmd("redrawtabline")
      end,
      name = "Heirline_tabline_prev_" .. NTABLINES,
    }

    right_trunc.on_click = {
      callback = function(self)
        self._buflist[1]._cur_page = self._cur_page + 1
        self._buflist[1]._force_page = true
        vim.cmd("redrawtabline")
      end,
      name = "Heirline_tabline_next_" .. NTABLINES,
    }

    local bufferline = {
      static = {
        _left_trunc = left_trunc,
        _right_trunc = right_trunc,
        _cur_page = 1,
        _force_page = false,
      },
      init = function(self)
        -- register the buflist component reference as global statusline attr
        if vim.tbl_isempty(self._buflist) then
          table.insert(self._buflist, self)
        end
        if not self.left_trunc then
          self.left_trunc = self:new(self._left_trunc)
        end
        if not self.right_trunc then
          self.right_trunc = self:new(self._right_trunc)
        end

        if not self._once then
          vim.api.nvim_create_autocmd({ "BufEnter" }, {
            callback = function()
              self._force_page = false
            end,
            desc = "Heirline release lock for next/prev buttons",
          })
          self._once = true
        end

        self.active_child = false
        local bufs = vim.tbl_filter(function(bufnr)
          return vim.api.nvim_buf_is_valid(bufnr)
        end, buf_func())
        local visible_buffers = bufs_in_tab()

        for i, bufnr in ipairs(bufs) do
          local child = self[i]
          if not (child and child.bufnr == bufnr) then
            self[i] = self:new(buffer_component, i)
            child = self[i]
            child.bufnr = bufnr
          end

          if bufnr == tonumber(vim.g.actual_curbuf) then
            child.is_active = true
            self.active_child = i
          else
            child.is_active = false
          end

          if visible_buffers[bufnr] then
            child.is_visible = true
          else
            child.is_visible = false
          end
        end
        if #self > #bufs then
          for i = #bufs + 1, #self do
            self[i] = nil
          end
        end
      end,
    }
    return bufferline
  end



  M.components.vimode = {
    provider = function(self)
      return U.get_mode_name()
    end,
    hl = function(self)
      return hi_finalize(U.get_mode_hi())
    end,
    update = 'ModeChanged',
  }

  M.components.fileinfo = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    -- icon
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
        return hi_finalize({ fg = self.icon_color })
      end
    },
    -- name
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
      hl = hi_finalize('Normal')
    },
    -- modified
    {
      provider = function() if vim.bo.modified then return ' •' end end,
      hl = hi_finalize('DiffAdd')
    },
    -- readonly
    {
      -- 
      provider = function() if (not vim.bo.modifiable) or vim.bo.readonly then return ' ' end end,
      hl = hi_finalize("ErrorMsg"),
    },
  }

  M.components.gitsigns = {
    init = function(self)
      ---@diagnostic disable-next-line: undefined-field
      self.status_dict = vim.b.gitsigns_status_dict
      -- self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    hl = hi_finalize('GitSignsDelete'),
    condition = function()
      return conditions.is_git_repo() and Features:has(FT.CONF, 'gitsigns.nvim')
    end,
    -- branch
    {
      provider = function(self)
        if self.status_dict.head ~= '' then
          return ' ' .. self.status_dict.head .. ' '
          -- 
        end
      end
    },
    -- adds
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return count > 0 and ("+" .. count)
      end,
      hl = hi_finalize("GitSignsAdd"),
    },
    -- changes
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and ("~" .. count)
      end,
      hl = hi_finalize("GitSignsChange"),
    },
    -- deletes
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and ("-" .. count)
      end,
      hl = hi_finalize("GitSignsDelete"),
    },
  }

  M.components.navic = {
    {
      condition = function()
        if Features:has(FT.PLUGIN, 'nvim-navic') then
          return require("nvim-navic").is_available()
        end
      end,
      provider = function()
        return require 'nvim-navic'.get_location()
      end,
      hl = hi_finalize('Folded'),
      update = 'CursorMoved'
    },
  }

  M.components.luasnip = {
    condition = function()
      if Features:has(FT.PLUGIN, 'LuaSnip') then
        return require 'luasnip'.jumpable()
      else
        return false
      end
    end,
    provider = function()
      local forward = require 'luasnip'.jumpable(1) and '' or ''
      local backward = require 'luasnip'.jumpable(-1) and '' or ''
      return backward .. Icons.item_kinds.Snippet .. forward
    end,
    hl = hi_finalize('CmpItemKindSnippet'),
  }

  M.components.spell = {
    condition = function()
      return vim.wo.spell
    end,
    provider = Icons.item_kinds.Text,
  }

  M.components.root_user = {
    condition = function()
      return vim.env['USER'] == 'root'
    end,
    provider = 'ROOT',
    hl = hi_finalize('ErrorMsg'),
  }

  M.components.showcmd = {
    provider = "%S",
    hl = hi_finalize('Comment'),
    -- update = 'CursorMoved',
  }

  M.components.lsp_diags = {
    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    static = {
      error_icon = Icons.diagnostic_states.Error,
      warn_icon = Icons.diagnostic_states.Warn,
      info_icon = Icons.diagnostic_states.Info,
      hint_icon = Icons.diagnostic_states.Hint,
    },
    update = { "DiagnosticChanged", "BufEnter" },
    condition = conditions.has_diagnostics,
    -- erros
    {
      provider = function(self)
        return self.errors > 0 and (self.error_icon .. ' ' .. self.errors .. " ")
      end,
      hl = hi_finalize('DiagnosticError'),
    },
    -- warns
    {
      provider = function(self)
        return self.warnings > 0 and (self.warn_icon .. ' ' .. self.warnings .. " ")
      end,
      hl = hi_finalize('DiagnosticWarn'),
    },
    -- infos
    {
      provider = function(self)
        return self.info > 0 and (self.info_icon .. ' ' .. self.info .. " ")
      end,
      hl = hi_finalize('DiagnosticInfo'),
    },
    -- hints
    {
      provider = function(self)
        return self.hints > 0 and (self.hint_icon .. ' ' .. self.hints)
      end,
      hl = hi_finalize('DiagnosticHint'),
    },
  }

  M.components.lsp_servers = {
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
    hl = hi_finalize('Folded'),
  }

  M.components.session = {
    condition = function() return Sessions.is_in_local_session end,
    provider = function()
      return ' local'
    end,
    hl = hi_finalize('WarningMsg'),
  }

  M.components.filetype = {
    provider = function()
      return vim.bo.filetype
    end,
    hl = hi_finalize('Comment'),
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
    hl = hi_finalize('Comment'),
    update = 'CursorMoved',
  }

  -- TODO merge into fileinfo
  M.components.helpfilename = {
    condition = function()
      return vim.bo.buftype == "help"
    end,
    {
      provider = ' ',
      hl = hi_finalize('Todo'),
    },
    {
      provider = function()
        local filename = vim.api.nvim_buf_get_name(0)
        return vim.fn.fnamemodify(filename, ":t")
      end,
    },
  }

  -- TODO merge into fileinfo
  M.components.terminalname = {
    condition = function()
      return vim.bo.buftype == "terminal"
    end,
    {
      provider = ' ',
      -- 
      hl = hi_finalize('Type'),
    },
    {
      provider = function()
        local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
        return tname
      end,
    },
  }

  M.components.indentation = {
    provider = function()
      local indent_type = vim.o.expandtab and 'S' or 'T'
      local indent_width = vim.o.shiftwidth .. ':' .. vim.o.tabstop .. ':' .. vim.o.softtabstop
      if vim.o.shiftwidth == vim.o.tabstop and vim.o.tabstop == vim.o.softtabstop then indent_width = tostring(vim.o
        .shiftwidth) end
      return indent_type .. ':' .. indent_width
    end,
    hl = hi_finalize('Comment'),
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
    hl = hi_finalize('Error'),
    update = {
      "RecordingEnter",
      "RecordingLeave",
    }
  }

  -- TODO abstract into a generic indicators system
  M.components.texlab_status = {
    condition = function()
      local util = require 'lspconfig.util'
      local client = util.get_active_client_by_name(0, 'texlab')
      return client ~= nil
    end,
    provider = function()
      return ''
      -- 
    end,
    hl = function()
      local build_status_hls = vim.tbl_add_reverse_lookup {
        DiffAdd = 0,
        ErrorMsg = 1,
        WarningMsg = 2,
        Folded = 3,
      }
      return hi_finalize(build_status_hls[Lang.texab_build_status])
    end
  }

  M.components.lazy = {
    condition = require("lazy.status").has_updates,
    provider = function() return require 'lazy.status'.updates() end,
    hl = hi_finalize('Type'),
    update = { "User", pattern = "LazyUpdate" },
  }


  local default_statusline = {
    condition = function()
      return vim.bo.buftype == ''
    end,
    M.components.fileinfo,
    M.components.gitsigns,
    align,
    M.components.lazy,
    M.components.texlab_status,
    M.components.luasnip,
    M.components.spell,
    M.components.root_user,
    M.components.showcmd,
    M.components.lsp_diags,
    M.components.lsp_servers,
    M.components.filetype,
    M.components.fileencoding,
    M.components.fileformat,
    M.components.indentation,
    M.components.searchinfo,
    M.components.session,
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
    M.components.helpfilename,
    align,
    M.components.root_user,
    M.components.filetype,
    M.components.searchinfo,
    M.components.session,
    M.components.ruler,
  }

  local terminal_statusline = {
    condition = function()
      return conditions.buffer_matches {
        buftype = { "terminal" },
        filetype = { "toggleterm" },
      }
    end,
    M.components.terminalname,
    align,
    M.components.root_user,
    M.components.filetype,
    M.components.searchinfo,
    M.components.session,
  }

  local statuslines = {
    fallthrough = false,
    space_statusline_components(default_statusline),
    space_statusline_components(special_statusline),
    space_statusline_components(terminal_statusline),
  }


  local default_winbar = {
    condition = function()
      return vim.bo.buftype == ''
    end,
    space,
    -- M.components.navic,
    align,
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
        return (Buffers.get_label_by_bufnr(self.bufnr) or '') .. ' '
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
        return { underline = self.is_loaded }
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
    make_buflist(utils.surround({ ' ', ' ' }, nil, buffer_abstract), { provider = '' }, { provider = '' })
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
    -- winbar = winbars,
    -- statuscolumn = {}
  }

end)

return M
