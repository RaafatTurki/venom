--- defines plugins configurations.
-- @module configs
local M = {}

M.impatient = U.Service():require(FT.PLUGIN, "impatient.nvim"):new(function()
  require 'impatient'
  require 'impatient'.enable_profile()
end)

M.devicons = U.Service():require(FT.PLUGIN, "nvim-web-devicons"):new(function()
  require 'nvim-web-devicons'.setup {
    override = {
      default_icon = {
        icon = "",
      }
    },
  }
end)

M.dressing = U.Service():require(FT.PLUGIN, "dressing.nvim"):new(function()
  require('dressing').setup({
    input = {
      enabled = true,
      border = "single",
      winblend = 0,
    },
    select = {
      enabled = true,
      builtin = {
        border = "single",
        winblend = 0,
      },
    },
  })
end)

M.notify = U.Service():require(FT.PLUGIN, "nvim-notify"):new(function()
  local notify = require 'notify'

  notify.setup {
    timeout = 1000,
    render = 'minimal',
    -- stages = 'static',
    stages = require 'extras.notify_stages',
  }

  vim.notify = notify
end)

M.bqf = U.Service():require(FT.PLUGIN, 'nvim-bqf'):new(function()
  require 'bqf'.setup {
    -- magic_window = false,
    -- auto_resize_height = true,
    preview = {
      border_chars = {'│', '│', '─', '─', '┌', '┐', '└', '┘', '█'},
      -- win_height = 15,

      -- win_vheight = {
      --   description = [[the height of preview window for vertical layout]],
      --   default = 15
      -- },
      -- wrap = {
      --   description = [[wrap the line, `:h wrap` for detail]],
      --   default = false
      -- },
      -- should_preview_cb = {
      --   description = [[a callback function to decide whether to preview while switching buffer,
      --           with (bufnr: number, qwinid: number) parameters]],
      --   default = nil
      -- }
    },
  }
end)

-- M.cinnamon = U.Service():require(FT.PLUGIN, "cinnamon.nvim"):new(function()
--   require 'cinnamon'.setup {
--     default_keymaps = false,
--     extra_keymaps = false,
--     extended_keymaps = false,
--     centered = true,
--     default_delay = 4,
--     horizontal_scroll = true,
--     scroll_limit = 150,
--   }
-- end)

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
    glsl = '//%s',
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

M.cmp_ls = U.Service():require(FT.PLUGIN, "nvim-cmp"):new(function()
  -- -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
  local ls = require 'luasnip'
  local ls_types = require 'luasnip.util.types'

  require'luasnip'.config.setup({
    ext_opts = {
      [ls_types.choiceNode] = {
        active = { virt_text = {{venom.icons.item_kinds.cozette.Snippet, 'SnippetChoiceIndicator'}} },
        passive = { virt_text = {{venom.icons.item_kinds.cozette.Snippet, 'SnippetPassiveIndicator'}} }
      },
      [ls_types.insertNode] = {
        active = { virt_text = {{venom.icons.item_kinds.cozette.Snippet, 'SnippetInsertIndicator'}} },
        passive = { virt_text = {{venom.icons.item_kinds.cozette.Snippet, 'SnippetPassiveIndicator'}} }
      }
    },
  })

  -- TODO: lazy load vscode format snippets (lang.lua)
  ls.add_snippets(nil, require 'extras.lua_snips')


  local cmp = require 'cmp'

  cmp.setup {
    -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
    snippet = { expand = function(args) ls.lsp_expand(args.body) end },

    mapping = {
      -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
      ["<Tab>"]       = cmp.mapping(function(fallback) if ls.expand_or_locally_jumpable() then ls.expand_or_jump() else fallback() end end, { "i", "s" }),
      ["<S-Tab>"]     = cmp.mapping(function(fallback) if ls.jumpable(-1) then ls.jump(-1) else fallback() end end, { "i", "s" }),

      ['<Down>']      = cmp.mapping.select_next_item(),
      ['<Up>']        = cmp.mapping.select_prev_item(),
      ['<S-j>']       = cmp.mapping.scroll_docs(4),
      ['<S-k>']       = cmp.mapping.scroll_docs(-4),
      ['<C-Space>']   = cmp.mapping.complete(),
      ['<C-e>']       = cmp.mapping.abort(),
      ['<Esc>']       = cmp.mapping.close(),
      ['<CR>']        = cmp.mapping.confirm({
        select = false,
        behavior = cmp.ConfirmBehavior.Replace,
      }),
    },
    sources = {
      { name = 'buffer' },
      { name = 'path' },
      { name = 'spell' },
      { name = 'luasnip' },
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      -- { name = 'digraphs' },
      -- { name = 'nvim_lsp_signature_help' },
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        vim_item.kind = venom.icons.item_kinds.cozette[vim_item.kind] or ''
        -- vim_item.menu = entry.source.name
        return vim_item
      end
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
      -- scrollbar = '║',
    },
    -- view = {
    --   entries = 'native',
    -- },
    -- experimental = {
    --   ghost_text = false,
    -- }
  }

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
      -- { name = 'nvim_lsp_document_symbol' },
    }
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
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
    { key = "<space>",    action = 'cd' },
    { key = "<BS>",       action = 'dir_up' },

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
      -- auto_resize = true,
      hide_root_folder = true,
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
      icons = {
        git_placement = 'after'
      }
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

