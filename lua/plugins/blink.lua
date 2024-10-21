local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons
local keys = require "helpers.keys"

local M = { plugins_info.blink }

M.version = 'v0.*'

M.config = function()
  require "blink-cmp".setup {
    keymap = {
      show = '<C-space>',
      hide = '<C-e>',
      accept = '<CR>',
      select_prev = { '<C-Up>' },
      select_next = { '<C-Down>' },

      show_documentation = '<C-space>',
      hide_documentation = '<C-space>',
      scroll_documentation_up = '<C-k>',
      scroll_documentation_down = '<C-j>',

      snippet_forward = '<Tab>',
      snippet_backward = '<S-Tab>',
    },

    trigger = {
      completion = {
        show_on_insert_on_trigger_character = false,
      },
    },

    signature_help = {
      enabled = true,
    },

    kind_icons = icons.kind,

    windows = {
      autocomplete = {
        border = 'single',
      },
      documentation = {
        border = 'single',
      },
      signature_help = {
        border = 'single',
      },
    },
  }
end

return M
