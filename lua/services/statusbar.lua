--- defines statusbar and winbar components.
-- @module statusbar
log = require 'logger'.log
U = require 'utils'

local M = {}

M.components = {}

M.setup = U.Service():require(FT.PLUGIN, "mini.nvim"):new(function()
  local utils = require 'heirline/utils'
  local conditions = require 'heirline/conditions'

  local align = { provider = "%=" }
  local space = { provider = " " }

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
        hl = 'DiffAdd'
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

  M.components.navic_simple = U.Service():new(function(opts)
    return {
      condition = function()
        return require 'nvim-navic'.is_available()
      end,
      -- opts.left_pad,
      {
        provider = require 'nvim-navic'.get_location,
        hl = 'Folded',
        update = 'CursorMoved'
      },
      -- opts.right_pad,
    }
  end)

  M.components.navic = U.Service():new(function(opts)
    return {
      condition = function() return require 'nvim-navic'.is_available() end,
      opts.left_pad,
      {
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
            local winnr = bit.band(c,  63)
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
                    vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), {line, col})
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
      },
      opts.right_pad,
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
          return backward..venom.icons.item_kinds.Snippet..forward
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
        provider = venom.icons.item_kinds.Text,
      },
      opts.left_pad,
    }
  end)

  M.components.rootinfo = U.Service():new(function(opts)
    return {
      condition = function()
        return vim.env['USER'] == 'root'
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
        hl = 'Folded',
      },
      opts.right_pad,
    }
  end)

  M.components.sessioninfo = U.Service():new(function(opts)
    return {
      condition = function () return Sessions.get_current() end,
      opts.left_pad,
      {
        provider = function()
          return ' ' .. Sessions.get_current()
        end,
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
        hl = 'Comment'
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
          if vim.o.shiftwidth == vim.o.tabstop and vim.o.tabstop == vim.o.softtabstop then indent_width = tostring(vim.o.shiftwidth) end
          return indent_type..':'..indent_width
        end,
        hl = 'Comment',
      },
      opts.right_pad,
    }
  end)

  M.components.searchinfo = U.Service():new(function(opts)
    return {
      condition = function()
        return vim.v.hlsearch == 1
      end,
      opts.left_pad,
      {
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
 
  -- TODO: abstract into a generic indicators system
  M.components.texlab_status = U.Service():new(function(opts)
    return {
      condition = function()
        local util = require 'lspconfig.util'
        local client = util.get_active_client_by_name(0, 'texlab')
        return client ~= nil
      end,
      opts.left_pad,
      {
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
    -- M.components.navic(component_opts.middle),
    align,
    M.components.texlab_status(component_opts.middle),
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
    fallthrough = false,
    default_statusline,
    special_statusline,
    terminal_statusline,
  }


  local default_winbar = {
    condition = function()
      return vim.bo.buftype == ''
    end,
    space,
    M.components.navic(component_opts.middle),
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
          vim.api.nvim_buf_delete(minwid, {force = false})
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
          return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable") or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
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
