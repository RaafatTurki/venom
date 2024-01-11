local plugins_info = require "helpers.plugins_info"
local buffers = require "helpers.buffers"
local U = require "helpers.utils"

local M = { plugins_info.treesitter.url }

M.dependencies = {
  plugins_info.treesitter_ctx_cms.url,
  -- plugins_info.treesitter_ctx.url,
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
      'dart',
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
      'prisma',
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
      disable = function(lang, buf) return U.is_buf_huge(buf) end,
    },
    indent = {
      enable = true,
      disable = function(lang, buf) return U.is_buf_huge(buf) end,
    },
  }

  -- require 'treesitter-context'.setup {
  --   -- max_lines = 0,
  --   -- min_window_height = 0,
  --   line_numbers = false,
  --   -- multiline_threshold = 20,
  --   -- trim_scope = 'outer',
  --   mode = 'cursor',
  --   separator = "─",
  -- }

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function(ev)
      if not U.is_buf_huge(ev.buf) then
        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      else
        -- vim.opt.foldmethod = "manual"
      end
    end
  })
end

return M
