local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons
local keys = require "helpers.keys"

local M = { plugins_info.blink }

M.dependencies = {
  { plugins_info.lazydev, dependencies = plugins_info.luvit_meta, ft = "lua" },
}

M.version = 'v0.*'

-- TODO: optimize for huge buffers
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

    completion = {
      trigger = {
        show_on_insert_on_trigger_character = false,
      },
      menu = {
        draw = {
          treesitter = { "lsp" },
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
      cmdline = {},
      -- cmdline = function()
      --   local type = vim.fn.getcmdtype()
      --   -- Search forward and backward
      --   if type == '/' or type == '?' then return { 'buffer' } end
      --   -- Commands
      --   if type == ':' then return { 'cmdline' } end
      -- end,
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
            friendly_snippets = true,
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
