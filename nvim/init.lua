require('config.options')
require('config.keybinds')
require('config.lazy')


-- general settings ...
vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  pattern = {"*.md","*.markdown","*.txt","*.typ"},
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
