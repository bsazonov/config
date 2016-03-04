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

" Location of the ag utility
if !exists("g:ag_prg")
  " --vimgrep (consistent output we can parse) is available from version  0.25.0+
  if split(system("ag --version"), "[ \n\r\t]")[2] =~ '\d\+.\(\(2[5-9]\)\|\([3-9][0-9]\)\)\(.\d\+\)\?'
    let g:ag_prg="ag --vimgrep"
  else
    " --noheading seems odd here, but see https://github.com/ggreer/the_silver_searcher/issues/361
    let g:ag_prg="ag --column --nogroup --noheading"
  endif
endif

function! DoSearch(expression)
  let l:ag_executable = get(split(g:ag_prg, " "), 0)

  " Ensure that `ag` is installed
  if !executable(l:ag_executable)
    echoe "Ag command '" . l:ag_executable . "' was not found. Is the silver searcher installed and on your $PATH?"
    return
  endif

  " Format, used to manage column jump
  let g:ag_format="%f:%l:%c:%m"

  let l:grepprg_bak=&grepprg
  let l:grepformat_bak=&grepformat
  let l:t_ti_bak=&t_ti
  let l:t_te_bak=&t_te
  try
    let &grepprg=g:ag_prg
    let &grepformat=g:ag_format
    set t_ti=
    set t_te=
    let l:search = substitute(a:expression,'\(\\<\|\\>\)','\\b','g')
    silent! execute "grep \"" . l:search . "\" ./"
  finally
    let &grepprg=l:grepprg_bak
    let &grepformat=l:grepformat_bak
    let &t_ti=l:t_ti_bak
    let &t_te=l:t_te_bak
  endtry
endfunction

command! -nargs=1 -complete=tag Search call DoSearch('<args>')

nnoremap <F5> :call DoSearch("\\<".expand("<cword>")."\\>")<CR><CR>:cw<CR>

