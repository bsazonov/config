set nocompatible

set hlsearch
set incsearch
set smartcase

set number
set wildmenu
set cursorline
set colorcolumn=80
set laststatus=2

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

set splitright

set noswapfile
set nobackup
set nowritebackup

set nohidden

set exrc

set rtp+=~/.config/nvim/vim-pathogen
call pathogen#infect()

syntax on
filetype plugin indent on

au BufRead,BufNewFile *.scons set filetype=python
au BufRead,BufNewFile SConstruct set filetype=python

set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set background=dark
colorscheme solarized

let $FZF_DEFAULT_COMMAND='ag -g ""'
nnoremap <F3> :Files<cr>
nnoremap <F12> :tabnew<cr>:Files<cr>

nnoremap <F4> :A<cr>

let g:ycm_show_diagnostics_ui=1
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_confirm_extra_conf=0
let g:ycm_collect_identifiers_from_tags_files=1

nnoremap <C-]> :YcmCompleter GoTo<CR>

nmap ZZ :echo "Save and exit prevented! =)"<CR>
nmap <C-C> :echo "Type  :quit<Enter>  to exit Vim"<CR>

let g:NERDTreeMapOpenInTab = "<C-T>"
let NERDTreeIgnore=['\.pyc$', '\~$']

function! NTToggle()
  if exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
    NERDTreeToggle
  else
    NERDTreeFind
  endif
endfunction

nnoremap <F2> :call NTToggle()<CR>

" Map Ctrl + T to open entries from quickfix in new tab
autocmd FileType qf nnoremap <buffer> <C-T> <C-W><Enter><C-W>T

nnoremap <M-PageUp> :tabprevious<cr>
nnoremap <M-PageDown> :tabnext<cr>

nnoremap <M-Left> :tabprevious<cr>
nnoremap <M-Right> :tabnext<cr>

nnoremap <C-Home> <Home>
nnoremap <C-End> <End>

nnoremap <C-S-Up> :cprevious<cr>
nnoremap <C-S-Down> :cnext<cr>

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
  let l:ag_format="%f:%l:%c:%m"

  let l:grepprg_bak=&grepprg
  let l:grepformat_bak=&grepformat
  let l:t_ti_bak=&t_ti
  let l:t_te_bak=&t_te
  try
    let &grepprg=g:ag_prg
    let &grepformat=l:ag_format
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

function! DoSearchFiles(filepattern, expression)
  let l:ag_executable = get(split(g:ag_prg, " "), 0)

  " Ensure that `ag` is installed
  if !executable(l:ag_executable)
    echoe "Ag command '" . l:ag_executable . "' was not found. Is the silver searcher installed and on your $PATH?"
    return
  endif

  " Format, used to manage column jump
  let l:ag_prg_filepattern=g:ag_prg . " -G " . a:filepattern
  let l:ag_format="%f:%l:%c:%m"

  let l:grepprg_bak=&grepprg
  let l:grepformat_bak=&grepformat
  let l:t_ti_bak=&t_ti
  let l:t_te_bak=&t_te
  try
    let &grepprg=l:ag_prg_filepattern
    let &grepformat=l:ag_format
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
command! -nargs=+ -complete=tag SearchFiles call DoSearchFiles(<f-args>)

function! DoCSearch(expression)
  let l:csearch_executable = "csearch"

  " Ensure that `csearch` is installed
  if !executable(l:csearch_executable)
    echoe "csearch command '" . l:csearch_executable . "' was not found. Is the code search installed and on your $PATH?"
    return
  endif

  let l:csearch_prg=l:csearch_executable . " -n"
  let l:csearch_format="%f:%l:%m"

  let l:grepprg_bak=&grepprg
  let l:grepformat_bak=&grepformat
  let l:t_ti_bak=&t_ti
  let l:t_te_bak=&t_te
  try
    let &grepprg=l:csearch_prg
    let &grepformat=l:csearch_format
    set t_ti=
    set t_te=
    let l:search = substitute(a:expression,'\(\\<\|\\>\)','\\b','g')
    silent! execute "grep \"" . l:search . "\""
  finally
    let &grepprg=l:grepprg_bak
    let &grepformat=l:grepformat_bak
    let &t_ti=l:t_ti_bak
    let &t_te=l:t_te_bak
  endtry
endfunction

function! DoCSearchFiles(filepattern, expression)
  let l:csearch_executable = "csearch"

  " Ensure that `csearch` is installed
  if !executable(l:csearch_executable)
    echoe "csearch command '" . l:csearch_executable . "' was not found. Is the code search installed and on your $PATH?"
    return
  endif

  let l:csearch_prg=l:csearch_executable . " -n -f " . a:filepattern
  let l:csearch_format="%f:%l:%m"

  let l:grepprg_bak=&grepprg
  let l:grepformat_bak=&grepformat
  let l:t_ti_bak=&t_ti
  let l:t_te_bak=&t_te
  try
    let &grepprg=l:csearch_prg
    let &grepformat=l:csearch_format
    set t_ti=
    set t_te=
    let l:search = substitute(a:expression,'\(\\<\|\\>\)','\\b','g')
    silent! execute "grep \"" . l:search . "\""
  finally
    let &grepprg=l:grepprg_bak
    let &grepformat=l:grepformat_bak
    let &t_ti=l:t_ti_bak
    let &t_te=l:t_te_bak
  endtry
endfunction

command! -nargs=1 -complete=tag CSearch call DoCSearch(<f-args>)
command! -nargs=+ -complete=tag CSearchFiles call DoCSearchFiles(<f-args>)

function! DoSearchWord(word)
  let l:keywords = [ "alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand", "bitor", "bool", "break", "case", "catch", "char", "char16_t", "char32_t", "class", "compl", "const", "constexpr", "const_cast", "continue", "decltype", "default", "delete", "do", "double", "dynamic_cast", "else", "enum", "explicit", "export", "extern", "false", "float", "for", "friend", "goto", "if", "inline", "int", "long", "mutable", "namespace", "new", "noexcept", "not", "not_eq", "nullptr", "operator", "or", "or_eq", "private", "protected", "public", "register", "reinterpret_cast", "return", "short", "signed", "sizeof", "static", "static_assert", "static_cast", "struct", "switch", "template", "this", "thread_local", "throw", "true", "try", "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual", "void", "volatile", "wchar_t", "while", "xor", "xor_eq" ]
  if (index(l:keywords, a:word) >= 0)
    echoe "Search term '" . a:word . "' is a keyword. Use :Search if you are brave enough."
    return
  endif
  call DoSearch("\\<" . a:word . "\\>")
endfunction

nnoremap <F5> :call DoSearchWord(expand("<cword>"))<CR><CR>:cw<CR>

inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

function DoDeleteHiddenBuffers()
    let tpbl=[]
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
        silent execute 'bwipeout' buf
    endfor
endfunction

command! -nargs=0 DeleteHiddenBuffers call DoDeleteHiddenBuffers()

