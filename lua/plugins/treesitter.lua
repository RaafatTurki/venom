local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.treesitter.url }

M.dependencies = {
  plugins_info.treesitter_ctx_cms.url
}

M.build = function()
  pcall(require("nvim-treesitter.install").update({ with_sync = true }))
end

M.config = function()
  require 'nvim-treesitter.configs'.setup {
    ensure_installed = {
      'bash',
      'c',
      -- 'comment',
      'c_sharp',
      'cmake',
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
      'ini',
      'java',
      'javascript',
      'jsdoc',
      'json',
      'jsonc',
      'latex',
      'lua',
      'make',
      'markdown',
      'markdown_inline',
      'meson',
      'nix',
      'org',
      'php',
      'pug',
      'python',
      'query',
      'regex',
      'rust',
      'scss',
      'sql',
      'ssh_config',
      'svelte',
      'sxhkdrc',
      'toml',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    },
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > large_filesize then return true end
      end,
    },
    indent = {
      enable = true
    },
  }

  vim.o.foldmethod = "expr"
  vim.o.foldexpr = "nvim_treesitter#foldexpr()"
end

return M
