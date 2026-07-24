require "pack_ui".setup {
  border = "single",
  title = " vim.pack ",
  max_width = 100,
  width_ratio = 0.9,
  height_ratio = 0.85,
  auto_check = false,   -- on setup, check remotes and notify if updates exist
  auto_update = false,  -- on setup, apply every available update automatically
  keymaps = {
    prefix = "<leader>p",
    status = "s",        -- <leader>ps -> :PackStatus
    update_all = "U",    -- <leader>pU -> :PackUpdateAll
    -- Buffer-local keys inside the float. Each takes a string or a list of
    -- keys; set one to `false` to unbind it. These stay active even with
    -- `keymaps = false` (that only turns off the global maps above).
    window = {
      close = { "q", "<Esc>" },
      toggle_mark = { "<Space>", "<Tab>" },
      mark_all = { "a" },
      update_marked = { "u" },
      update_all = { "U" },
      refresh = { "r", "R" },
      changelog = { "<CR>", "K" },
    },
  },
}
