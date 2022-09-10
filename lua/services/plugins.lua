--- defines plugins configurations.
-- @module plugins
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
        color = "#6d8086",
        cterm_color = "66",
        name = "Default",
      }
    },
  }
end)

M.dressing = U.Service():require(FT.PLUGIN, "dressing.nvim"):new(function()
  require 'dressing'.setup {
    input = {
      border = 'single',
      winblend = 0,
      override = function(conf)
        conf.col = -1
        return conf
      end,
    },
    select = {
      backend = { 'builtin' },

      builtin = {
        border = 'single',
        winblend = 0,
        winhighlight = "CursorLine:CursorLineSelect",
      }
    }
  }
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

M.reach = U.Service():require(FT.PLUGIN, 'reach.nvim'):new(function()
  require 'reach'.setup {
    notifications = false
  }
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
    sign_priority = 9, -- because nvim diagnostic signs are 10
  }
end)

M.cmp_ls = U.Service():require(FT.PLUGIN, "nvim-cmp"):new(function()
  -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
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

    mapping = {
      -- TODO: conditionally load luasnip realted stuff depending on features (requries plugin manager dependency feature registering)
      ["<Tab>"]     = cmp.mapping({
        i = function(fb) tab(fb) end,
        s = function(fb) tab(fb) end,
        c = function(fb)
          if cmp.visible() then cmp.select_next_item()
          else cmp.complete() end
          -- local complete_or_next = not cmp.visible() and cmp.mapping.complete() or cmp.mapping.select_next_item()
          -- complete_or_next(fb)
        end
      }),
      ["<S-Tab>"]     = cmp.mapping({
        i = function(fb) s_tab(fb) end,
        s = function(fb) s_tab(fb) end,
        c = function(fb)
          if cmp.visible() then cmp.select_prev_item()
          else cmp.complete() end
          -- local complete_or_prev = not cmp.visible() and cmp.mapping.complete() or cmp.mapping.select_prev_item()
          -- complete_or_prev(fb)
        end
      }),

      ['<C-n>']       = cmp.mapping.select_next_item(),
      ['<C-p>']       = cmp.mapping.select_prev_item(),
      ['<C-Down>']      = cmp.mapping.select_next_item(),
      ['<C-Up>']        = cmp.mapping.select_prev_item(),
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
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'nvim_lua' },
      { name = 'rg' },
      { name = 'omni' },
      { name = 'path' },
      { name = 'buffer' },
      -- { name = 'spell' },
      -- { name = 'nvim_lsp_signature_help' },
      -- { name = 'digraphs' },
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        if entry.source.name == 'omni' then
          if entry.completion_item.documentation == nil then
            entry.completion_item.documentation = vim_item.menu
            vim_item.menu = nil
          end
          vim_item.kind = 'Ω'
          vim_item.kind_hl_group = 'CmpItemKindProperty'
        else
          vim_item.kind = venom.icons.item_kinds.cozette[vim_item.kind] or ''
        end

        return vim_item
      end
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      completion = {
        border = 'single',
        winhighlight = 'CursorLine:CursorLineSelect',
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
    }
    -- sorting = {
    --   priority_weight = 0,
    -- },
    -- view = {
    --   entries = 'native',
    -- },
    -- experimental = {
    --   ghost_text = false,
    -- }
  }

  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' },
      -- { name = 'nvim_lsp_document_symbol' },
    }
  })

  cmp.setup.cmdline(':', {
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    },
  })
end)

