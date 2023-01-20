--- defines plugins configurations.
-- @module plugins
local M = {}

M.impatient = U.Service({{FT.PLUGIN, "impatient.nvim"}}, {}, function()
  require 'impatient'
  require 'impatient'.enable_profile()
end)

M.illuminate = U.Service({{FT.PLUGIN, 'vim-illuminate'}}, {}, function()
  -- default configuration
  require('illuminate').configure {
    filetypes_denylist = {
      'dirvish',
      'fugitive',
      'NvimTree',
      'mason',
    },
    modes_allowlist = { 'n' },
    -- large_file_cutoff = 3000,
    -- large_file_overrides = {
    --   'treesitter',
    --   under_cursor = true,
    -- },
  }
end)

M.devicons = U.Service({{FT.PLUGIN, "nvim-web-devicons"}}, {}, function()
  require 'nvim-web-devicons'.setup {
    override = {
      default_icon = {
        icon = "",
        color = "#6d8086",
        cterm_color = "66",
        name = "Default",
      }
    },
  }
end)

M.dressing = U.Service({{FT.PLUGIN, "dressing.nvim"}}, {}, function()
  require 'dressing'.setup {
    input = {
      enabled = false,
    },
    -- input = {
    --   border = 'single',
    --   win_options = {
    --     winblend = 0,
    --   },
    --   override = function(conf)
    --     conf.col = -1
    --     return conf
    --   end,
    -- },
    select = {
      backend = { 'telescope' },
      -- builtin = {
      --   border = 'single',
      --   win_options = {
      --     winblend = 0,
      --     winhighlight = "CursorLine:Normal",
      --   },
      -- }
    }
  }
end)

M.telescope = U.Service({{FT.PLUGIN, 'telescope.nvim'},{FT.PLUGIN, 'telescope-fzf-native.nvim'}}, {}, function()
  require('telescope').setup {
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      }
    },
    defaults = {
      mappings = {
        i = {
          -- NOTE: fixes the folds not applying issue
          ["<CR>"] = function()
            vim.cmd [[:stopinsert]]
            vim.cmd [[call feedkeys("\<CR>")]]
          end
        }
      }
    }
  }

  require('telescope').load_extension('fzf')
end)

M.notify = U.Service({{FT.PLUGIN, "nvim-notify"}}, {}, function()
  local notify = require 'notify'

  notify.setup {
    timeout = 1000,
    render = 'minimal',
    -- stages = 'static',
  }

  vim.notify = notify
end)

