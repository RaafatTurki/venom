# VENOM

A chill take at configuring neovim.

> Crafting a neovim config is like maintaining a muscle car,
it breaks one too many times and you get a Toyota, Which is the emacs of cars.

## Layout
```text
venom
├── init.lua                    entry point
├── lua/
│   ├── icons.lua               icon sets
│   ├── logger.lua              logger
│   ├── options.lua             vim.o, vim.opt ... etc
│   ├── plugin_manager.lua      lazy.nvim bootstrap and setup
│   ├── module_loader.lua       declarative style control center
│   ├── utils.lua               utilities
│   └── modules/                
│       └── *.lua               each module builds a certain ascpect of nvim
├── colors/                     colorchemes
└── snippets/                   snippets
```

## Mechanisims
Due to the rolling nature of neovim and some infrastructure must be put in place to ensure our code editor won't break under unexpected conditions:


### FeatureList
Features are classes that contain a table of strings where each string represents the availability of a certain feature.

A feature is a string in the form of `<TYPE>:<NAME>`.

**Usage:**
```lua
local features = FeatureList():new()

-- plugin_manager.lua automatically registers all installed plugins
features:add_str("PLUGIN:nvim-cmp")

if features:has_str("PLUGIN:nvim-cmp") then
  -- setup nvim jdtls and what not
end
```
<details>
<summary>Extras</summary>

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
</details>


### Events
Events are glorified auto commands, they provide a more streamlines way of using them like how one would use C# events/delegates.

**Usage:**
```lua
local clear = U.Event():new()

clear:sub [[noh]]
clear:sub(function() print("cleared highlights") end)
-- conditionally subscribe dap marks clearing if PLUGIN:dap is present
-- conditionally subscribe neotest marks clearing if PLUGIN:neotest is present

clear() -- calls all subscribers in order
```
<details>
<summary>Extras</summary>

```lua
clear:front_sub() -- puts a subsriber infront of all the others
clear:subscribers -- table of subscribers
clear:invoke() -- same as clear()
clear:wrap() -- returns `function() return invoke() end`

-- clear()/clear:invoke() are variadic and passes everything to all lua func subs (vim cmds are WIP)
```
</details>


### Service

a service integrates with `FeatureList` heavily, it takes 3 arguments `provides: {string}`, `requires: {string}` and `callback: function` and returns a function.

all strings must be formatted as features (feature tuples are also supported).
the returned function can be called to execute the `callback` however it will fail if one of the features in `requires` doesn't exist.
otherwise it registers all features in `provides`.

**Usage:**
```lua
local impatient = U.service({ "CONF:impatient.nvim" }, { "PLUGIN:impatient.nvim" }, function()
  require 'impatient'
  require 'impatient'.enable_profile()
end)

impatient()
```
