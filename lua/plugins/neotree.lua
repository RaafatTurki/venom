local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local icons= require "helpers.icons"

local M = { plugins_info.neotree.url }

M.branch = "v3.x"

M.dependencies = {
  plugins_info.plenary.url,
  plugins_info.devicons.url,
  plugins_info.nui.url,
  -- plugins_info.image.url, -- Optional image support in preview window: See `# Preview Mode` for more information
}

M.config = function()
  require "neo-tree".setup {
    close_if_last_window = true,
    popup_border_style = 'single',
    use_libuv_file_watcher = true,
    default_component_configs = {
      git_status = {
        symbols = {
          added     = icons.icons.vcs.staged,
          deleted   = icons.icons.vcs.deleted,
          modified  = icons.icons.vcs.modified,
          renamed   = icons.icons.vcs.renamed,
          untracked = icons.icons.vcs.untracked,
          ignored   = icons.icons.vcs.ignored,
          staged    = icons.icons.vcs.staged,
          conflict  = icons.icons.vcs.conflicted,
          unstaged  = '',
        }
      },
      symlink_target = {
        enabled = true,
      },
    }
  }

  keys.map("n", "<C-e>", ":Neotree toggle reveal_force_cwd<CR>", "Neotree Toggle")
  -- keys.map("n", "<C-e>", ":Neotree toggle float git_status<CR>", "")
  -- keys.map("n", "<C-e>", ":Neotree toggle float reveal<CR>", "")
  -- keys.map("n", "<C-e>", ":Neotree toggle float reveal_file=<cfile> reveal_force_cwd<CR>", "")
  -- keys.map("n", "<C-e>", ":Neotree toggle show buffers right<CR>", "")
end

return M