M.bqf = U.Service({{FT.PLUGIN, 'nvim-bqf'}}, {}, function()
  require 'bqf'.setup {
    -- magic_window = false,
    -- auto_resize_height = true,
    preview = {
      border_chars = { '│', '│', '─', '─', '┌', '┐', '└', '┘', '█' },
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

M.reach = U.Service({{FT.PLUGIN, 'reach.nvim'}}, {}, function()
  require 'reach'.setup {
    notifications = false
  }
end)

M.grapple = U.Service({{FT.PLUGIN, 'grapple.nvim'}}, {}, function()
  require 'grapple'.setup {
  }
end)

M.gitsigns = U.Service({{FT.PLUGIN, "gitsigns.nvim"}}, {}, function()
  require 'gitsigns'.setup {
    signs = {
      add          = { text = '│' },
      change       = { text = '│' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
    },
    keymaps = {},
    sign_priority = 9, -- because nvim diagnostic signs are 10
  }
end)

M.cmp_ls = U.Service({{FT.PLUGIN, "nvim-cmp"}}, {}, function()
  -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
  local ls = require 'luasnip'
  local ls_types = require 'luasnip.util.types'

  require 'luasnip'.config.setup({
    ext_opts = {
      [ls_types.choiceNode] = {
        active = { virt_text = { { Icons.item_kinds.Snippet, 'SnippetChoiceIndicator' } } },
        passive = { virt_text = { { Icons.item_kinds.Snippet, 'SnippetPassiveIndicator' } } }
      },
      [ls_types.insertNode] = {
        active = { virt_text = { { Icons.item_kinds.Snippet, 'SnippetInsertIndicator' } } },
        passive = { virt_text = { { Icons.item_kinds.Snippet, 'SnippetPassiveIndicator' } } }
      }
    },
  })

  -- require("luasnip.loaders.from_snipmate").lazy_load({paths = "~/.config/nvim/snips"})
  require("luasnip.loaders.from_snipmate").load()

  local cmp = require 'cmp'

  local function tab(fb)
    -- if cmp.visible() then cmp.select_next_item()
    if ls.expand_or_locally_jumpable() then ls.expand_or_jump()
    else fb() end
  end

  local function s_tab(fb)
    -- if cmp.visible() then cmp.select_prev_item()
    if ls.jumpable(-1) then ls.jump(-1)
    else fb() end
  end

  cmp.setup {
    -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
    snippet = { expand = function(args) ls.lsp_expand(args.body) end },

    mapping = cmp.mapping.preset.insert({
      -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
      -- ["<Tab>"]   = function(fb) tab(fb) end,
      -- ["<S-Tab>"] = function(fb) s_tab(fb) end,

      ["<Tab>"]   = cmp.mapping({
        i = function(fb) tab(fb) end,
        c = function(fb)
          if cmp.visible() then cmp.select_next_item()
          else cmp.complete() end
          -- local complete_or_next = not cmp.visible() and cmp.mapping.complete() or cmp.mapping.select_next_item()
          -- complete_or_next(fb)
        end
      }),
      ["<S-Tab>"] = cmp.mapping({
        i = function(fb) s_tab(fb) end,
        c = function(fb)
          if cmp.visible() then cmp.select_prev_item()
          else cmp.complete() end
          -- local complete_or_prev = not cmp.visible() and cmp.mapping.complete() or cmp.mapping.select_prev_item()
          -- complete_or_prev(fb)
        end
      }),

      ['<PageDown>'] = cmp.mapping.scroll_docs(4),
      ['<PageUp>']   = cmp.mapping.scroll_docs(-4),
      ['<C-Space>']  = cmp.mapping.complete(),
      ['<C-e>']      = cmp.mapping.abort(),
      ['<Esc>']      = cmp.mapping.close(),
      ['<CR>']       = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
    }),
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      -- { name = 'nvim_lua' },
      { name = 'buffer' },
      -- { name = 'rg', option = { additional_arguments = '--smart-case --hidden', }},
      { name = 'path' },
      -- { name = 'omni' },
      -- { name = 'spell' },
      -- { name = 'nvim_lsp_signature_help' },
      -- { name = 'digraphs' },
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        -- if entry.source.name == 'omni' then
        --   if entry.completion_item.documentation == nil then
        --     entry.completion_item.documentation = vim_item.menu
        --     vim_item.menu = nil
        --   end
        --   vim_item.kind = 'Ω'
        --   vim_item.kind_hl_group = 'CmpItemKindProperty'
        -- else
        vim_item.kind = Icons.item_kinds[vim_item.kind] or ''
        -- end
        return vim_item
      end
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      completion = {
        border = 'single',
        winhighlight = 'CursorLine:Normal',
      },
      documentation = {
        border = 'single',
        winhighlight = '',
      },
      -- scrollbar = '║',
    },
    completion = {
      get_trigger_characters = function(trigger_chars)
        local new_trigger_chars = {}
        for _, char in ipairs(trigger_chars) do
          if char ~= '>' then
            table.insert(new_trigger_chars, char)
          end
        end
        return new_trigger_chars
      end
    },
    experimental = {
      ghost_text = { hl_group = 'LspCodeLens' },
    }
  }

  cmp.setup.cmdline({ '/', '?' }, {
    -- mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
      -- { name = 'nvim_lsp_document_symbol' },
    }
  })

  cmp.setup.cmdline(':', {
    -- mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    },
  })
end)

M.coq = U.Service({{FT.PLUGIN, 'coq_nvim'}}, {}, function()
  vim.cmd [[COQnow --shut-up]]
end)

M.nvim_tree = U.Service({{FT.PLUGIN, "nvim-tree.lua"}}, {}, function()
  vim.g.nvim_tree_allow_resize = 1

  local nvimtree_keybindings = {
    { key = "<C-Up>", action = 'first_sibling' },
    { key = "<C-Down>", action = 'last_sibling' },
    { key = "d", action = 'trash' },
    { key = "D", action = 'remove' },
    { key = "t", action = 'tabnew' },
    { key = "?", action = 'toggle_help' },
    { key = "<space>", action = 'cd' },
    { key = "<BS>", action = 'dir_up' },

    { key = "<C-e>", action = '' },
    { key = "g?", action = '' },
  }

  require 'nvim-tree'.setup {
    hijack_cursor       = true,
    sync_root_with_cwd  = true,
    view                = {
      -- adaptive_size = true,
      centralize_selection = true,
      mappings = {
        custom_only = false,
        list = nvimtree_keybindings
      }
    },
    renderer            = {
      full_name = true,
      highlight_git = true,
      group_empty = true,
      indent_markers = {
        enable = true,
        icons = {
          corner = "└",
          item   = "├",
          edge   = "│",
          none   = " ",
        },
      },
      icons = {
        git_placement = 'after',
        symlink_arrow = ' -> ',
        show = {
          folder_arrow = false,
        },
        glyphs = {
          default = '',
          symlink = '',
          modified = '•',
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
          git = {
            unstaged = "",
            staged = "",
            unmerged = "",
            renamed = "r ",
            untracked = "-",
            deleted = "d",
            ignored = "i",
          },
        }
      },
      symlink_destination = true,
    },
    update_focused_file = {
      enable = true,
      -- ignore_list = {}
    },
    ignore_ft_on_setup  = { 'startify', 'dashboard' },
    diagnostics         = {
      enable = true,
      icons = {
        hint    = Icons.diagnostic_states.Hint,
        info    = Icons.diagnostic_states.Info,
        warning = Icons.diagnostic_states.Warn,
        error   = Icons.diagnostic_states.Error,
      },
    },
    filters             = {
      dotfiles = false,
      custom = { 'node_modules', '.cache', '*.import', '__pycache__', 'pnpm-lock.yaml', 'package-lock.json' }
    },
    modified            = {
      enable = true
    },
    git                 = {
      show_on_open_dirs = false
    },
    actions             = {
      change_dir = {
        enable = true,
        global = true,
      },
      open_file = {
        window_picker = {
          enable = true,
          chars = "1234567890",
        }
      }
    },
    tab                 = {
      sync = {
        open = true,
        close = true,
      }
    },
  }
end)

M.neo_tree = U.Service({{FT.PLUGIN, "neo-tree.nvim"}}, {}, function()
  require 'window-picker'.setup {
    autoselect_one = true,
    include_current = false,
    filter_rules = {
      bo = {
        filetype = { 'neo-tree', "neo-tree-popup", "notify", "quickfix" },
        buftype = { 'terminal' },
      },
    },
    -- other_win_hl_color = '#e35e4f',
  }

  vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

  require 'neo-tree'.setup {
    close_if_last_window = true,
    -- use_popups_for_input = false,
    popup_border_style = 'single',
    default_component_configs = {
      modified = {
        symbol = '•',
      },
      name = {
        -- trailing_slash = false,
      },
      git_status = {
        symbols = {
          -- Change type
          added     = '',
          modified  = '',
          deleted   = "✖",
          renamed   = "⭢",
          -- Status type
          untracked = "?",
          ignored   = "☒",
          unstaged  = "☐",
          staged    = "☑",
          conflict  = "",
        }
      },
      window = {
        mappings = {
          ["S"] = "split_with_window_picker",
          ["s"] = "vsplit_with_window_picker",
          ["t"] = "open_tabnew",
          ["w"] = "open_with_window_picker",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          -- ["Z"] = "expand_all_nodes",
          ["a"] = {
            "add",
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none" -- "none", "relative", "absolute"
            }
          },
          ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add".
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
          -- ["c"] = {
          --  "copy",
          --  config = {
          --    show_path = "none" -- "none", "relative", "absolute"
          --  }
          --}
          ['m'] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
          ['q'] = "close_window",
          ['R'] = "refresh",
          ['?'] = "show_help",
          ['<'] = "prev_source",
          ['>'] = "next_source",
        }
      },
      indent = {
        with_expanders = true,
        expander_collapsed = '>',
        expander_expanded = 'v',
        expander_highlight = 'NeoTreeExpander',
      },
    },
    nesting_rules = {
      js = { 'js.map', 'd.ts' },
    },
    filesystem = {
      filtered_items = {
        hide_by_name = {
          -- 'node_modules',
          -- '__pycache__',
          -- 'pnpm-lock.yaml',
          -- 'package-lock.json',
        },
        hide_by_pattern = {
          -- "*.import"
        },
        never_show = {
        },
      },
      commands = {
        delete = function(state)
          local inputs = require "neo-tree.ui.inputs"
          local path = state.tree:get_node().path
          local msg = "Are you sure you want to trash " .. path
          inputs.confirm(msg, function(confirmed)
            if not confirmed then return end
            vim.fn.system { "gio", "trash", vim.fn.fnameescape(path) }
            require("neo-tree.sources.manager").refresh(state.name)
          end)
        end,
      },
      follow_current_file = true,
      use_libuv_file_watcher = true,
    },
    source_selector = {
      winbar = true,
      -- statusline = true,
    }
  }
end)

