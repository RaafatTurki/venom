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

  -- local widgets = require('dap.ui.widgets')
  -- local dap_scopes = widgets.sidebar(widgets.scopes)
  -- local dap_frames = widgets.sidebar(widgets.frames)

  -- dap_scopes.open()
  -- dap_frames.open()

  -- sessions
  -- scopes
  -- frames
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

return M