M.fidget = U.Service():require(FT.PLUGIN, "fidget.nvim"):new(function()
  require 'fidget'.setup {
    window = {
      blend = 0,
    }
  }
end)

M.mini_starter = U.Service():require(FT.PLUGIN, "mini.nvim"):new(function()
  local starter = require 'mini.starter'

--     header = [[
-- ┬  ┬┬─╮╭╮╭╭─╮╭┬╮
-- ╰┐┌╯├┤ ││││ ││││
--  ╰╯ ╰─╯╯╰╯╰─╯┴ ┴]],

    local header_art = [[
╭╮╭┬─╮╭─╮┬  ┬┬╭┬╮
│││├┤ │ │╰┐┌╯││││
╯╰╯╰─╯╰─╯ ╰╯ ┴┴ ┴
]]

  starter.setup {
    autoopen = true,
    evaluate_single = true,
    header = header_art,
    footer = "",
    -- content_hooks = nil,
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.aligning('center', 'center'),
    },
    query_updaters = [[abcdefghijklmnopqrstuvwxyz0123456789_-.]],
  }
end)

M.mini_surround = U.Service():require(FT.PLUGIN, "mini.nvim"):new(function()
  require 'mini.surround'.setup()
end)

M.corn = U.Service():require(FT.PLUGIN, "corn.nvim"):new(function()
  require 'corn'.setup()
  -- require 'corn'.setup {
  --   -- win_opts = {
  --   --   anchor = 'NE',
  --   -- },
  --   icons = {
  --     error = venom.icons.diagnostic_states.cozette.Error,
  --     warn = venom.icons.diagnostic_states.cozette.Warn,
  --     hint = venom.icons.diagnostic_states.cozette.Hint,
  --     info = venom.icons.diagnostic_states.cozette.Info,
  --   },
  -- }
end)

M.trld = U.Service():require(FT.PLUGIN, "trld.nvim"):new(function()
  local function get_icon_by_severity(severity)
    local icon_set = venom.icons.diagnostic_states.cozette
    local icons = {
      icon_set.Error,
      icon_set.Warn,
      icon_set.Info,
      icon_set.Hint,
    }
    return icons[severity]
  end

  require 'trld'.setup {
    formatter = function(diag)
      local u = require 'trld.utils'
      local diag_lines = {}

      for line in diag.message:gmatch("[^\n]+") do
        line = line:gsub('[ \t]+%f[\r\n%z]', '')
        table.insert(diag_lines, line)
      end

      local lines = {}
      for _, diag_line in ipairs(diag_lines) do
        table.insert(lines, {
          { diag_line..' ', u.get_hl_by_serverity(diag.severity) },
          { get_icon_by_severity(diag.severity), u.get_hl_by_serverity(diag.severity) },
        })
      end

      return lines
    end,
  }
end)

M.dirty_talk = U.Service():require(FT.PLUGIN, 'vim-dirtytalk'):new(function()
  vim.opt.spelllang:append 'programming'
end)

M.hover = U.Service():require(FT.PLUGIN, 'hover.nvim'):new(function()
  require 'hover'.setup {
    init = function()
      require('hover.providers.lsp')
      require('hover.providers.gh')
      require('hover.providers.man')
      require('hover.providers.dictionary')
    end,
    preview_opts = {
      border = nil
    },
    title = true
  }
end)

M.paperplanes = U.Service():require(FT.PLUGIN, 'paperplanes.nvim'):new(function()
  require 'paperplanes'.setup {
    register = "+",
    -- provider = "0x0.st",
    -- provider = "sr.ht",
    -- provider = "dpaste.org",
    provider = "paste.rs",
    provider_options = {},
    cmd = "curl"
  }
end)

-- M.remember = U.Service():require(FT.PLUGIN, 'remember.nvim'):new(function()
--   require 'remember'.setup {
--     ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit", "NvimTree" },
--     ignore_buftype  = { "quickfix", "nofile", "help" },
--     open_folds      = true
--   }
-- end)

return M