M.bufferline = U.Service({{FT.PLUGIN, 'bufferline.nvim'}}, {}, function()
  require 'bufferline'.setup {
    options = {
      mode = 'tabs',
      indicator = {
        style = 'none',
      },
      modified_icon = '●',
      left_trunc_marker = '←',
      right_trunc_marker = '→',
      show_buffer_close_icons = false,
      show_close_icon = false,
      always_show_bufferline = false,
      separator_style = { '', '' },
      -- enforce_regular_tabs = true,
      offsets = {
        { filetype = "NvimTree" },
        { filetype = "neo-tree" },
      },
    },
  }
end)

M.toggle_term = U.Service({{FT.PLUGIN, "nvim-toggleterm.lua"}}, {}, function()
  require 'toggleterm'.setup {
    shade_terminals = false,
    direction = 'horizontal',
    size = function(term)
      if term.direction == "horizontal" then
        return vim.o.lines * 0.6
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.5
      end
    end,
    -- winbar = {
    --   enabled = true,
    --   -- name_formatter = function(term)
    --   --   -- log(term)
    --   --   return term.name
    --   -- end
    -- }
  }
end)

M.fidget = U.Service({{FT.PLUGIN, "fidget.nvim"}}, {}, function()
  require 'fidget'.setup {
    window = {
      blend = 0,
    }
  }
end)

