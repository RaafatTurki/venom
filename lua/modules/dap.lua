local U = require 'utils'

local M = {}

M.setup = service({{ feat.DAP, 'setup' }}, {{ feat.PLUGIN, 'nvim-dap' }, { feat.PLUGIN, 'mason-nvim-dap.nvim' }}, function()

  -- customize DAP signs
  vim.fn.sign_define('DapBreakpoint', { text=icons.dap.breakpoint, texthl='DapBreakpoint', linehl='', numhl='' })
  vim.fn.sign_define('DapBreakpointCondition', { text=icons.dap.breakpoint_conditional, texthl='DapBreakpointCondition', linehl='', numhl='' })
  vim.fn.sign_define('DapBreakpointRejected', { text=icons.dap.breakpoint_rejected, texthl='DapBreakpointRejected', linehl='', numhl='' })
  vim.fn.sign_define('DapLogPoint', { text=icons.dap.logpoint, texthl='DapLogPoint', linehl='', numhl='' })
  vim.fn.sign_define('DapStopped', { text=icons.dap.stoppoint, texthl='', linehl='DapStopped', numhl='' })

  require 'mason-nvim-dap'.setup({
    -- ensure_installed = {'stylua', 'jq'},
    handlers = {
      function(config)
        require('mason-nvim-dap').default_setup(config)
      end,
    },
  })

  local widgets = require('dap.ui.widgets')
  local dap_scopes = widgets.sidebar(widgets.scopes)
  local dap_frames = widgets.sidebar(widgets.frames)
  local dap_sessions = widgets.sidebar(widgets.sessions)
  local dap_expression = widgets.sidebar(widgets.expression)
  local dap_threads = widgets.sidebar(widgets.threads)

  local dap_win_scopes = widgets.builder(widgets.scopes)
  .new_buf(function()
    local BUFFER_OPTIONS = {
      swapfile = false,
      buftype = "nofile",
      modifiable = false,
      filetype = "sfm",
      bufhidden = "wipe",
      buflisted = false,
    }

    local bufnr = vim.api.nvim_create_buf(false, false)
    
    for option, value in pairs(BUFFER_OPTIONS) do
      vim.bo[bufnr][option] = value
    end

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'a', "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})

    -- api.nvim_buf_set_keymap( buf, "n", "<CR>", "<Cmd>lua require('dap.ui').trigger_actions({ mode = 'first' })<CR>", {})
    -- api.nvim_buf_set_keymap( buf, "n", "a", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})
    -- api.nvim_buf_set_keymap( buf, "n", "o", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})
    -- api.nvim_buf_set_keymap( buf, "n", "<2-LeftMouse>", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})

    return bufnr
  end)
  .new_win(function()
    local WIN_OPTIONS = {
      relativenumber = false,
      number = false,
      list = false,
      foldenable = false,
      winfixwidth = true,
      winfixheight = true,
      spell = false,
      signcolumn = "no",
      foldmethod = "manual",
      foldcolumn = "0",
      cursorcolumn = false,
      cursorline = true,
      cursorlineopt = "both",
      colorcolumn = "0",
      wrap = false,
    }

    vim.api.nvim_command "vsp"
    vim.api.nvim_command "wincmd L" -- right

    for option, value in pairs(WIN_OPTIONS) do
      vim.wo[option] = value
    end

    return vim.api.nvim_get_current_win()
  end)
  .build()

  local dap_win_frames = widgets.builder(widgets.frames)
  .new_buf(function()
    local BUFFER_OPTIONS = {
      swapfile = false,
      buftype = "nofile",
      modifiable = false,
      filetype = "sfm",
      bufhidden = "wipe",
      buflisted = false,
    }

    local bufnr = vim.api.nvim_create_buf(false, false)
    
    for option, value in pairs(BUFFER_OPTIONS) do
      vim.bo[bufnr][option] = value
    end

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'a', "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})

    -- api.nvim_buf_set_keymap( buf, "n", "<CR>", "<Cmd>lua require('dap.ui').trigger_actions({ mode = 'first' })<CR>", {})
    -- api.nvim_buf_set_keymap( buf, "n", "a", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})
    -- api.nvim_buf_set_keymap( buf, "n", "o", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})
    -- api.nvim_buf_set_keymap( buf, "n", "<2-LeftMouse>", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})

    return bufnr
  end)
  .new_win(function()
    local WIN_OPTIONS = {
      relativenumber = false,
      number = false,
      list = false,
      foldenable = false,
      winfixwidth = true,
      winfixheight = true,
      spell = false,
      signcolumn = "no",
      foldmethod = "manual",
      foldcolumn = "0",
      cursorcolumn = false,
      cursorline = true,
      cursorlineopt = "both",
      colorcolumn = "0",
      wrap = false,
    }

    vim.api.nvim_command "vsp"
    vim.api.nvim_command "wincmd L" -- right

    for option, value in pairs(WIN_OPTIONS) do
      vim.wo[option] = value
    end

    return vim.api.nvim_get_current_win()
  end)
  .build()

  vim.api.nvim_create_user_command('DapToggleTest', function(opts)
    local widget_name = opts.fargs[1]

    local widget_wins = {
      scopes = dap_win_scopes,
      frames = dap_win_frames,
    }

    for name, widget in pairs(widget_wins) do
      widget.close()
      -- if name ~=  widget_name then end
    end

    if widget_name then
      widget_wins[widget_name].open()
    end

  end, { nargs = '?' })
  -- vim.api.nvim_create_user_command('DapToggleTest', dap_test.toggle, {})
  vim.api.nvim_create_user_command('DapToggleScopes', dap_scopes.toggle, {})
  vim.api.nvim_create_user_command('DapToggleFrames', dap_frames.toggle, {})
  vim.api.nvim_create_user_command('DapToggleSessions', dap_sessions.toggle, {})
  vim.api.nvim_create_user_command('DapToggleExpression', dap_expression.toggle, {})
  vim.api.nvim_create_user_command('DapToggleThreads', dap_threads.toggle, {})

  -- scopes
  -- frames
  -- sessions
  -- expression
  -- threads

  -- local icons = {
  --   disconnect = "",
  --   pause = "",
  --   play = "",
  --   run_last = "",
  --   step_back = "",
  --   step_into = "",
  --   step_out = "",
  --   step_over = "",
  --   terminate = ""
  -- }
end)

M.aggregate = function()
  local data = {
    files_breakpoints = {},
    -- other_type_of_breakpoints = {},
  }

  -- list dap breakpoint signs for every currently open buffer
  for i, buf in ipairs(Buffers.buflist.bufs) do
    local signs = vim.fn.sign_getplaced(buf.bufnr, { group = 'dap_breakpoints' })[1].signs

    local file_breakpoints = {
      file_index = i,
      breakpoints = {},
    }

    for _, sign in ipairs(signs) do
      if sign.name == 'DapBreakpoint' then
        table.insert(file_breakpoints.breakpoints, { lnum = sign.lnum })
      end
    end

    if #file_breakpoints.breakpoints > 0 then
      table.insert(data.files_breakpoints, file_breakpoints)
    end
  end

  return data
end

M.populate = function(data)
  local dap_bp = require 'dap.breakpoints'
  data = data or {}

  if data.files_breakpoints then
    for i, file_breakpoints in ipairs(data.files_breakpoints) do
      local buf_info = Buffers.buflist:get_buf_info(file_breakpoints.file_index)
      if not buf_info then break end

      for _, file_breakpoint in ipairs(file_breakpoints.breakpoints) do
        dap_bp.set({}, buf_info.buf.bufnr, file_breakpoint.lnum)
      end
    end
  end

end

return M
