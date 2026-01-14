local U = require "helpers.utils"
local buffers = require "helpers.buffers"
local sessions = require "helpers.sessions"
local icons = require "helpers.icons".icons

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
        if MiniIcons then self.icon, self.icon_hl = MiniIcons.get('filetype', extension) end
      end
    end,
    provider = function(self) return self.icon and (self.icon) end,
    hl = function(self) return self.icon_hl end
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
      hl = '@diff.plus',
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
        return vim.b[self.bufnr].large_buf
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
    if MiniIcons then self.icon, self.icon_hl = MiniIcons.get('filetype', extension) end
  end,
  provider = function(self)
    return self.icon
  end,
  hl = function(self)
    return self.icon_hl
  end
}

local file_name = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":.")
    if filename == "" then return "[No Name]" end
    if not conditions.width_percent_below(#filename, 0.25) then filename = vim.fn.pathshorten(filename) end
    return filename
  end,
  hl = "Directory",
}

local file_flag_modified = {
  condition = function()
    return vim.bo.modified
  end,
  provider = icons.misc.modified,
  hl = "@diff.plus",
}

local file_flag_readonly = {
  condition = function()
    return not vim.bo.modifiable or vim.bo.readonly
  end,
  provider = "",
  hl = "ErrorMsg",
}

local show_cmd = {
  condition = function() return vim.o.cmdheight == 0 end,
  provider = "%S",
  hl = "Comment",
}

-- ext
local mini_git = {
  condition = function()
    if not MiniDiff then return false end
    local buf_data = MiniDiff.get_buf_data()
    if buf_data then return buf_data.summary end
  end,
  init = function(self)
    self.data = vim.b['minigit_summary']
    self.summary = MiniDiff.get_buf_data().summary
  end,
  provider = function(self)
    if self.data and self.data.head_name then
      return icons.misc.git_branch .. ' ' .. self.data.head_name
    end
  end,
  -- add
  {
    provider = function(self)
      -- print(self.summary)
      local count = self.summary.add or 0
      return count > 0 and ("+" .. count)
    end,
    hl = "@diff.plus"
  },
  -- delete
  {
    provider = function(self)
      local count = self.summary.delete or 0
      return count > 0 and ("-" .. count)
    end,
    hl = "@diff.minus"
  },
  -- change
  {
    provider = function(self)
      local count = self.summary.change or 0
      return count > 0 and ("~" .. count)
    end,
    hl = "@diff.delta"
  },
  -- hunks
  {
    provider = function(self)
      local count = self.summary.n_ranges or 0
      return count > 0 and ("|" .. count)
    end,
    hl = "Comment"
  },
  hl = "ErrorMsg"
}

local root = {
  condition = function(self)
    return os.getenv("USER") == "root"
  end,
  provider = function(self)
    return icons.misc.user .. " " .. "root"
  end,
  space,
  hl = "ErrorMsg",
}

local lsp_diagnostics = {
  condition = conditions.has_diagnostics,
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  -- error
  {
    condition = function(self) return self.errors > 0 end,
    provider = function(self) return self.errors .. " " .. icons.diag.Error end,
    space,
    hl = "DiagnosticError"
  },
  -- warn
  {
    condition = function(self) return self.warnings > 0 end,
    provider = function(self) return self.warnings .. " " .. icons.diag.Warn end,
    space,
    hl = "DiagnosticWarn",
  },
  -- info
  {
    condition = function(self) return self.info > 0 end,
    provider = function(self) return self.info .. " " .. icons.diag.Info end,
    space,
    hl = "DiagnosticInfo"
  },
  -- hint
  {
    condition = function(self) return self.hints > 0 end,
    provider = function(self) return self.hints > 0 and (self.hints .. " " .. icons.diag.Hint) end,
    space,
    hl = "DiagnosticHint"
  },
  update = { "DiagnosticChanged", "BufEnter" },
}

