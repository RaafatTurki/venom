local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons
local buffers = require "helpers.buffers"

local M = {
  plugins_info.mason,
}

M.dependencies = {
  -- LSP
  plugins_info.lspconfig,
  plugins_info.mason_lspconfig,
  plugins_info.omnisharp_ext,
  plugins_info.sqls,
  plugins_info.schemastore,
  { plugins_info.typescript_tools, dependencies = plugins_info.plenary },
  plugins_info.fmt_ts_errors,
  -- DAP
  plugins_info.dap,
  plugins_info.mason_dap,
  { plugins_info.dap_ui, dependencies = plugins_info.nio },
}

M.lsp = {}
M.dap = {}

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

  M.lsp.config()
  M.dap.config()
end

M.lsp.config = function()
  -- setting up mason servers
  local lspconfig_util = require 'lspconfig.util'
  require "mason-lspconfig".setup {
    handlers = {
      function(server_name)
        M.lsp.setup_server(server_name, {})
      end,
      ts_ls = function()
        local opts = {
          settings = {
            expose_as_code_action = "all",
          },
        }

        -- -- use format-ts-errors if available
        -- local fmt_ts_errors = prequire 'format-ts-errors'
        -- if fmt_ts_errors then
        --   fmt_ts_errors.setup({
        --     add_markdown = true,
        --     start_indent_level = 0,
        --   })
        --
        --   opts.handlers = {
        --     ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
        --       if result.diagnostics == nil then return end
        --
        --       -- ignore some tsserver diagnostics
        --       local idx = 1
        --       while idx <= #result.diagnostics do
        --         local entry = result.diagnostics[idx]
        --
        --         local formatter = require('format-ts-errors')[entry.code]
        --         entry.message = formatter and formatter(entry.message) or entry.message
        --
        --         -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
        --         if entry.code == 80001 then
        --           -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
        --           table.remove(result.diagnostics, idx)
        --         else
        --           idx = idx + 1
        --         end
        --       end
        --
        --       vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
        --     end,
        --   }
        -- end

        -- use typescript-tools if available
        local ts_tools = prequire 'typescript-tools'
        if ts_tools then
          ts_tools.setup(M.lsp.shared_opts_extender(opts))
        else
          M.lsp.setup_server('ts_ls', opts)
        end
      end,
      clangd = function()
        M.lsp.setup_server('clangd', {
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

        M.lsp.setup_server('lua_ls', {
          settings = {
            Lua = {
              telemetry = { enable = false },
              diagnostics = {
                disable = { 'lowercase-global', 'trailing-space', 'unused-local' }
              },
              workspace = { checkThirdParty = false },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            }
          },
        })
      end,
      jsonls = function()
        local opt = {}

        local schemastore_ext = require "schemastore"
        if schemastore_ext then
          opt.settings = {
            json = {
              validate = { enable = true },
              schemas = schemastore_ext.json.schemas(),
            },
          }
        end

        M.lsp.setup_server('jsonls', opt)
      end,
      sqls = function()
        local opt = {
          settings = {
            sqls = {
              connections = {
                {
                  driver = 'postgresql',
                  dataSourceName = 'host=127.0.0.1 port=5432 user=admin password=admin dbname=tam sslmode=disable',
                },
              },
            },
          },
        }

        -- use sqls plugin if available
        local sqls_nvim = prequire 'sqls'
        if sqls_nvim then
          opt.on_attach = function(client, bufnr)
            sqls_nvim.on_attach(client, bufnr)
          end
        end

        M.lsp.setup_server('sqls', opt)
      end,
      omnisharp = function()
        local opt = {}

        local omnisharp_ext = prequire "omnisharp_extended"
        if omnisharp_ext then
          opt.handlers = {
            ["textDocument/definition"] = require('omnisharp_extended').handler,
          }
        end

        M.lsp.setup_server('omnisharp', opt)
      end,
      markdown_oxide = function()
        M.lsp.setup_server('markdown_oxide', {
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
        M.lsp.setup_server('texlab', {
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
  local gdshader_lsp_bin = "/home/potato/sectors/rust/gdshader-lsp/target/debug/gdshader-lsp"
  if vim.fn.executable('gdshader_lsp_bin') == 1 then
    M.lsp.setup_server('gdshader_lsp', {
      name = "gdshader",
      cmd = { gdshader_lsp_bin, "--stdio" },
    })
  end
  if vim.fn.executable('godot') == 1 then
    M.lsp.setup_server('gdscript', {
      cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      flags = {
        debounce_text_changes = 150,
      },
    })
  end
  if vim.fn.executable('dart') == 1 then
    M.lsp.setup_server('dartls', {
      -- cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      -- flags = {
      --   debounce_text_changes = 150,
      -- },
    })
  end
end

M.lsp.shared_opts_extender = function(opts)
  -- setup shared capabilities
  local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
  if prequire "cmp" and prequire "cmp_nvim_lsp" then
    shared_capabilities = require 'cmp_nvim_lsp'.default_capabilities(shared_capabilities)
  elseif prequire "autocomplete.capabilities" then
    shared_capabilities = vim.tbl_deep_extend('force', shared_capabilities, require 'autocomplete.capabilities')
  elseif prequire "epo" then
    shared_capabilities = vim.tbl_deep_extend('force', shared_capabilities, require 'epo'.register_cap())
  end

  shared_capabilities.textDocument.completion.completionItem.insertReplaceSupport = true

  local shared_opts = {
    capabilities = shared_capabilities,
    -- TODO: remove
    -- handlers = {
    --   ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
    --   ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
    -- },
    -- on_init = function(client, _)
    --   client.server_capabilities.semanticTokensProvider = nil
    -- end,
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

      -- enable inlay hints
      -- if client.server_capabilities.inlayHintProvider then
      --   -- this might not be needed
      --   vim.g.inlay_hints_visible = true
      --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      -- else
      --   print("no inlay hints available")
      -- end

      -- calling the server specific on attach
      if opts.on_attach then
        opts.on_attach(client, bufnr)
      end
    end
  }

  return vim.tbl_deep_extend('force', opts, shared_opts)
end

M.lsp.setup_server = function(server_name, opts)
  local lspconfig = require 'lspconfig'
  lspconfig[server_name].setup(M.lsp.shared_opts_extender(opts))
end



M.dap.config = function()
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
          -- "breakpoints",
          "stacks",
          -- "watches",
        },
      },
      -- {
      --   position = "bottom",
      --   size = 0.2,
      --   elements = {
      --     "repl",
      --   },
      -- },
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
  keys.map("n", "ss", function() dap.continue() dapui.open() end, "DAP Start")
  keys.map("n", "sq", function() dap.terminate() dapui.close() end, "DAP Terminate")
  keys.map("n", "sc", dap.continue, "DAP Continue")
  keys.map("n", "sx", dap.toggle_breakpoint, "DAP Toggle breakpoint")
  keys.map("n", "s<Right>", dap.step_into, "DAP Step into")
  keys.map("n", "s<Left>", dap.step_out, "DAP Step out")
  keys.map("n", "s<Up>", dap.step_back, "DAP Step back")
  keys.map("n", "s<Down>", dap.step_over, "DAP Step over")
end

M.dap.list_breakpoints = function(bufnr)
  local lnums = {}

  local dap_bps = prequire "dap.breakpoints"
  if dap_bps == nil then return lnums end

  local bps = dap_bps.get(bufnr)[1]
  if bps == nil then return lnums end
  lnums = vim.tbl_map(function(bp) return bp.line end, bps)

  return lnums
end

M.dap.set_breakpoint = function(bufnr, lnum)
  local dap_bps = prequire "dap.breakpoints"
  if dap_bps == nil then return end
  dap_bps.set({}, bufnr, lnum)
end

M.dap.aggregate = function()
  local data = {
    breakpoints = {},
  }

  for i, buf in ipairs(buffers.buflist.bufs) do
    if not buf.is_persistable then goto dap_aggregate_loop_continue end

    local file_path = U.get_relative_path(buf.file_path)
    local lnums = M.dap.list_breakpoints(buf.bufnr)

    if #lnums > 0 then
      data.breakpoints[file_path] = lnums
    end

    ::dap_aggregate_loop_continue::
  end

  return data
end

M.dap.populate = function(data)
  for i, buf in ipairs(buffers.buflist.bufs) do
    file_path = U.get_relative_path(buf.file_path)

    if data.breakpoints[file_path] then
      for _, lnum in ipairs(data.breakpoints[file_path]) do
        M.dap.set_breakpoint(buf.bufnr, lnum)
      end
    end
  end
end

return M
