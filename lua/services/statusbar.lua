--- defines statusbar services
-- @module statusbar
local M = {}

M.components = {}

M.setup = U.Service():require(FT.PLUGIN, "mini.nvim"):new(function()
  local utils = require 'heirline/utils'
  local conditions = require 'heirline/conditions'

  local align = { provider = "%=" }

  M.components.vimode = U.Service():new(function(opts)
    return {
      opts.left_pad,
      {
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
      },
      opts.right_pad,
    }
  end)

  M.components.fileinfo = U.Service():new(function(opts)
    return {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
      end,
      opts.left_pad,
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
        -- 
        provider = function() if (not vim.bo.modifiable) or vim.bo.readonly then return ' ' end end,
        hl = "ErrorMsg"
      },
      opts.right_pad,
    }
  end)

  M.components.gitinfo = U.Service():new(function(opts)
    return {
      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        -- self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
      end,
      hl = "GitSignsDelete",
      condition = conditions.is_git_repo,
      opts.left_pad,
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
      opts.right_pad,
    }
  end)

  M.components.navic = U.Service():new(function(opts)
    return {
      condition = function()
        return require 'nvim-navic'.is_available()
      end,
      -- opts.left_pad,
      {
        provider = require 'nvim-navic'.get_location,
        hl = 'Folded',
      },
      -- opts.right_pad,
    }
  end)

  M.components.snippetinfo = U.Service():new(function(opts)
    return {
      condition = require 'luasnip'.jumpable,
      opts.left_pad,
      {
        provider = function()
          local forward = require 'luasnip'.jumpable(1) and '' or ''
          local backward = require 'luasnip'.jumpable(-1) and '' or ''
          return backward..venom.icons.item_kinds.cozette.Snippet..forward
        end,
        hl = 'CmpItemKindSnippet',
      },
      opts.right_pad,
    }
  end)

  M.components.spellinfo = U.Service():new(function(opts)
    return {
      condition = function()
        return vim.wo.spell
      end,
      opts.right_pad,
      {
        provider = venom.icons.item_kinds.cozette.Text,
      },
      opts.left_pad,
    }
  end)

  M.components.rootinfo = U.Service():new(function(opts)
    return {
      condition = function ()
        return U.user():is_root()
      end,
      opts.left_pad,
      {
        provider = 'ROOT',
        hl = 'ErrorMsg',
      },
      opts.right_pad,
    }
  end)

  M.components.diaginfo = U.Service():new(function(opts)
    return {
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
        opts.left_pad,
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
        opts.right_pad,
      }
  end)
  
  M.components.lspinfo = U.Service():new(function(opts)
    return {
      condition = conditions.lsp_attached,
      opts.left_pad,
      {
        provider  = function()
          local SERVER_STATES = { IDLE = "IDLE", LOADING = "LOADING" }
          local attached_servers = {}
          local res = ''

          for i, server in pairs(vim.lsp.buf_get_clients(0)) do
            table.insert(attached_servers, {
              name = server.name,
              state = SERVER_STATES.IDLE,
            })
          end

          for i, msg in pairs(vim.lsp.util.get_progress_messages()) do
            for j, attached_server in pairs(attached_servers) do
              if (msg.name == attached_server.name) then
                attached_server.state = SERVER_STATES.LOADING
              end
            end
          end

          for i, attached_server in pairs(attached_servers) do
            state_icon = ''
            if attached_server.state == SERVER_STATES.IDLE then
              state_icon = ''
            elseif attached_server.state == SERVER_STATES.LOADING then
              state_icon = ''
              -- ⏳
            end
            res = res .. state_icon .. ' ' .. attached_server.name
            if (i ~= #attached_servers) then res = res .. ' ' end
          end

          return res
        end,
        update = {'LspAttach', 'LspDetach', 'User LspProgressUpdate'},
      },
      opts.right_pad,
    }
  end)

  M.components.sessioninfo = U.Service():new(function(opts)
    return {
      condition = function () return (vim.v.this_session ~= '') end,
      opts.left_pad,
      {
        provider = '',
        hl = 'WarningMsg',
      },
      opts.right_pad
    }
  end)

  M.components.filetype = U.Service():new(function(opts)
    return {
      opts.left_pad,
      {
        provider = function()
          -- return string.upper(vim.bo.filetype)
          return vim.bo.filetype
        end,
        hl = 'Folded'
      },
      opts.right_pad,
    }
  end)

  M.components.fileencoding = U.Service():new(function(opts)
    return {
      condition = function(self)
        return self.enc ~= 'utf-8'
      end,
      init = function(self)
        self.enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
      end,
      opts.left_pad,
      {
        provider = function(self)
          return self.enc:upper()
        end,
      },
      opts.right_pad,
    }
  end)

  M.components.fileformat = U.Service():new(function(opts)
    return {
      condition = function(self)
        return self.fmt ~= 'unix'
      end,
      init = function(self)
        self.fmt = vim.bo.fileformat
      end,
      opts.left_pad,
      {
        provider = function(self)
          return self.fmt:upper()
        end,
      },
      opts.right_pad,
    }
  end)

  M.components.ruler = U.Service():new(function(opts)
    return {
      opts.left_pad,
      {
        provider = function(self)
          local curr_line = vim.api.nvim_win_get_cursor(0)[1]
          local total_lines = vim.api.nvim_buf_line_count(0)
          local percentage = math.floor(((curr_line-1) / (total_lines-1)) * 100)
          return string.format("%5s", percentage..'%%')
        end,
        hl = 'Folded',
      },
      opts.right_pad,
    }
  end)
  
  M.components.helpfilename = U.Service():new(function(opts)
    return {
      condition = function()
        return vim.bo.buftype == "help"
      end,
      opts.left_pad,
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
      opts.right_pad,
    }
  end)

  M.components.terminalname = U.Service():new(function(opts)
    return {
      condition = function()
        return vim.bo.buftype == "terminal"
      end,
      opts.left_pad,
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
      opts.right_pad,
    }
  end)

  M.components.indentinfo = U.Service():new(function(opts)
    return {
      opts.left_pad,
      {
        provider = function()
          local indent_type = vim.o.expandtab and 'S' or 'T'
          local indent_width = vim.o.shiftwidth..':'..vim.o.tabstop..':'..vim.o.softtabstop
          if vim.o.shiftwidth == vim.o.tabstop and vim.o.tabstop == vim.o.softtabstop then indent_width = vim.o.shiftwidth end
          return indent_type..':'..indent_width
        end,
        hl = 'Folded',
      },
      opts.right_pad,
    }
  end)

  M.components.searchinfo = U.Service():new(function(opts)
    return {
      condition = function()
        if vim.fn.getreg("/") ~= '' then
          return true
        end
        return false
      end,
      opts.left_pad,
      {
        provider = function()
          local search = vim.fn.searchcount({ maxcount = 0 })
          local search_current = search.current
          local search_total = search.total
          return ' ' .. search_current .. '/' .. search_total
        end
      },
      opts.right_pad,
    }
  end)

  M.components.test = U.Service():new(function(opts)
    return {
      opts.left_pad,
      {
        provider = function()
          messages = vim.lsp.util.get_progress_messages()
          -- log(messages)
          -- if (#messages > 0) then
          --   return 'LOADING'
          -- else
          --   return '.......'
          -- end
          return ''
        end,
        -- update = 'User LspProgressUpdate',
      },
      opts.right_pad,
    }
  end)

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
    M.components.vimode(component_opts.left),
    M.components.fileinfo(component_opts.middle),
    M.components.gitinfo(component_opts.middle),
    M.components.navic(component_opts.middle),
    align,
    M.components.snippetinfo(component_opts.middle),
    M.components.spellinfo(component_opts.middle),
    M.components.rootinfo(component_opts.middle),
    M.components.diaginfo(component_opts.middle),
    M.components.lspinfo(component_opts.middle),
    M.components.filetype(component_opts.middle),
    M.components.fileencoding(component_opts.middle),
    M.components.fileformat(component_opts.middle),
    M.components.indentinfo(component_opts.middle),
    M.components.searchinfo(component_opts.middle),
    M.components.sessioninfo(component_opts.middle),
    M.components.ruler(component_opts.right),
  }

  local special_statusline = {
    condition = function()
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix" },
        filetype = { "^git.*", "fugitive", "NvimTree" },
      })
    end,
    M.components.vimode(component_opts.left),
    M.components.helpfilename(component_opts.middle),
    align,
    M.components.rootinfo(component_opts.middle),
    M.components.filetype(component_opts.middle),
    M.components.searchinfo(component_opts.middle),
    M.components.sessioninfo(component_opts.right),
    -- M.components.ruler,
  }

  local terminal_statusline = {
    condition = function()
      return conditions.buffer_matches {
        buftype = { "terminal" },
        filetype = { "toggleterm" },
      }
    end,
    M.components.vimode(component_opts.left),
    M.components.terminalname(component_opts.middle),
    align,
    M.components.rootinfo(component_opts.middle),
    M.components.filetype(component_opts.middle),
    M.components.searchinfo(component_opts.middle),
    M.components.sessioninfo(component_opts.right),
  }

  local statuslines = {
    init = utils.pick_child_on_condition,
    default_statusline,
    special_statusline,
    terminal_statusline,
  }

  require'heirline'.setup(statuslines)
end)


-- au User LspProgressUpdate redrawstatus
-- au User LspRequest redrawstatus

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
