"/--------------------------------------------------------------------------------
" vimrc
"--------------------------------------------------------------------------------/
let g:vimrc_loaded_state = "start"

set nocompatible

execute pathogen#infect()
execute pathogen#helptags()
function! PluginEnabled(plugin_name)
    let l:path = expand("~")."/.vim/bundle/".a:plugin_name
    return filereadable(l:path) || isdirectory(l:path)
endfunction

" Colors and syntax highlighting
"    set colorscheme ...
"    ...
"<<<
colorscheme solarized
set background=dark
hi LineNr ctermbg=None
"hi Normal ctermfg=White
"hi Comment ctermfg=Blue
set enc=utf8
set fillchars=eob:\ ,vert:\│,stl:⎯,stlnc:⎯
set signcolumn=auto
hi SignColumn ctermbg=none
" todo: Find a good unintrusive styling for thgis line.
hi debugPC ctermbg=none
">>>

augroup filetype_qf
    autocmd!
    autocmd Filetype qf nnoremap <buffer> <C-t> <C-w><cr><C-w>T
augroup END

" Yank file path and line number.
function! YankFilePath()
    let @" = expand("%:p")." ".line(".")."\n"
endfunction
" Yank file path and line number to the system clipboard, in gdb breakpoint syntax.
function! YankBreakPoint()
    let l:bp = "break ".expand("%:p").":".line(".")."\n"
    call system("echo ".shellescape(l:bp)." | xclip")
endfunction
" Also yank the word under the cursor, with the register formatted like
" function
"   /file/with/function.cpp 2033
function! YankWordAndFilePath()
    let l:tmp = @"
    normal! yiw
    let l:word = @"
    let @" = l:tmp

    let @" = "    ".l:word."\n".expand("%:p")." ".line(".")."\n"
endfunction
function! YankSelectionAndFilePath()
    let @" = "    ".@*."\n".expand("%:p")." ".line(".")."\n"
endfunction
nnoremap .cp :call YankFilePath()<cr>
nnoremap .CP :call YankWordAndFilePath()<cr>
vnoremap .cp :call YankSelectionAndFilePath()<cr>
nnoremap .cb :call YankBreakPoint()<cr>

" Settings
"    syntax on
"    ...
"<<<
syntax on
set path=.,,
filetype indent on
filetype plugin on
" Allow modified buffers to be hidden.
set hidden
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
" help :!
"    On Unix the command normally runs in a non-interactive
"    shell.  If you want an interactive shell to be used
"    (to use aliases) set 'shellcmdflag' to "-ic".
" Reason not to do this: aliases should be for interactive mode anyway, e.g.
" passing highlighting flags. There are other downsides to using more general aliases
" in non-interactive mode, e.g., doesn't work in xargs. So prefer wrapper exec
" scripts to aliases for non-interactive mode work.
"set shellcmdflag=-ic
"

"set autochdir
set foldmethod=marker
set foldmarker=<<<,>>>
" set cursorline
set nonumber
set nuw=5
set noswapfile
set mouse=a
" Disable splash
set shm+=I
set ignorecase
set smartcase
"Buggy? started not working, hiding even with > 1 tab page. todo
"set showtabline=1
set splitright
" Don't resize splits when closing a window.
set noequalalways
" COLUMNS=120 man
" This is a script as I cannot figure out the right syntax, or if vim would
" accept a form which allows environment variable setting.
"TODO: Get this to work also with vim :help.
"set keywordprg=man_120_columns
set keywordprg=
" Press enter after executing external keywordprg pages.
nnoremap K K<cr>
vnoremap K K<cr>
" H and L are useful in their default mappings, but I am very used to H and L
" for ^ and $. So <M-H> and <M-L> are the originals.
nnoremap <M-H> H
nnoremap <M-L> L
" Define M this way too for consistency.
nnoremap <M-M> M

" Project browser.
function! ProjectBrowser()
    NERDTree
endfunction
function! ToggleProjectBrowser()
    NERDTreeToggle
endfunction
nnoremap <silent> <M-a> :call ProjectBrowser()<cr>
nnoremap <silent> <M-A> :call ToggleProjectBrowser()<cr>

" Tab line
" :help tabline
" :help setting-tabline
set showtabline=2
set tabline=%!TabLine()
function! TabLine()
    let s = ''
    for i in range(1, tabpagenr('$'))
        " set the tab page number (for mouse clicks)
        let s ..= '%' .. i .. 'T'

        let tab_tag = gettabvar(i, "tab_tag", "")
        let tab_label = TabLabel(i)
        if !empty(tab_tag)
            if i == tabpagenr()
                let s ..= '%#TabLineTagSel#'
            else
                let s ..= '%#TabLineTag#'
            endif
            let s ..= ' '
            let s ..= tab_tag
        endif

        if i == tabpagenr()
            let s ..= '%#TabLineSel#'
        else
            let s ..= '%#TabLine#'
        endif

        if empty(tab_tag)
            let s ..= ' '
        elseif !empty(tab_label)
            let s ..= ':'
        endif
        let s ..= tab_label
        let s ..= ' '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s ..= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    " if tabpagenr('$') > 1
    "     let s ..= '%=%#TabLine#%999Xclose'
    " endif

    return s
endfunction

command! -nargs=1 TabTag let t:tab_tag = <q-args>

function! TabLabel(tabnr)
    function! TryIgnoreBuffer(buf)
        let buf_type = getbufvar(a:buf, "&buftype", "")
        if index(["quickfix", "help", "terminal", "nofile", "prompt", "popup"], buf_type) >= 0
            return 1
        endif
        return 0
    endfunction

    let buflist = tabpagebuflist(a:tabnr)
    let winnr = tabpagewinnr(a:tabnr)
    let l:buf = -1
    if TryIgnoreBuffer(buflist[winnr - 1])
        " Should try to not displayed focused window, as it is an ignored
        " buffer type.
        " Look for representative window.
        for alt_buf in buflist
            if !TryIgnoreBuffer(alt_buf)
                let l:buf = alt_buf
                break
            endif
        endfor
    endif
    if l:buf == -1
        " Focused window will be displayed.
        let l:buf = buflist[winnr - 1]
    endif
    let buf_info = l:buf->getbufinfo()
    let buf_type = getbufvar(l:buf, "&buftype", "")

    let buf_name = bufname(l:buf)
    if buf_name == ""
        let buf_basename = "*empty*"
    else
        let buf_basename = split(buf_name, '/')[-1]
    endif

    if buf_type ==# "terminal"
        if getbufvar(l:buf, "is_primary_terminal", 0) == 1
            " Don't label the primary shell.
            " That will be tagged with shell details (e.g. the cwd, etc.)
            " anyway.
            let str = ""
        else
            let l:job = buf->term_getjob()
            if l:job == v:null
                let str = "[no-job-found terminal]"
            else
                let l:job_info = job->job_info()

                let cmd = get(l:job_info, "cmd")
                if len(cmd) == 0
                    let str = "[empty terminal]"
                else
                    let str = cmd[0]
                endif
            endif
        endif
    elseif buf_type ==# "help"
        let str = "[help ".buf_basename."]"
    elseif buf_type ==# "quickfix"
        let str = "[qf ".buf_basename."]"
    else
        let str = buf_basename
    endif

    return str
