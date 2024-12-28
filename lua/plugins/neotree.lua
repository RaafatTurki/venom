local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons

local M = { plugins_info.neotree }

M.branch = "v3.x"

M.dependencies = {
  plugins_info.plenary,
  plugins_info.nui,
  -- plugins_info.image, -- Optional image support in preview window: See `# Preview Mode` for more information
}

M.config = function()

  local function on_move(data)
    ---@diagnostic disable-next-line: undefined-global
    Snacks.rename.on_rename_file(data.source, data.destination)
  end

  local events = require("neo-tree.events")
  event_handlers = {}
  vim.list_extend(event_handlers, {
    { event = events.FILE_MOVED, handler = on_move },
    { event = events.FILE_RENAMED, handler = on_move },
  })


  require "neo-tree".setup {
    -- close_if_last_window = true,
    popup_border_style = 'single',
    use_libuv_file_watcher = true,
    default_component_configs = {
      git_status = {
        symbols = {
          added     = icons.vcs.staged,
          deleted   = icons.vcs.deleted,
          modified  = icons.vcs.modified,
          renamed   = icons.vcs.renamed,
          untracked = icons.vcs.untracked,
          ignored   = icons.vcs.ignored,
          staged    = icons.vcs.staged,
          conflict  = icons.vcs.conflicted,
          unstaged  = '',
        }
      },
      diagnostics = {
        symbols = {
          hint = icons.diag.Hint,
          info = icons.diag.Info,
          warn = icons.diag.Warn,
          error = icons.diag.Error,
        },
        highlights = {
          hint = "DiagnosticSignHint",
          info = "DiagnosticSignInfo",
          warn = "DiagnosticSignWarn",
          error = "DiagnosticSignError",
        },
      },
      symlink_target = {
        enabled = true,
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,

        hide_by_name = {
          ".git",
          "node_modules",
          ".venom.json",
          ".DS_Store",
          -- "thumbs.db",
        },
      },
    },
    event_handlers = event_handlers,
  }

  keys.map("n", "<C-e>", ":Neotree toggle reveal_force_cwd<CR>", "Neotree Toggle")
  -- keys.map("n", "<C-e>", ":Neotree toggle float git_status<CR>", "")
  -- keys.map("n", "<C-e>", ":Neotree toggle float reveal<CR>", "")
  -- keys.map("n", "<C-e>", ":Neotree toggle float reveal_file=<cfile> reveal_force_cwd<CR>", "")
  -- keys.map("n", "<C-e>", ":Neotree toggle show buffers right<CR>", "")
end

return M