M.mini_starter = U.Service({{FT.PLUGIN, "mini.nvim"}}, {}, function()
  local starter = require 'mini.starter'

  local new_item = function(section, key, title, action)
    return {
      action  = action,
      section = section,
      name    = string.format('%s  %s', key, title)
    }
  end

  items = {
    new_item('Common', 'a', 'New file', vim.cmd.enew),
    new_item('Common', 'q', 'Quit', vim.cmd.qall),

    new_item('Update', 'p', 'Update plugins', function() PluginManager.sync() end),
    new_item('Update', 'l', 'Update tools', 'Mason'),

    new_item('Browse', 'e', 'Explorer', 'NvimTreeOpen'),
    new_item('Browse', 'f', 'Find', 'Telescope live_grep'),
    new_item('Browse', 'r', 'Recent', 'Telescope oldfiles'),
  }

  if Features:has(FT.SESSION, 'setup') then
    -- last session
    table.insert(items, new_item('Session', 'x', 'Last session', function() Sessions.load_last() end))
    -- all other sessions
    for i, session_name in pairs(Sessions.get_all()) do
      if session_name ~= Sessions.last_session_name then
        table.insert(items, new_item('Session', 's' .. i, session_name, function()
          Sessions.load(session_name)
        end))
      end
    end
  end

  starter.setup {
    autoopen = true,
    evaluate_single = true,
    header = table.concat({
      '              Neovim',
      '───────────────────────────────────'
    }, '\n'),
    footer = table.concat({
      '───────────────────────────────────'
    }, '\n'),
    content_hooks = {
      starter.gen_hook.adding_bullet('', false),
      starter.gen_hook.aligning('center', 'center'),
    },
    query_updaters = [[abcdefghijklmnopqrstuvwxyz0123456789_-.]],
    items = items,
  }
end)

