--- defines plugins configurations.
-- @module configs
local M = {}

M.impatient = U.Service():require(FT.PLUGIN, "impatient.nvim"):new(function()
  require 'impatient'
  require 'impatient'.enable_profile()
end)

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

  Bind.key:invoke {'<leader>c',  ':CommentToggle<CR>'}
  Bind.key:invoke {'<leader>c',  ':CommentToggle<CR>',    mode = 'v'}
  Bind.key:invoke {'Y',          'ygv:CommentToggle<CR>', mode = 'v'}
end)

M.cmp = U.Service():require(FT.PLUGIN, "nvim-cmp"):new(function()
  -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  cmp.setup {
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = {
      ["<Tab>"]       = cmp.mapping(function(fallback) if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fallback() end end, { "i", "s" }),
      ["<S-Tab>"]     = cmp.mapping(function(fallback) if luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end end, { "i", "s" }),
      ['<Down>']      = cmp.mapping.select_next_item(),
      ['<Up>']        = cmp.mapping.select_prev_item(),
      ['<C-Down>']    = cmp.mapping.scroll_docs(4),
      ['<C-Up>']      = cmp.mapping.scroll_docs(-4),
      ['<C-Space>']   = cmp.mapping.complete(),
      ['<C-e>']       = cmp.mapping.close(),
      ['<CR>']        = cmp.mapping.confirm(),
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
      fields = { "kind", "abbr" },
      format = function(entry, vim_item)
        vim_item.kind = venom.icons.item_kinds.cozette[vim_item.kind]
        return vim_item
      end
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
      -- scrollbar = '║',
    },
    experimental = {
      ghost_text = true
    }
  }

  cmp.setup.cmdline('/', {
    -- mapping = {
    --   ['<Down>']      = cmp.mapping.select_next_item(),
    --   ['<Up>']        = cmp.mapping.select_prev_item(),
    -- },
    sources = {
      { name = 'buffer' }
    }
  })
  
  cmp.setup.cmdline(':', {
    -- mapping = {
    --   ['<Down>']      = cmp.mapping.select_next_item(),
    --   ['<Up>']        = cmp.mapping.select_prev_item(),
    -- },
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    }
  })
end)

M.nvim_tree = U.Service():require(FT.PLUGIN, "nvim-tree.lua"):new(function()
  U.gvar('nvim_tree_side'):set('left')
  U.gvar('nvim_tree_width'):set(40)
  U.gvar('nvim_tree_git_hl'):set(1)
  U.gvar('nvim_tree_highlight_opened_files'):set(0)
  U.gvar('nvim_tree_root_folder_modifier'):set(':t')
  U.gvar('nvim_tree_add_trailing'):set(0)
  U.gvar('nvim_tree_group_empty'):set(1)
  U.gvar('nvim_tree_icon_padding'):set(' ')
  U.gvar('nvim_tree_allow_resize'):set(1)
  U.gvar('nvim_tree_auto_ignore_ft'):set({ 'startify', 'dashboard' })
  U.gvar('nvim_tree_show_icons'):set({ git = 1, folders = 1, files = 1, folder_arrows = 0 })
  U.gvar('nvim_tree_icons'):set({
    default = '',
    symlink = '',
    git = {
      unstaged = "+",
      staged = "*",
      unmerged = "",
      renamed = "r ",
      untracked = "-",
      deleted = "d",
      ignored = "i",
    },
    folder = {
      arrow_open = "",
      arrow_closed = "",
      default = "",
      open = "",
      empty = "",
      empty_open = "",
      symlink = "",
      symlink_open = "",
    },
  })

  local nvimtree_keybindings = {
    { key = "<C-Up>",     action = 'first_sibling' },
    { key = "<C-Down>",   action = 'last_sibling' },
    { key = "d",          action = 'trash' },
    { key = "D",          action = 'remove' },
    { key = "t",          action = 'tabnew' },
    { key = "h",          action = 'toggle_help' },

    { key = "<C-e>",      action = '' },
    { key = "g?",         action = '' },
  }

  local NVIMTREE_LSP_DIAG_ICONS = venom.icons.diagnostic_states.cozette

  require 'nvim-tree'.setup {
    open_on_tab         = true,
    hijack_cursor       = true,
    update_cwd          = true,
    hijack_unnamed_buffer_when_opening = false,
    diagnostics = {
      enable = true,
      icons = {
        hint    = NVIMTREE_LSP_DIAG_ICONS.Hint,
        info    = NVIMTREE_LSP_DIAG_ICONS.Info,
        warning = NVIMTREE_LSP_DIAG_ICONS.Warn,
        error   = NVIMTREE_LSP_DIAG_ICONS.Error,
      },
    },
    update_focused_file = {
      enable      = true,
      update_cwd  = false,
      ignore_list = {}
    },
    view = {
      -- width = 40,
      -- height = 10,
      -- side = 'left',
      auto_resize = true,
      hide_root_folder = false,
      mappings = {
        custom_only = false,
        list = nvimtree_keybindings
      }
    },
    renderer = {
      indent_markers = {
        enable = true,
        icons = {
          corner = "└ ",
          edge = "│ ",
          none = "  ",
        },
      },
    },
    filters = {
      dotfiles = false,
      custom = {'.git', 'node_modules', '.cache', '*.import', '__pycache__', 'pnpm-lock.yaml', 'package-lock.json'}
    },
    git = {
      ignore = true
    },
    trash = {
      cmd = "trash",
      require_confirm = true,
    },
    actions = {
      change_dir = {
        enable = true,
        global = true,
      },
      open_file = {
        window_picker = {
          enable = true,
          chars = "1234567890",
          exclude = {
            filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", },
            buftype  = { "nofile", "terminal", "help", },
          }
        }
      }
    }
  }
end)

M.toggle_term = U.Service():require(FT.PLUGIN, "nvim-toggleterm.lua"):new(function()
  require("toggleterm").setup {
    open_mapping = [[<C-\>]],
    insert_mappings = true,

    shade_terminals = false,

    direction = 'vertical',

    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return 84
        -- return vim.o.columns * 0.35
      end
    end,
  -- on_close = fun(t: Terminal), -- function to run when the terminal closes
  -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
  -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
  -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
  }
end)

M.nvim_gps = U.Service():require(FT.PLUGIN, "nvim-gps"):new(function()
  require 'nvim-gps'.setup {
    -- separator = ' > ',
    icons = {
      ["class-name"] = venom.icons.item_kinds.cozette.Class..' ',
      ["function-name"] = venom.icons.item_kinds.cozette.Function..' ',
      ["method-name"] = venom.icons.item_kinds.cozette.Method..' ',
      ["container-name"] = venom.icons.item_kinds.cozette.TypeParameter..' ',
      ["tag-name"] = venom.icons.item_kinds.cozette.TypeParameter..' ',
    },
  }
end)

M.fidget = U.Service():require(FT.PLUGIN, "fidget.nvim"):new(function()
  require 'fidget'.setup {
    window = {
      blend = 0,
    }
  }
end)

M.alpha = U.Service():require(FT.PLUGIN, "alpha-nvim"):new(function()
  -- require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
  -- require 'alpha'.setup(require 'alpha.themes.theta'.config)
  require 'alpha'.setup(require '../extras/startpage'.config)
  -- require 'alpha'.setup({})
end)

return M
