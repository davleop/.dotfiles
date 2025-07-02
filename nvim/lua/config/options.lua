-- OPTIONS
local set = vim.opt

--line nums
set.relativenumber = true
set.number = true

-- indentation and tabs
set.tabstop = 4
set.shiftwidth = 4
set.autoindent = true
set.expandtab = true

-- search settings
set.ignorecase = true
set.smartcase = true

-- appearance
set.termguicolors = true
set.background = "dark"
set.signcolumn = "yes"

-- cursor line
set.cursorline = true

-- 80th column
set.colorcolumn = "80"

-- clipboard
set.clipboard:append("unnamedplus")

-- backspace
set.backspace = "indent,eol,start"

-- split windows
set.splitbelow = true
set.splitright = true

-- dw/diw/ciw works on full-word
set.iskeyword:append("-")

-- keep cursor at least 8 rows from top/bot
set.scrolloff = 8

-- undo dir settings
set.swapfile = false
set.backup = false
set.undodir = os.getenv("HOME") .. "/.vim/undodir"
set.undofile = true

-- incremental search
set.incsearch = true

-- faster cursor hold
set.updatetime = 50

-- My raw vim script functions
vim.cmd([[
  let s:numbers = 0
  function! HideNumbers()
    if s:numbers
      set number
      set ruler
      set relativenumber
      let s:numbers = 0
    else
      set nonumber
      set noruler
      set norelativenumber
      let s:numbers = 1
    endif
  endfun
  command! -nargs=0 HideNumbers call HideNumbers()

  function! SetTab(n)
    let &l:tabstop=a:n
    let &l:softtabstop=a:n
    let &l:shiftwidth=a:n
    set expandtab
  endfunction
  command! -nargs=1 SetTab call SetTab(<f-args>)

  function! Trim()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endfun
  command! -nargs=0 Trim call Trim()
]])