endfunction
highlight clear TabLine
highlight clear TabLineSel
highlight clear TabLineFill
highlight TabLine cterm=underline ctermfg=white ctermbg=black
highlight TabLineSel cterm=underline ctermfg=black ctermbg=white
highlight TabLineFill cterm=underline ctermfg=white ctermbg=black
" custom
highlight TabLineTag cterm=underline ctermfg=blue ctermbg=black
highlight TabLineTagSel cterm=underline ctermfg=darkblue ctermbg=white

" Nice to have center-scroll when going to end of file.
function! EndOfFileNavigate()
    if line('.') == line('$')
        " Already at the end. Go to insert new line.
        " This means GG will always start inserting.
        normal! o
        startinsert
    else
        " Scroll to bottom of file, and center view.
        normal! Gzz
    endif
endfunction
nnoremap <silent> G :call EndOfFileNavigate()<cr>

" Alt key mappings
" If terminal is sending modifiers as esc-key.
" For some reason, the below works!
" TODO: Do this without autocmds, setlocal not working?
let g:alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-,.\\-"
function! ResetAltKeyMappings()
    call system("echo reset >> /tmp/vimlog")
    for char in g:alphabet
        execute "set <M-".char.">=\e".char
    endfor
endfunction
function! UnsetAltKeyMappings()
    call system("echo unset >> /tmp/vimlog")
    for char in g:alphabet
        execute "set <M-".char.">="
    endfor
    " OVERRIDE
    " Allow these to act normally as they are detected in terminal mode.
    " Allow universal navigation modifier <M-w>.
    execute "set <M-w>=\ew"
    " Allow escape
    execute "set <M-j>=\ej"
    execute "set <M-k>=\ek"
    " Allow tab switching
    execute "set <M-1>=\e1"
    execute "set <M-2>=\e2"
    execute "set <M-3>=\e3"
    execute "set <M-4>=\e4"
    execute "set <M-5>=\e5"
    execute "set <M-6>=\e6"
    execute "set <M-7>=\e7"
    execute "set <M-8>=\e8"
    execute "set <M-9>=\e9"
    " Allow navigation
    execute "set <M-H>=\eH"
    execute "set <M-J>=\eJ"
    execute "set <M-K>=\eK"
    execute "set <M-L>=\eL"
    " Allow system paste.
    execute "set <M-p>=\ep"
endfunction
autocmd ModeChanged *:t* silent! call UnsetAltKeyMappings()
autocmd ModeChanged t*:* silent! call ResetAltKeyMappings()

">>>

" Basic mappings
"    inoremap jk <esc>
"    ...
"<<<
inoremap jk <esc>
let mapleader = "."
nnoremap Q @q
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $
onoremap H ^
onoremap L $
nnoremap .sv :source ~/.vimrc<cr>
inoremap <tab> <space><space><space><space>
nnoremap j gj
nnoremap k gk
nnoremap gj gT
nnoremap gk gt
" Source selection
vnoremap <leader>S :<C-u>@*<cr>
" Write
nnoremap <M-s> :w<cr>
inoremap <M-s> <Esc>:w<cr>
" Navigate windows
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
" Use shift when in job mode.
" M-h,j,k,l are useful for bash prompt mappings,
" and M-H,J,K,L are less likely to be used by terminal programs.
tnoremap <M-H> <C-w>h
tnoremap <M-J> <C-w>j
tnoremap <M-K> <C-w>k
tnoremap <M-L> <C-w>l
" Close window
nnoremap <silent> <M-w><M-x> :quit<cr>
nnoremap <silent> <M-x> :quit<cr>
tnoremap <silent> <M-w><M-x> :quit<cr>
" Close tab
nnoremap <silent> <M-w><M-X> :tabclose<cr>
nnoremap <silent> <M-X> :tabclose<cr>
tnoremap <silent> <M-w><M-X> :tabclose<cr>
" Quick new empty tab.
nnoremap <silent> <M-w><M-n> :tabnew<cr>
tnoremap <silent> <M-w><M-n> :tabnew<cr>
" Copy file path
nnoremap .cp :let @" = expand("%:p")<cr>
" Copy file directory
nnoremap .cd :let @" = expand("%:p:h")<cr>
" Move to first tab.
nnoremap .q :tabm 0<cr>
" Move tab left and right.
nnoremap <silent> <M-w><M-.> :tabm +1<cr>
nnoremap <silent> <M-w><M-,> :tabm -1<cr>
" todo: Shouldn't leave the terminal tab entered in command mode.
tnoremap <silent> <M-w><M-.>. <C-\><C-n>:tabm +1<cr>
tnoremap <silent> <M-w><M-,> <C-\><C-n>:tabm -1<cr>
" emacs-style keybindings.
" C-u by default kills to start of a line restricted to the insert region.
" Preferring emacs logic (kill to start of line, regardless of insert region).
function! EmacsKillToStartOfLine()
    if col(".") >= col("$") - 1
        " At the end of line, kill the whole line.
        normal! "_cc
    else
        " Kill to the start of line.
        " This does not include the character the cursor is on.
        normal! l"_d0
    endif
    startinsert
endfunction
inoremap <silent> <C-u> <Esc>:call EmacsKillToStartOfLine()<cr>
function! EmacsKillToEndOfLine()
    if col(".") == 1
        " At the start of line, kill the whole line.
        normal! "_cc
    else
        " Kill to the end of line.
        " This does not include the character the cursor is on.
        normal! l"_d$
    endif
    startinsert
endfunction
inoremap <silent> <C-k> <Esc>:call EmacsKillToEndOfLine()<cr>
" Add newline above.
"For mapping Shift-Enter, see
"https://stackoverflow.com/questions/16359878/how-to-map-shift-enter
"todo: Not working
"inoremap <M-O> <Esc>O
"inoremap <M-o> <Esc>o

function! ToggleFullscreen()
    if get(w:, 'is_fullscreen', 0) == 1
        let l:line = line(".")
        let l:col = col(".")
        let l:topline = winsaveview().topline
        let l:old_winid = w:is_fullscreen_old_winid
        tabclose
        call win_gotoid(l:old_winid)
        call cursor(l:topline, 1)
        normal! zt
        call cursor(l:line, l:col)
        set showtabline=1
    else
        let l:line = line(".")
        let l:col = col(".")
        let l:topline = winsaveview().topline
        let l:old_winid = win_getid()
        " Open in a new tab. This doesn't close the window.
        tabedit %
        call cursor(l:topline, 1)
        normal! zt
        call cursor(l:line, l:col)
        set showtabline=0
        let w:is_fullscreen = 1
        let w:is_fullscreen_old_winid = l:old_winid
    endif