M.nvim_tree = U.Service():require(FT.PLUGIN, "nvim-tree.lua"):new(function()
  vim.g.nvim_tree_allow_resize = 1

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
    hijack_cursor       = true,
    open_on_tab         = true,
    update_cwd          = true,
    view = {
      adaptive_size = true,
      hide_root_folder = true,
      centralize_selection = true,
      mappings = {
        custom_only = false,
        list = nvimtree_keybindings
      }
    },
    renderer = {
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
        show = {
          folder_arrow = false,
        },
        glyphs = {
          default = '',
          symlink = '',
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
            unstaged = "+",
            staged = "*",
            unmerged = "",
            renamed = "r ",
            untracked = "-",
            deleted = "d",
            ignored = "i",
          },
        }
      }
    },
    update_focused_file = {
      enable      = true,
      update_cwd  = false,
      ignore_list = {}
    },
    ignore_ft_on_setup = { 'startify', 'dashboard' },
    diagnostics = {
      enable = true,
      icons = {
        hint    = NVIMTREE_LSP_DIAG_ICONS.Hint,
        info    = NVIMTREE_LSP_DIAG_ICONS.Info,
        warning = NVIMTREE_LSP_DIAG_ICONS.Warn,
        error   = NVIMTREE_LSP_DIAG_ICONS.Error,
      },
    },
    filters = {
      dotfiles = false,
      custom = {'node_modules', '.cache', '*.import', '__pycache__', 'pnpm-lock.yaml', 'package-lock.json'}
    },
    git = {
      ignore = true
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

M.neo_tree = U.Service():require(FT.PLUGIN, "neo-tree.nvim"):new(function()
  require'window-picker'.setup {
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
    -- popup_border_style = 'single',
    default_component_configs = {
      modified = {
        symbol = '•',
      },
      name = {
        -- trailing_slash = false,
        -- use_git_status_colors = true,
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
          'node_modules',
          '__pycache__',
          'pnpm-lock.yaml',
          'package-lock.json',
        },
        hide_by_pattern = {
          "*.import"
        },
        never_show = {
        },
      },
      commands = {
        -- delete = function(state)
        --   local path = state.tree:get_node().path
        --   vim.fn.system({ "gio", 'trash', vim.fn.fnameescape(path) })
        --   require('neo-tree.sources.manager').refresh(state.name)
        -- end,
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

M.bufferline = U.Service():require(FT.PLUGIN, 'bufferline.nvim'):new(function()
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
      separator_style = {'', ''},
      -- enforce_regular_tabs = true,
      offsets = {
        { filetype = "NvimTree" },
        { filetype = "neo-tree" },
      },
    },
  }
end)

M.toggle_term = U.Service():require(FT.PLUGIN, "nvim-toggleterm.lua"):new(function()
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
    winbar = {
      enabled = true,
      -- name_formatter = function(term)
      --   -- log(term)
      --   return term.name
      -- end
    },
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

  local header_art = [[
┬  ┬┬─╮╭╮╭╭─╮╭┬╮
╰┐┌╯├┤ ││││ ││││
 ╰╯ ╰─╯╯╰╯╰─╯┴ ┴
]]
--   local header_art = [[
-- ╭╮╭┬─╮╭─╮┬  ┬┬╭┬╮
-- │││├┤ │ │╰┐┌╯││││
-- ╯╰╯╰─╯╰─╯ ╰╯ ┴┴ ┴
-- ]]

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

M.paperplanes = U.Service():require(FT.PLUGIN, 'paperplanes.nvim'):new(function()
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

M.fold_cycle = U.Service():require(FT.PLUGIN, 'fold-cycle.nvim'):new(function()
  require 'fold-cycle'.setup {
    open_if_max_closed = true,
    close_if_max_opened = true,
    softwrap_movement_fix = false,
  }
end)

M.fold_preview = U.Service():require(FT.PLUGIN, 'fold-preview.nvim'):new(function()
  require 'fold-preview'.setup {
    default_keybindings = false,
    border = 'single',
  }
end)

M.icon_picker = U.Service():require(FT.PLUGIN, 'icon-picker.nvim'):new(function()
  require 'icon-picker'
end)

M.fzf_lua = U.Service():require(FT.PLUGIN, 'fzf-lua'):new(function()
  require'fzf-lua'.setup {
    winopts = {
      border           = 'single',
      hl = {
        border         = 'VertSplit',        -- border color (try 'FloatBorder')
      },
      preview = {
        title          = true,
        scrollbar      = 'border',
      },
    }
  }
end)

M.guess_indent = U.Service():require(FT.PLUGIN, 'guess-indent.nvim'):new(function()
  require 'guess-indent'.setup {}
end)

M.gomove = U.Service():require(FT.PLUGIN, 'nvim-gomove'):new(function()
  require 'gomove'.setup {
    map_defaults = false,
  }
end)

return M
