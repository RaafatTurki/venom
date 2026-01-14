- disolve utils this into many helper files
- make helpers.buffers work on file paths w special chars
- implement a line order reverser in visual mode
- implement a way to copy/cut without effecting the clipboard (especially in macros)
- look into why sometime treesitter does't highlight files
- check if the commented helper requires in init.lua are even needed anymore
- colorize git diff markers (https://github.com/akinsho/git-conflict.nvim)


- vim.pack build step
<!-- local hooks = function(ev) -->
<!--   -- Use available |event-data| -->
<!--   local name, kind = ev.data.spec.name, ev.data.kind -->
<!--   -- Run build script after plugin's code has changed -->
<!--   if name == 'plug-1' and (kind == 'install' or kind == 'update') then -->
<!--     -- Append `:wait()` if you need synchronous execution -->
<!--     vim.system({ 'make' }, { cwd = ev.data.path }) -->
<!--   end -->
<!--   -- If action relies on code from the plugin (like user command or -->
<!--   -- Lua code), make sure to explicitly load it first -->
<!--   if name == 'plug-2' and kind == 'update' then -->
<!--     if not ev.data.active then -->
<!--       vim.cmd.packadd('plug-2') -->
<!--     end -->
<!--     vim.cmd('PlugTwoUpdate') -->
<!--     require('plug2').after_update() -->
<!--   end -->
<!-- end -->
<!-- -- If hooks need to run on install, run this before `vim.pack.add()` -->
<!-- vim.api.nvim_create_autocmd('PackChanged', { callback = hooks }) -->
