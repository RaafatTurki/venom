--- implements a plugin manager according to the plugin manager interface.
-- @module plugin_manager
local M = {}

M.is_bootstraping = false
M.is_syncing = false
M.plugin_manager_name = 'packer.nvim'
M.install_paths = {
  vim.fn.stdpath('data')..'/site/pack/packer/start',
  vim.fn.stdpath('data')..'/site/pack/packer/opt'
}
M.plugins = {}
M.event_post_complete = U.Event():new()

--- bootstraps the plugin manager if not installed
M.attempt_bootstrap = U.Service():new(function()
  if not M.is_plugin_installed(M.plugin_manager_name) then
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', M.install_paths[1]..'/'..M.plugin_manager_name }
    M.is_bootstraping = true
    log('Installing packer close and reopen Neovim...')
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

--- checks if plugin is installed
M.is_plugin_installed = U.Service():new(function(plugin_name)
  for _, path in pairs(M.install_paths) do
    if U.is_file_exists(path..'/'..plugin_name) then
      return true
    end
  end
  return false
end)

--- registers a single plugin entry
M.register_plugin = U.Service():new(function(entry)
  local entry_type = type(entry)
  local full_name = nil
  local deps = entry.requires or {}

  if entry_type == 'nil' then
    return
  elseif entry_type == 'string' then
    full_name = entry
  elseif entry_type == 'table' then
    full_name = entry[1]
  end

  local name_split = vim.split(full_name, '/')
  local name_short = name_split[#name_split]

  if venom.features:has(FT.PLUGIN, name_short) then
    log.warn('plugin feature re-register attempt "'..name_short..'"')
  elseif not M.is_plugin_installed(name_short) then
    log.warn('plugin listed but not installed "'..name_short..'"')
    M.is_syncing = true
  else
    venom.features:add(FT.PLUGIN, name_short)
  end
end)

--- registers plugins
M.register_plugins = U.Service():new(function()
  local status_ok, packer = pcall(require, 'packer')
  if not status_ok then
    log.err("could not require packer")
    return
  end

  for _, plugin in pairs(M.plugins) do
    packer.use(plugin)

    -- TODO: make this dependent on install state (not just exisiting in the M.plugins table)
    M.register_plugin(plugin)
  end

  if M.is_bootstraping then 
    vim.api.nvim_command 'PackerSync'
    -- TODO: convert to an auto group
    vim.cmd [[autocmd User PackerComplete lua PluginManager.event_post_complete()]]
  else
    M.event_post_complete()
  end

  -- attempt to install missing plugins
  if M.is_syncing then M.sync() end

end)

--- syncs plugins (updates them regardless of the method)
M.sync = U.Service():new(function()
  log("packer syncing...")
  local time = os.date("!%Y-%m-%dT%TZ")
  vim.cmd([[PackerSnapshot snapshot_]]..time)
  vim.cmd [[PackerSync]]
end)

return M
