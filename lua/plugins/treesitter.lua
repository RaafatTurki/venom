local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local buffers = require "helpers.buffers"

local M = { plugins_info.treesitter }

M.dependencies = {
  plugins_info.auto_tag,
}

M.build = function()
  pcall(require("nvim-treesitter.install").update({ with_sync = true }))
end

M.config = function()
  local filetypes = {
    dart = { indent = false },
  }

  require 'nvim-treesitter.configs'.setup {
    ensure_installed = {
      'bash',
      'comment',
      'c_sharp',
      'cmake',
      'cpp',
      'css',
      'dart',
      'elm',
      'fish',
      'gdscript',
      'gdshader',
      'gitcommit',
      'gitignore',
      'glsl',
      'go',
      'godot_resource',
      'gomod',
      'html',
      'http',
      'hurl',
      'ini',
      'java',
      'javascript',
      'jsdoc',
      'json',
      'jsonc',
      'kdl',
      'latex',
      'make',
      'markdown',
      'markdown_inline',
      'meson',
      'nix',
      'org',
      'php',
      'prisma',
      'pug',
      'python',
      'regex',
      'rust',
      'scss',
      'sql',
      'ssh_config',
      'svelte',
      'sxhkdrc',
      'toml',
      'typescript',
      'typst',
      'tsx',
      'vimdoc',
      'yaml',

      -- parsers that are bundled but arch neovim package does not include them
      'c',
      'vim',
      'query',
      'lua',
    },
    highlight = {
      enable = true,
    --   disable = function(lang, buf)
    --     local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
    --     local is_ft_blocked = vim.tbl_get(filetypes, ft, "highlight") == false
    --
    --     return is_ft_blocked
    --   end,
    },
    indent = {
      enable = true,
      -- disable = function(lang, buf)
      --   local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
      --   local is_ft_blocked = vim.tbl_get(filetypes, ft, "indent") == false
      --
      --   return is_ft_blocked
      -- end,
    },
  }

  -- treesitter folding
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function(ev)
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end
  })

  -- treesitter auto tag
  require('nvim-ts-autotag').setup({
    opts = {
      enable_close = true,
      enable_rename = false,
      enable_close_on_slash = true
    },
  })
end

return M
