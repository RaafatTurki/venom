local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.edgy }

M.config = function()
  require 'edgy'.setup {
    left = {
      {
        title = "Files",
        ft = "neo-tree",
        filter = function(buf) return vim.b[buf].neo_tree_source == "filesystem" end,
        size = { width = 40 }
      },
    },
    right = {
      {
        title = "Help",
        ft = "help",
        size = { width = 100 },
        filter = function(buf) return vim.bo[buf].buftype == "help" end,
      },
      {
        title = "Help",
        ft = "markdown",
        size = { width = 100 },
        filter = function(buf) return vim.bo[buf].buftype == "help" end,
      },
      {
        title = "Scopes",
        ft = "dapui_scopes",
        size = { width = 100 },
      },
      {
        title = "Breakpoints",
        ft = "dapui_breakpoints",
        size = { width = 100 },
      },
      {
        title = "Stacks",
        ft = "dapui_stacks",
        size = { width = 100, height = 20 },
      },
      {
        title = "Watches",
        ft = "dapui_watches",
        size = { width = 100 },
      },
    },
    bottom = {
      {
        title = "QuickFix",
        ft = "qf",
      },
      {
        title = "REPL",
        ft = "dap-repl",
        size = { height = 20 },
      },
      -- {
      --   title = "Console",
      --   ft = "dapui_console",
      -- },
    },
    animate = {
      enabled = false
    },
    exit_when_last = true,
    close_when_all_hidden = false,
  }
end

return M
