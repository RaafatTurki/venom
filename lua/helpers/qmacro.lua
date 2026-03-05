-- visit https://www.reddit.com/r/neovim/comments/1gbbnsq/minimal_macro_plugin_in_11_lines

vim.api.nvim_create_autocmd('RecordingLeave',{callback=function ()
  if vim.v.event.regcontents~='' then
    vim.schedule_wrap(vim.notify)('Recorded macro: '..vim.fn.keytrans(vim.v.event.regcontents))
  else
    vim.schedule_wrap(vim.notify)('Empty macro, previous recoding is kept')
    vim.schedule_wrap(function (prev) vim.fn.setreg('q',prev) end)(vim.fn.getreg'q')
  end
end})


-- start and stop recording a macro, if the recorded macro is empty, keep previous macro
vim.keymap.set('n','q','(reg_recording()==""?"qq":"q")',{expr=true})

-- execute macro safely (e.g. it wont execute if recoding or executing macros)
vim.keymap.set('n','Q','(reg_recording()==""&&reg_executing()==""?":norm! @q\r":"")',{expr=true})

-- modify the current macro, if passed input is empty (or just space) don't do anything
vim.keymap.set('n','cq',':let b:_t=input(">",keytrans(@q))|let @q=(trim(b:_t)!=""?nvim_replace_termcodes(b:_t,1,1,1):@q)\r')
