local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons
local keys = require "helpers.keys"

local M = { plugins_info.blink }

M.dependencies = {
  { plugins_info.lazydev, dependencies = plugins_info.luvit_meta, ft = "lua" },
}

M.version = 'v0.*'

M.config = function()
  local lazydev = prequire "lazydev"
  if lazydev then
    -- lazydev.setup { library = { plugins = false } }
    lazydev.setup {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
      -- library = {
      --   -- vim.env.LAZY .. "/luvit-meta/library",
      --   vim.fn.stdpath("data") .. "/lazy/luvit-meta/library"
      --   -- vim.env.LAZY .. "/",
      -- }
    }
  end

  require "blink-cmp".setup {
    enabled = function()
      -- bigfile check
      if vim.bo.filetype == "bigfile" then return false end
      -- if vim.tbl_contains({ "cpp" }, vim.bo.filetype) then return false end
      if vim.bo.buftype == "prompt" then return false end
      if vim.b.completion == false then return false end

      return true
    end,

    keymap = {
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },

      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

      ['<C-Up>'] = { 'select_prev', 'fallback' },
      ['<C-Down>'] = { 'select_next', 'fallback' },

      ['<C-k>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-j>'] = { 'scroll_documentation_down', 'fallback' },
    },

    cmdline = {
      keymap = {
        preset = 'none',
        ['<C-Up>'] = { 'select_prev', 'fallback' },
        ['<C-Down>'] = { 'select_next', 'fallback' },

        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      }
    },

    completion = {
      trigger = {
        show_on_insert_on_trigger_character = false,
      },
      menu = {
        draw = {
          treesitter = {},
        },
        border = 'single',
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = 'single'
        },
      },
      list = {
        selection = {
          auto_insert = function(ctx)
            if ctx.mode == 'cmdline' then return true end
            return false
          end
        }
      }
      -- ghost_text = {
      --   enabled = true
      -- },
    },

    signature = {
      enabled = true,
      window = {
        border = 'single',
      }
    },

    appearance = {
      kind_icons = icons.kind,
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer", "lazydev" },
      providers = {
        path = {
          name = 'path',
          module = 'blink.cmp.sources.path',
          score_offset = 3,
          opts = {
            trailing_slash = false,
            label_trailing_slash = true,
            get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
            show_hidden_files_by_default = false,
          }
        },
        snippets = {
          name = 'snippets',
          module = 'blink.cmp.sources.snippets',
          score_offset = -3,
          opts = {
            friendly_snippets = false,
            search_paths = { vim.fn.stdpath('config') .. '/snippets' },
            global_snippets = { 'all' },
            extended_filetypes = {},
            ignored_filetypes = {},
          }

          --- Example usage for disabling the snippet provider after pressing trigger characters (i.e. ".")
          -- enabled = function(ctx) return ctx ~= nil and ctx.trigger.kind == vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter end,
        },
        buffer = {
          name = 'buffer',
          module = 'blink.cmp.sources.buffer',
        },
        lsp = {
          name = 'lsp',
          fallbacks = { 'buffer' },
        },
        lazydev = {
          name = "lazydev",
          module = "lazydev.integrations.blink",
          fallbacks = { "lsp" },
        },
      },
    },
  }
end

return M
