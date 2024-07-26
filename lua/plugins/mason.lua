local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons

local M = {
  plugins_info.mason,
}

M.dependencies = {
  -- LSP
  plugins_info.lspconfig,
  plugins_info.mason_lspconfig,
  plugins_info.omnisharp_ext,
  { plugins_info.typescript_tools, dependencies = plugins_info.plenary },
  -- DAP
  plugins_info.dap,
  plugins_info.mason_dap,
  { plugins_info.dap_ui, dependencies = plugins_info.nio },
}

M.config = function()
  require "mason".setup {
    ui = {
      width = 0.8,
      height = 0.8,
      border = 'single',
      icons = {
        package_installed = icons.misc.package,
        package_pending = icons.misc.clock,
        package_uninstalled = icons.misc.package,
      },
      keymaps = {
        toggle_package_expand = "<Space>",
        install_package = "<CR>",
        update_package = "<CR>",
        uninstall_package = "<BS>",
        cancel_installation = "<C-c>",
        check_package_version = "v",
        update_all_packages = "u",
        check_outdated_packages = "o",
        apply_language_filter = "f",
      },
    }
  }

  M.config_lsp()
  M.config_dap()
end

M.config_lsp = function()
  -- set border to :LspInfo window
  require('lspconfig.ui.windows').default_options.border = 'single'

  -- setting up mason servers
  local lspconfig_util = require 'lspconfig.util'
  require "mason-lspconfig".setup {
    handlers = {
      function(server_name)
        M.setup_lsp_server_lspconfig(server_name, {})
      end,
      tsserver = function()
        require "typescript-tools".setup {
          settings = {
            expose_as_code_action = "all",
          },
        }
      end,
      clangd = function()
        M.setup_lsp_server_lspconfig('clangd', {
          cmd = {
            "clangd",
            "--offset-encoding=utf-16",
          },
        })
      end,
      lua_ls = function()
        local neodev = prequire "neodev"
        if neodev then
          neodev.setup { library = { plugins = false } }
        end

        M.setup_lsp_server_lspconfig('lua_ls', {
          settings = {
            Lua = {
              diagnostics = { disable = { 'lowercase-global', 'trailing-space', 'unused-local' } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            }
          },
        })
      end,
      omnisharp = function()
        local opt = {}

        local omnisharp_ext = prequire "omnisharp_extended"
        if omnisharp_ext then
          opt.handlers = {
            ["textDocument/definition"] = require('omnisharp_extended').handler,
          }
        end

        M.setup_lsp_server_lspconfig('omnisharp', opt)
      end,
      markdown_oxide = function()
        M.setup_lsp_server_lspconfig('markdown_oxide', {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              }
            }
          }
        })
      end,
      texlab = function()
        M.setup_lsp_server_lspconfig('texlab', {
          settings = {
            texlab = {
              build = {
                onSave = true,
                executable = 'tectonic',
                args = { '%f', '--synctex', '-k' },
              },
            }
          }
        })
      end,
    }
  }

  -- setting up non-mason servers
  if vim.fn.executable('godot') == 1 then
    M.setup_lsp_server_lspconfig('gdscript', {
      cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      flags = {
        debounce_text_changes = 150,
      },
    })
  end
  if vim.fn.executable('dart') == 1 then
    M.setup_lsp_server_lspconfig('dartls', {
      -- cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      -- flags = {
      --   debounce_text_changes = 150,
      -- },
    })
  end
end

