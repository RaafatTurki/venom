local U = require "helpers.utils"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons
local buffers = require "helpers.buffers"


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

keys.map("n", "<leader>l", "<CMD>Mason<CR>", "Open mason")


local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
shared_capabilities.textDocument.completion.completionItem.insertReplaceSupport = true


vim.lsp.config("*", {
  capabilities = shared_capabilities,
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      telemetry = { enable = false },
      diagnostics = {
        disable = { 'lowercase-global', 'trailing-space', 'unused-local' }
      },
      workspace = {
        checkThirdParty = false,
        -- library = {
        --   vim.env.VIMRUNTIME
        -- }
      },
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



require "mason-lspconfig".setup {
  handlers = {
    function(server_name) vim.lsp.enable(server_name) end,
  }
}
