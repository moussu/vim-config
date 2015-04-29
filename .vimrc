" .vimrc
" by A. Rames <alexandre.rames@gmail.com>
"
" The configuration is targeted at and has only been tested on terminal vim.

if !has('nvim')
  " Use Vim settings, rather then Vi settings.
  " This must be first, because it changes other options as a side effect.
  " Neovim has removed this.
  set nocompatible
endif

if !has('nvim')
  " This has been removed in neovim.
  set shell=/bin/bash
endif

if !has('nvim')
  " This is the default in neovim.
  set encoding=utf-8
endif

set history=10000               " Keep 10000 lines of command line history.
set mouse=a                     " Enable the mouse (eg. for resizing).
set ignorecase                  " Ignore case in search by default.
set smartcase                   " Case insensitive when not using uppercase.
set wildignore=*.bak,*.o,*.e,*~ " Wildmenu: ignore these extensions.
set wildmenu                    " Command-line completion in an enhanced mode.
set wildmode=list:longest       " Complete longest common string, then list.
set showcmd                     " Display incomplete commands.

let hostname = substitute(system('hostname'), '\n', '', '')
if hostname == "achille"
  let mapleader = "\"
endif

" Load/save and automatic backup ==========================================={{{1

if has('nvim')
  set viewdir=~/.nvim/view
  set backupdir=~/.nvim/backup
  set undodir=~/.nvim/undo
else
  set viewdir=~/.vim/view
  set backupdir=~/.vim/backup
  set undodir=~/.vim/undo
endif


