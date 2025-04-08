local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local buffers = require "helpers.buffers"
local sessions = require "helpers.sessions"
local icons = require "helpers.icons".icons

local M = { plugins_info.heirline }

M.config = function()
  local utils = require 'heirline/utils'
  local conditions = require 'heirline/conditions'

  local align = { provider = "%=" }
  local space = { provider = " " }


  -- TABLINE
  local tabline_offset = {
    condition = function(self)
      local win = vim.api.nvim_tabpage_list_wins(0)[1]
      local bufnr = vim.api.nvim_win_get_buf(win)
      self.winid = win

      local ft_to_title = {
        ['neo-tree'] = "",
        ['NvimTree'] = "",
        ['sfm'] = "",
      }

      for ft, title in pairs(ft_to_title) do
        if vim.bo[bufnr].filetype == ft then
          self.title = title
          return true
        end
      end
    end,
    provider = function(self)
      local title = ""
      local width = vim.api.nvim_win_get_width(self.winid)
      local pad = math.ceil((width - #title) / 2)
      local str = string.rep(" ", pad) .. title .. string.rep(" ", pad)
      return str .. "│"
    end,
    hl = "Tabline"
  }

  local buffer_abstract = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      self.is_loaded = vim.api.nvim_buf_is_loaded(self.bufnr)
    end,
    hl = function(self)
      return self.is_active and 'TablineSel' or 'Tabline'
    end,
    -- label
    {
      provider = function(self)
        if self.bufnr == nil then return end
        return (buffers.buflist:get_buf_info(buffers.buflist:get_buf_index({bufnr = self.bufnr})).label or '')
      end,
      hl = "ErrorMsg",
    },
    space,
    -- icon
    {
      init = function(self)
        if vim.api.nvim_get_option_value('buftype', { buf = self.bufnr }) == 'terminal' then
          self.icon = ' '
          self.icon_color = utils.get_highlight('Type').fg
        else
          local filename = self.filename
          local extension = vim.fn.fnamemodify(filename, ':e')
          if prequire 'nvim-web-devicons' then
            self.icon, self.icon_color = require 'nvim-web-devicons'.get_icon_color(filename, extension, { default = true })
          end
        end
      end,
      provider = function(self) return self.icon and (self.icon) end,
      hl = function(self) return { fg = self.icon_color } end
    },
    space,
    -- buffer name
    {
      provider = function(self)
        local filename = self.filename
        filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
        return filename
      end,
      hl = function(self)
        return { underline = self.is_loaded }
      end,
    },
    space,
    -- indicators
    {
      {
        condition = function(self) return vim.api.nvim_get_option_value('modified', { buf = self.bufnr }) end,
        provider = '• ',
        hl = 'DiffAdd',
      },
      {
        condition = function(self)
          -- return (not vim.api.nvim_buf_get_option(self.bufnr, "modifiable") or vim.api.nvim_buf_get_option(self.bufnr, "readonly")) and not vim.api.nvim_buf_get_option(self.bufnr, 'buff type') == 'terminal'
          return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr }) or
            vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
        end,
        provider = ' ',
        hl = 'ErrorMsg',
      },
      {
        condition = function(self)
          if self.bufnr == nil then return end
          local ft = vim.bo[self.bufnr].filetype
          return ft == 'bigfile'
        end,
        provider = ' ',
        hl = 'WarningMsg',
      },
    },
  }

  local bufferline = {
    utils.make_buflist(utils.surround({ ' ', ' ' }, nil, buffer_abstract), { provider = '' }, { provider = '' }, function()
      return vim.tbl_map(function(buf) return buf.bufnr end, buffers.buflist.bufs)
    end, false)
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


  -- STATUSLINE
  local file_icon = {
    init = function(self)
      local filename = vim.api.nvim_buf_get_name(0)
      local extension = vim.fn.fnamemodify(filename, ":e")
      if prequire 'nvim-web-devicons' then
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
      end
    end,
    provider = function(self)
      return self.icon
    end,
    hl = function(self)
      return { fg = self.icon_color }
    end
  }

  local file_name = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    provider = function(self)
      local filename = vim.fn.fnamemodify(self.filename, ":.")
      if filename == "" then return "[No Name]" end
      if not conditions.width_percent_below(#filename, 0.25) then
        filename = vim.fn.pathshorten(filename)
      end
      return filename
    end,
    hl = "Directory",
  }

  local file_flag_modified = {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = icons.misc.modified,
      hl = "DiffAdd",
    },
  }

  local file_flag_readonly = {
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = "",
      hl = "ErrorMsg",
    },
  }

  local gitsigns = {
    condition = function()
      return conditions.is_git_repo() and prequire "gitsigns"
    end,
    init = function(self)
      self.status_dict = vim.b['gitsigns_status_dict']
      self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    {
      provider = function(self)
        return icons.misc.git_branch .. ' ' .. self.status_dict.head
      end,
      space,
      hl = "ErrorMsg"
    },
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return count > 0 and ("+" .. count)
      end,
      hl = "DiffAdd"
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and ("-" .. count)
      end,
      hl = "DiffDelete",
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and ("~" .. count)
      end,
      hl = "DiffChange"
    },
  }

  local mini_git_branch = {
    condition = function()
      return prequire "mini.git"
    end,
    init = function(self)
      self.summary = vim.b['minigit_summary']
    end,
    provider = function(self)
      if self.summary and self.summary.head_name then
        return icons.misc.git_branch .. ' ' .. self.summary.head_name
      end
    end,
    hl = "ErrorMsg"
  }

  local mini_diff_summary = {
    condition = function()
      local mini_diff = prequire "mini.diff"

      if mini_diff then
        local buf_data = mini_diff.get_buf_data()
        if buf_data then
          return buf_data.summary
        end
      end
    end,
    init = function(self)
      self.summary = prequire "mini.diff".get_buf_data().summary
    end,
    {
      provider = function(self)
        local count = self.summary.add or 0
        return count > 0 and ("+" .. count)
      end,
      hl = "DiffAdd"
    },
    {
      provider = function(self)
        local count = self.summary.delete or 0
        return count > 0 and ("-" .. count)
      end,
      hl = "DiffDelete",
    },
    {
      provider = function(self)
        local count = self.summary.change or 0
        return count > 0 and ("~" .. count)
      end,
      hl = "DiffChange"
    },
    {
      provider = function(self)
        local count = self.summary.n_ranges or 0
        return count > 0 and ("|" .. count)
      end,
      hl = "Comment"
    },
  }

  local root = {
    condition = function(self)
      self.user = os.getenv("USER")
      return self.user == "root"
    end,
    provider = function(self)
      return icons.misc.user .. " " .. self.user
    end,
    space,
    hl = "ErrorMsg",
  }

  local copilot = {
    condition = function()
      return prequire "copilot"
    end,
    provider = function()
      local message = require "copilot.api".status.data.message
      -- local message = require "copilot.api".status.data.status
      if message ~= '' then message = ' ' .. message end
      return icons.copilot.Copilot .. message
    end,
    space,
    hl = function()
      local status = require "copilot.api".status.data.status
      if status == "InProgress" then
        return "Type"
      elseif status == "Normal" then
        return "Folded"
      else
        return "Comment"
      end
    end,
  }

  local lsp_diagnostics = {
    condition = conditions.has_diagnostics,
    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    {
      condition = function(self) return self.errors > 0 end,
      provider = function(self) return self.errors .. " " .. icons.diag.Error end,
      space,
      hl = "DiagnosticError"
    },
    {
      condition = function(self) return self.warnings > 0 end,
      provider = function(self) return self.warnings .. " " .. icons.diag.Warn end,
      space,
      hl = "DiagnosticWarn",
    },
    {
      condition = function(self) return self.info > 0 end,
      provider = function(self) return self.info .. " " .. icons.diag.Info end,
      space,
      hl = "DiagnosticInfo"
    },
    {
      condition = function(self) return self.hints > 0 end,
      provider = function(self) return self.hints > 0 and (self.hints .. " " .. icons.diag.Hint) end,
      space,
      hl = "DiagnosticHint"
    },
    update = { "DiagnosticChanged", "BufEnter" },
  }

  local lsp_active = {
    -- condition = conditions.lsp_attached,
    static = {
      blacklisted_servers = { "copilot" }
    },
    provider = function(self)
      local names = {}
      for i, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if not vim.tbl_contains(self.blacklisted_servers, server.name) then
          table.insert(names, server.name)
        end
      end
      return icons.misc.cogwheel .. " " .. table.concat(names, " ")
    end,
    space,
    hl = "Type",
    update = {
      'LspAttach', 'LspDetach', 'BufEnter',
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end)
    },
  }

  local search_count = {
    condition = function()
      return vim.v.hlsearch ~= 0
    end,
    init = function(self)
      local ok, search = pcall(vim.fn.searchcount)
      if ok and search.total then
        self.search = search
      end
    end,
    provider = function(self)
      local search = self.search
      return string.format(
        icons.misc.search .. " %d/%d",
        search.current,
        math.min(search.total, search.maxcount)
      )
    end,
    space
  }

  local macro_rec = {
    condition = function()
      return vim.fn.reg_recording() ~= ""
    end,
    provider = function()
      return icons.misc.record .. " " .. vim.fn.reg_recording()
    end,
    space,
    hl = "ErrorMsg",
    update = { "RecordingEnter", "RecordingLeave" }
  }

  local local_session = {
    condition = function()
      return sessions.is_in_local_session
    end,
    provider = function()
      return icons.misc.sessions
    end,
    space,
    hl = "WarningMsg",
  }

  local file_encoding = {
    provider = function()
      local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
      return enc
    end,
    hl = "Comment"
  }

  local filetype = {
    provider = function()
      return vim.bo.filetype
    end,
    hl = "Folded",
  }

  local spell = {
    condition = function()
      return vim.opt.spell:get()
    end,
    provider = function()
      if vim.opt.spell:get() then
        return icons.misc.spellcheck
      end
    end,
    space,
    hl = "Normal"
  }

  local ignorecase = {
    condition = function()
      return not vim.opt.ignorecase:get()
    end,
    provider = function()
      if not vim.opt.ignorecase:get() then
        return icons.misc.letter_case
      end
    end,
    space,
    hl = "Normal"
  }

  local ruler = {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = "%(%l/%L%):%c",
    hl = "Comment"
  }


  -- STATUSCOLUMN
  local sc_lnum = {
    -- condition = function()
    --   return vim.o.number
    -- end,
    init = function(self)
      self.lnum = vim.v.lnum
      self.visual_range = nil
      if vim.fn.mode():lower():find('v') then
        local visual_lnum = vim.fn.getpos('v')[2]
        local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1]
        -- ensure visual_range is ascending
        if visual_lnum > cursor_lnum then
          self.visual_range = { cursor_lnum, visual_lnum }
        else
          self.visual_range = { visual_lnum, cursor_lnum }
        end
      end
    end,
    provider = function(self)
      return '%l'
      -- TODO: remove
      -- local num_count = vim.api.nvim_buf_line_count(0)
      --
      -- if vim.v.virtnum > 0 then
      --   return U.str_pad('.', #tostring(num_count), ' ')
      -- else
      --   return U.str_pad(tostring(self.lnum), #tostring(num_count), ' ')
      -- end
    end,
    hl = function(self)
      if vim.v.relnum == 0 then
        return "Normal"
      elseif self.visual_range and self.lnum >= self.visual_range[1] and self.lnum <= self.visual_range[2] then
        return "Folded"
      else
        return "Comment"
      end
    end
  }

  local sc_fold = {
    condition = function()
      -- there is no point in showing foldcolumn if we can't access the folds api
      -- TODO: make this work on higher values than 1
      return vim.o.foldcolumn == "1"
    end,
    init = function(self)
      self.ffi = require "helpers.fold_ffi"
    end,
    static = {
      foldopen = vim.opt.fillchars:get().foldopen,
      foldclosed = vim.opt.fillchars:get().foldclose,
      foldsep = vim.opt.fillchars:get().foldsep,
    },
    provider = function(self)
      local wp = self.ffi.C.find_window_by_handle(0, self.ffi.new "Error") -- get window handler
      local width = self.ffi.C.compute_foldcolumn(wp, 0) -- get foldcolumn width

      -- get fold info of current line
      local foldinfo = width > 0 and self.ffi.C.fold_info(wp, vim.v.lnum) or { start = 0, level = 0, llevel = 0, lines = 0 }

      local str = ""
      if width ~= 0 then
        str = ""
        if foldinfo.level == 0 then
          str = str .. (" "):rep(width)
        else
          local closed = foldinfo.lines > 0
          local first_level = foldinfo.level - width - (closed and 1 or 0) + 1
          if first_level < 1 then first_level = 1 end

          for col = 1, width do
            str = str
            .. (
            (vim.v.virtnum ~= 0 and self.foldsep)
            or ((closed and (col == foldinfo.level or col == width)) and self.foldclosed)
            or ((foldinfo.start == vim.v.lnum and first_level + col > foldinfo.llevel) and self.foldopen)
            or self.foldsep
          )
            if col == foldinfo.level then
              str = str .. (" "):rep(width - col)
              break
            end
          end
        end
      end

      -- return str
      return str .. "%*"
      -- return status_utils.stylize(str .. "%*", opts)
    end,
    hl = function()
      return vim.v.relnum > 0 and "FoldColumn" or "CursorLineFold"
    end
  }

  local sc_mini_diff = {
    condition = function()
      return prequire "mini.diff"
    end,
    init = function(self)
      self.ns = vim.api.nvim_get_namespaces()["MiniDiffViz"]
    end,
    provider = function(self)
      local sign = U.get_lnum_extmark_signs(self.ns, true)[1]
      return sign and sign.sign_text or ' '
    end,
    hl = function(self)
      local sign = U.get_lnum_extmark_signs(self.ns)[1]
      return sign and sign.sign_hl_group or 'Normal'
    end,
  }

  local sc_dap = {
    init = function(self)
      local ns = {}

      -- breakpoints namespace
      ns.breakpoints = vim.api.nvim_get_namespaces()["dap_breakpoints"]

      -- stoppoint namespace
      local bufnr = vim.api.nvim_get_current_buf()
      local dap_ns = vim.api.nvim_get_namespaces()["dap-" .. bufnr]
      if dap_ns then ns.stoppoint = vim.api.nvim_get_namespaces()["dap-" .. dap_ns] end

      self.ns = ns
    end,
    provider = function(self)
      local signs = {
        breakpoint = self.ns.breakpoints and U.get_lnum_extmark_signs(self.ns.breakpoints, true)[1],
        stoppoint = self.ns.stoppoint and U.get_lnum_extmark_signs(self.ns.stoppoint, true)[1],
      }

      local str = ''

      if signs.breakpoint and signs.stoppoint then
        str = icons.dap.stoppoint_active
      elseif signs.breakpoint then
        str = signs.breakpoint.sign_text
      elseif signs.stoppoint then
        str = signs.stoppoint.sign_text
      else
        str = ' '
      end

      return str
    end,
    hl = function(self)
      local signs = {
        breakpoint = self.ns.breakpoints and U.get_lnum_extmark_signs(self.ns.breakpoints, true)[1],
        stoppoint = self.ns.stoppoint and U.get_lnum_extmark_signs(self.ns.stoppoint, true)[1],
      }

      local hl = "Normal"

      if signs.breakpoint then
        hl = signs.breakpoint.sign_hl_group
      end

      if signs.stoppoint then
        hl = signs.stoppoint.sign_hl_group
      end

      return hl
    end,
  }

  local sc_lightbulb = {
    condition = function()
      return prequire "nvim-lightbulb"
    end,
    init = function(self)
      self.ns = vim.api.nvim_get_namespaces()["nvim-lightbulb"]
    end,
    provider = function(self)
      local sign = U.get_lnum_extmark_signs(self.ns, true)[1]
      return sign and sign.sign_text or ' '
    end,
    hl = function(self)
      local sign = U.get_lnum_extmark_signs(self.ns)[1]
      return sign and sign.sign_hl_group or 'Normal'
    end,
  }

  local sc_diags = {
    provider = function(self)
      local severity_level = U.get_lnum_diag_severity()

      local diag_icons = {
        icons.diag.Error,
        icons.diag.Warn,
        icons.diag.Info,
        icons.diag.Hint,
      }

      return severity_level and diag_icons[severity_level] or ' '
    end,
    hl = function()
      local severity_level = U.get_lnum_diag_severity()
      if not severity_level then return 'Normal' end

      local diag_hls = {
        "DiagnosticSignError",
        "DiagnosticSignWarn",
        "DiagnosticSignInfo",
        "DiagnosticSignHint",
      }

      return diag_hls[severity_level]
    end
  }

  require "heirline".setup {
    tabline = {
      fallthrough = false,
      { tabline_offset, bufferline, tabpages }
    },
    statusline = {
      fallthrough = false,
      {
        file_icon, space,
        file_name, space,
        file_flag_modified,
        file_flag_readonly, space,
        -- gitsigns, space,
        mini_git_branch, space,
        mini_diff_summary, space,

        align,

        lsp_diagnostics,
        ignorecase,
        spell,
        copilot,
        lsp_active,
        search_count,
        macro_rec,
        local_session,
        root,
        file_encoding, space,
        filetype, space,
        ruler
      }
    },
    statuscolumn = {
      fallthrough = false,
      {
        condition = function()
          local is_terminal = vim.bo.buftype == 'terminal'
          local is_help = vim.bo.ft == 'help' and vim.bo.buftype == 'help'
          local is_ft = vim.tbl_contains({
            "dap-repl",
            "dapui_breakpoints",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
            "neo-tree",
            "NvimTree",
            "sfm",
          }, vim.bo.ft)

          if is_terminal or is_help or is_ft then
            vim.wo.foldcolumn = '0'
            vim.wo.number = false

            return true
          end
        end,
      },
      {
        sc_dap,
        space,

        sc_lnum,

        sc_mini_diff,
        space,

        sc_diags,
        space,

        sc_fold,
        sc_lightbulb,
        space,
      }
    },
  }
end

return M