local lsp_active = {
  condition = conditions.lsp_attached,
  provider = function(self)
    local names = {}
    for i, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do table.insert(names, server.name) end
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
    if vim.v.hlsearch == 0 then return false end
    local ok, search = pcall(vim.fn.searchcount, { recompute = 1, maxcount = 0 })
    if not ok then return false end
    return (search.total or 0) > 0
  end,
  init = function(self)
    local ok, search = pcall(vim.fn.searchcount, { recompute = 1, maxcount = 0 })
    if ok and search.total then self.search = search end
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
  condition = function() return vim.fn.reg_recording() ~= "" end,
  provider = function() return icons.misc.record .. " " .. vim.fn.reg_recording() end,
  space,
  hl = "ErrorMsg",
  update = { "RecordingEnter", "RecordingLeave" }
}

local local_session = {
  condition = function() return sessions.is_in_local_session end,
  provider = function() return icons.misc.sessions end,
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
  provider = function() return vim.bo.filetype end,
  hl = "Folded",
}

local spell = {
  condition = function() return vim.opt.spell:get() end,
  provider = function()
    if vim.opt.spell:get() then return icons.misc.spellcheck end
  end,
  space,
  hl = "Normal"
}

local ignorecase = {
  condition = function() return not vim.opt.ignorecase:get() end,
  provider = function() if not vim.opt.ignorecase:get() then return icons.misc.letter_case end end,
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

local neocodeium = {
  static = {
    symbols = {
      status = {
        [0] = "󰚩 ", -- Enabled
        [1] = "󱚧 ", -- Disabled Globally
        [2] = "󱙻 ", -- Disabled for Buffer
        [3] = "󱙺 ", -- Disabled for Buffer filetype
        [4] = "󱙺 ", -- Disabled for Buffer with enabled function
        [5] = "󱚠 ", -- Disabled for Buffer encoding
        [6] = "󱚠 ", -- Buffer is special type
      },
      server_status = {
        [0] = "󰣺 ", -- Connected
        [1] = "󰣻 ", -- Connecting
        [2] = "󰣽 ", -- Disconnected
      },
    },
  },
  update = {
    "User",
    pattern = { "NeoCodeiumServer*", "NeoCodeium*{En,Dis}abled" },
    callback = function() vim.cmd.redrawstatus() end,
  },
  provider = function(self)
    local symbols = self.symbols
    local status, server_status = require("neocodeium").get_status()
    return symbols.status[status] .. symbols.server_status[server_status]
  end,
  hl = "WarningMsg",
}


-- STATUSCOLUMN
local sc_lnum = {
  provider = function(self) return '%l' or '..' end,
  hl = function(self) if vim.v.relnum == 0 then return "Normal" else return "Comment" end end
}

local sc_fold = {
  -- there is no point in showing foldcolumn if we can't access the folds api
  condition = function() return vim.o.foldcolumn == "1" end,
  init = function(self) self.ffi = require "helpers.fold_ffi" end,
  static = {
    foldopen = vim.opt.fillchars:get().foldopen,
    foldclosed = vim.opt.fillchars:get().foldclose,
    foldsep = vim.opt.fillchars:get().foldsep,
  },
  provider = function(self)
    -- use the fold_ffi module to get fast fold data

    -- get window handler
    local wp = self.ffi.C.find_window_by_handle(0, self.ffi.new "Error")
    -- get foldcolumn width
    local width = self.ffi.C.compute_foldcolumn(wp, 0)
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
  hl = function() return vim.v.relnum > 0 and "Comment" or "Normal" end
}

local sc_mini_diff = {
  condition = function() return MiniDiff end,
  init = function(self) self.ns = vim.api.nvim_get_namespaces()["MiniDiffViz"] end,
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
      mini_git, space,
      show_cmd, space,

      align,

      align,
      neocodeium,
      lsp_diagnostics,
      ignorecase,
      spell,
      lsp_active,
      search_count,
      macro_rec,
      local_session,
      root,
      file_encoding, space,
      filetype, space,
      ruler,
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
      sc_lnum,

      sc_mini_diff,
      space,

      sc_diags,
      space,

      sc_fold,
      space,
    }
  },
}
