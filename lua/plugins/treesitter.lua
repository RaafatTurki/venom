local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local buffers = require "helpers.buffers"

local M = { plugins_info.treesitter }

-- M.dev = true

M.dependencies = {
  -- plugins_info.treesitter_ctx_cms,
  -- plugins_info.treesitter_ctx,
  plugins_info.treesitter_comments,
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
      disable = function(lang, buf)
        local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
        local is_ft_blocked = vim.tbl_get(filetypes, ft, "highlight") == false
        local is_buf_huge = U.is_buf_huge(buf)

        return is_buf_huge or is_ft_blocked
      end,
    },
    indent = {
      enable = true,
      disable = function(lang, buf)
        local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
        local is_ft_blocked = vim.tbl_get(filetypes, ft, "indent") == false
        local is_buf_huge = U.is_buf_huge(buf)

        return is_buf_huge or is_ft_blocked
      end,
    },
  }

  require 'ts-comments'.setup {}

  -- vim.g.skip_ts_context_commentstring_module = true
  --
  -- require 'ts_context_commentstring'.setup {
  --   enable_autocmd = false,
  -- }

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
