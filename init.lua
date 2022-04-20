--- the entry point, calls all other modules.
-- @module init

--- prints with vim.inspect
function inspect(val) log(vim.inspect(val)) end
--- TODO: implement better logging with LT (log type)
--- logs an arg
function log(msg, log_level)
  local log_level = log_level or LL.INFO
  vim.notify(msg, log_level)
end
--- logs an inspected arg
function logi(data, log_level)
  local msg = vim.inspect(data)
  log(msg, log_level)
end
-- catches and logs errors
function catch(err)
  if (err) then
    log(err, LL.ERROR)
    return true
  else
    return false
  end
end
--- calls require safely
function prequire(module_name)
  local status, value = pcall(require, module_name)
  if (not status) then
    -- "requiring a missing module ["..module_name.."]"
    return nil, value
  else
    return value, nil
  end
end
--- loads a module safely
function load_module(module_name)
  -- return require(module_name)
  local module_value, err = prequire(module_name)
  if (catch(err)) then
    log(err)
    return nil
  else
    return module_value
  end
end


-- Loading Modules
U = load_module "utils"
load_module "options"
load_module "service_loader"
