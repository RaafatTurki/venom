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
  'ini',
  'java',
  'javascript',
  'jsdoc',
  'json',
  'jsonc',
  'latex',
  'lua',
  'make',
  'markdown_inline',
  'markdown',
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
  'svelte',
  'sql',
  'sxhkdrc',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

M.setup = service({{feat.LANG, 'setup'}}, nil, function()
  -- mason
  if feat_list:has(feat.PLUGIN, 'mason.nvim') then
    require 'mason'.setup {
      ui = {
        border = 'single',
        icons = {
          package_installed = " ",
          package_pending = " ",
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
  end

  -- mini.comment
  if feat_list:has(feat.PLUGIN, 'mini.nvim') then
    require 'mini.comment'.setup {
      mappings = {
        comment = '<space>c',
        comment_line = '<space>c',
        textobject = '',
      },
      hooks = {
        pre = function() end,
        post = function() end,
      },
      options = {
        custom_commentstring = function()
          ---@diagnostic disable-next-line: missing-parameter
          return require 'ts_context_commentstring.internal'.calculate_commentstring() or vim.bo.commentstring
        end,
        ignore_blank_line = true,
      },
    }
  end

  -- navic
  if feat_list:has(feat.CONF, 'nvim-navic') then
    local navic_icons = {}
    for name, icon in pairs(icons.lsp) do navic_icons[name] = icon .. ' ' end
    vim.g.navic_silence = true
    require 'nvim-navic'.setup {
      highlight = true,
      separator = ' > ',
      icons = navic_icons,
    }
  end

  -- treesitter
  if feat_list:has(feat.PLUGIN, 'nvim-treesitter') then
    require 'nvim-treesitter.configs'.setup {
      -- to add more parsers https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
      ensure_installed = M.ts_parsers_ensure_installed,
      highlight = { enable = true },
      indent = { enable = true }, -- indentexpr (=)
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          -- node_incremental = "grn",
          scope_incremental = "<CR>",
          node_decremental = "<BS>",
        },
      },
      -- TODO: ensure the plgu is installed
      context_commentstring = { enable = true, enable_autocmd = false },
    }
  end
end)

M.toggle_spell = service(function()
  vim.wo.spell = not vim.wo.spell
end)

-- TODO: abstract into a generic indicators system
M.texab_build_status = 0

M.builders = {
  texlab = service(function(bufnr)
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
