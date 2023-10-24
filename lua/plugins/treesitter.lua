local plugins_info = require "helpers.plugins_info"
local buffers = require "helpers.buffers"

local M = { plugins_info.treesitter.url }

M.dependencies = {
  plugins_info.treesitter_ctx_cms.url
}

M.build = function()
  pcall(require("nvim-treesitter.install").update({ with_sync = true }))
end

M.config = function()
  local function ts_module_huge_buffer_disable(lang, buf)
    local buf_i = buffers.buflist:get_buf_index({bufnr = buf})
    if not buf_i then return false end
    if buffers.buflist:get_buf_info(buf_i).buf.is_huge then return true else return false end
  end

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
      disable = ts_module_huge_buffer_disable
    },
    indent = {
      enable = true,
      disable = ts_module_huge_buffer_disable
    },
  }

  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
end

return M
