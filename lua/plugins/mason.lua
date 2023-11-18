local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons

local M = { plugins_info.mason.url }

M.dependencies = {
  plugins_info.lspconfig.url,
  plugins_info.mason_lspconfig.url,
  plugins_info.neodev.url,
}

M.config = function()
  -- NOTE: add border to :LspInfo window
  require('lspconfig.ui.windows').default_options.border = 'single'

  function setup_lspconfig_server(server_name, opts)
    local lspconf = require 'lspconfig'

    -- setup shared capabilities
    local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
    if prequire "nvim-cmp" then
      shared_capabilities = require 'cmp_nvim_lsp'.default_capabilities()
    end

    local shared_opts = {
      capabilities = shared_capabilities,
      handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
      },
      on_attach = function(client, bufnr)
        -- set gq command to use the lsp formatter for this buffer
        vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
        -- Lsp.setup_buf_fmt_on_save(client, bufnr)

        -- navic
        -- if feat_list:has(feat.CONF, 'nvim-navic') then
        --   require 'nvim-navic'.attach(client, bufnr)
        -- end

        -- lsp-overloads
        -- if feat_list:has(feat.CONF, 'lsp-overloads.nvim') and client.server_capabilities.signatureHelpProvider then
        --   require 'lsp-overloads'.setup(client, {
        --     ui = {
        --       border = "single"
        --     },
        --     keymaps = {
        --       next_signature = "<S-Down>",
        --       previous_signature = "<S-Up>",
        --       next_parameter = "<S-Right>",
        --       previous_parameter = "<S-Left>",
        --     },
        --   })
        -- end

        -- calling the server specific on attach
        if opts.on_attach then
          opts.on_attach(client, bufnr)
        end
      end
    }

    lspconf[server_name].setup(vim.tbl_deep_extend('force', opts, shared_opts))
  end

  local lspconfig_util = require 'lspconfig.util'

  require "mason".setup {
    ui = {
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

  keys.map("n", "<leader>l", "<CMD>Mason<CR>", "Open mason")

  for type, icon in pairs(icons.diag) do
    local hl = "DiagnosticSign" .. type
    -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
  end

  require "mason-lspconfig".setup()
  require "mason-lspconfig".setup_handlers {
    function(server_name)
      setup_lspconfig_server(server_name, {})
    end,
    lua_ls = function()
      local neodev = prequire "neodev"
      if neodev then
        neodev.setup { library = { plugins = false } }
      end

      setup_lspconfig_server('lua_ls', {
        settings = {
          Lua = {
            diagnostics = { disable = { 'lowercase-global', 'trailing-space', 'unused-local' } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          }
        },
      })
    end,
    texlab = function()
      setup_lspconfig_server('texlab', {
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

  if vim.fn.executable('godot') == 1 then
    setup_lspconfig_server('gdscript', {
      cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      flags = {
        debounce_text_changes = 150,
      },
    })
  end


  local function lsp_rename()
      local curr_name = vim.fn.expand("<cword>")
      local input_opts = {
        prompt = 'LSP Rename: ',
        default = curr_name
      }
      -- ask user input
      vim.ui.input(input_opts, function(new_name)
        -- check new_name is valid
        if not new_name or #new_name == 0 or curr_name == new_name then return end

        -- request lsp rename
        local params = vim.lsp.util.make_position_params()
        params.newName = new_name

        vim.lsp.buf_request(0, "textDocument/rename", params, function(err, res, ctx, _)
          if err then
            if err.message then log.err(err.message) end
            return
          end
          if not res then return end

          -- apply renames
          local client = vim.lsp.get_client_by_id(ctx.client_id)
          vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)

          -- display a message
          local changes = U.count_lsp_res_changes(res)
          local message = string.format("renamed %s instance%s in %s file%s. %s",
            changes.instances,
            changes.instances == 1 and '' or 's',
            changes.files,
            changes.files == 1 and '' or 's',
            changes.files > 1 and "To save them run ':wa'" or ''
          )
          vim.notify(message)
        end)
      end)
  end

  local function lsp_references()
    if prequire "telescope" then
      vim.cmd [[Telescope lsp_references]]
    else
      vim.lsp.buf.references()
    end
  end

  local function lsp_definition()
    if prequire "telescope" then
      vim.cmd [[Telescope lsp_definitions]]
    else
      vim.lsp.buf.definition()
    end
  end

  local function lsp_code_action()
    vim.lsp.buf.code_action()
  end

  local function lsp_hover()
    local fold_preview = prequire "fold-preview"
    if fold_preview then
      if not fold_preview.toggle_preview() then
        vim.lsp.buf.hover()
      end
    else
      vim.lsp.buf.hover()
    end
  end

  local function lsp_format()
    vim.lsp.buf.format()
  end

  local function lsp_diags_list()
    vim.diagnostic.setloclist()
    -- vim.diagnostic.setqflist()
  end

  local function lsp_diags_hover()
    vim.diagnostic.open_float({ border = "single" })
  end


  local function toggle_diags()
    -- TODO: ...
  end

  local function setup_buf_fmt_on_save(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function(ev) vim.lsp.buf.format() end,
      })
    end
  end

  -- keys.map("n", "<leader>D",         lsp_toggle_diags, {})
  keys.map("n", "<leader>r",         lsp_rename, {})
  keys.map("n", "<leader>R",         lsp_references, {})
  keys.map("n", "<leader>d",         lsp_definition, {})
  keys.map("n", "<leader>C",         lsp_code_action, {})
  keys.map("n", "<leader>v",         lsp_hover, {})
  keys.map("n", "<leader>x",         lsp_diags_hover, {})
  keys.map("n", "<leader>X",         lsp_diags_list, {})

  vim.api.nvim_create_user_command('LspRename', lsp_rename, {})
  vim.api.nvim_create_user_command('LspReferences', lsp_references, {})
  vim.api.nvim_create_user_command('LspDefinition', lsp_definition, {})
  vim.api.nvim_create_user_command('LspCodeAction', lsp_code_action, {})
  vim.api.nvim_create_user_command('LspHover', lsp_hover, {})
  vim.api.nvim_create_user_command('LspDiagsList', lsp_diags_list, {})
  vim.api.nvim_create_user_command('LspDiagsHover', lsp_diags_hover, {})
  vim.api.nvim_create_user_command('LspFormat', lsp_format, {})
end

return M
