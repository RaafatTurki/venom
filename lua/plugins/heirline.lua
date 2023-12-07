local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local buffers = require "helpers.buffers"
local icons = require "helpers.icons".icons

local M = { plugins_info.heirline.url }

M.dependecies = {
  plugins_info.devicons.url,
}

M.config = function()
  local utils = require 'heirline/utils'
  local conditions = require 'heirline/conditions'

  local align = { provider = "%=" }
  local space = { provider = " " }


  -- NOTE: tabline
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
        if vim.api.nvim_buf_get_option(self.bufnr, 'buftype') == 'terminal' then
          self.icon = ' '
          self.icon_color = utils.get_highlight('Type').fg
        else
          local filename = self.filename
          local extension = vim.fn.fnamemodify(filename, ':e')
          self.icon, self.icon_color = require 'nvim-web-devicons'.get_icon_color(filename, extension, { default = true })
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
        condition = function(self) return vim.api.nvim_buf_get_option(self.bufnr, 'modified') end,
        provider = '•',
        hl = 'DiffAdd',
      },
      {
        condition = function(self)
          -- return (not vim.api.nvim_buf_get_option(self.bufnr, "modifiable") or vim.api.nvim_buf_get_option(self.bufnr, "readonly")) and not vim.api.nvim_buf_get_option(self.bufnr, 'buftype') == 'terminal'
          return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable") or
            vim.api.nvim_buf_get_option(self.bufnr, "readonly")
        end,
        provider = '',
        hl = 'ErrorMsg',
      },
      {
        condition = function(self)
          if self.bufnr == nil then return end
          return (buffers.buflist:get_buf_info(buffers.buflist:get_buf_index({bufnr = self.bufnr})).buf.is_huge)
        end,
        provider = '',
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


  -- NOTE: statusline
  local file_icon = {
    init = function(self)
      local filename = vim.api.nvim_buf_get_name(0)
      local extension = vim.fn.fnamemodify(filename, ":e")
      self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
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

  local copilot = {
    condition = function()
      return prequire "copilot"
    end,
    provider = function()
      local message = require "copilot.api".status.data.message
      -- local message = require "copilot.api".status.data.status
      if message ~= '' then message = ' ' .. message end
      return icons.kind.Copilot .. message
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
      for i, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
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
      return string.format(icons.misc.search .. " %d/%d", search.current, math.min(search.total, search.maxcount))
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

  local ruler = {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = "%(%l/%L%):%c",
    hl = "Comment"
  }


  -- NOTE: statuscolumn
  local sc_lnum = {
    condition = function() return vim.o.number end,
    provider = function()
      local num_count = vim.api.nvim_buf_line_count(0)
      return U.str_pad(tostring(vim.v.lnum), #tostring(num_count), ' ')
    end,
    hl = function()
      local ls, _, le, _ = U.get_cursor_pos()
      local lnums = {}

      if ls > le then
        local tmp = le
        le = ls
        ls = tmp
      end

      for i = ls, le do
        table.insert(lnums, i)
      end

      if vim.tbl_contains(lnums, vim.v.lnum) then
        return vim.api.nvim_get_hl(0, { name = U.get_mode_hl() or "Normal" })
      end
    end,
  }

  local sc_fold = {
    condition = function()
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
        str = vim.v.relnum > 0 and "%#FoldColumn#" or "%#CursorLineFold#"
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
    space,
  }

  local sc_gitsigns = {
    init = function(self)
      local bufs_signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), { group = "gitsigns_vimfn_signs_", lnum = vim.v.lnum })
      local signs = bufs_signs[1].signs

      if #signs == 0 then
        self.sign = nil
      else
        self.sign = vim.fn.sign_getdefined(signs[1].name)[1]
      end
    end,
    provider = function(self)
      if self.sign then
        return self.sign.text
      else
        return '  '
      end
    end,
    hl = function(self)
      if self.sign then
        return self.sign.texthl
      else
        return nil
      end
    end,
  }

  local sc_diags = {
    init = function(self)
      local bufs_signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), { group = "*", lnum = vim.v.lnum })
      local signs = bufs_signs[1].signs


      if #signs == 0 then
        self.sign = nil
      else
        local sign = vim.fn.sign_getdefined(signs[1].name)[1]
        if vim.startswith(sign.name, "DiagnosticSign") then
          self.sign = sign
        else
          self.sign = nil
        end
      end
    end,
    provider = function(self)
      if self.sign then
        return self.sign.text
      else
        return '  '
      end
    end,
    hl = function(self)
      if self.sign then
        return self.sign.texthl
      else
        return nil
      end
    end,
  }


  require "heirline".setup {
    tabline = { { tabline_offset, bufferline, tabpages } },
    statusline = { {
      file_icon, space,
      file_name, space,
      file_flag_modified,
      file_flag_readonly, space,
      gitsigns, space,

      align,

      lsp_diagnostics,
      copilot,
      lsp_active,
      search_count,
      macro_rec,
      file_encoding, space,
      filetype, space,
      ruler
    } },
    statuscolumn = { {
      -- TODO: sc_dap
      sc_lnum,
      -- sc_diags,
      sc_gitsigns,
      sc_fold,
    } },
  }

end

return M
