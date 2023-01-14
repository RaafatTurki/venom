--- defines language specific configurations
-- @module lang
log = require 'logger'.log
U = require 'utils'

local M = {}

M.ts_parsers_ensure_installed = {
  'bash',
  'c',
  'c_sharp',
  'cmake',
  -- 'comment',
  'cpp',
  'css',
  'elm',
  'fish',
  'gdscript',
  'gitcommit',
  'gitignore',
  'glsl',
  'go',
  'godot_resource',
  'gomod',
  'html',
  'http',
  'java',
  'javascript',
  'jsdoc',
  'json',
  'jsonc',
  'latex',
  'lua',
  'make',
  'markdown',
  'meson',
  'nix',
  'org',
  'php',
  'python',
  'query',
  'regex',
  'rust',
  'scss',
  'svelte',
  'sql',
  'sxhkdrc',
  'toml',
  'typescript',
  'vim',
  'yaml',
}

M.setup = U.Service():require(FT.PLUGIN, "mason.nvim"):require(FT.PLUGIN, "nvim-navic"):require(FT.PLUGIN, 'nvim-treesitter'):new(function()
  -- mason
  require 'mason'.setup {
    ui = {
      border = 'single',
      icons = {
        package_installed = " ",
        package_pending = " ",
        package_uninstalled = "  ",
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

  -- mini.comment
  require 'mini.comment'.setup {
    mappings = {
      comment = '<space>c',
      comment_line = '<space>c',
      textobject = '',
    },
    hooks = {
      pre = function()
        require('ts_context_commentstring.internal').update_commentstring()
      end,
      post = function() end,
    },
  }

  -- navic
  local navic_icons = {}
  for name, icon in pairs(venom.icons.item_kinds) do navic_icons[name] = icon .. ' ' end
  vim.g.navic_silence = true
  require 'nvim-navic'.setup {
    highlight = true,
    separator = ' > ',
    icons = navic_icons,
  }

  -- neotest
  -- require 'neotest'.setup {
  --   adapters = {
  --     require 'neotest-go',
  --     require 'neotest-jest',
  --   }
  -- }
  -- vim.api.nvim_create_user_command('NeotestToggleTree',   function() require 'neotest'.summary.toggle() end,              {})
  -- vim.api.nvim_create_user_command('NeotestRunNearest',   function() require 'neotest'.run.run() end,                     {})
  -- vim.api.nvim_create_user_command('NeotestRunFile',      function() require 'neotest'.run.run(vim.fn.expand("%")) end,   {})

  -- treesitter
  -- local parser_configs = require 'nvim-treesitter.parsers'.get_parser_configs()
  require 'nvim-treesitter.configs'.setup {
    -- to add more parsers https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = M.ts_parsers_ensure_installed,
    highlight = { enable = true },
    indent = { enable = true }, -- indentexpr (=)
    context_commentstring = { enable = true, enable_autocmd = false },
    matchup = { enable = true },
    -- playground = { enable = true },
  }
end)

-- TODO: abstract into a generic build state system
M.texab_build_status = 0

M.builders = {
  texlab = U.Service():new(function(bufnr)
    -- local build_status = vim.tbl_add_reverse_lookup { Success = 0, Error = 1, Failure = 2, Cancelled = 3, }
    local util = require 'lspconfig.util'
    bufnr = util.validate_bufnr(bufnr)
    local client = util.get_active_client_by_name(bufnr, 'texlab')
    local params = {
      textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    }
    if client then
      client.request('textDocument/build', params, function(err, result)
        if err then error(tostring(err)) end
        M.texab_build_status = result.status
      end, bufnr)
    else
      print 'method textDocument/build is not supported by any servers active on the current buffer'
    end
  end)
}

return M
