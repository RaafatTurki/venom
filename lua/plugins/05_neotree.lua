local keys = require "helpers.keys"
local icons = require "helpers.icons".icons
local events = require "neo-tree.events"

-- TODO: maybe put this somewhere globally reachable
local function lsp_rename_handler(data)
  Snacks.rename.on_rename_file(data.source, data.destination)
end

require "neo-tree".setup {
  popup_border_style = 'single',
  use_libuv_file_watcher = true,
  enable_cursor_hijack = true,
  use_popups_for_input = false,

  filesystem = {
    window = {
      mappings = {
        ["o"] = "system_open",
      },
    },

    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false,

      hide_by_name = {
        "node_modules",
        ".venom.json",
        -- "thumbs.db",
        -- ".git",
        -- ".DS_Store",
      },
    },
  },

  commands = {
    system_open = function(state)
      local node = state.tree:get_node()
      local path = node:get_id()
      -- macOs: open file in default application in the background.
      -- vim.fn.jobstart({ "open", path }, { detach = true })
      -- Linux: open file in default application
      vim.fn.jobstart({ "xdg-open", path }, { detach = true })

      -- Windows: Without removing the file from the path, it opens in code.exe instead of explorer.exe
      local p
      local lastSlashIndex = path:match("^.+()\\[^\\]*$") -- Match the last slash and everything before it
      if lastSlashIndex then
        p = path:sub(1, lastSlashIndex - 1) -- Extract substring before the last slash
      else
        p = path -- If no slash found, return original path
      end
      vim.cmd("silent !start explorer " .. p)
    end,
  },

  event_handlers = {
    { event = events.FILE_MOVED, handler = lsp_rename_handler },
    { event = events.FILE_RENAMED, handler = lsp_rename_handler },
  },

  window = {
    auto_expand_width = true,
    width = 30,
  },

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
    icon = {
      provider = function(icon, node)
        local text, hl
        if node.type == "file" then -- if it's a file, set the text/hl
          text, hl = MiniIcons.get("file", node.name)
        elseif node.type == "directory" then -- get directory icons
          text, hl = MiniIcons.get("directory", node.name)
          -- only set the icon text if it is not expanded
          if node:is_expanded() then text = nil end
        end

        -- set the icon text/highlight only if it exists
        if text then icon.text = text end
        if hl then icon.highlight = hl end
      end,
    },
  },
}

keys.map("n", "<C-e>", ":Neotree toggle reveal_force_cwd<CR>", "Neotree Toggle")
