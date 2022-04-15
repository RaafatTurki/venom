--- implements a plugin manager according to the plugin manager interface.
-- @module plugin_manager
local M = {}

M.is_bootstraped = false
M.install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
M.plugins = {}

--- bootstraps the plugin manager if not installed
M.attempt_bootstrap = function()
  if vim.fn.empty(vim.fn.glob(M.install_path)) > 0 then
    M.is_bootstraped = true
    vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', M.install_path})
    vim.api.nvim_command 'packadd packer.nvim'
  end
end

--- initializes and configures the plugin manager
M.setup = function()
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
end

--- registers plugins
M.register_plugins = function()
  local packer = require 'packer'

  for _, plugin in pairs(M.plugins) do
    packer.use(plugin)

    -- TODO: make depends on install state
    -- add feature PLUGIN:<plugin-name>
    local plugin_name_full
    if type(plugin) == 'string' then
      plugin_name_full = plugin
    elseif type(plugin) == 'table' then
      plugin_name_full = plugin[1]
    end
    local plugin_name_arr = vim.split(plugin_name_full, '/')
    local plugin_name = plugin_name_arr[#plugin_name_arr]
    -- TODO: add features for each dependency as well
    venom.features:add(FT.PLUGIN, plugin_name)
  end

  if (M.is_bootstraped) then 
    vim.api.nvim_command 'PackerSync'
    -- TODO: convert to an auto group
    vim.cmd [[autocmd User PackerComplete lua venom.actions.pm_post_complete:invoke()]]
  else
    venom.actions.pm_post_complete:invoke()
  end
end

return M