M.mini_surround = U.Service({{FT.PLUGIN, "mini.nvim"}}, {}, function()
  require 'mini.surround'.setup()
end)

M.mini_map = U.Service({{FT.PLUGIN, "mini.nvim"}}, {}, function()
  local map = require('mini.map')

  require 'mini.map'.setup {
    window = {
      width = 1,
      winblend = 0,
      show_integration_count = false,
    }
  }

  -- open on vim enter
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function(ctx)
      map.open()
    end
  })

  -- refresh on window resize
  vim.api.nvim_create_autocmd('VimResized', {
    callback = function(ctx)
      map.refresh()
    end
  })

  -- refresh on folding/unfolding
  Events.fold_update:sub(map.refresh)
end)

M.mini_bufremove = U.Service({{FT.PLUGIN, "mini.nvim"}}, {}, function()
  require 'mini.bufremove'.setup()
end)

M.mini_pairs = U.Service({{FT.PLUGIN, 'mini.nvim'}}, {}, function()
  require 'mini.pairs'.setup {}
end)

M.mini_move = U.Service({{FT.PLUGIN, 'mini.nvim'}}, {}, function()
  require 'mini.move'.setup {}
end)

M.corn = U.Service({{FT.PLUGIN, "corn.nvim"}}, {}, function()
  require 'corn'.setup()
  -- require 'corn'.setup {
  --   -- win_opts = {
  --   --   anchor = 'NE',
  --   -- },
  --   icons = {
  --     error = venom.icons.diagnostic_states.Error,
  --     warn = venom.icons.diagnostic_states.Warn,
  --     hint = venom.icons.diagnostic_states.Hint,
  --     info = venom.icons.diagnostic_states.Info,
  --   },
  -- }
end)

M.trld = U.Service({{FT.PLUGIN, "trld.nvim"}}, {}, function()
  local function get_icon_by_severity(severity)
    local icon_set = Icons.diagnostic_states
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
          -- { diag_line..' ', u.get_hl_by_serverity(diag.severity) },
          { diag_line .. ' ', u.get_hl_by_serverity(diag.severity) },
          { get_icon_by_severity(diag.severity) .. ' ', u.get_hl_by_serverity(diag.severity) },
        })
      end

      return lines
    end,
  }
end)

M.dirty_talk = U.Service({{FT.PLUGIN, 'vim-dirtytalk'}}, {}, function()
  vim.opt.spelllang:append 'programming'
end)

M.hover = U.Service({{FT.PLUGIN, 'hover.nvim'}}, {}, function()
  require 'hover'.setup {
    init = function()
      require('hover.providers.lsp')
      -- require('hover.providers.gh')
      -- require('hover.providers.man')
      -- require('hover.providers.dictionary')
    end,
    preview_opts = {
      border = nil
    },
    title = false
  }
end)

M.paperplanes = U.Service({{FT.PLUGIN, 'paperplanes.nvim'}}, {}, function()
  require 'paperplanes'.setup {
    register = '+',
    -- provider = "0x0.st",
    -- provider = "sr.ht",
    provider = "dpaste.org",
    -- provider = "paste.rs",
    provider_options = {},
    cmd = "curl"
  }
end)

M.fold_cycle = U.Service({{FT.PLUGIN, 'fold-cycle.nvim'}}, {}, function()
  require 'fold-cycle'.setup {
    open_if_max_closed = false,
    close_if_max_opened = false,
    softwrap_movement_fix = false,
  }
end)

M.fold_preview = U.Service({{FT.PLUGIN, 'fold-preview.nvim'}}, {}, function()
  local fold_preview = require 'fold-preview'

  fold_preview.setup {
    default_keybindings = false,
    border = 'none',
  }

  Events.fold_update:sub(fold_preview.close_preview)
end)

M.icon_picker = U.Service({{FT.PLUGIN, 'icon-picker.nvim'}}, {}, function()
  require 'icon-picker'
end)

