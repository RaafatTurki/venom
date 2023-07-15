--- defines plugins configurations.
-- @module plugins
local M = {}

M.setup = U.Service(function()
  Events.plugin_setup()
end)

M.impatient = U.Service({{FT.CONF, "impatient.nvim"}}, {}, function()
  require 'impatient'
  require 'impatient'.enable_profile()
end)

M.illuminate = U.Service({{FT.CONF, 'vim-illuminate'}}, {}, function()
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

M.devicons = U.Service({{FT.CONF, "nvim-web-devicons"}}, {}, function()
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

M.dressing = U.Service({{FT.CONF, "dressing.nvim"}}, {}, function()
  require 'dressing'.setup {
    input = {
      border = 'single',
      title_pos = 'center',
      win_options = {
        winblend = 0,
      },
    },
    select = {
      backend = { 'telescope', 'builtin' },
      builtin = {
        border = 'single',
        win_options = {
          winblend = 0,
        },
      }
    }
  }
end)

M.telescope = U.Service({{FT.CONF, 'telescope.nvim'},{FT.CONF, 'telescope-fzf-native.nvim'}}, {}, function()
  require 'telescope'.setup {
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      ['ui-select'] = {
        require 'telescope.themes'.get_dropdown {}
      }
    },
    defaults = {
      layout_strategy = 'vertical',
      layout_config = { height = 0.99 },
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
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
  require("telescope").load_extension("ui-select")
end)

M.notify = U.Service({{FT.CONF, "nvim-notify"}}, {}, function()
  local notify = require 'notify'

  notify.setup {
    timeout = 1000,
    render = 'minimal',
    -- stages = 'static',
  }

  vim.notify = notify
end)

M.bqf = U.Service({{FT.CONF, 'nvim-bqf'}}, {}, function()
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

M.reach = U.Service({{FT.CONF, 'reach.nvim'}}, {}, function()
  require 'reach'.setup {
    notifications = false
  }
end)

M.grapple = U.Service({{FT.CONF, 'grapple.nvim'}}, {}, function()
  require 'grapple'.setup {
  }
end)

M.gitsigns = U.Service({{FT.CONF, "gitsigns.nvim"}}, {}, function()
  require 'gitsigns'.setup {
    signs = {
      add          = { text = '│' },
      change       = { text = '│' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
    },
    sign_priority = 9, -- because nvim diagnostic signs are 10
  }
end)

M.cmp_ls = U.Service({{FT.CONF, "nvim-cmp"}}, {}, function()
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

  local function ls_tab(fb)
    -- if cmp.visible() then cmp.select_next_item()
    if ls.expand_or_locally_jumpable() then ls.expand_or_jump()
    else fb() end
  end

  local function ls_s_tab(fb)
    -- if cmp.visible() then cmp.select_prev_item()
    if ls.jumpable(-1) then ls.jump(-1)
    else fb() end
  end

  cmp.setup {
    -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
    snippet = { expand = function(args) ls.lsp_expand(args.body) end },

    mapping = {
      -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
      -- ["<Tab>"]   = function(fb) tab(fb) end,
      -- ["<S-Tab>"] = function(fb) s_tab(fb) end,

      ["<Tab>"]   = cmp.mapping({
        i = function(fb) ls_tab(fb) end,
        c = function(fb)
          if cmp.visible() then cmp.select_next_item()
          else cmp.complete() end
          -- local complete_or_next = not cmp.visible() and cmp.mapping.complete() or cmp.mapping.select_next_item()
          -- complete_or_next(fb)
        end
      }),
      ["<S-Tab>"] = cmp.mapping({
        i = function(fb) ls_s_tab(fb) end,
        c = function(fb)
          if cmp.visible() then cmp.select_prev_item()
          else cmp.complete() end
          -- local complete_or_prev = not cmp.visible() and cmp.mapping.complete() or cmp.mapping.select_prev_item()
          -- complete_or_prev(fb)
        end
      }),

      ['<PageDown>'] = cmp.mapping.scroll_docs(4),
      ['<PageUp>']   = cmp.mapping.scroll_docs(-4),
      ['<C-Space>']  = cmp.mapping.complete({}),
      ['<C-e>']      = cmp.mapping.abort(),
      ['<Esc>']      = cmp.mapping.close(),
      ['<CR>']       = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
      ['<Down>'] = function(fb)
        cmp.close()
        fb()
      end,
      ['<Up>'] = function(fb)
        cmp.close()
        fb()
      end,
      ['<C-Down>'] = cmp.mapping.select_next_item(),
      ['<C-Up>'] = cmp.mapping.select_prev_item(),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      -- { name = 'nvim_lua' },
      { name = 'buffer' },
      -- { name = 'rg', option = { additional_arguments = '--smart-case --hidden', }},
      { name = 'path' },
      -- { name = 'codeium' },
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

        -- if entry.source.name == 'codeium' then
        --   vim_item.kind = ''
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
        winhighlight = '',
        -- winhighlight = 'CursorLine:Normal',
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

M.coq = U.Service({{FT.CONF, 'coq_nvim'}}, {}, function()
  vim.cmd [[COQnow --shut-up]]
end)

M.nvim_tree = U.Service({{FT.CONF, "nvim-tree.lua"}}, {}, function()
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

M.neo_tree = U.Service({{FT.CONF, "neo-tree.nvim"}}, {}, function()
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
    add_blank_line_at_top = true,
    close_if_last_window = true,
    -- use_popups_for_input = false,
    popup_border_style = 'single',
    default_component_configs = {
      container = {
        enable_character_fade = false
      },
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
      -- js = { 'js.map', 'd.ts' },
      -- ['+layout.svelte'] = { '+layout.js', '+layout.ts', '+layout.server.js', '+layout.server.js' },
      -- ['+page.svelte'] = { '+page.js', '+page.ts', '+page.server.js', '+page.server.js' },

      -- ["js"] = { "js.map" },
      -- ['svelte'] = { 'svelte.js', 'svelte.ts' },
      -- ['*.svelte'] = { '*.js', '*.ts', '*.svelte.ts' },

      -- ['+page.svelte'] = { '+page.js', '+page.ts', '+page.server.js', '+page.server.js' },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
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
        system_open = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          path = path:gsub(" ", "\\ ")
          local cmd = string.format("xdg-open %s", path)
          vim.fn.jobstart(cmd, { detach = true })
        end,
        delete = function(state)
          local inputs = require "neo-tree.ui.inputs"
          local path = state.tree:get_node().path
          local msg = "Are you sure you want to trash " .. path
          inputs.confirm(msg, function(confirmed)
            if not confirmed then return end
            U.trash_file(path)
            require("neo-tree.sources.manager").refresh(state.name)
          end)
        end,
        open_in_terminal = function(state)
          local node = state.tree:get_node()
          local is_dir = (node.type == "directory")

          if is_dir then
            require 'toggleterm'.toggle(2, 100, node.path)
          end
        end
      },
      window = {
        mappings = {
          ["s"] = "system_open",
          ["v"] = "open_vsplit",
          ["\\"] = "open_in_terminal",
        },
      },
      follow_current_file = true,
      use_libuv_file_watcher = true,
    },
    source_selector = {
      winbar = true,
      -- statusline = true,
    }
  }

  Events.session_write_pre:sub [[NeoTreeClose]]
end)

M.bufferline = U.Service({{FT.CONF, 'bufferline.nvim'}}, {}, function()
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

M.toggle_term = U.Service({{FT.CONF, "toggleterm.nvim"}}, {}, function()
  require 'toggleterm'.setup {
    open_mapping = [[<C-\>]],
    insert_mappings = true,
    terminal_mappings = true,
    direction = 'horizontal',
    autochdir = true,
    size = function(term)
      if term.direction == "horizontal" then
        return vim.o.lines
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.5
      end
    end,
    highlights = {
      CursorLine = {},
    },
    -- winbar = {
    --   enabled = true,
    --   -- name_formatter = function(term)
    --   --   -- log(term)
    --   --   return term.name
    --   -- end
    -- }
  }
end)

M.fidget = U.Service({{FT.CONF, "fidget.nvim"}}, {}, function()
  require 'fidget'.setup {
    window = {
      blend = 0,
    }
  }
end)

M.mini_starter = U.Service({{FT.CONF, "mini.nvim"}}, {}, function()
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
    table.insert(items, new_item('Session', 'x', 'Last session', function() Sessions.load() end))
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

M.mini_map = U.Service({{FT.CONF, "mini.nvim"}}, {}, function()
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

M.mini_bufremove = U.Service({{FT.CONF, "mini.nvim"}}, {}, function()
  require 'mini.bufremove'.setup()
end)

M.mini_pairs = U.Service({{FT.CONF, 'mini.nvim'}}, {}, function()
  require 'mini.pairs'.setup {}
end)

M.mini_move = U.Service({{FT.CONF, 'mini.nvim'}}, {}, function()
  require 'mini.move'.setup {}
end)

M.mini_hipatterns = U.Service({{FT.CONF, 'mini.nvim'}}, {}, function()
  local hipatterns = require 'mini.hipatterns'

  require 'mini.hipatterns'.setup {
    highlighters = {
      -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
      fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
      hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
      todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
      note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

      -- Highlight hex color strings (`#rrggbb`) using that color
      hex_color = hipatterns.gen_highlighter.hex_color(),
    }
  }
end)

M.corn = U.Service({{FT.CONF, "corn.nvim"}}, {}, function()
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

M.trld = U.Service({{FT.CONF, "trld.nvim"}}, {}, function()
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

M.dirty_talk = U.Service({{FT.CONF, 'vim-dirtytalk'}}, {}, function()
  vim.opt.spelllang:append 'programming'
end)

M.hover = U.Service({{FT.CONF, 'hover.nvim'}}, {}, function()
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

M.paperplanes = U.Service({{FT.CONF, 'paperplanes.nvim'}}, {}, function()
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

M.fold_cycle = U.Service({{FT.CONF, 'fold-cycle.nvim'}}, {}, function()
  require 'fold-cycle'.setup {
    open_if_max_closed = false,
    close_if_max_opened = false,
    softwrap_movement_fix = false,
  }
end)

M.fold_preview = U.Service({{FT.CONF, 'fold-preview.nvim'}}, {}, function()
  local fold_preview = require 'fold-preview'

  fold_preview.setup {
    default_keybindings = false,
    border = 'single',
  }

  Events.fold_update:sub(fold_preview.close_preview)
end)

M.icon_picker = U.Service({{FT.CONF, 'icon-picker.nvim'}}, {}, function()
  require 'icon-picker'
end)

M.fzf_lua = U.Service({{FT.CONF, 'fzf-lua'}}, {}, function()
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

M.guess_indent = U.Service({{FT.CONF, 'guess-indent.nvim'}}, {}, function()
  require 'guess-indent'.setup {}
end)

M.gomove = U.Service({{FT.CONF, 'nvim-gomove'}}, {}, function()
  require 'gomove'.setup {
    map_defaults = false,
  }
end)

M.colorizer = U.Service({{FT.CONF, 'nvim-colorizer.lua'}}, {}, function()
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

M.vim_markdown_composer = U.Service({{FT.CONF, 'vim-markdown-composer'}}, {}, function()
  vim.g.markdown_composer_autostart = 0
  -- vim.g.markdown_composer_custom_css = 'file:///home/potato/markdown.css'
  -- vim.g.markdown_composer_syntax_theme = 'github-dark'
  if vim.fn.executable('qutebrowser') == 1 then
    vim.g.markdown_composer_browser = 'qutebrowser'
  end
end)

M.overseer = U.Service({{FT.CONF, 'overseer.nvim'}}, {}, function()
  require 'overseer'.setup {}
end)

M.rest = U.Service({{FT.CONF, 'rest.nvim'}}, {}, function()
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

M.paint = U.Service({{FT.CONF, 'paint.nvim'}}, {}, function()
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

M.noice = U.Service({{FT.CONF, 'noice.nvim'}}, {}, function()
  require 'noice'.setup {
    cmdline = {
      format = {
        cmdline = { icon = ">" },
        lua = { icon = "> lua" },
        search_down = { icon = " " },
        search_up = { icon = " " },
        filter = { icon = "$" },
        help = { icon = "?" },
      },
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      progress = {
        enabled = true,
      },
      hover = {
        enabled = true,
        view = 'hover',
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
          luasnip = true,
          throttle = 50,
        },
        view = 'hover',
      },
      message = {
        enabled = true,
        view = "notify",
      },
      documentation = {
        view = "hover",
      },
    },
    messages = {
      view_search = false,
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  }
end)

M.hex = U.Service({{FT.CONF, 'hex.nvim'}}, {}, function()
  require 'hex'.setup {}
end)

M.image = U.Service({{FT.CONF, 'image.nvim'}}, {}, function()
  require 'image'.setup {}
end)

M.peek = U.Service({{FT.CONF, 'peek.nvim'}}, {}, function()
  require 'peek'.setup {
    -- auto_load = true,
    -- app = 'webview',
    -- filetype = { 'markdown' },
    -- throttle_at = 200000,
    -- throttle_time = 'auto',
  }
  
  vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
  vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
end)

M.otter = U.Service({{FT.CONF, 'otter.nvim'}}, {}, function()
  local otter = require 'otter'

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*.md" },
    callback = function()
      otter.activate({ 'r', 'python', 'lua', 'javascript', 'typescript' }, true)
      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>d', ":lua require 'otter'.ask_definition()<cr>", { silent = true })
      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>v', ":lua require 'otter'.ask_hover()<cr>", { silent = true })
    end,
  })
end)

M.sentiment = U.Service({{FT.CONF, 'sentiment.nvim'}}, {}, function()
  require 'sentiment'.setup {}
end)

M.modicator = U.Service({{FT.CONF, 'modicator.nvim'}}, {}, function()
  require 'modicator'.setup {}
end)

M.edgy = U.Service({{FT.CONF, 'edgy.nvim'}}, {}, function()
  require 'edgy'.setup {
    bottom = {
      { ft = "toggleterm", size = { height = 0.8 }, filter = function(buf, win) return vim.api.nvim_win_get_config(win).relative == "" end },
      { ft = "qf", title = "QuickFix" },
      { ft = "help", size = { height = 0.5 }, filter = function(buf) return vim.bo[buf].buftype == "help" end },
    },
    animate = {
      fps = 120,
      cps = 120,
    },
  }
end)

return M
