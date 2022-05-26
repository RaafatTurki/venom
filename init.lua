--- the entry point, calls all other modules.
-- @module init

-- Loading Modules
U = require 'utils'
log = require 'logger'.log
require 'options'
require 'service_loader'