endfunction
nnoremap <silent> <M-f> :call ToggleFullscreen()<cr>

let g:detail_view_active = 1
function! SetDetailView(val)
    if a:val == 1
        let g:detail_view_active = 1
        set laststatus=2
        "set statusline=%{BufferLabel(bufnr())}
        set statusline=
    elseif a:val == 0
        let g:detail_view_active = 0
        set laststatus=0
        set statusline=⎯
    endif
endfunction
call SetDetailView(g:detail_view_active)
function! ToggleDetailView()
    if g:detail_view_active == 0
        call SetDetailView(1)
    else
        call SetDetailView(0)
    endif
    call SetDetailView(g:detail_view_active)
endfunction
nnoremap <silent> <M-r> :call ToggleDetailView()<cr>
nnoremap <silent> <M-n> :set number!<cr>

" Tab metakeys.
for index in [1,2,3,4,5,6,7,8,9]
    " Go to tab
    execute "nnoremap <silent> <M-".index."> :normal! ".index."gt<cr>"
    execute "tnoremap <silent> <M-".index."> <C-\\><C-n>:normal! ".index."gt<cr>"
    " Move window to tab
    execute "nnoremap <silent> <M-w><M-".index."> :normal! ".index."gt<cr>"
    execute "tnoremap <silent> <M-w><M-".index."> <C-\\><C-n>:normal! ".index."gt<cr>"
endfor
" Move window to new tab.
function! MoveCurrentWindowToNewTab(background)
    let win_id = win_getid()
    let buf_nr = bufnr()
    let tabpage_nr = tabpagenr()
    let number_of_windows = len(get(gettabinfo(tabpage_nr)[0], 'windows'))
    execute "tab sbuf ".buf_nr
    call win_execute(win_id, "close")
    if a:background == 1
        if number_of_windows > 1
            " If there are more windows in this tab page,
            " stay in the tab page. As there was more than one window, the
            " tabpage should still be around.
            "todo: Is there a function to go to a tab? Would prefer that to
            "      normal-mode commands.
            execute "normal! ".tabpage_nr."gt"
        endif
    endif
endfunction
nnoremap <silent> <M-w><M-t> :call MoveCurrentWindowToNewTab(0)<cr>
tnoremap <silent> <M-w><M-t> <cmd>call MoveCurrentWindowToNewTab(0)<cr>
nnoremap <silent> <M-w><M-T> :call MoveCurrentWindowToNewTab(1)<cr>
tnoremap <silent> <M-w><M-T> <cmd>call MoveCurrentWindowToNewTab(1)<cr>

" Create splits
nnoremap <silent> <M-\> :vsp<cr>
nnoremap <silent> <M--> :sp<cr>

" Be careful...
" todo: Better than this. Popup, or general terminal, pager.
nnoremap .! :execute "!".getline(".")<cr>

" Scroll offset trick to make search navigation centered (auto-zz).
" https://vim.fandom.com/wiki/Make_search_results_appear_in_the_middle_of_the_screen
"todo: Disable this in non-file.
"set scrolloff=5

">>>

" Plugins
"    ...
"<<<
if PluginEnabled("vim-surround") == 1
    nmap s ys
endif

if PluginEnabled("tagbar") == 1
    nnoremap <leader>t :Tagbar<cr>
endif

"if PluginEnabled("quickpeek") == 1
let g:quickpeek_auto = 1
let g:quickpeek_popup_options = {
    \ 'border': [0,0,0,0],
    \ 'title': ''
    \ }
"let g:quickpeek_window_settings = ["wincolor=Window"]
"endif

"if PluginEnabled("tig-explorer.vim") == 1
"    let g:tig_explorer_use_builtin_term = 0
"
"    let g:tig_explorer_keymap_edit_e  = 'e'
"    let g:tig_explorer_keymap_edit    = 'e'
"    let g:tig_explorer_keymap_tabedit = 'E'
"    let g:tig_explorer_keymap_split   = '_'
"    let g:tig_explorer_keymap_vsplit  = '|'
"    
"    "let g:tig_explorer_keymap_commit_edit    = 'o'
"    "let g:tig_explorer_keymap_commit_tabedit = 'O'
"    "let g:tig_explorer_keymap_commit_split   = '<C-_>'
"    "let g:tig_explorer_keymap_commit_vsplit  = '<C-o>'
"
"    nnoremap <M-p> :Tig<cr>
"    nnoremap <M-o> :TigOpenCurrentFile<cr>
"    nnoremap .bl :TigBlame<cr>
"endif

if PluginEnabled("vim-gitgutter") == 1
    let g:gitgutter_enabled = 0
    let g:gitgutter_preview_win_floating = 0

    nnoremap <space>p :GitGutterToggle<cr>
    nnoremap <space>P :GitGutterPreviewHunk<cr>

    function! RefreshGitGutter()
        if g:gitgutter_enabled == 1
            GitGutterAll
        endif
    endfunction
    augroup GitGutterAuGroup
        autocmd!
        autocmd BufWritePost * :call RefreshGitGutter()
    augroup END
endif

if PluginEnabled("vim-lsp") == 1
    let g:lsp_diagnostics_enabled = 0
    let g:lsp_document_highlight_enabled = 0

    if executable('ccls')
        " Register ccls C++ lanuage server.
       au User lsp_setup call lsp#register_server({
          \ 'name': 'ccls',
          \ 'cmd': {server_info->['ccls']},
          \ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'compile_commands.json'))},
          \ 'initialization_options': {'cache': {'directory': expand('~/.cache/ccls') }},
          \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
          \ })
    endif

    nnoremap <space>d :LspDefinition<cr>
    nnoremap <space>D :LspDeclaration<cr>
    nnoremap <space>r :LspReferences<cr>
    nnoremap <space>t :LspTypeDefinition<cr>
endif

if PluginEnabled("targets") == 1
    " Documentation:
    " https://github.com/wellle/targets.vim

    " If enabled (set to 1) , both growing and seeking will work on the
    " largest available count if a too large count is given. 
    let g:targets_gracious = 1

    " Default: 'aiAI'
    let g:targets_aiAI = 'aiAI'

    " Default: 'nl'
    " nN seems more in line with forward/backward keys (e.g. search).
    " Also 'l' feels like hjkl's 'go to right' but 'last' should 'go to left',
    " so that is a bit non-mnemonic.
    let g:targets_nl = 'nN'
endif

">>>


