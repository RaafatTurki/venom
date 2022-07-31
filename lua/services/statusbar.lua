--- defines statusbar services
-- @module statusbar
local M = {}

M.components = {}

M.setup = U.Service():require(FT.PLUGIN, "mini.nvim"):new(function()
  local utils = require 'heirline/utils'
  local conditions = require 'heirline/conditions'

  local Align = { provider = "%=" }
  local Space = { provider = ' ' }
  local RightPad = ' '
  local LeftPad = ' '

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
      hl = 'Normal'
    },
    {
      provider = function() if (not vim.bo.modifiable) or vim.bo.readonly then return ' ' end end,
      hl = "ErrorMsg"
    },
  }

  M.components.gitinfo = {
    init = function(self)
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
        return count > 0 and ("+" .. count) .. ' '
      end,
      hl = "GitSignsAdd",
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and ("~" .. count) .. ' '
      end,
      hl = "GitSignsChange",
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and ("-" .. count) .. ' '
      end,
      hl = "GitSignsDelete",
    },
  }

  M.components.navic = {
    provider = require 'nvim-navic'.get_location,
    condition = require 'nvim-navic'.is_available,
    hl = 'Folded',
  }

  M.components.snippetinfo = {
    provider = function()
      local forward = require 'luasnip'.jumpable(1) and '' or ''
      local backward = require 'luasnip'.jumpable(-1) and '' or ''
      return backward..venom.icons.item_kinds.cozette.Snippet..forward
    end,
    hl = 'CmpItemKindSnippet',
    condition = require 'luasnip'.jumpable,
  }

  M.components.spellinfo = {
    provider = venom.icons.item_kinds.cozette.Text,
    condition = function()
      return vim.wo.spell
    end,
  }

  M.components.rootinfo = {
    provider = 'ROOT',
    hl = 'ErrorMsg',
    condition = function ()
      return U.user():is_root()
    end,
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
    {
      provider = function()
        if #vim.lsp.util.get_progress_messages() > 0 then
          return Lsp.get_progress_spinner()..' '
        else
          return 'x '
        end
      end,
      update = function ()
        return true
      end
    },
    {
      provider  = function()
        local server_names = {}
        for i, server in pairs(vim.lsp.buf_get_clients(0)) do
          table.insert(server_names, server.name)
        end
        return table.concat(server_names, " | ")
      end,
      update = {'LspAttach', 'LspDetach'},
    },
  }

  M.components.sessioninfo = {
    provider = '',
    hl = 'WarningMsg',
    condition = function () return (vim.v.this_session ~= '') end
  }

  M.components.filetype = {
    provider = function()
      -- return string.upper(vim.bo.filetype)
      return vim.bo.filetype
    end,
    hl = 'Folded'
  }

  M.components.fileencoding = {
    init = function(self)
      self.enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
    end,
    provider = function(self)
      return self.enc:upper()
    end,
    condition = function(self)
      return self.enc ~= 'utf-8'
    end
  }

  M.components.fileformat = {
    init = function(self)
      self.fmt = vim.bo.fileformat
    end,
    provider = function(self)
      return self.fmt:upper()
    end,
    condition = function(self)
      return self.fmt ~= 'unix'
    end
  }

  M.components.ruler = {
    provider = function(self)
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local total_lines = vim.api.nvim_buf_line_count(0)
      local percentage = math.floor(((curr_line-1) / (total_lines-1)) * 100)
      return string.format("%5s", percentage..'%%')
    end,
    hl = 'Folded',
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
    }
  }

  M.components.terminalname = {
    condition = function()
      return vim.bo.buftype == "terminal"
    end,
    {
      provider = ' ',
      hl = 'Type'
    },
    {
      provider = function()
        local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
        return tname
      end,
    }
  }

  M.components.indentinfo = {
    provider = function()
      return U.get_indent_settings_str()
    end,
    hl = 'Folded'
  }


  for name, component in pairs(M.components) do
    M.components[name] = utils.surround({ LeftPad, RightPad }, '', component)
  end


  local default_statusline = {
    condition = function()
      return vim.bo.buftype == ''
    end,
    M.components.vimode,
    M.components.fileinfo,
    M.components.gitinfo,
    M.components.navic,
    Align,
    M.components.snippetinfo,
    M.components.spellinfo,
    M.components.rootinfo,
    M.components.diaginfo,
    M.components.lspinfo,
    M.components.filetype,
    M.components.fileencoding,
    M.components.fileformat,
    M.components.indentinfo,
    M.components.sessioninfo,
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
    Align,
    M.components.rootinfo,
    M.components.filetype,
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
    Align,
    M.components.rootinfo,
    M.components.filetype,
    M.components.sessioninfo,
  }

  local statuslines = {
    init = utils.pick_child_on_condition,
    default_statusline,
    special_statusline,
    terminal_statusline,
  }

  require'heirline'.setup({ statuslines })
end)


-- TODO: divide up into related services
-- M.setup = U.Service():require(FT.PLUGIN, "mini.nvim"):new(function()
--   require 'mini.statusline'.setup {
--     -- Content of statusline as functions which return statusline string. See
--     -- `:h statusline` and code of default contents (used instead of `nil`).
--     content = {
--       inactive = nil,
--       active = nil
--     },
--
--     -- Whether to set Vim's settings for statusline (make it always shown with
--     -- 'laststatus' set to 2). To use global statusline in Neovim>=0.7.0, set
--     -- this to `false` and 'laststatus' to 3.
--     set_vim_settings = true,
--   }
-- end)


return M
