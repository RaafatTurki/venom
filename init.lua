--- the entry point, calls all other modules.
-- @module init

--- prints with vim.inspect
function inspect(val) log(vim.inspect(val)) end
--- TODO: implement better logging with LT (log type)
--- logs an arg
function log(msg, log_level)
  log_level = log_level or LL.INFO
  vim.notify(msg, log_level)
end
--- logs an inspected arg
function logi(data, log_level)
  local msg = vim.inspect(data)
  log(msg, log_level)
end

-- Loading Modules
U = require 'utils'
require 'options'
require 'service_loader'
