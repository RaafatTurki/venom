--- defines statusbar services
-- @module statusbar
local M = {}

-- TODO: divide up into related services
M.setup = U.Service():require(FT.PLUGIN, "feline.nvim"):new(function()
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
        c({ provider = { name = 'file_info',                              opts = { file_readonly_icon = ' ' }}}),

        c({ provider = 'git_branch',          hl = 'GitSignsDelete',      icon = ' ' }),
        c({ provider = 'git_diff_added',      hl = 'GitSignsAdd',         icon = '+' }),
        c({ provider = 'git_diff_removed',    hl = 'GitSignsDelete',      icon = '-' }),
        c({ provider = 'git_diff_changed',    hl = 'GitSignsChange',      icon = '~' }),
        c({ provider = require 'nvim-navic'.get_location,     hl = 'Folded',    enabled = require 'nvim-navic'.is_available }),
      },
      {
        -- c({
        --   enabled = require 'luasnip'.jumpable,
        --   provider = function()
        --     local forward = (require 'luasnip'.jumpable(1)) and '⭢' or ''
        --     local backward = (require 'luasnip'.jumpable(-1)) and '⭠' or ''
        --     if forward ~= '' or backward ~= '' then
        --       return backward..venom.icons.item_kinds.cozette.Snippet..forward
        --     else
        --       return ''
        --     end
        --   end,
        --   hl = 'CmpItemKindSnippet',
        -- }),
        -- c({ provider = require 'package-info'.get_status, hl = 'Folded' }),
        c({ provider = venom.icons.item_kinds.cozette.Text,               enabled = function() return vim.wo.spell end }),
        c({ provider = 'ROOT',                hl = 'ErrorMsg',            enabled = U.user():is_root() }),

        c({ provider = 'diagnostic_errors',   hl = 'DiagnosticSignError', icon = lsp_diag_icons.Error }),
        c({ provider = 'diagnostic_warnings', hl = 'DiagnosticSignWarn',  icon = lsp_diag_icons.Warn }),
        c({ provider = 'diagnostic_info',     hl = 'DiagnosticSignInfo',  icon = lsp_diag_icons.Info }),
        c({ provider = 'diagnostic_hints',    hl = 'DiagnosticSignHint',  icon = lsp_diag_icons.Hint }),
        c({ provider = 'lsp_client_names',    icon = U.swrap(Lsp.progress_spinner) }),

        c({ provider = '',                   hl = 'WarningMsg',          enabled = function () return (vim.v.this_session ~= "") end }),
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


-- TODO: divide up into related services
-- M.setup = U.Service():require(FT.PLUGIN, "mini.nvim"):new(function()
--   require 'mini.statusline'.setup {
--     -- Content of statusline as functions which return statusline string. See
--     -- `:h statusline` and code of default contents (used instead of `nil`).
--     content = {
--       inactive = nil,
--       active = nil
--     },
--
--     -- Whether to set Vim's settings for statusline (make it always shown with
--     -- 'laststatus' set to 2). To use global statusline in Neovim>=0.7.0, set
--     -- this to `false` and 'laststatus' to 3.
--     set_vim_settings = true,
--   }
-- end)


return M
