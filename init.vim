set nocompatible

set hlsearch
set incsearch
set ignorecase
set smartcase

syntax on

set number
set wildmenu
set cursorline
set laststatus=2

set tabstop=4
set softtabstop=4
set shiftwidth=4

set splitright
set nocindent

set noswapfile
set nobackup
set nowritebackup

set hidden

set exrc

call plug#begin('~/.config/nvim/plugged')
Plug 'frankier/neovim-colors-solarized-truecolor-only'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'scrooloose/nerdtree'
Plug 'Valloric/YouCompleteMe'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'camelcasemotion'
Plug 'easymotion/vim-easymotion'
Plug 'vim-scripts/a.vim'
Plug 'benekastah/neomake'
call plug#end()

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set background=dark
colorscheme solarized

let $FZF_DEFAULT_COMMAND='ag -g ""'
nnoremap <F3> :FZF<cr>

nnoremap <F4> :A<cr>

let NERDTreeIgnore=['\.pyc$', '\~$']

let g:ycm_show_diagnostics_ui=0
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_confirm_extra_conf=0

nnoremap <leader>g :YcmCompleter GoTo<CR>
nnoremap <leader>v :YcmCompleter GetType<CR>

nnoremap <leader>e :NERDTreeToggle<CR><Paste>

nnoremap <M-PageUp> :tabprevious<cr>
nnoremap <M-PageDown> :tabnext<cr>

nnoremap <F7> :cprevious<cr>
nnoremap <F8> :cnext<cr>

function! s:tags_sink(line)
  let parts = split(a:line, '\t\zs')
  let excmd = matchstr(parts[2:], '^.*\ze;"\t')
  execute 'silent e' parts[1][:-2]
  let [magic, &magic] = [&magic, 0]
  execute excmd
  let &magic = magic
endfunction

function! s:tags()
  if empty(tagfiles())
    echohl WarningMsg
    echom 'Preparing tags'
    echohl None
    call system('ctags -R')
  endif

  call fzf#run({
  \ 'source':  'cat '.join(map(tagfiles(), 'fnamemodify(v:val, ":S")')).
  \            '| grep -v ^!',
  \ 'options': '+m -d "\t" --with-nth 1,4.. -n 1 --tiebreak=index',
  \ 'down':    '40%',
  \ 'sink':    function('s:tags_sink')})
endfunction

command! Tags call s:tags()
