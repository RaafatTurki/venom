local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local precomputed_colors = require "helpers.precomputed_colors"

local M = { plugins_info.mini.url }

M.config = function()
  local mini_map = require "mini.map"
  if mini_map then
    mini_map.setup {
      window = {
        width = 1,
        winblend = 0,
        show_integration_count = false,
      },
      symbols = {
        -- encode = mini_map.gen_encode_symbols.dot('4x2'),
        -- encode = mini_map.gen_encode_symbols.block('2x1'),
        -- encode = mini_map.gen_encode_symbols.shade('2x1'),
        scroll_line = '┃',
        scroll_view = '│',
      },
      integrations = {
        -- mini_map.gen_integration.builtin_search(),
        -- mini_map.gen_integration.gitsigns(),
        -- mini_map.gen_integration.diagnostic(),
      },
    }
    -- open on vim enter
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function(ev) mini_map.open() end
    })

    -- hide on insert
    vim.api.nvim_create_autocmd('ModeChanged', {
      callback = function(ev)
        local mode = vim.api.nvim_get_mode().mode
        if mode == 'i' then
          mini_map.close()
        else
          mini_map.open()
        end
      end
    })

    -- hide on normal when cursor is on the far edge 
    -- vim.api.nvim_create_autocmd('CursorMoved', {
    --   callback = function(ev)
    --     log(ev)
    --     -- if cursor is on the right most edge of the entire editor close minimap, else open it
    --     -- if ... then
    --     --   mini_map.close()
    --     -- else
    --     --   mini_map.open()
    --     -- end
    --   end
    -- })
  end

  local mini_bufremove = require 'mini.bufremove'
  if mini_bufremove then
    mini_bufremove.setup()
    keys.map("n", "<A-c>", mini_bufremove.delete, "Delete buffer")
  end

  local mini_move = require 'mini.move'
  if mini_move then
    mini_move.setup()
    keys.map("n", "<Tab>",      function() mini_move.move_line('right') end, "Indent")
    keys.map("n", "<S-Tab>",    function() mini_move.move_line('left') end, "Deindent")
    keys.map("x", "<Tab>",      function() mini_move.move_selection('right') end, "Visual indent")
    keys.map("x", "<S-Tab>",    function() mini_move.move_selection('left') end, "Visual deindent")
    keys.map("n", "<A-Down>",   function() mini_move.move_line('down') end, "Shift line down")
    keys.map("n", "<A-Up>",     function() mini_move.move_line('up') end, "Shift line up")
    keys.map("x", "<A-Down>",   function() mini_move.move_selection('down') end, "Visual shift lines down")
    keys.map("x", "<A-Up>",     function() mini_move.move_selection('up') end, "Visual shift lines up")
  end

  local mini_hipatterns = require 'mini.hipatterns'
  if mini_hipatterns then

    -- precomputing hex values for named colors
    -- local color_map_uc = vim.tbl_map(function(v) return string.format('#%06x', v) end, vim.api.nvim_get_color_map())
    -- local color_map_lc = {}
    -- for k, v in pairs(color_map_uc) do color_map_lc[string.lower(k)] = v end

    mini_hipatterns.setup {
      highlighters = {
        -- highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
        todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
        note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

        -- highlight hex color strings (#FF0000, #FFFF00)
        hex_colors = mini_hipatterns.gen_highlighter.hex_color(),

        -- highlight named color string (red)
        -- named_colors = {
        --   pattern = '%w+',
        --   group = function(_, match)
        --     local hex = precomputed_colors.all[match]
        --     if hex ~= nil then return mini_hipatterns.compute_hex_color_group(hex, 'bg') end
        --   end
        -- },
      }
    }
  end



  -- local ts_ctx_cms = prequire 'ts_context_commentstring'
  -- if ts_ctx_cms then
  --   ts_ctx_cms.setup {
  --     languages = {
  --       javascript = {
  --         __default = '# %s',
  --         jsx_element = '# %s',
  --         jsx_fragment = '# %s',
  --         jsx_attribute = '# %s',
  --         comment = '# %s',
  --       },
  --     },
  --   }
  -- end

  local mini_comment = require 'mini.comment'
  if mini_comment then
    mini_comment.setup {
      mappings = {
        comment = '<leader>c',
        comment_line = '<leader>c',
        comment_visual = '<leader>c',
        textobject = '',
      },
      hooks = {
        pre = function() end,
        post = function() end,
      },
      options = {
        custom_commentstring = function()
          -- use tree sitter powered commentstring calculation if present
          return prequire 'ts_context_commentstring'.calculate_commentstring() or vim.bo.commentstring
        end,
        ignore_blank_line = true,
      },
    }
  end

  local mini_trailspace = require 'mini.trailspace'
  if mini_trailspace then
    mini_trailspace.setup()
    vim.api.nvim_create_user_command('Trim', mini_trailspace.trim, {})
    vim.api.nvim_create_user_command('TrimLastLines', mini_trailspace.trim_last_lines, {})
    vim.api.nvim_create_user_command('TrimAll', function()
      mini_trailspace.trim()
      mini_trailspace.trim_last_lines()
    end, {})
  end

  local mini_extra = require "mini.extra"

  local mini_pick = require 'mini.pick'
  if mini_pick then
    mini_pick.setup {
      mappings = {
        -- choose_marked = "<C-q>",
      },
      window = {
        config = function()
          height = math.floor(0.618 * vim.o.lines)
          width = math.floor(0.618 * vim.o.columns)

          return {
            anchor = 'NW',
            height = height,
            width = width,
            row = math.floor(0.5 * (vim.o.lines - height)),
            col = math.floor(0.5 * (vim.o.columns - width)),
          }
        end
      },
    }

    keys.map("n", "<leader><CR>", "<CMD>Pick resume<CR>", "Pick resume")
    keys.map("n", "<leader>f",    "<CMD>Pick files<CR>", "Pick find files")
    keys.map("n", "<leader>g",    "<CMD>Pick grep_live<CR>", "Pick grep string")
    keys.map("n", "<leader>h",    "<CMD>Pick help<CR>", "Pick help pages")

    -- if mini_extra then
      -- keys.map("n", "<leader>b",    "<CMD>Pick buffer_lines<CR>", "Pick buffer lines")
      -- keys.map("n", "<leader>b",    "<CMD>Pick diagnostic<CR>", "Pick lsp diagnostics")
      -- keys.map("n", "<leader>b",    "<CMD>Pick explorer<CR>", "Pick file tree explorer")
      -- keys.map("n", "<leader>b",    "<CMD>Pick git_branches<CR>", "Pick git branches")
      -- keys.map("n", "<leader>b",    "<CMD>Pick git_commits<CR>", "Pick git commits")
      -- keys.map("n", "<leader>b",    "<CMD>Pick git_files<CR>", "Pick git files")
      -- keys.map("n", "<leader>b",    "<CMD>Pick git_hunks<CR>", "Pick git hunks")
    -- end

    ---@diagnostic disable-next-line: undefined-global
    vim.ui.select = MiniPick.ui_select
  end

  local mini_notify = require "mini.notify"
  if mini_notify then
    mini_notify.setup {
      content = {
        format = function(notif)
          return notif.msg
        end,
      },
      lsp_progress = {
        enable = true,
        duration_last = 1000,
      },
      window = {
        config = {
          border = 'none',
          anchor = 'SE',
          col = vim.api.nvim_win_get_width(0) -2, -- because of the scrollbar
          row = vim.api.nvim_win_get_height(0),
        },
        winblend = 0,
      },
    }

    vim.notify = mini_notify.make_notify()
  end

  -- TODO: clue
  -- local mini_clue = require 'mini.clue'
  -- if mini_clue then
  --   mini_clue.setup {}
  -- end

  -- TODO: surround
  -- local mini_surround = require 'mini.surround'
  -- if mini_surround then
  --   mini_surround.setup()
  -- end

  -- TODO: operators
  -- require 'mini.operators'.setup()

  -- TODO: align
  -- require 'mini.align'.setup()

  -- TODO: pairs
  -- require 'mini.pairs'.setup()
end

return M