M.config_dap = function()
  vim.fn.sign_define("DapBreakpoint",           { text = icons.dap.breakpoint,              texthl = "ErrorMsg" })
  vim.fn.sign_define("DapBreakpointCondition",  { text = icons.dap.breakpoint_conditional,  texthl = "ErrorMsg" })
  vim.fn.sign_define("DapBreakpointRejected",   { text = icons.dap.breakpoint_rejected,     texthl = "ErrorMsg" })
  vim.fn.sign_define("DapLogPoint",             { text = icons.dap.logpoint,                texthl = "Type" })
  vim.fn.sign_define("DapStopped",              { text = icons.dap.stoppoint,               texthl = "WarningMsg" })

  local dap = require "dap"
  require "mason-nvim-dap".setup {
    handlers = {
      function(cfg)
        require('mason-nvim-dap').default_setup(cfg)
      end
    }
  }

  local dapui = require "dapui"

  dapui.setup {
    mappings = {
      edit = "e",
      expand = { "<Right>" },
      open = { "<CR>", 'o' },
      remove = "d",
      repl = "r",
      toggle = "<Space>"
    },

    layouts = {
      {
        position = "right",
        size = 0.5,
        elements = {
          "scopes",
          "breakpoints",
          "stacks",
          -- "watches",
        },
      },
      {
        position = "bottom",
        size = 0.2,
        elements = {
          "repl",
        },
      },
      -- { elements = { "repl" } },
      -- { elements = { "console", }, size = 0.25, position = "left" },
    },

    controls = {
      enabled = false,
    }

    -- floating = {
    --   max_height = nil, -- These can be integers or a float between 0 and 1.
    --   max_width = nil, -- Floats will be treated as percentage of your screen.
    --   border = "single", -- Border style. Can be "single", "double" or "rounded"
    --   mappings = {
    --     close = { "q", "<Esc>" },
    --   },
    -- },

    -- windows = {
    --   indent = 1
    -- },
    --
    -- render = {
    --   max_type_length = nil, -- Can be integer or nil.
    --   max_value_lines = 100, -- Can be integer or nil.
    -- },
  }

  -- MASON
  keys.map("n", "<leader>l", "<CMD>Mason<CR>", "Open mason")
  -- DAP
  keys.map("n", "xs", function() dap.continue() dapui.open() end, "DAP Start")
  keys.map("n", "xq", function() dap.terminate() dapui.close() end, "DAP Terminate")
  keys.map("n", "xc", dap.continue, "DAP Continue")
  keys.map("n", "xx", dap.toggle_breakpoint, "DAP Toggle breakpoint")
  keys.map("n", "x<Right>", dap.step_into, "DAP Step into")
  keys.map("n", "x<Left>", dap.step_out, "DAP Step out")
  keys.map("n", "x<Up>", dap.step_back, "DAP Step back")
  keys.map("n", "x<Down>", dap.step_over, "DAP Step over")
end

-- server setup opts extender wrapper
M.shared_lsp_server_opts_extension = function(opts)
  -- setup shared capabilities
  local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
  if prequire "nvim-cmp" then
    shared_capabilities = require 'cmp_nvim_lsp'.default_capabilities()
  elseif prequire "autocomplete.capabilities" then
    shared_capabilities = vim.tbl_deep_extend('force', shared_capabilities, require 'autocomplete.capabilities')
  elseif prequire "epo" then
    shared_capabilities = vim.tbl_deep_extend('force', shared_capabilities, require 'epo'.register_cap())
  end

  local shared_opts = {
    capabilities = shared_capabilities,
    handlers = {
      ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
      ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
    },
    on_attach = function(client, bufnr)
      -- set gq command to use the lsp formatter for this buffer
      vim.api.nvim_set_option_value('formatexpr', 'v:lua.vim.lsp.formatexpr()', { buf = bufnr })

      -- format on save
      -- if client.supports_method("textDocument/formatting") then
      --   vim.api.nvim_create_autocmd("BufWritePre", {
      --     buffer = bufnr,
      --     callback = function(ev) vim.lsp.buf.format() end,
      --   })
      -- end

      -- calling the server specific on attach
      if opts.on_attach then
        opts.on_attach(client, bufnr)
      end
    end
  }

  return vim.tbl_deep_extend('force', opts, shared_opts)
end

-- lspconfig server setup wrapper
M.setup_lsp_server_lspconfig = function(server_name, opts)
  local lspconf = require 'lspconfig'
  lspconf[server_name].setup(M.shared_lsp_server_opts_extension(opts))
end

return M
