--- the entry point, calls all other modules.
-- @module init

-- Loading Modules
log = require 'logger'.log
U = require 'utils'
require 'options'
require 'service_loader'