" Cursor styles
"    ...
"<<<
" Change between cursor modes.
" https://vi.stackexchange.com/questions/7306/vim-normal-and-insert-mode-cursor-not-changing-in-gnu-screen
" if &term =~ "screen."
"     let &t_ti.="\eP\e[1 q\e\\"
"     let &t_SI.="\eP\e[5 q\e\\"
"     let &t_EI.="\eP\e[1 q\e\\"
"     let &t_te.="\eP\e[0 q\e\\"
" else
"     let &t_ti.="\<Esc>[1 q"
"     let &t_SI.="\<Esc>[5 q"
"     let &t_EI.="\<Esc>[1 q"
"     let &t_te.="\<Esc>[0 q"
" endif

" TODO: Reset the cursor for the correct mode when switching to vim.
" :help terminal-info
" function! ResetCursor()
"     "--- Doesn't work...
"     let l:mode = mode()
"     if l:mode == "n"
"         echo &t_EI
"     elseif l:mode == "i"
"         echo &t_SI
"     endif
" endfunction
" autocmd FocusGained * :call ResetCursor()
">>>

" Debugging
" ...
"<<<
packadd termdebug

let g:termdebug_config = {
            \ 'winbar' : 0,
            \ 'disasm_window' : 0,
            \ 'disasm_window_height' : 16,
            \ 'wide' : 32,
            \ 'use_prompt' : 0
            \ }

hi debugPC ctermbg=white
"hi SignColumn ctermbg=blue
nnoremap .T :Termdebug<cr><Esc><C-w>h<C-w>L<C-w>h<C-w>j<C-w>100-<C-w>15+<C-w>1000<<C-w>58><C-w>k
function! DoTermdebugBreakpointModify(cmd)
    execute a:cmd
    sleep 150m
    TermdebugSendCommand json_serialize_breakpoints
    sleep 150m
    call BreakpointsQuickfix()
    Source
endfunction
function! DoTermdebugCodeMove(cmd)
    execute a:cmd
    sleep 150m
    TermdebugSendCommand json_serialize_stacktrace
    sleep 150m
    call QuickfixCallstackFromGDB()
    Source
endfunction
nnoremap <space>b :call DoTermdebugBreakpointModify("Break")<cr>
nnoremap <space>B :call DoTermdebugBreakpointModify("Clear")<cr>
nnoremap <space>u :call DoTermdebugCodeMove("Until")<cr>
nnoremap <space>n :call DoTermdebugCodeMove("Over")<cr>
nnoremap <space>c :call DoTermdebugCodeMove("Continue")<cr>
nnoremap <space>s :call DoTermdebugCodeMove("Step")<cr>
nnoremap <space>f :call DoTermdebugCodeMove("Finish")<cr>
function! ToggleTermdebugAsm()
    if bufnr('Termdebug-asm-listing') == bufnr()
        close
    else
        Asm
    endif
endfunction
nnoremap <space>a :call ToggleTermdebugAsm()<cr>
function! ToggleTermdebugAsm()
    if bufnr('Termdebug-asm-listing') == bufnr()
        close
    else
        Asm
    endif
endfunction
function! SwapBetweenSourceAndGdb()
    if bufnr() == bufnr("gdb")
        Source
    else
        Gdb
    endif
endfunction
nnoremap <space>e :call SwapBetweenSourceAndGdb()<cr>

" help termdebug_shortcuts
function! GDBRelativeFrame(jump)
    call TermdebugSendCommand("__vim_write_selected_frame_number")
    " Note: Apparently there is a race condition...
    sleep 25m
    let l:frame_number = readfile("/tmp/gdb__vim_write_selected_frame_number")[0]
    call TermdebugSendCommand("select-frame ".(l:frame_number+a:jump))

    " Todo: Simplify this, don't require multiple calls.
    " -- To do this, need to query max frame number.
    call TermdebugSendCommand("__vim_write_selected_frame_number")
    sleep 25m
    let l:frame_number = readfile("/tmp/gdb__vim_write_selected_frame_number")[0]
    execute "cc ".(l:frame_number+1)

    "--------------------------------------------------------------------------------
    " pwndbg
    " call TermdebugSendCommand("context")
endfunction

nnoremap [f :call GDBRelativeFrame(-1)<cr>zz
nnoremap ]f :call GDBRelativeFrame(1)<cr>zz

function! ToggleQuickFix()
    " https://stackoverflow.com/questions/11198382/how-to-create-a-key-map-to-open-and-close-the-quickfix-window-in-vim
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        botright copen
        let l:quickfix_list_length = len(getqflist())
        let l:quickfix_window_height = min([l:quickfix_list_length, 12])
        execute "resize ".l:quickfix_window_height
    else
        cclose
    endif
endfunction
function! GoToQuickFix()
    let tabnr = tabpagenr()
    " Find quickfix in this tab.
    " (There shouldn't be more than one, but account for more than one.)
    let quickfixes = filter(getwininfo(), 'v:val.quickfix && v:val.tabnr == '.string(tabnr))
    if empty(quickfixes)
        botright copen
        let l:quickfix_list_length = len(getqflist())
        let l:quickfix_window_height = min([l:quickfix_list_length, 12])
        execute "resize ".l:quickfix_window_height
    else
        call win_gotoid(quickfixes[0].winid)
    endif
endfunction
"nnoremap <M-w><M-q> :call ToggleQuickFix()<cr>
nnoremap <M-w><M-q> :call GoToQuickFix()<cr>

" Global variable for access by quickfixtextfunc.
let g:quickfix_callstack_frame_dicts = []

function! QuickfixCallstackFromGDB()
    let l:json_file_path = $GDB_DEV."/state/stacktrace"
    try
        let l:json_string = join(readfile(l:json_file_path), "\n")
        let l:json_dict = json_decode(l:json_string)
    catch /.*/
        echoerr "Unable to decode json from file \"".l:json_file_path."\""
        return
    endtry

    " Save globally so frame information can be accessed by the quickfixtextfunc,
    " to display a custom
    let g:quickfix_callstack_frame_dicts = l:json_dict["frames"]

    let l:qflist = []
    for l:frame in l:json_dict["frames"]
        if l:frame["type"] == "Source"
            call add(l:qflist, {
                \ "filename": l:frame["filename"],
                \ "lnum": l:frame["line"]
            \ })
        elseif l:frame["type"] == "Binary"
            call add(l:qflist, {
                \ "filename": "__NO_FILENAME__",
                \ "lnum": 0
            \ })
        else
            echoerr "Unknown frame type name \"".l:frame["type"]."\" in callstack json."
            return
        endif
    endfor

    call setqflist([], ' ', {"items" : l:qflist, "quickfixtextfunc" : "QuickfixCallstackTextFunc"})

    augroup filetype_qf_statusline
        autocmd!
        autocmd Filetype qf setlocal nonumber
        autocmd Filetype qf setlocal statusline=%{QuickfixCallstackStatusLine()}
    augroup END

    cclose
    call ToggleQuickFix()
    botright copen

endfunction

function! QuickfixCallstackTextFunc(args)
    let l:start = a:args["start_idx"]
    let l:end = a:args["end_idx"]
    
    let l:lines = []
    let l:index = l:start - 1
    while l:index != l:end
        let l:frame = g:quickfix_callstack_frame_dicts[l:index]

        "Todo: Why is system() returning trailing character/s?
        let l:binary_basename = system("basename -z \"".l:frame["binary"]."\"")
        let l:binary_basename = l:binary_basename[:len(l:binary_basename)-2]

        if l:frame["type"] == "Source"

            " If the file is in a git repo, display the path relative to that
            " repo (including the repo name).
            " Todo: This isn't very robust.
            let l:git_root = system("git -C \"$(dirname ".l:frame["filename"]." 2>/dev/null)\" rev-parse --show-toplevel 2>/dev/null | tr -d '\n'")
            if v:shell_error == 0
                let l:git_root_up_one = system("realpath ".l:git_root."/..")
                let l:relative_filename = l:frame["filename"][len(l:git_root_up_one):]
            else
                let l:relative_filename = l:frame["filename"]
            endif

            let l:line = l:index."&".l:frame["function"]."&".l:binary_basename."&".l:relative_filename.":".l:frame["line"]
        elseif l:frame["type"] == "Binary"
            let l:line = l:index."&?&".l:binary_basename."&?"
        else
            " Indicate an error.
            let l:line = "ERROR: Unknown frame type name \"".l:frame["type"]."\" in callstack json."
        endif
        call add(l:lines, l:line)
        let l:index = l:index + 1
    endwhile

    " Align as a table
    let l:tmpfile = tempname()
    call writefile(l:lines, l:tmpfile)
    let l:table = systemlist("cat ".l:tmpfile." | column -t -s'&'")
    call delete(l:tmpfile)

    return l:table
endfunction

function! QuickfixCallstackStatusLine()
    return "  Callstack"
endfunction

nnoremap .1 :call QuickfixCallstackFromGDB()<cr>
nnoremap .S :call QuickfixCallstackFromGDB()<cr>


let g:gdb_breakpoint_jsons = []
function! BreakpointsQuickfixTextFunc(args)
    let l:start = a:args["start_idx"]
    let l:end = a:args["end_idx"]
    
    let l:lines = []
    let l:index = l:start - 1
    while l:index != l:end
        let l:bp = g:gdb_breakpoint_jsons[l:index]
        let l:line = ""

        let l:source_cols = ""
        if l:bp["source"] != v:null
            let l:source_cols = l:bp["source"]["file"].":".l:bp["source"]["line"]
        else
            let l:source_cols = "<unknown>"
        endif
        let l:line = l:bp["number"]."&".l:bp["expression"]."&".l:bp["symbol"]["name"]."&".l:source_cols

        call add(l:lines, l:line)
        let l:index = l:index + 1
    endwhile

    " Align as a table
    let l:tmpfile = tempname()
    call writefile(l:lines, l:tmpfile)
    let l:table = systemlist("cat ".l:tmpfile." | column -t -s'&'")
    call delete(l:tmpfile)

    return l:table
endfunction

function! BreakpointsQuickfix()
    let l:json_file_path = $GDB_DEV."/state/breakpoints"
    try
        let l:json_string = join(readfile(l:json_file_path), "\n")
        let l:breakpoints = json_decode(l:json_string)
    catch /.*/
        echoerr "Unable to decode json from file \"".l:json_file_path."\""
        return
    endtry

    " Save this globally so it can referenced in the text func (for
    " determining displays for ranges of locations).
    let g:gdb_breakpoint_jsons = []

    let l:qflist = []
    for l:bp in l:breakpoints
        for l:loc in l:bp["locations"]
            " Make overall breakpoint info available in the sub-breakpoints info.
            let l:loc["number"] = l:bp["number"]
            let l:loc["expression"] = l:bp["expression"]
            call add(g:gdb_breakpoint_jsons, l:loc)
            if l:loc["source"] != v:null
                call add(l:qflist, {
                    \ "filename": l:loc["source"]["file"],
                    \ "lnum": l:loc["source"]["line"]
                \ })
            endif
        endfor
    endfor

    call setqflist([], ' ', {"items" : l:qflist, "quickfixtextfunc" : "BreakpointsQuickfixTextFunc"})

    augroup filetype_qf_breakpoints
        autocmd!
        autocmd Filetype qf setlocal nonumber
        autocmd Filetype qf setlocal nowrap
        autocmd Filetype qf setlocal statusline=%{BreakpointsQuickfixStatusLine()}
    augroup END

    cclose
    call ToggleQuickFix()
endfunction

function! BreakpointsQuickfixStatusLine()
    return "  Breakpoints"
endfunction

function! BreakpointsQuickfixSyncGdb()
    TermdebugSendCommand json_serialize_breakpoints
    sleep 150m
    call BreakpointsQuickfix()
endfunction

nnoremap <M-d><M-B> :call BreakpointsQuickfixSyncGdb()<cr>


">>>

" Terminal
" ...
"<<<

function! VimTermDeskInit()
    call GoToPrimaryShell(0)
endfunction

function! UpdatePrimaryShell()
    let [buf, winid] = GetPrimaryShellBufferAndWindow()
    if winid != -1
        let tab = win_id2tabwin(winid)[0]
        " Tag the primary shell with the the bash prompt.
        "todo: Interpret ansi color codes.
        let tag = system("prompt | cclean")
        call settabvar(tab, "tab_tag", tag)
    endif
endfunction

function! GetPrimaryShellBufferAndWindow()
    " Returns [buf, winid]
    " If no buffer exists, buf is -1.
    " If no window exists, winid is -1.
    " This can return a valid buf but a -1 winid as it is possible
    " for there to be primary shell buffers but none of them loaded in
    " window.
    let primary_terminal_buffers = filter(getbufinfo(), 'v:val.listed && getbufvar(v:val.bufnr, "is_primary_terminal", 0) == 1')
    let buf = -1
    let winid = -1
    for bufinfo in primary_terminal_buffers
        if !empty(bufinfo.windows)
            let buf = bufinfo.bufnr
            let winid = bufinfo.windows[0]
        endif
    endfor

    if winid == -1 && !empty(primary_terminal_buffers)
        " No mapped window, return [buf, -1] where buf is the first found primary
        " shell buffer.
        let buf = primary_terminal_buffers[0].bufnr
    endif
    return [buf, winid]
endfunction

augroup PrimaryShell
    autocmd!
    autocmd DirChanged global call UpdatePrimaryShell()
augroup END

function! GoToPrimaryShell(newtab)
    let [buf, winid] = GetPrimaryShellBufferAndWindow()
    if winid != -1
        call win_gotoid(winid)
    else
        if a:newtab == 1
            tabnew
            " Avoid cluttering with empty buffers.
            set bufhidden=wipe
            tabm 0
        endif
        if buf != -1
            " Possibly a primary terminal buffer exists but isn't shown in a
            " window. Try to load this.
            execute "buffer ".buf
        else
            " Create a new primary terminal.
            let term_buf = term_start('bash', {
                \ 'term_name' : 'shell',
                \ 'curwin' : 1,
                \ 'env' : { 'TERMDESK_PRIMARY_SHELL' : '1' },
                \ 'term_finish' : 'close'
                \ })
            call setbufvar(term_buf, "is_primary_terminal", 1)
        endif
    endif

    call UpdatePrimaryShell()
endfunction

function! CtrlCHandler()
    if &buftype == "terminal"
        " Note: startinsert is ineffective in terminal mode.
        execute "normal! i"
    else
        execute "normal! <C-c>"
    endif
endfunction

tnoremap <M-j><M-k> <C-\><C-n>
tnoremap <M-w><M-w> <C-\><C-n>
tnoremap <M-w><M-j> <C-\><C-n>:normal! gT<cr>
tnoremap <M-w><M-k> <C-\><C-n>:normal! gt<cr>
nnoremap <silent> <C-c> :call CtrlCHandler()<cr>
nnoremap <M-w><M-j> gT
nnoremap <M-w><M-k> gt
" Open a terminal below.
function! LowerTerminal()
    if v:count == 0
        let height = 12
    else
        let height = v:count
    endif
    execute "set termwinsize=".string(height)."x0"
    botright terminal
    set termwinsize=0x0
endfunction
nnoremap <silent> <M-c> <cmd>call LowerTerminal()<cr>
" Open a terminal in the current window.
nnoremap <silent> <M-C> :set termwinsize=0x0 \| term ++curwin<cr>
nnoremap <silent> <M-q> :call GoToPrimaryShell(1)<cr>
">>>

" Notes system
" ...
"<<<
function! PopupTextLink(filename, line)
    if bufname() != a:filename
        execute "badd ".a:filename
    endif
    let buffer = bufnr(a:filename, 1)
    let screen_height = &lines
    let screen_width = &columns

    let follow = 0
    if follow
        let options = {
            \ 'line' : "cursor+1",
            \ 'col'  : (1*screen_width)/5,
            \ 'minheight' : 1,
            \ 'maxheight' : 15,
            \ 'minwidth' : (4*screen_width)/5 - 2,
            \ 'maxwidth' : (4*screen_width)/5 - 2,
            \ }
    else
        let options = {
            \ 'line'  : (1*screen_height)/10,
            \ 'col'  : (3*screen_width)/10,
            \ 'minheight' : (8*screen_height)/10,
            \ 'maxheight' : (8*screen_height)/10,
            \ 'minwidth' : (7*screen_width)/10 - 2,
            \ 'maxwidth' : (7*screen_width)/10 - 2,
            \ }
    endif
    call extend(options, {
        \ 'scrollbar' : 0,
        \ 'moved' : [line('.'), 0, 1000],
        \ 'title' : a:filename.", line ".a:line,
        \ 'cursorline' : 1,
        \ 'wrap' : 0,
        \ 'highlight' : 'hl-Normal',
        \ 'border' : [1,1,1,1],
        \ })
    " Copied logic from quickpeek.vim.
    " -Apparently necessary for filetype detection, not sure why.
    call timer_start(1, {-> DelayPopupTextLink(buffer, a:filename, a:line, options)})
endfunction

function! DelayPopupTextLink(buffer, filename, line_identifier, options)
    let popup_winid = popup_create(a:buffer, a:options)
    if a:line_identifier == "$"
        call win_execute(popup_winid, "normal! Gzz")
    else
        call win_execute(popup_winid, "normal! ".a:line_identifier."ggzz")
    endif
    "call win_execute(popup_winid, "set number")
    "call win_execute(popup_winid, "set relativenumber")
    call win_execute(popup_winid, "set wincolor=Window")
endfunction

function! GetNotesTextLinkUnderCursor()
    let line = getline('.')
    let parts = split(line)
    if len(parts) != 2
        return []
    endif
    if parts[1] !~# '^\d\+$' && parts[1] != "$"
        return []
    endif
    let filename = parts[0]
    let line = parts[1]

    if filename =~# "^(.*)$"
        let cmd = "ns resolve ".filename[1:-2]." ".expand("%:p")
        let filename = systemlist(cmd)[0]
        echo filename
        return []
        if v:shell_error
            echoerr "ns resolve failed"
            return []
        endif
    endif
    return [filename, line]
endfunction

function! RefreshNotesTextLink()
    " Only do this in normal mode.
    if mode() != "n"
        return
    endif

    let parts = GetNotesTextLinkUnderCursor()
    if empty(parts)
        return
    endif
    let filename = parts[0]
    let line = parts[1]
    call PopupTextLink(filename, line)
endfunction

function! NotesFollowLinkUnderCursor(tabnew)
    let parts = GetNotesTextLinkUnderCursor()
    if empty(parts)
        return
    endif
    let filename = parts[0]
    let line_identifier = parts[1]
    call system("mkdir -p $(dirname \"".filename."\")")
    if v:shell_error
        echoerr "Couldn't make a directory for the notes file."
        return
    endif

    if a:tabnew
        let cmd = "tabnew "
    else
        let cmd = "edit "
    endif
    execute cmd." ".filename
    if line_identifier == "$"
        call cursor(line("$"), 1)
    else
        call cursor(line_identifier, 1)
    endif
endfunction

let g:magic_card_was_hovering = 0
let g:is_viewing_magic_card_gallery = 0
function! RefreshMagicCardPreview()
    if g:is_viewing_magic_card_gallery
        let g:is_viewing_magic_card_gallery = 0
        return
    endif
    if g:magic_card_was_hovering
        let g:magic_card_was_hovering = 0
        call system("pgrep feh | xargs kill -9")
    endif
    if mode() != "n"
        return
    endif
    let curline = getline(".")
    if len(curline) > 2 && curline[0] == "=" && curline[1] == " "
        let card_name = curline[2:]
        let card_filename = "/home/lucas/drive/magic/images/".card_name.".jpg"
        if !filereadable(card_filename)
            echo "Magic card image not found: ".card_name
        else
            let screen_width = 2160
            let screen_height = 1350
            let width = 488
            let height = 680
            let start_x = float2nr(floor(screen_width/2.0 - width/2.0))
            let start_y = float2nr(floor(screen_height/2.0 - height/2.0))
            let cmd = "pgrep feh | xargs kill -9 ; FOCUS=$(xdotool getwindowfocus) ; feh --scale-down -g ".width."x".height."+".start_x."+".start_y." \"".card_filename."\" > /dev/null 2>&1 & sleep 0.1 ; xdotool windowfocus $FOCUS > /dev/null 2>&1"
            let g:magic_card_was_hovering = 1
            silent! call system(cmd)
            redraw!
        endif
    endif
endfunction

function! MultipleMagicCardPreviewOnSelection() range
    let startline = a:firstline
    let endline = a:lastline
    let g:startline = startline
    let g:endline = endline
    if startline > endline
        let tmp = startline
        let endline = startline
        let startline = tmp
    endif
    let i = startline
    let card_names = []
    while i <= endline
        let curline = getline(i)
        if len(curline) > 2 && curline[0] == "=" && curline[1] == " "
            call add(card_names, curline[2:])
        endif
        let i += 1
    endwhile
    if len(card_names) > 0
        let g:magic_card_was_hovering = 1
        call MultipleMagicCardPreview(card_names)
    endif
endfunction

function! MultipleMagicCardPreview(card_names)
    let card_filenames = []
    let card_filenames_argument = ""
    for card_name in a:card_names
        let card_filename = "/home/lucas/drive/magic/images/".card_name.".jpg"
        if !filereadable(card_filename)
            echo "Magic card image not found: ".card_name
            return
        endif
        call add(card_filenames, card_filename)
        let card_filenames_argument .= " \"".card_filename."\""
    endfor
    let tile_width = min([len(card_filenames), 4])
    let tile_height = (len(card_filenames)-1)/4 + 1
    let cmd = "montage -geometry +0+0 -tile ".tile_width."x".tile_height." ".card_filenames_argument." /tmp/gallery.jpg"
    silent! call system(cmd)

    " todo: Actually use monitor dimensions
    let screen_width = 2160
    let screen_height = 1350
    let max_width = 1600
    let width = tile_width * 488
    let height = tile_height * 680
    if width > max_width
        let height = float2nr(floor(height * ((1.0 * max_width) / width)))
        let width = max_width
    endif
    let max_height = screen_height
    if height > max_height
        let width = float2nr(floor(width * ((1.0 * max_height) / height)))
        let height = max_height
    endif
    let start_x = float2nr(floor(screen_width/2.0 - width/2.0))
    let start_y = float2nr(floor(screen_height/2.0 - height/2.0))
    let cmd = "pgrep feh | xargs kill -9 ; FOCUS=$(xdotool getwindowfocus) ; feh --scale-down -g ".width."x".height."+".start_x."+".start_y." /tmp/gallery.jpg & sleep 0.1 ; xdotool windowfocus $FOCUS > /dev/null 2>&1"
    let g:is_viewing_magic_card_gallery = 1
    silent! call system(cmd)
    redraw!
    "echo cmd
endfunction

augroup Notes
    autocmd!
    autocmd CursorMoved *.ns :call RefreshNotesTextLink()
    autocmd WinScrolled *.ns :call RefreshNotesTextLink()
    autocmd Filetype notes nnoremap <buffer> ./ :call NotesFollowLinkUnderCursor(0)<cr>
    autocmd Filetype notes nnoremap <buffer> <enter> :call NotesFollowLinkUnderCursor(0)<cr>
    autocmd Filetype notes nnoremap <buffer> .? :call NotesFollowLinkUnderCursor(1)<cr>
    autocmd Filetype notes nnoremap <buffer> >? :call NotesFollowLinkUnderCursor(1)<cr>
    " It is convenient to not have to have notes open on only one vim.
    " Currently want this as keep switching between screen tabs, but each vim
    " should have a notes buffer anyway. It is nice to synchronize them.
    autocmd Filetype notes set autoread

    autocmd CursorMoved *.ns :call RefreshMagicCardPreview()
    autocmd WinScrolled *.ns :call RefreshMagicCardPreview()
    autocmd ModeChanged *.ns :call RefreshMagicCardPreview()
    autocmd Filetype notes vnoremap <buffer> <silent> <space>m :call MultipleMagicCardPreviewOnSelection()<cr>
    autocmd Filetype notes nnoremap <buffer> <space>m V7j:call MultipleMagicCardPreviewOnSelection()<cr>:let g:is_viewing_magic_card_gallery=1<cr>8j
    autocmd Filetype notes nnoremap <buffer> <space>M kV7k:call MultipleMagicCardPreviewOnSelection()<cr>:let g:is_viewing_magic_card_gallery=1<cr>
augroup END

function! YankNotesTextLink()
    let ext = expand("%:p:t:e")
    if ext == "ns"
        let link = systemlist("ns link ".expand("%:p"))[0]
        if v:shell_error
            return
        endif
        let @" = "(".link.") ".line(".")."\n"
    else
        let @" = systemlist("realpath \"".expand("%")."\"")[0]." ".line(".")."\n"
    endif
endfunction

function! CycleNotesFiles(yank_from_non_notes_file=0, tabnew=0)
    "let directory = getcwd()
    let directory = readfile($VIMSERVER_ID)[0]
    let parts = split(directory, "/")
    let notes_files = []
    for i in range(len(parts))
        let filename = "/".join(parts[:i], "/")."/notes.d/notes.ns"
        if filereadable(filename)
            call add(notes_files, filename)
        endif
    endfor
    let global_notes_file = "/home/lucas/notes.d/notes.ns"
    if index(notes_files, global_notes_file) < 0
        call add(notes_files, global_notes_file)
    endif

    let current_file = expand("%:p")
    let current_file_index = index(notes_files, current_file)
    if current_file_index >= 0
        let notes_file = notes_files[(current_file_index + 1) % len(notes_files)]
    else
        if a:yank_from_non_notes_file
            call YankNotesTextLink()
        endif
        let notes_file = notes_files[-1]
    endif

    if a:tabnew
        let cmd = "tabnew"
    else
        let cmd = "edit"
    endif
    execute cmd." ".notes_file
    call cursor(line('$'), 1)
    normal! zz
endfunction

nnoremap .. :call CycleNotesFiles(1)<cr>
nnoremap .> :call CycleNotesFiles(1, 1)<cr>
nnoremap ., :call YankNotesTextLink()<cr>

function! GoToLetterboxdMovie()
    let movie_name = getline(".")
    let movie_name_modified = system("echo \"".movie_name."\" | tr ' ' '-' | tr A-Z a-z")
    let url = "https://letterboxd.com/film/".movie_name_modified
    call system("qutebrowser \"".url."\" &")
endfunction
nnoremap .<M-m> :call GoToLetterboxdMovie()<cr>
">>>

" Enable syntax highlighting for LLVM files. To use, copy
" utils/vim/syntax/llvm.vim to ~/.vim/syntax .
augroup filetype
  autocmd! BufRead,BufNewFile *.ll set filetype=llvm
augroup END

" Enable syntax highlighting for tablegen files. To use, copy
" utils/vim/syntax/tablegen.vim to ~/.vim/syntax .
augroup filetype
    autocmd! BufRead,BufNewFile *.td set filetype=tablegen
augroup END

" Code file settings.
function! CodeFileType()
    " set number
endfunction
let g:code_filetypes = [
    \ "c",
    \ "cpp",
    \ "sh",
    \ "glsl",
    \ "python",
    \ "vim",
    \ "cmake",
    \ "make",
    \ ]
augroup filetype
    execute "autocmd! FileType ".join(g:code_filetypes, ",")." call CodeFileType()"
augroup END

" guifg trick to prevent vim from inserting ^^^ if stl/stlnc fillchars are
" the same, see https://vi.stackexchange.com/questions/15873/carets-in-status-line
hi StatusLine term=NONE cterm=NONE ctermfg=white ctermbg=black guibg=red
hi StatusLineNC term=NONE cterm=NONE ctermfg=white ctermbg=black guibg=green
hi StatusLineTerm term=NONE cterm=NONE ctermfg=white ctermbg=black guibg=red
hi StatusLineTermNC term=NONE cterm=NONE ctermfg=white ctermbg=black guibg=green

" patch-9.0.0340
"     a2a8973e51a0052bb52e43a2b22e7ecdecc32003
"     Removes cmdheight=0.
if exists("&cmdheight") == 1
    if has("patch-9.0.0340") == 1
        set cmdheight=1
        let g:cmdheight_default=1
    else
        " Hide the command line by default.
        set cmdheight=0
        let g:cmdheight_default=0
    endif
    let g:cmdheight_expanded=3
    
    " Toggle cmdheight.
    " If cmdheight=0, the vim feature (before it was patched out) seems to
    " buggy, missing some messages. So this is useful to see them.
    function! ToggleCmdHeight()
        " Note: cmdheight is "global or local to tab page", according to :help cmdheight.
        if &cmdheight == g:cmdheight_default
            for tab in gettabinfo()
                call win_execute(get(tab, "windows")[0], "setlocal cmdheight=".g:cmdheight_expanded)
            endfor
        else
            for tab in gettabinfo()
                call win_execute(get(tab, "windows")[0], "setlocal cmdheight=".g:cmdheight_default)
            endfor
        endif
    endfunction
    nnoremap <silent> <M-w><M-c> :call ToggleCmdHeight()<cr>
    tnoremap <silent> <M-w><M-c> <C-\><C-n>:call ToggleCmdHeight()<cr>
endif

set wincolor=Window
hi clear Window
hi clear Normal
"hi Window ctermbg=0 ctermfg=white
hi Window ctermbg=0 ctermfg=white
"hi Normal ctermbg=white ctermfg=darkgrey
hi Normal ctermbg=black ctermfg=white

function! TerminalWinOpenCommands()
    set wincolor=Window
    setlocal scrolloff=0
endfunction
augroup TerminalWinOpen_augroup
    autocmd!
    autocmd TerminalWinOpen * call TerminalWinOpenCommands()
augroup END

hi clear VertSplit
hi VertSplit ctermbg=0 ctermfg=darkgrey

" register "+ paste
" paste on new line
function! SystemPasteLine()
    let curline = getline(".")
    if curline =~ '^\_s*$'
        " If the cursor is on a line containing only whitespace,
        " overwrite it. This seems to be intuitive with using paste for e.g.
        " taking notes. Tend to create newlines once finished writing a
        " section, to put cursor at the starting point of a new section.
        normal! V"+p$
    else
        normal! o
        normal! "+p
    endif
endfunction
nnoremap <silent> <M-p> :call SystemPasteLine()<cr>
" wipe the selection's lines then paste a line.
" Note that this doesn't care about column-level selection precision, it just
" wipes all of the lines which the selection spans.
" Select the line at the end so the '< and '> marks are intuitively reset to
" the 'collapsed' selection.
vnoremap <silent> <M-p> <C-c>'<V'>"_c<Esc>:call SystemPasteLine()<cr>V<Esc>
" paste in terminal job mode
tnoremap <silent> <M-p> <C-w>"+
" paste at cursor
nnoremap <silent> <M-P> "+p
" register "+ yank
"------todo: Apparently doesn't allow <M-y>... to be mapped. Thought this would work.
"nnoremap <silent> <M-y> "+y
" yank line. So don't have to do <M-y>y, can keep holding Alt.
nnoremap <silent> <M-y><M-y> :let @+ = getline(".")<cr>
" yank selection
vnoremap <M-y> "+y
" yank full file path
nnoremap <silent> <M-y><M-p> :let @+ = expand("%:p")<cr>

" <M-v>: Prefix for execution commands.
" execute vimscript line
nnoremap <M-v><M-v> :<C-u>.source<cr>
vnoremap <M-v><M-v> :source<cr>

" Source the syncer'd mappings.
source $CONFIG_DIR/scripts/syncer_files/syncer-vim.vim

" Vim state
" function! GetVimState()
"     for buf_info in getbufinfo()
"         getbufvar(get(buf_info, "bufnr"), 
"     endfor
" endfunction

" jump list
" center cursor after jumping
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

" Select the last inserted text.
"todo: Seems to not be accurate.
"Also, maybe trimming whitespace would be intuitive.
nnoremap <M-v><M-i> `[v`]

" VimTerminalEditor
" Called remotely by the vim-terminal-editor script which can be assigned as
" the EDITOR/VISUAL/GIT_EDITOR, etc.
function! VimTerminalEditor(filename, requesting_pid)
    execute "tabnew ".a:filename
    let b:is_vim_terminal_editor = 1
    " Pass this onto the buffer so it can use it on autocmd.
    " todo: Can autocmds easily contain evaluating expressions at definition time?
    let b:vim_terminal_editor_requesting_pid = a:requesting_pid
    augroup VimTerminalEditor
        autocmd!
        " Saving finishes the edit.
        autocmd BufWritePre,BufWinLeave,WinClosed *
                  \   if get(b:, 'is_vim_terminal_editor', 0) == 1
                  \ |     write
                  \ |     call system("kill -SIGUSR1 ".b:vim_terminal_editor_requesting_pid)
                  \ |     quit!
                  \ | endif
    augroup END
endfunction

function! QuickfixDeserialize()
endfunction

" Tags
nnoremap <C-[> <C-t>

" JSON remote procedure calls
function! VimJSONRPC(vim_function_name, json_temp_file)
    let Func = function(a:vim_function_name)
    let json_string = join(readfile(a:json_temp_file), "\n")
    let json = json_decode(json_string)
    call Func(json)
endfunction

function! QuickFixFromJSON(json)
    let qflist = []
    for entry in a:json
        call add(l:qflist, {
            \ "filename": entry["path"],
            \ "lnum": entry["line"],
            \ "col": entry["column"]
        \ })
    endfor
    let g:qflist = qflist
    call setqflist([], ' ', {"items" : qflist, "quickfixtextfunc" : ""})

    " Open the quickfix.
    call GoToQuickFix()
endfunction


augroup QFClose
  autocmd!
  autocmd WinEnter * if winnr('$') == 1 && &buftype == "quickfix" | q | endif
augroup END


let g:vimrc_loaded_state = "finished"
