# VENOM

A chill take at configuring neovim.

> Crafting a neovim config is like maintaining a muscle car,
it breaks one too many times and you get a Toyota, Which is the emacs of cars.

I dislike over-engineering, Keeping things simple is its own reward.
However some safety nets must be put in place to ensure our code won't break under unexpected conditions.

Hence the introduction of the following mechanisims:


## 1. Features
(N)vim already provides `:help has()` and this is it's equivalent for user defined features.
At the end of the day it's just a table of strings and each represents the availability of a certain feature.
Implemented as the LUA class `FeatureList`

**Usage:**
```lua
local features = FeatureList():new()

-- plugin_manager.lua automatically registers all installed plugins
features:add_str("PLUGIN:nvim-jdtls")

if features:has_str("PLUGIN:nvim-jdtls") then
  -- setup nvim jdtls and what not
end
```
**Extras:**
```lua
--- an "enum" of feature types
FT = {
  PLUGIN = "PLUGIN", -- installed plugins
  LSP = "LSP", -- lsp module
  BIN = "BIN", -- binaries present on system (rg, find, wget, curl, xxd, rg ... etc)
  MISC = "MISC", -- miscellanous stuff
}

features:list -- table of features
features:add(FT.PLUGIN, "nvim-jdtls") -- same as add_str but uses FT
features:has(FT.PLUGIN, "nvim-jdtls") -- same as has_str but uses FT
features:stitch(FT.PLUGIN, "nvim-jdtls") -- returns "PLUGIN:nvim-jdtls"
features:unstitch("PLUGIN:nvim-jdtls") -- { FT.PLUGIN, "nvim-jdtls" }
```


## 2. Events
Much like C# events/delegates events are invokable and subscribable (accepts lua funcs and vim cmds).
Implemented as the LUA class `Event`

**Usage:**
```lua
local clear = U.Event():new()

clear:sub [[noh]]
clear:sub(function() print("cleared highlights") end)
-- conditionally subscribe dap marks clearing if PLUGIN:dap is present
-- conditionally subscribe neotest marks clearing if PLUGIN:neotest is present

clear() -- calls all subscribers in order
```
**Extras:**
```lua
clear:front_sub() -- puts a subsriber infront of all the others
clear:subscribers -- table of subscribers
clear:invoke() -- same as clear()
clear:wrap() -- returns `function() return invoke() end`

-- clear()/clear:invoke() are variadic and passes everything to all lua func subs (vim cmds are WIP)
```

> With the recent introduction of LUA autocmds the implementation can be further simplified.


## 3. Services
Subscribing events conditionally based on features is not enough,
we need functions that conditionally execute depending on what features they require
and register the features they provide once executed.
Implemented as the function `service()`

**Usage:**
```lua
local impatient = U.service({{ FT.CONF, "impatient.nvim" }}, {{ FT.PLUGIN, "impatient.nvim" }}, function()
  require 'impatient'
  require 'impatient'.enable_profile()
end)

impatient()
```

## Notes
- The rest of the config is just normal nvim/lua stuff that utilize the above machanisms.
- Some parts of the config aren't utilizing the above mechanisms yet.
- There's a builtin colorscheme that's built around `vim.api.nvim_set_hl()`
- Lazy loading is not a priority


## Final Thoughts:
As featurful as one might want to make their nvim,
at the end of the day adding more code/plugins does increase the number of moving parts.

With Murphy's law in mind, trying to make the most out of what we have in order to minimize that number should be a goal.
