set path+=**

" Nice menu when typing :find *.py
set wildmode=longest,list,full
set wildmenu
" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*

call plug#begin()
" theme
Plug 'drewtempelmeyer/palenight.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Plebvim lsp Plugins
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
Plug 'onsails/lspkind-nvim'
"Plug 'github/copilot.vim'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'

"
Plug 'glepnir/lspsaga.nvim'
Plug 'simrat39/symbols-outline.nvim'

"
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'windwp/nvim-autopairs'
Plug 'nvim-treesitter/playground'
Plug 'romgrk/nvim-treesitter-context'

"
Plug 'mfussenegger/nvim-dap'
Plug 'Pocco81/DAPInstall.nvim'
Plug 'szw/vim-maximizer'

" Snippets
Plug 'hrsh7th/cmp-cmdline'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'

"
Plug 'mbbill/undotree'

"
Plug 'gruvbox-community/gruvbox'
Plug 'luisiacc/gruvbox-baby'
Plug 'tpope/vim-projectionist'
Plug 'sbdchd/neoformat'

"
Plug 'vim-syntastic/syntastic'
Plug 'wlangstroth/vim-racket'
Plug 'sheerun/vim-polyglot'
Plug 'rust-lang/rust.vim'
Plug 'darrikonn/vim-gofmt'
Plug 'preservim/tagbar'
Plug 'universal-ctags/ctags'
Plug 'luochen1990/rainbow'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
" Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'tommcdo/vim-lion'
Plug 'Shirk/vim-gas'
Plug 'ntpeters/vim-better-whitespace'
Plug 'ARM9/arm-syntax-vim'
Plug 'mhinz/vim-rfc'
Plug 'vim-utils/vim-man'

call plug#end()

lua require("david.cmp")
lua require("david.keymaps")
lua require("david.plugins")
lua require("david.lsp")
lua require("david.treesitter")

if (empty($TMUX))
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" change leader
let mapleader = " "
nnoremap <leader>x :silent !chmod +x %<CR>
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>

" Try new shit below
" Try new shit above

" Get syntax files from config folder
set runtimepath+=~/.config/nvim/syntax

" Airline stuff
let g:airline#extensions#tabline#enabled = 1 " Enable the list of buffers

" Theme
"colorscheme palenight
"set bg=dark
if !exists('g:syntax_on')
  syntax on
endif

if !exists('g:loaded_color')
  let g:loaded_color = 1

  set background=dark
  " Put your favorite colorscheme here
  colorscheme gruvbox-baby
  autocmd VimEnter * ++nested colorscheme gruvbox-baby
  autocmd VimEnter * ++nested let g:gruvbox_transparent_bg=1
  autocmd VimEnter * ++nested let g:gruvbox_contrast_dark='soft'
endif

autocmd BufEnter * set hls

" Disable C-z from job-controlling neovim
nnoremap <c-z> <nop>

nnoremap <leader>u :UndotreeShow<CR>

" Remap C-c to <esc>

imap <c-c> <esc>
vmap <c-c> <esc>
omap <c-c> <esc>

" keybind to show registers
map <silent> '' :call DisplayRegisters()<cr>

function! DisplayRegisters()
  redir => output
  silent exe 'reg "0123456789'
  redir END
  new
  silent file [Registers]
  setlocal nonumber norelativenumber
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
  silent put =output
  silent normal gg"_d2j
  exe 'resize ' . line('$')
  map <silent> <buffer> q :q<cr>
  map <silent> <buffer> <esc> q
endfunction

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

" Syntax highlighting
"syntax on

" Position in code
set number
set ruler
set relativenumber

" Don't make noise
set visualbell

" default file encoding
set encoding=utf-8

" Line wrap
set wrap

" Function to set tab width to n spaces
function! SetTab(n)
    let &l:tabstop=a:n
    let &l:softtabstop=a:n
    let &l:shiftwidth=a:n
    set expandtab
endfunction

command! -nargs=1 SetTab call SetTab(<f-args>)

" Function to trim extra whitespace in whole file
function! Trim()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

command! -nargs=0 Trim call Trim()

set laststatus=2

" Highlight search results
set incsearch

" auto + smart indent for code
set autoindent
set smartindent

set t_Co=256

" Mouse support
set mouse=a

" Map F8 to Tagbar
nmap <F8> :TagbarToggle<CR>

" CTags config
let g:Tlist_Ctags_Cmd='/usr/local/Cellar/ctags/5.8_1/bin/ctags'

" disable backup files
set nobackup
set nowritebackup

" no delays!
set updatetime=300

set cmdheight=1
set shortmess+=c

set signcolumn=yes

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

au BufNewFile,BufRead *.s,*.S set filetype=arm " arm = armv6/7
au BufNewFile,BufRead *.asm set filetype=nasm

" python syntax highlighting fix
let g:syntastic_python_checkers = ['python']
let g:syntastic_python_checkers_exec = 'python3'

let g:python3_host_prog = '/usr/bin/python3.8'

au VimEnter,VimResume * set guicursor=n-v:block,i-ci-ve-c:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175
au VimLeave,VimSuspend * set guicursor=a:block-blinkon0