" Backup files and keep a history of the edits so changes form a previous
" session can be undone.
set backup
set undofile
" Do not keep a backup of temporary files.
autocmd BufWritePre /tmp/*,~/tmp/* setlocal nobackup 
autocmd BufWritePre /tmp/*,~/tmp/* setlocal noundofile 

" Create directories if they don't already exist.
if !isdirectory(&viewdir)
  exec "silent !mkdir -p " . &viewdir
endif
if !isdirectory(&backupdir)
  exec "silent !mkdir -p " . &backupdir
endif
if !isdirectory(&undodir)
  exec "silent !mkdir -p " . &undodir
endif

" Automatically save and load views.
autocmd BufWinLeave,BufWrite *.* mkview
autocmd BufWinEnter *.* silent! loadview

" Jump to last known cursor position when editing a file.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

set autoread     " Automatically reload files changed on the disk.
set autowrite    " Write a modified buffer on each :next , ...

" Autodetect filetype on first save.
autocmd BufWritePost * if &ft == "" | filetype detect | endif


" Plugins =================================================================={{{1

" Use Vundle to manage the plugins. See https://github.com/gmarik/vundle for
" details.

" Vundle configuration start ==========================={{{2
filetype off
if has('nvim')
  set runtimepath+=~/.nvim/bundle/vundle/
else
  set runtimepath+=~/.vim/bundle/vundle/
endif

if has('nvim')
  call vundle#rc('~/.nvim/bundle')
else
  call vundle#rc('~/.vim/bundle')
endif

call vundle#begin()

Plugin 'gmarik/vundle'

" List of plugins managed =============================={{{2

" Word highlighting.
Plugin 'vim-scripts/Mark--Karkat'

" Allow opening a file to a specific line with 'file:line'
Plugin 'bogado/file-line'

" Easy access to an undo tree.
Plugin 'mbbill/undotree'

" Quickly move around.
Plugin 'Lokaltog/vim-easymotion'
let g:EasyMotion_leader_key = ','
let g:EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

Plugin 'arames/vim-diffgofile'
let g:diffgofile_goto_existing_buffer = 1
autocmd FileType diff nnoremap <buffer> <C-]> :call DiffGoFile('n')<CR>
autocmd FileType diff nnoremap <buffer> <C-v><C-]> :call DiffGoFile('v')<CR>
autocmd FileType git nnoremap <buffer> <C-]> :call DiffGoFile('n')<CR>
autocmd FileType git nnoremap <buffer> <C-v><C-]> :call DiffGoFile('v')<CR>

" Git integration.
Plugin 'tpope/vim-fugitive'
" Display lines git diff status when editing a file in a git repository.
Plugin 'airblade/vim-gitgutter'

" Switch between header and implementation files.
Plugin 'vim-scripts/a.vim'
nnoremap <leader>hh :A<CR>

" Languages syntax.
Plugin 'dart-lang/dart-vim-plugin'
Plugin 'plasticboy/vim-markdown'
Plugin 'hynek/vim-python-pep8-indent'

" Personal wiki
Plugin 'vim-scripts/vimwiki'
" Use the markdown syntax
let g:vimwiki_list = [{'path': '~/repos/vimwiki/',
                     \ 'syntax': 'markdown', 'ext': '.md'}]

" Quick file find and open.
" See `:help command-t` for details and installation instructions.
Plugin 'wincent/Command-T'
nnoremap <silent> sp :sp<CR>:CommandT<CR>
nnoremap <silent> vsp :vsplit<CR>:CommandT<CR>
let g:CommandTMaxHeight=10
let g:CommandTMatchWindowReverse=1

if has('python')
  Plugin 'Valloric/YouCompleteMe'
  " A few YCM configuration files are whitelisted in `~/.vim.ycm_whitelist`. For
  " others, ask for confirmation before loading.
  let g:ycm_confirm_extra_conf = 1
  if filereadable(resolve(expand("~/.vim.ycm_whitelist")))
    " This file should look something like:
    "   let g:ycm_extra_conf_globlist = ['path/to/project_1/*', 'path/to/project_2/*' ]
    source ~/.vim.ycm_whitelist
  endif
  nnoremap <F12> :silent YcmForceCompileAndDiagnostics<CR>
  nnoremap ]] :lnext<CR>
  nnoremap [[ :lprevious<CR>
  " Don't use <Tab>. <C-n> and <C-p> are better, and we use tabs in vim-sem-tabs.
  let g:ycm_key_list_select_completion = ['<Down>']
  let g:ycm_key_list_previous_completion = ['<Up>']
endif

" Unused plugins ===================={{3

"" Easy alignment.
"Plugin 'junegunn/vim-easy-align'
"vmap <Enter> <Plug>(EasyAlign)

""Plugin 'Rip-Rip/clang_complete'
""let g:clang_library_path='/usr/lib/llvm-3.2/lib/'
"
""" Asynchronous commands
""Plugin 'tpope/vim-dispatch'
""Plugin 'vim-scripts/Align'
""" Need to work out how to get it working for more complex projects.
"""Plugin 'scrooloose/syntastic'


" Vundle configuration end ============================={{{2
call vundle#end()
filetype plugin indent on


" Presentation ============================================================={{{1

" Uncommenting this will allow specifying 24bit colors. The very simple color
" scheme used does not need this.
"if has('nvim')
"  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
"endif

if !has('nvim')
  " neovim looks at the environment variable `$TERM`, which is expected to
  " contain `256color`.
  set t_Co=256                  " 256 colors.
endif
syntax on                       " Enable syntax highlighting.
colorscheme quiet
set ruler                       " Show the cursor position all the time.
set winminheight=0              " Minimum size of splits is 0.
set nowrap                      " Do not wrap lines.
set scrolloff=5                 " Show at least 5 lines around the cursor.
set noerrorbells                " No bells.
"let &sbr = nr2char(8618).' '    " Show ↪ at the beginning of wrapped lines.

set number                      " Display line numbers.
" Display relative line numbers in normal mode and absolute line numbers
" in insert mode.
set relativenumber              " Display relative line numbers.
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber
" Always display absolute line numbers in the quick-fix windows for easy
" 'cc <n>' commands.
autocmd BufRead * if &ft == "qf" | setlocal norelativenumber | endif



" Custom color groups =================================={{{2
highlight MessageWarning ctermbg=88 guibg=#902020
highlight MessageDone    ctermbg=22

" Editing =================================================================={{{1

set backspace=indent,eol,start   " Backspacing over everything in insert mode.
set hlsearch                     " Highlight the last used search pattern.
set showmatch                    " Briefly display matching bracket.
set matchtime=5                  " Time (*0.1s) to show matching bracket.
set incsearch                    " Perform incremental searching.
set tags=.tags

" Turn off last search highlighting
nmap <Space> :nohlsearch<CR>

" Move between splits.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


" Easy bracketing in visual mode.
" Take care of saving the unnamed register.
vnoremap <leader>(  :<C-u>let@z=@"<CR>gvs()<Esc>P<Right>%:<C-u>let@"=@z<CR>
vnoremap <leader>[  :<C-u>let@z=@"<CR>gvs[]<Esc>P<Right>%:<C-u>let@"=@z<CR>
vnoremap <leader>{  :<C-u>let@z=@"<CR>gvs{}<Esc>P<Right>%:<C-u>let@"=@z<CR>
xnoremap <leader>'  :<C-u>let@z=@"<CR>gvs''<Esc>P<Right>%:<C-u>let@"=@z<CR>
xnoremap <leader>"  :<C-u>let@z=@"<CR>gvs""<Esc>P<Right>%:<C-u>let@"=@z<CR>
xnoremap <leader>`  :<C-u>let@z=@"<CR>gvs``<Esc>P<Right>%:<C-u>let@"=@z<CR>

" Completion ==========================================={{{2
" Display a menu, insert the longest common prefix but don't select the first
" entry, and display some additional information if available.
set completeopt=menu,longest,preview

" Grep/tags ============================================{{{2

" Grep in current directory.
set grepprg=grep\ -RHIn\ --exclude=\".tags\"\ --exclude-dir=\".svn\"\ --exclude-dir=\".git\"
" Grep for the word under the cursor or the selected text.
nnoremap <F8> :Grep "<C-r><C-w>" .<CR>
nnoremap <F7> :Grep "<C-r><C-w>" %:p:h<CR>
nnoremap <leader>grep :Grep "<C-r><C-w>" .<CR>
vnoremap <leader>grep "zy:<C-u>Grep "<C-r>z" .<CR>
" The extended versions cause vim to wait for a further key.
" If the wait is too long press space!
nnoremap <leader>grep<Space> :Grep "<C-r><C-w>" .<CR>
vnoremap <leader>grep<Space> "zy:<C-u>Grep "<C-r>z" .<CR>
" Grep for text with word boundaries.
nnoremap <leader>grepw :Grep "\\<<C-r><C-w>\\>" .<CR>
vnoremap <leader>grepw "zy:<C-u>Grep "\\<<C-r>z\\>" .<CR>

" Background grep
let g:BgGrep_res = '/tmp/vim.grep.res'
let s:BgGrep_command = 'silent !' . &grepprg
command! -nargs=* -complete=dir Grep call Async(s:BgGrep_command, 'BgGrepStart()', 'BgGrepDone()', g:BgGrep_res, <f-args>)
function! BgGrepStart()
  echohl MessageWarning | echo 'Running background grep...' | echohl None
endfunction
function! BgGrepDone()
  exec('cgetfile' . g:BgGrep_res)
  echohl MessageDone | echo "Background grep done." | echohl None
endfunction

let g:Jrep_res = '/tmp/vim.jrep.res'
let s:Jrep_command = '!jrep -RHn'
command! -nargs=* -complete=dir Jrep call JrepFunction(<f-args>)
function! JrepFunction(...)
  exec(s:Jrep_command. ' ' . join(a:000, ' ') . ' &> ' . g:Jrep_res)
  exec('cgetfile' . g:Jrep_res)
endfunction

" Update tags file.
" --c-kind=+p considers function definitions.
" --fields=+S registers signature of functions.
let s:TagsUpdate_command = 'silent !ctags -o .tags --recurse --c-kinds=+p --c++-kinds=+p --fields=+iaS --extra=+q'
function! TagsUpdateStart()
  echohl MessageWarning | echo "Building tags..." | echohl None
endfunction
function! TagsUpdateDone()
  echohl MessageDone | echo "Done building tags." | echohl None
endfunction
command! -nargs=* -complete=dir TagsUpdate call Async(s:TagsUpdate_command, 'TagsUpdateStart()', 'TagsUpdateDone()', '/dev/null', <f-args>)

"" Create custom syntax file based on tags.
"" See :help tag-highlight.
"command! TagsSyntax !ctags -R --c-kinds=gstu --c++-kinds=+c -o- | awk 'BEGIN{printf("syntax keyword Type ")}{printf("\%s ", $1)}END{print "\n"}' > .tags.vim;
"" Process all tags related commands.
"command! Tags exe 'TagsUpdate' | exe 'TagsSyntax' | source .tags.vim
""TODO: Add highlighting for other kinds of tags.

" Opens the definition in a vertical split.
" <C-w><C-]> is the default for the same in a horizontal split.
map <C-]>       :exec("tjump "  . expand("<cword>"))<CR>
map <C-w><C-]>  :exec("stjump " . expand("<cword>"))<CR>
map <C-v><C-]>  :vsp <CR>:exec("tjump ".expand("<cword>"))<CR>

" Indentation =========================================={{{2

set textwidth=80

" Automatically strip the comment marker when joining automated lines.
set formatoptions+=j
" Recognize numbered lists and indent them nicely.
set formatoptions+=n

command IndentDefault     set noexpandtab shiftwidth=8 tabstop=8 cinoptions=(0,w1,i4,W4,l1,g1,h1,N-s,t0,+4
command IndentGoogle      set   expandtab shiftwidth=2 tabstop=2 cinoptions=(0,w1,i4,W4,l1,g1,h1,N-s,t0,+4
command IndentLinuxKernel set noexpandtab shiftwidth=8 tabstop=8 cinoptions=(0,w1,i4,W4,l1,g1,h1,N-s,t0,:0,+4

IndentDefault


""  Show indentation guides.
"set list listchars=tab:\.\

" Misc commands ========================================{{{2

" Insert current date.
imap <leader>date <C-R>=strftime('%Y-%m-%d')<CR>
nmap <leader>date i<C-R>=strftime('%Y-%m-%d')<CR><Esc>

" Spread parenthesis enclosed arguments, one on each line.
map <F9> vi(:s/,\s*\([^$]\)/,\r\1/g<CR>vi(=f(%l

" Easy paste of the search pattern without word boundaries.
imap <C-e>/ <C-r>/<Esc>:let @z=@/<CR>`[v`]:<C-u>s/\%V\\<\\|\\>//g<CR>:let @/=@z<CR>a

" Automatically close the pop-up windown on move.
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Background compilation ==================================================={{{1
let g:BgCompilation_res = '/tmp/vim.compilation.res'
let s:BgCompilation_command = 'silent !' . &makeprg
command! -nargs=* -complete=dir Make call Async(s:BgCompilation_command, 'BgCompilationStart()', 'BgCompilationDone()', g:BgCompilation_res, <f-args>)
function! BgCompilationStart()
  echohl MessageWarning | echo 'Running background compilation...' | echohl None
endfunction
function! BgCompilationDone()
  exec('cgetfile' . g:BgCompilation_res)
  echohl MessageDone | echo "Background compilation done." | echohl None
endfunction


" Command line ============================================================={{{1

" Pressing shift-; takes too much time!
noremap ; :
" But the ';' key to re-execute the latest find command is useful
noremap - ;
noremap _ ,

" %% expands to the path of the current file.
cabbr <expr> %% expand('%:p:h')

" Easy quote of the searched pattern in command line.
cmap <C-e>/ "<C-r>/"

" Moving around maps

" Make <C-N> and <C-P> take the beginning of the line into account.
cmap <C-n> <Down>
cmap <C-p> <Up>

" Remap keys to move like in edit mode.
cnoremap <C-j> <C-N>
cnoremap <C-k> <C-P>
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
cnoremap <C-b> <C-Left>
cnoremap <C-w> <C-Right>
cnoremap <C-x> <Del>


command! NukeTrailingWhitespace :%s/\s\+$//e
" We could automatcially delete trailing whitespace upon save with
"   autocmd BufWritePre * :%s/\s\+$//e
" However this becomes annoying when dealing with dirty external projects, when
" the deletions make it into patches.


" Projects ================================================================={{{1

augroup ART
  autocmd BufRead,BufEnter */art/* IndentGoogle
  autocmd BufRead,BufEnter */art/* exec "set tags+=" . substitute(system('git rev-parse --show-toplevel'), '\n', '', 'g') . "/.tags"
augroup END

augroup VIXL
  autocmd BufRead,BufEnter */vixl/* IndentGoogle
augroup END

"" Linux Kernel style.
"augroup LinuxKernel
"  autocmd BufRead,BufEnter /work/linux/* IndentLinuxKernel
"augroup END
"augroup KernelGit
"  autocmd BufRead,BufEnter /work/linux/git/* set tags+=/work/linux/git/.tags
"augroup END


" Misc ====================================================================={{{1

autocmd BufEnter SConstruct setf python

map <F8> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" The following allows using mappings with the 'alt' key in terminals using the
" ESC prefix (including gnome terminal). Unluckily this does not always play
" well with macros.
" The info was found at:
"   http://stackoverflow.com/questions/6778961/alt-key-shortcuts-not-working-on-gnome-terminal-with-vim
"let c='a'
"while c <= 'z'
"  exec "set <A-".c.">=\e".c
"  exec "imap \e".c." <A-".c.">"
"  let c = nr2char(1+char2nr(c))
"endw
"set timeout ttimeoutlen=50



" .vimrc specific options =================================================={{{1
" vim: set foldmethod=marker:
" nvim: set foldmethod=marker:
