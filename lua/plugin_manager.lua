--- defines plugin managment mechanism.
-- @module plugin_manager
local M = {}

M.plugin_manager_name = 'lazy.nvim'
M.install_path = vim.fn.stdpath("data") .. '/lazy/'

--- bootstraps the plugin manager if not installed
M.bootstrap = U.Service(function()
  local plugin_manager_path = M.install_path .. M.plugin_manager_name

  if not vim.loop.fs_stat(plugin_manager_path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      plugin_manager_path,
    })
  end

  vim.opt.runtimepath:prepend(plugin_manager_path)
end)

--- initializes and configures the plugin manager
M.setup = U.Service(function(plugins)
  M.bootstrap()

  Events.install_pre()

  require 'lazy'.setup(plugins, {
    root = M.install_path,
    dev = {
      path = '~/sectors/nvim/',
    },
    install = {
      colorscheme = { 'venom' }
    },
    ui = {
      size = { width = 142, height = 0.8 },
      wrap = false,
      border = 'single',
    },
    checker = {
      enabled = true,
    },
  })

  -- registering plugins that are both installed and listed
  local instaled_plugins = U.scan_dir(M.install_path)
  local listed_plugins = M.get_short_plugin_names_from_plugin_spec_tree(plugins)

  for _, v in ipairs(U.tbl_intersect(instaled_plugins, listed_plugins)) do
    M.register_plugin(v)
  end

  Events.install_post()
end)

--- returns plugin short name from a single plugin spec
M.get_short_name_from_plugin_spec = function(spec)
  local name = nil

  if type(spec) == 'string' then
    name = spec
  elseif type(spec) == 'table' and spec[1] ~= nil then
    name = spec[1]
  end

  ---@diagnostic disable-next-line: missing-parameter
  local name_arr = vim.split(name, '/')
  return name_arr[#name_arr]
end

--- recurses through the plugin spec tree to extract plugin short names
M.get_short_plugin_names_from_plugin_spec_tree = function(specs)
  local names = {}

  if type(specs) == 'string' then
    table.insert(names, M.get_short_name_from_plugin_spec(specs))
  else
    for _, spec in ipairs(specs) do
      table.insert(names, M.get_short_name_from_plugin_spec(spec))
      if spec.dependencies ~= nil then
        names = U.tbl_union(names, M.get_short_plugin_names_from_plugin_spec_tree(spec.dependencies))
      end
    end
  end

  return names
end

--- registers a plugin into the feature list as PLUGIN:<plugin short name>
M.register_plugin = U.Service(function(short_name)
  if Features:has(FT.PLUGIN, short_name) then
    log.warn('attempt to feature re-register a plugin "' .. short_name .. '"')
  else
    Features:add(FT.PLUGIN, short_name)
  end
end)

--- syncs plugins (updates them regardless of the method)
M.sync = U.Service(function()
  vim.cmd [[Lazy update]]
end)

--- checks for new pending updates
M.check = U.Service(function()
  vim.cmd [[Lazy check]]
end)

return M
