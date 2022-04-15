--- defines plugins configurations.
-- @module configs
local M = {}

M.notify = U.Service():require(FT.PLUGIN, "nvim-notify"):new(function()
  local notify = require 'notify'

  notify.setup {
    timeout = 500,
    render = 'minimal',
  }

  vim.notify = notify
end)

M.possession = U.Service():require(FT.PLUGIN, "possession.nvim"):new(function()
  require 'possession'.setup {}
  -- require('telescope').load_extension('possession')
end)

M.gitsigns = U.Service():require(FT.PLUGIN, "gitsigns.nvim"):new(function()
  require 'gitsigns'.setup {
    signs = {
      add             = {text = '│'},
      change          = {text = '│'},
      delete          = {text = '_'},
      topdelete       = {text = '‾'},
      changedelete    = {text = '~'},
    },
    keymaps = {},
    sign_priority = 14, -- because nvim diagnostic signs are <13
  }
end)

M.nvim_comment = U.Service():require(FT.PLUGIN, "nvim-comment"):new(function()
  local commentstrings_context_aware = {
    vue = {},
    svelte = {},
    html = {},
    javascript = {},
  }

  local commentstrings = {
    gdscript = '#%s',
    fish = '#%s',
    c = '//%s',
    toml = '#%s',
    samba = '#%s',
    desktop = '#%s',
    dosini = '#%s',
    bc = '#%s',
  }

  require 'nvim_comment'.setup {
    create_mappings = false,
    marker_padding = true,
    hook = function()
      for filetype, value in pairs(commentstrings) do
        if vim.api.nvim_buf_get_option(0, "filetype") == filetype then
          vim.api.nvim_buf_set_option(0, "commentstring", value)
        end
      end
      for filetype, value in pairs(commentstrings_context_aware) do
        if vim.api.nvim_buf_get_option(0, "filetype") == filetype then
          require("ts_context_commentstring.internal").update_commentstring()
        end
      end
    end
  }
end)

M.cmp = U.Service():require(FT.PLUGIN, "nvim-cmp"):new(function()
  -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  local function snippet_jump(dir, modes)
    return cmp.mapping(function(fallback)
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump(dir)
      else
        cmp.mapping.close()
        fallback()
      end
    end, modes)
  end

  cmp.setup {
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = {
      ["<Tab>"]       = snippet_jump(1,   { 'i', 's' }),
      ["<S-Tab>"]     = snippet_jump(-1,  { 'i', 's' }),
      ['<C-d>']       = cmp.mapping.scroll_docs(-4),
      ['<C-f>']       = cmp.mapping.scroll_docs(4),
      ['<C-Space>']   = cmp.mapping.complete(),
      ['<C-e>']       = cmp.mapping.close(),
      ['<C-y>']       = cmp.config.disable,
      ['<CR>']        = cmp.mapping.confirm({ select = false }),
    },
    sources = {
      { name = 'nvim_lsp' },  -- depends on LSP:cmp feature
      { name = 'nvim_lua' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
      { name = 'spell' },
    },
    formatting = {
      format = function(entry, vim_item)
        vim_item.kind = venom.icons.item_kinds.codeicons[vim_item.kind] .. ' ' .. vim_item.kind
        return vim_item
      end
    },
    window = {
      documentation = {
        border = 'single',
        -- max_width = 90,
        -- scrollbar = '║',
      },
      completion = {
        border = 'single',
        -- scrollbar = '║',
      }
    }
  }

  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  cmp.setup.cmdline(':', {
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    }
  })
end)

-- abstract into a statusbar service
M.feline = U.Service():require(FT.PLUGIN, "feline.nvim"):new(function()
  local lsp_diag_icons = venom.icons.diagnostic_states.cozette

  local function c(comp)
    if comp == nil then comp = {} end

    -- left and right separators
    local sep = {
      str = ' ',
      hl = 'StatusLine'
    }
    comp.right_sep = sep
    comp.left_sep = sep

    -- fixing up highlighting

    if type(comp.hl) == 'string' then

      comp.hl = {
        -- fg = get_col(comp.hl, 'fg') or get_col('StatusLine', 'fg') or 'NONE',
        -- bg = get_col(comp.hl, 'bg') or get_col('StatusLine', 'bg') or 'NONE',
        fg = U.hi(comp.hl).fg or U.hi('StatusLine').fg or 'NONE',
        bg = U.hi(comp.hl).bg or U.hi('StatusLine').bg or 'NONE',
      }
    elseif comp.hl == nil then
      comp.hl = {
        fg = U.hi('StatusLine').fg or 'NONE',
        bg = U.hi('StatusLine').bg or 'NONE',
      }
    end

    return comp
  end

  local components = {
    active = {
      {
        c({ provider = U.get_mode_name }),
        c({ provider = { name = 'file_info',                              opts = { file_readonly_icon = '  ' }}}),

        c({ provider = 'git_branch',          hl = 'GitSignsDelete',      icon = ' ' }),
        c({ provider = 'git_diff_added',      hl = 'GitSignsAdd',         icon = '+' }),
        c({ provider = 'git_diff_removed',    hl = 'GitSignsDelete',      icon = '-' }),
        c({ provider = 'git_diff_changed',    hl = 'GitSignsChange',      icon = '~' }),
      },
      {
        -- c({ provider = require 'package-info'.get_status, hl = 'Folded' }),
        c({ provider = '',                  hl = 'WarningMsg',          enabled = function () return (vim.v.this_session ~= "") end }),
        c({ provider = 'ROOT',                hl = 'ErrorMsg',            enabled = U.user():is_root() }),

        c({ provider = 'diagnostic_errors',   hl = 'DiagnosticSignError', icon = lsp_diag_icons.Error }),
        c({ provider = 'diagnostic_warnings', hl = 'DiagnosticSignWarn',  icon = lsp_diag_icons.Warn }),
        c({ provider = 'diagnostic_info',     hl = 'DiagnosticSignInfo',  icon = lsp_diag_icons.Info }),
        c({ provider = 'diagnostic_hints',    hl = 'DiagnosticSignHint',  icon = lsp_diag_icons.Hint }),

        c({ provider = 'lsp_client_names' }),
        c({ provider = 'file_type' }),
        -- c({ provider = 'file_encoding' }),
        -- c({ provider = 'file_size', enabled = function() return vim.fn.getfsize(vim.fn.expand('%:p')) > 0 end }),
        c({ provider = U.get_indent_settings_str() }),
        c({ provider = 'position' }),
      },
    },
    inactive = {
      {},
      {}
    },
  }

  require 'feline'.setup {
    components = components,
    force_inactive = {
      filetypes = {'packer', 'NvimTree', 'DiffviewFiles'},
      buftypes = {},
      bufnames = {}
    },
  }
end)

return M