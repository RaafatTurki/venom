# VENOM

A chill take at configuring neovim.

> Crafting a neovim config is like maintaining a muscle car,
it breaks one too many times and you get a Toyota, Which is the emacs of cars.

I dislike over-engineering, Keeping things simple is its own reward.
However some safety nets must be put in place to ensure our code won't break under unexpected conditions.

Hence the introduction of the following mechanisims in order to stabilize working in such a volitile environment:


### 1. Features
This is a simple table of strings `venom.features.list` that each represents the existence of a single feature.

Usage:
```lua
venom.features.add_str("PLUGIN:nvim-jdtls") -- plugin_manager automatically registers all installed plugins as such

if venom.features.has_str("PLUGIN:nvim-jdtls") then
  -- setup nvim jdtls and what not
end
```
Extras:
```lua
--- an "enum" of feature types
FT = {
  PLUGIN = "PLUGIN", -- installed plugins
  LSP = "LSP", -- lsp module
  BIN = "BIN", -- binaries present on system (rg, find, wget, curl ... etc)
  MISC = "MISC", -- miscellanous stuff
}

venom.features.list -- table of features
venom.features.add(FT.PLUGIN, "nvim-jdtls") -- same as add_str but uses FT
venom.features.has(FT.PLUGIN, "nvim-jdtls") -- same as has_str but uses FT
```



### 2. Events
Much like C# events/delegates events are invokable and subscribable (accepts lua funcs and vim cmds).
Currently they're implemented as a LUA utility "class" (`U.Event`) and are generally stored in `venom.events`

Usage:
```lua
local clear = U.Event():new()

clear:sub [[noh]]
clear:sub(function() print("cleared highlights") end)
-- conditionally subscribe dap marks clearing if PLUGIN:dap is present
-- conditionally subscribe neotest marks clearing if PLUGIN:neotest is present

clear() -- calls all subscribers in order
```
Extras:
```lua
clear:front_sub() -- puts a subsriber infront of all the others
clear:subscribers -- table of subscribers
clear:invoke() -- same as clear()
clear:wrap() -- returns `function() return clear() end`

-- clear()/clear:invoke() are variadic and passes everything to all lua func subs (vim cmds are WIP)
```

With the recent introduction of LUA autocmds the implementation can be further simplified.



### 3. Services
Subscribing events conditionally based on features is not enough,
we need functions that conditionally execute depending on what features they require
and register the features they provide once executed.
Currently they're implemented as a LUA utility "class" (`U.Service`)

Usage:
```lua
local impatient = U.Service():require(FT.PLUGIN, "impatient.nvim"):new(function()
  require 'impatient'
  require 'impatient'.enable_profile()
end)

impatient()
```
Extras:
```lua
impatient:required_features -- table of features this service requires
impatient:provided_features -- 
impatient:callback -- the callback to be executed once service called all requirments are met
impatient:provide() -- a feature that gets registered once service is finished excuting
impatient:invoke(...) -- same as impatient(...)
impatient:wrap() -- returns `function() return clear() end`
```



## Notes
- The rest of the config is just normal nvim/lua stuff that utilize the above machanisms.
- Currently this config requires nvim nightly.
- Some parts of the config aren't utilizing the above mechanisms yet.
- There's a builtin colorscheme that's built around `vim.api.nvim_set_hl()`
- Lazy loading is not present (yet)

## Final Thoughts:
As featurful as one might want to make their nvim,
at the end of the day adding more code/plugins does increase the number of moving parts.

With Murphy's law in mind, trying to make the most out of what we have in order to minimize that number should be a goal.
