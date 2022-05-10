--- implements a plugin manager according to the plugin manager interface.
-- @module plugin_manager
local M = {}

M.is_bootstraped = false
M.install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
M.plugins = {}

--- bootstraps the plugin manager if not installed
M.attempt_bootstrap = U.Service():new(function()
  if vim.fn.empty(vim.fn.glob(M.install_path)) > 0 then
    M.is_bootstraped = true
    vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', M.install_path})
    vim.api.nvim_command 'packadd packer.nvim'
  end
end)

--- initializes and configures the plugin manager
M.setup = U.Service():new(function()
  -- Settings
  local packer = require 'packer'
  packer.init {
    compile_path = vim.fn.stdpath("data")..'/plugin/packer_compiled.vim',
    git = {
      clone_timeout = 100,
    },
    profile = {
      enable = true,
      -- threshold = 1 -- the amount in ms that a plugins load time must be over for it to be included in the profile
      threshold = 0
    },
    display = {
      open_fn = function() return require'packer.util'.float({ border = 'single' }) end,
      open_cmd = '100vnew \\[packer\\]',
      working_sym = ' ',
      error_sym = ' ',
      done_sym = ' ',
      removed_sym = ' ',
      moved_sym = ' ',
      header_sym = ' ',
      prompt_border = 'single', -- Border style of prompt popups.
    }
  }
  packer.reset()
end)

--- registers a single plugin entry
M.register_plugin = U.Service():new(function(plugin_entry)
  local plugin_entry_type = type(plugin_entry)
  local plugin_full_name = nil
  local plugin_deps = plugin_entry.requires or {}

  if plugin_entry_type == 'nil' then
    return
  elseif plugin_entry_type == 'string' then
    plugin_full_name = plugin_entry
  elseif plugin_entry_type == 'table' then
    plugin_full_name = plugin_entry[1]
  end

  local plugin_name_split = vim.split(plugin_full_name, '/')
  local plugin_name_short = plugin_name_split[#plugin_name_split]

  if venom.features:has(FT.PLUGIN, plugin_name_short) then
    log("plugin feature re-registering attempt", LL.WARN)
  else
    venom.features:add(FT.PLUGIN, plugin_name_short)
  end
end)

--- registers plugins
M.register_plugins = U.Service():new(function()
  local packer = require 'packer'

  for _, plugin in pairs(M.plugins) do
    packer.use(plugin)

    -- TODO: make this dependent on install state (not just exisiting in the M.plugins table)
    M.register_plugin:invoke(plugin)
  end

  if (M.is_bootstraped) then 
    vim.api.nvim_command 'PackerSync'
    -- TODO: convert to an auto group
    vim.cmd [[autocmd User PackerComplete lua venom.actions.pm_post_complete:invoke()]]
  else
    venom.actions.pm_post_complete:invoke()
  end
end)

--- syncs plugins (updates them regardless of the method)
M.sync = U.Service():new(function()
  log("packer syncing...")
  local time = os.date("!%Y-%m-%dT%TZ")
  vim.cmd([[PackerSnapshot snapshot_]]..time)
  vim.cmd [[PackerSync]]
end)

return M
