local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons
local buffers = require "helpers.buffers"

local M = { plugins_info.sfm.url }

M.dependencies = {
  plugins_info.plenary.url,
  plugins_info.devicons.url,
  plugins_info.sfm_git.url,
}

M.config = function()
  local sfm = require "sfm"
  local sfm_api = require "sfm.api"
  local sfm_event = require "sfm.event"

  local sfm_explorer = sfm.setup({
    view = {
      width = 35,
      selection_render_method = 'highlight',
    },
    mappings = {
      list = {
        { key = 'a', action = 'create' },
        { key = 'd', action = 'trash' },
        { key = 'c', action = 'copy' },
        { key = 'x', action = 'move' },

        -- { key = 'za', action = 'toggle_entry' },
        -- { key = 'zc', action = 'close_entry' },
        -- { key = 's', action = 'system_open' },
        -- { key = 's', action = 'parent_entry' },
        -- { key = 'p', action = 'paste' },
        -- { key = '<cr>', action = 'entry_open_or_toggle' },
        -- { key = '<c-Space>', action = 'clear' },
      },
    },
    file_nesting = {
      enabled = true,
      patterns = {
        { "go.mod", { "go.sum" } },
        { "*.tex", { "$(capture).aux", "$(capture).out", "$(capture).synctex.gz" } },
      },
    },
  })

  sfm_explorer:load_extension("sfm-git", {
    debounce_interval_ms = 100,
    icons = {
      unstaged = icons.vcs.modified,
      staged = icons.vcs.staged,
      unmerged = icons.vcs.conflicted,
      renamed = icons.vcs.renamed,
      untracked = icons.vcs.untracked,
      deleted = icons.vcs.deleted,
      ignored = icons.vcs.ignored,
    },
  })

  keys.map("n", "<C-e>", sfm_api.explorer.toggle, "Toggle SFM")

  -- rename any related open buffers on file rename
  sfm_explorer:subscribe(sfm_event.EntryRenamed, function(payload)
    local from_path = payload["from_path"]
    local to_path = payload["to_path"]

    local index = buffers.buflist:get_buf_index({ file_path = from_path })
    if index then
      buffers.buflist:get_buf_info(index).buf:rename(to_path)
    end
  end)

  -- remove any related open buffers on file delete
  sfm_explorer:subscribe(sfm_event.EntryDeleted, function(payload)
    local path = payload["path"]

    local index = buffers.buflist:get_buf_index({ file_path = path })

    -- TODO: make mini bufremove a dependency or find a vanilla way to remove buffers
    local mini_bufremove = require 'mini.bufremove'
    if mini_bufremove then
      mini_bufremove.delete(buffers.buflist:get_buf_info(index).buf.bufnr)
    end
  end)
end

return M