M.fzf_lua = U.Service({{FT.PLUGIN, 'fzf-lua'}}, {}, function()
  require 'fzf-lua'.setup {
    winopts = {
      border  = 'single',
      hl      = {
        border = 'VertSplit', -- border color (try 'FloatBorder')
      },
      preview = {
        title     = true,
        scrollbar = 'border',
      },
    }
  }
end)

M.guess_indent = U.Service({{FT.PLUGIN, 'guess-indent.nvim'}}, {}, function()
  require 'guess-indent'.setup {}
end)

M.gomove = U.Service({{FT.PLUGIN, 'nvim-gomove'}}, {}, function()
  require 'gomove'.setup {
    map_defaults = false,
  }
end)

M.colorizer = U.Service({{FT.PLUGIN, 'nvim-colorizer.lua'}}, {}, function()
  require 'colorizer'.setup {
    filetypes = {
      '*',
      '!lazy',
      '!packer',
    },
    user_default_options = {
      RGB = true,
      RRGGBB = true,
      names = false,
      RRGGBBAA = true,
      AARRGGBB = true,
      rgb_fn = true,
      hsl_fn = true,
      mode = "background", -- Set the display mode.
      tailwind = 'both',
      sass = { enable = false, parsers = { 'css' }, },
    },
  }
end)

M.vim_markdown_composer = U.Service({{FT.PLUGIN, 'vim-markdown-composer'}}, {}, function()
  vim.g.markdown_composer_autostart = 0
  -- vim.g.markdown_composer_browser = 'qutebrowser'
end)

M.overseer = U.Service({{FT.PLUGIN, 'overseer.nvim'}}, {}, function()
  require 'overseer'.setup {}
end)

M.rest = U.Service({{FT.PLUGIN, 'rest.nvim'}}, {}, function()
  require 'rest-nvim'.setup {
    -- skip_ssl_verification = false,
    -- result = {
    --   show_url = true,
    --   show_http_info = true,
    --   show_headers = true,
    -- },
    -- jump_to_request = false,
    env_file = '.env.development',
    -- custom_dynamic_variables = {},
    -- yank_dry_run = true,
  }
end)

M.paint = U.Service({{FT.PLUGIN, 'paint.nvim'}}, {}, function()
  require 'paint'.setup {
    highlights = {
      -- snippets
      {
        filter = { filetype = 'snippets' },
        pattern = "snippet",
        hl = "Keyword",
      },
      {
        filter = { filetype = 'snippets' },
        pattern = "extends",
        hl = "Keyword",
      },
      {
        filter = { filetype = 'snippets' },
        pattern = "snippet%s%w+%s(.*)",
        hl = "Comment",
      },
      -- license files
      {
        filter = function()
          local file_name = vim.fn.fnamemodify(vim.fn.bufname(), ':t')
          return string.match(file_name, "LICENSE.*")
        end,
        pattern = "Copyright%s+.*(%d%d%d%d%s+.+)",
        hl = "Label",
      },
      -- TODOs, FIXMEs .. etc
      -- {
      --   filter = { filetype = 'xxd' },
      --   -- pattern = "%s00%s",
      --   -- pattern = "%s(%x%x)%s",
      --   pattern = "%s(00)%s",
      --   hl = "Comment",
      -- },
    },
  }
end)

M.noice = U.Service({{FT.PLUGIN, 'noice.nvim'}}, {}, function()
  require 'noice'.setup {
    cmdline = {
      -- format = {
      --   cmdline = { icon = ">" },
      --   search_down = { icon = "⌄" },
      --   search_up = { icon = "⌃" },
      --   filter = { icon = "$" },
      --   lua = { icon = "" },
      --   help = { icon = "?" },
      -- },
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        -- override cmp documentation with Noice (needs the other options to work)
        -- ["cmp.entry.get_documentation"] = true,
      },
    },
    popupmenu = {
      -- backend = 'nui',
      -- backend = 'cmp',
    },
    messages = {
      view_search = false,
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true
      -- lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  }
end)

M.hex = U.Service({{FT.PLUGIN, 'hex.nvim'}}, {}, function()
  require 'hex'.setup {}
end)

return M
