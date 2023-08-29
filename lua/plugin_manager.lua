local U = require 'utils'

local M = {}

events.install_pre = U.Event("install_pre"):new()
events.install_post = U.Event("install_post"):new()

M.plugin_manager_name = 'lazy.nvim'
M.install_path = vim.fn.stdpath("data") .. '/lazy/'
M.dev_path = '~/sectors/nvim/'

--- bootstraps the plugin manager if not installed
M.bootstrap = service(function()
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
M.setup = service(function(plugins)
  M.bootstrap()

  events.install_pre()

  require 'lazy'.setup(plugins, {
    root = M.install_path,
    dev = {
      path = M.dev_path,
    },
    install = {
      colorscheme = { default_colorscheme }
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
  local dev_plugins = M.get_dev_plugin_names_from_plugin_spec_tree(plugins)
  local listed_plugins = M.get_short_plugin_names_from_plugin_spec_tree(plugins)

  for _, v in ipairs(U.tbl_intersect(U.tbl_union(instaled_plugins, dev_plugins), listed_plugins)) do
    M.register_plugin(v)
  end

  events.install_post()
end)

--- returns plugin short name from a single plugin spec
M.get_short_name_from_plugin_spec = function(spec)
  local name = nil

  if type(spec) == 'string' then
    name = spec
  elseif type(spec) == 'table' and spec[1] ~= nil then
    name = spec[1]
  end

  local name_arr = vim.split(name, '/')
  return name_arr[#name_arr]
end

--- returns plugin dev bool from a single plugin spec
M.get_dev_bool_from_plugin_spec = function(spec)
  if type(spec) == 'table' and spec.dev ~= nil then
    return spec.dev
  end

  return false
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

--- recurses through the plugin spec tree to extract plugin short names
M.get_dev_plugin_names_from_plugin_spec_tree = function(specs)
  local names = {}

  if type(specs) == 'table' then
    for _, spec in ipairs(specs) do
      if M.get_dev_bool_from_plugin_spec(spec) then
        table.insert(names, M.get_short_name_from_plugin_spec(spec))
      end
      if spec.dependencies ~= nil then
        names = U.tbl_union(names, M.get_dev_plugin_names_from_plugin_spec_tree(spec.dependencies))
      end
    end
  end

  return names
end

--- registers a plugin into the feature list as PLUGIN:<plugin short name>
M.register_plugin = service(function(short_name)
  if feat_list:has(feat.PLUGIN, short_name) then
    log.warn('attempt to feature re-register a plugin "' .. short_name .. '"')
  else
    feat_list:add(feat.PLUGIN, short_name)
  end
end)

--- syncs plugins (updates them regardless of the method)
M.sync = service(function()
  vim.cmd [[Lazy update]]
end)

--- checks for new pending updates
M.check = service(function()
  vim.cmd [[Lazy check]]
end)

return M
