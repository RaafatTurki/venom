--- implements a plugin manager according to the plugin manager interface.
-- @module plugin_manager
local M = {}

M.plugin_manager_name = 'packer.nvim'
M.plugin_manager = nil
M.install_paths = {
  vim.fn.stdpath('data')..'/site/pack/packer/start',
  vim.fn.stdpath('data')..'/site/pack/packer/opt'
}
M.is_bootstraping = false
M.missing_plugins = {}
M.event_post_complete = U.Event():new()

--- bootstraps the plugin manager if not installed
M.bootstrap = U.Service():new(function()
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', M.install_paths[1]..'/'..M.plugin_manager_name }
  log('bootstrapping plugin manager...')
  vim.api.nvim_command 'packadd packer.nvim'
end)

--- initializes and configures the plugin manager
M.setup = U.Service():new(function()
  -- bootstrap if no pm detected
  if not M.is_plugin_installed(M.plugin_manager_name) then
    M.bootstrap()
    M.is_bootstraping = true
  end

  -- loading
  local ok, packer = pcall(require, 'packer')
  if not ok then
    log.err("could not require packer")
    return
  end
  M.plugin_manager = packer

  -- settings
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
M.is_plugin_installed = U.Service():new(function(short_name)
  for _, path in pairs(M.install_paths) do
    if U.is_file_exists(path..'/'..short_name) then
      return true
    end
  end
  return false
end)

--- gets plugin entry split name
M.get_plugin_entry_split_name = U.Service():new(function(entry)
  local full_name = nil
  if type(entry) == 'string' then
    full_name = entry
  elseif type(entry) == 'table' then
    full_name = entry[1]
  end
  return vim.split(full_name, '/')
end)

--- detects if a plugin is missing
M.detect_missing_plugins = U.Service():new(function(entries)
  -- local deps = entry.requires or {}
  for _, entry in pairs(entries) do
    --- extract short name
    local name_split = M.get_plugin_entry_split_name(entry)
    local name_short = name_split[#name_split]

    --- detect if plugin is not installed
    if not M.is_plugin_installed(name_short) then
      table.insert(M.missing_plugins, name_short)
    end
  end
end)

--- syncs plugins (updates them regardless of the method)
M.sync = U.Service():new(function()
  log("packer syncing...")
  local time = os.date("!%Y-%m-%dT%TZ")
  vim.cmd([[PackerSnapshot snapshot_]]..time)
  vim.cmd [[PackerSync]]
end)

--- installs plugins
M.setup_plugins = U.Service():new(function(entries)
  -- setup plugins
  for _, entry in pairs(entries) do
    M.plugin_manager.use(entry)
  end

  -- detect missing plugins and sync if needed
  M.missing_plugins = {}
  M.detect_missing_plugins(entries)

  if #M.missing_plugins > 0 and M.is_bootstraping then
    vim.api.nvim_command 'PackerSync'
    vim.cmd [[autocmd User PackerComplete lua PluginManager.event_post_complete()]]
  elseif #M.missing_plugins > 0 then
    log.warn(#M.missing_plugins ..' missing plugins detected')
    vim.api.nvim_command 'PackerSync'
    vim.cmd [[autocmd User PackerComplete lua PluginManager.event_post_complete()]]
  else
    M.event_post_complete()
  end

end)

return M
