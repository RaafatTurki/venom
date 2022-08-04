--- defines language specific configurations
-- @module lang
local M = {}

M.ts_parsers_ensure_installed = {
  'bash',
  'c',
  'cmake',
  'comment',
  'cpp',
  'c_sharp',
  'css',
  'fish',
  'gdscript',
  'glsl',
  'go',
  'gomod',
  'godot_resource',
  'html',
  'http',
  'java',
  'javascript',
  'jsdoc',
  'json',
  'latex',
  'lua',
  'markdown',
  'python',
  'query',
  'regex',
  'rust',
  'scss',
  'svelte',
  'toml',
  'typescript',
  'vim',
  'yaml',
}

M.setup = U.Service()
:require(FT.PLUGIN, "mason.nvim")
:require(FT.PLUGIN, "nvim-navic")
:require(FT.PLUGIN, "spellsitter.nvim")
:require(FT.PLUGIN, "neotest")
:require(FT.PLUGIN, 'nvim-treesitter')
:new(function()
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

  -- nvim comment
  local ts_ctx_cs_filetypes = { 'html', 'svelte' }
  require 'Comment'.setup {
    mappings = false,
    ignore = '^$',
    pre_hook = function(ctx)
      if U.has_value(ts_ctx_cs_filetypes, vim.bo.filetype) then
        local comment_utils = require 'Comment.utils'
        local ts_ctx_cs_utils = require 'ts_context_commentstring.utils'
        local ts_ctx_cs_internal = require 'ts_context_commentstring.internal'

        -- determine the location where to calculate commentstring from
        local cs_pos = nil
        if ctx.ctype == comment_utils.ctype.block then
          cs_pos = ts_ctx_cs_utils.get_cursor_location()
        elseif ctx.cmotion == comment_utils.cmotion.v or ctx.cmotion == comment_utils.cmotion.V then
          cs_pos = ts_ctx_cs_utils.get_visual_start_location()
        end

        -- return '%s'
        -- commentstring calculation
        return ts_ctx_cs_internal.calculate_commentstring({
          key = ctx.ctype == comment_utils.ctype.line and '__default' or '__multiline',
          location = cs_pos,
        })
      end
    end,
  }

  -- navic
  local navic_icons = {}
  for name, icon in pairs(venom.icons.item_kinds.cozette) do navic_icons[name] = icon..' ' end
  vim.g.navic_silence = true
  require 'nvim-navic'.setup {
    highlight = true,
    separator = ' > ',
    icons = navic_icons,
  }

  -- spellsitter
  require 'spellsitter'.setup {
    enable = true,
  }

  -- neotest
  require 'neotest'.setup {
    adapters = {
      require 'neotest-go',
      require 'neotest-jest',
    }
  }
  vim.api.nvim_create_user_command('NeotestToggleTree',   function() require 'neotest'.summary.toggle() end,              {})
  vim.api.nvim_create_user_command('NeotestRunNearest',   function() require 'neotest'.run.run() end,                     {})
  vim.api.nvim_create_user_command('NeotestRunFile',      function() require 'neotest'.run.run(vim.fn.expand("%")) end,   {})

  -- treesitter
  -- local parser_configs = require 'nvim-treesitter.parsers'.get_parser_configs()
  require 'nvim-treesitter.configs'.setup {
    -- to add more parsers https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = M.ts_parsers_ensure_installed,
    highlight = { enable = true },
    indent = { enable = true },   -- indentexpr (=)
    context_commentstring = { enable = true, enable_autocmd = false },
    matchup = { enable = true },
    -- playground = { enable = true },
  }
end)

return M
