" vimrc
"--------------------------------------------------------------------------------/

function! DEBUGLOG(str)
    call system("date '+%H:%M:%S ' | tr -d '\n' >> /tmp/a")
    call system("cat >> /tmp/a", a:str)
    call system("echo >> /tmp/a")
endfunction

"------------------------------------------------------------
" Load defaults.vim.
" (:help usr_05.txt)
" (:help defaults.vim)
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" option: display
" =lastline: Show @@@ rightmost, can see more of the last line versus =truncate.
set display=lastline

" option: mouse
set mouse=a

" option: incsearch?
set noincsearch

" option: termwinsize
" Default each terminal to adapt to resize to the size of its window.
set termwinsize=

" option: jumpoptions
" stack: Act like tag list.
"        e.g., the jumplist behaviour is now:
"        1 2 3 4 [5] Starting jump list of lines 1,2,3,4,5 in one file
"        1 2 3 [4] 5 <C-o>
"        1 2 [3] 4 5 <C-o>
"        1 2 3 [9]   Jump to line 9
"        (Introduced in neovim and implemented in vim 9.0.1921.)
set jumpoptions=stack
" 
augroup JumpListModifications
    autocmd!
    " Clear the jump list for a new window.
    " This makes the jump list truly window-local.
    " NOTE:
    "     I'm not sure when vim is setting the jumps, but this appears to work.
    " TODO: There is a single jump at the first position of the file for a new tab. Maybe this is fine?
    autocmd VimEnter * clearjumps
    autocmd WinNew * let w:jumplistmodifications_new_window = 1
                 \ | let w:jumplistmodifications_new_buf = 1
    autocmd WinEnter * if exists("w:jumplistmodifications_new_window")
                   \ |     clearjumps
                   \ |     unlet w:jumplistmodifications_new_window
                   \ | endif
    autocmd BufEnter * if exists("w:jumplistmodifications_new_buf")
                   \ |     clearjumps
                   \ |     unlet w:jumplistmodifications_new_buf
                   \ | endif
augroup END

" Add missing window/tab/winid API to get the buffer number from a window ID.
" To get from window and tab number, use win_getid(win, tab).
" e.g. Win_id2bufnr(win_getid(win, tab))
function! Win_id2bufnr(winid)
    let l:win = win_id2win(a:winid)
    silent! call win_execute(a:winid, "let g:tmpwinbufnr = winbufnr(".l:win.")")
    let l:buf = g:tmpwinbufnr
    unlet g:tmpwinbufnr
    return l:buf
endfunction

" Alt key mappings
" If terminal is sending modifiers as esc-key.
" For some reason, the below works!
" TODO: Do this without autocmds, setlocal not working?
let g:alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-,.\\-/?;:'"
function! ResetAltKeyMappings()
    for char in g:alphabet
        execute "set <M-".char.">=\e".char
    endfor
endfunction
function! UnsetAltKeyMappings()
    for char in g:alphabet
        execute "set <M-".char.">="
    endfor
    " OVERRIDE
    " Allow these to act normally as they are detected in terminal mode.
    " Allow universal navigation modifier <M-w>.
    execute "set <M-w>=\ew"
    execute "set <M-W>=\eW"
    " Allow escape
    "--These are useful bindings for terminal programs,
    " probably don't want to override them.
    " Just use <M-J><M-K> to escape.
    execute "set <M-j>=\ej"
    execute "set <M-k>=\ek"
    execute "set <M-l>=\el"
    execute "set <M-;>=\e;"
    " Allow escape
    execute "set <M-J>=\eJ"
    execute "set <M-K>=\eK"
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
    " Allow tab moving
    execute "set <M-.>=\e."
    execute "set <M-,>=\e,"
    " Allow system paste.
    execute "set <M-p>=\ep"
endfunction
autocmd ModeChanged *:t* silent! call UnsetAltKeyMappings()
autocmd ModeChanged t*:* silent! call ResetAltKeyMappings()
call ResetAltKeyMappings()

" Detail view
let g:detail_view_active = 0
function! SetDetailView(val)
    if a:val == 1
        let g:detail_view_active = 1
        set laststatus=2
        "set statusline=%{BufferLabel(bufnr())}
        set statusline=

        " Make tabpanel refresh detail.
        " So, I can just toggle detail view if it is out of sync,
        " without recomputing it every tabpanel draw.
        let g:tabpanel_directory_header = ""
        let g:tabpanel_current_branch = ""
        let g:tabpanel_vcs_author = ""
        let g:tabpanel_vcs_project = ""
        redrawtabpanel
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

" Make help buffers listed
autocmd FileType help setlocal buflisted

" Allow editing in block mode adding whitespace at the end of misaligned lines.
"todo: "block" doesn't work for inserts
"set virtualedit=all

" Use l; for left/right motions instead of hl.
noremap l h
noremap ; l
noremap L H
noremap : L
" Use h for : and ;.
"noremap h ;
"noremap H :
noremap H ;
noremap h :
noremap <M-h> :tab help 
" Beginning and end of line.
noremap L ^
noremap : $
" Close command prompt
cnoremap <M-H> <C-c>
" Run command
cnoremap <M-H> <cr>
" Insert mode to normal mode
inoremap <M-h> <Esc>
" Normal mode 
inoremap <M-H> <Esc>:
" Move windows
nnoremap <C-w><C-l> <C-w><C-h>
nnoremap <C-w><C-;> <C-w><C-l>
nnoremap <C-w>l <C-w>h
nnoremap <C-w>; <C-w>l
nnoremap <C-w>L <C-w>H
nnoremap <C-w>: <C-w>L

nnoremap <M-d> ddj

set textwidth=0
" change textwidth by tab, useful for formatting
" indented text with gq.
nnoremap <space>3 :let &textwidth = &textwidth - 4 \| echo &textwidth<cr>
nnoremap <space>4 :let &textwidth = &textwidth + 4 \| echo &textwidth<cr>
nnoremap <space>1 :set textwidth&<cr>
nnoremap <space>2 :set textwidth=80<cr>

set nocompatible
let g:mapleader = "<C-\>"
let g:maplocalleader = "<C-\>"

" Prevent loading of netrw.
"todo: Why is netrw sometimes appearing in terminal buffers? And how would
"this be fixed if a problem during a vim session?
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

" Pathogen
let g:pathogen_blacklist = []
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
"colorscheme solarized
colorscheme default
set background=dark
hi LineNr ctermfg=darkgrey ctermbg=None
hi QuickFixLine cterm=underline ctermfg=white ctermbg=None
" Error message highlighting.
hi ErrorMsg cterm=bold ctermfg=Red ctermbg=Black
" Selection highlighting
hi Visual cterm=underline ctermfg=NONE ctermbg=NONE
hi SignColumn ctermbg=none
" todo: Find a good unintrusive styling for this line.
hi debugPC ctermbg=none

set enc=utf8
set fillchars=eob:\ ,vert:\│,stl:⎯,stlnc:⎯
set signcolumn=auto
">>>

augroup filetype_qf
    autocmd!
    autocmd Filetype qf nnoremap <buffer> <C-t> <C-w><cr><C-w>T
augroup END

" Yank file path and line number to system clipboard.
function! YankFilePath()
    let @+ = expand("%:p")." ".line(".")."\n"
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

    let @+ = "    ".l:word."\n".expand("%:p")." ".line(".")."\n"
endfunction
function! YankSelectionAndFilePath()
endfunction
nnoremap <space>cp :call YankFilePath()<cr>
nnoremap <space>CP :call YankWordAndFilePath()<cr>
vnoremap <space>cp :call YankSelectionAndFilePath()<cr>
nnoremap <space>cb :call YankBreakPoint()<cr>

" toggle syntax highlighting
" Useful if highlighting is failing for some reason and making it hard to read.
" (as of writing, .rst in kernel docs does this)
nnoremap \s :if &syntax == "off" \| setlocal syntax=on \| else \| setlocal syntax=off \| endif<cr>

" make executable
nnoremap \x :!chmod a+x %<cr>

" System yank.
" Overrides Y default of yy synonym.
nnoremap Y "+y

"" Go to header
"function! OpenHeader()
"    "todo: these envvars should already be set in !-shell.
"    let l:header_path = "/tmp/a"
"    let l:cmd = "env VIMSERVER_ID="..$VIMSERVER_ID.." v "..l:header_path
"    echo l:cmd
"    call system(l:cmd)
"endfunction

" Settings
"    syntax on
"    ...
"<<<
"syntax on
" Syntax off, eye problems.
"todo: Would prefer to at least have the comment highlight group.
"      Perhaps rather a very muted palette with comments, and possibly keywords, a different colour.
syntax off
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
set nonumber
set nuw=5
set noswapfile
set mouse=a
" Disable splash
set shm+=I
set ignorecase
set smartcase
set splitright
" Don't resize splits when closing a window.
set noequalalways
" COLUMNS=120 man
" This is a script as I cannot figure out the right syntax, or if vim would
" accept a form which allows environment variable setting.
"TODO: Get this to work also with vim :help.
"set keywordprg=man_120_columns
"set keywordprg=
" Press enter after executing external keywordprg pages.
nnoremap K K<cr>
vnoremap K K<cr>
" Define M this way too for consistency.
nnoremap <M-m> M

" alt+search: Search for starts of lines, skipping whitespace.
" TODO: M-? doesn't work.
nnoremap <M-/> /^\s*
nnoremap <M-?> ?^\s*

" Project browser.
"function! ProjectBrowser()
"    NERDTree
"endfunction
"function! ToggleProjectBrowser()
"    NERDTreeToggle
"endfunction
"nnoremap <silent> <M-a> :call ProjectBrowser()<cr>
"nnoremap <silent> <M-A> :call ToggleProjectBrowser()<cr>

" Tab line
" :help tabline
" :help setting-tabline

let g:use_tabpanel = 1
let g:tabpanel_width = 30
function! SetTabPanelWidth(width)
    execute "set tabpanelopt=vert,columns:"..g:tabpanel_width..",align:left"
endfunction
call SetTabPanelWidth(g:tabpanel_width)

if g:use_tabpanel
    set showtabpanel=2
    set showtabline=0
else
    set showtabpanel=0
    set showtabline=2
    set tabline=%!TabLine()
endif

function! ToggleTabPanel()
    let g:use_tabpanel = !g:use_tabpanel
    if g:use_tabpanel
        set showtabpanel=2
        set showtabline=0
    else
        set showtabpanel=0
        set showtabline=2
    endif
endfunction
nnoremap <M-w><C-p> :call ToggleTabPanel()<cr>

function! TabLine()
    let s = ''
    for i in range(1, tabpagenr('$'))
        " set the tab page number (for mouse clicks)
        let s ..= '%' .. i .. 'T'

        let tab_tag = gettabvar(i, "tab_tag", "")
        let tab_label = TabLabel(i)

        " Display tab number.
        if i == tabpagenr()
            let s ..= '%#TabLineNumberSel#'
        else
            let s ..= '%#TabLineNumber#'
        endif
        let s ..= ' ' .. string(i) .. ' '

        " Display tab tag if there is any.
        if !empty(tab_tag)
            if i == tabpagenr()
                let s ..= '%#TabLineTagSel#'
            else
                let s ..= '%#TabLineTag#'
            endif
            let s ..= tab_tag
        endif

        " Display the rest of the tab.
        if i == tabpagenr()
            let s ..= '%#TabLineSel#'
        else
            let s ..= '%#TabLine#'
        endif

        if !empty(tab_tag) && !empty(tab_label)
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

command! -nargs=1 Ttag let t:tab_tag = <q-args>

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

    let rename_bufexplorer = 0
    if getbufvar(l:buf, "bufexplorer", 0)
        if get(g:, "bufexplorer_from_bufnr", -1) != -1
            let l:buf = g:bufexplorer_from_bufnr
            let rename_bufexplorer = 1
        endif
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
            if getbufvar(l:buf, "custom_terminal_buffer_name", 0) == 1
                " If a custom terminal buffer name is signified, then use that.
                let str = buf_name
            else
                " Otherwise, display the command name.
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
        endif
    elseif buf_type ==# "help"
        let str = "[help ".buf_basename."]"
    elseif buf_type ==# "quickfix"
        let str = "[qf ".buf_basename."]"
    else
        let str = buf_basename
    endif

    if rename_bufexplorer
        let str = "<".str.">"
    endif

    return str
endfunction
highlight clear TabLine
highlight clear TabLineSel
highlight clear TabLineFill
highlight TabLine cterm=underline ctermfg=blue ctermbg=black
highlight TabLineSel cterm=underline ctermfg=white ctermbg=black
highlight TabLineFill cterm=underline ctermfg=blue ctermbg=black
" custom
highlight TabLineNumber cterm=underline ctermfg=blue ctermbg=black
highlight TabLineNumberSel cterm=underline ctermfg=blue ctermbg=black
highlight TabLineTag cterm=underline ctermfg=gray ctermbg=black
highlight TabLineTagSel cterm=underline ctermfg=white ctermbg=black

" TabPanel
hi TabPanel cterm=NONE ctermfg=grey
hi TabPanelFill cterm=NONE
hi TabPanelSel cterm=NONE ctermfg=white
set fillchars+=tpl_vert:\ 

" Wrapper for redrawtabpanel so it can be remote-called through vim server commands.
" execute("redrawtabpanel") doesn't work because redir is not allowed in
" execute() context.
function! RedrawTabPanel()
    redrawtabpanel
endfunction

"@@
function! GetTabPanelBufName(buf, cwd)
    let buf = a:buf
    let cwd = a:cwd

    let buftype = getbufvar(buf, "&buftype")
    let s = ""
    if buftype == ""
        " Normal buffer.
        " Note: I assume bufname is the absolute or relative path, is this always true?
        let path = bufname(buf)
        if empty(path)
            let s .= "(empty)"
        else
            let path = fnamemodify(path, ":p")
            if stridx(path, cwd..'/') == 0
                " File in vim's working directory.
                let path = path[strlen(cwd) + 1:]

                "TODO: Find a way to display without long line.
                "let s .= path
                "For now, just displaying basename.
                let basename = fnamemodify(path, ":t")
                let s .= basename
            else
                " File outside vim's working directory.
                let basename = fnamemodify(path, ":t")
                " r for "remote".
                let s .= "[r] "..basename
            endif
        endif
    elseif buftype == "help"
        let basename = fnamemodify(bufname(buf), ":t:r")
        let s .= "[?] "..basename
    elseif buftype == "terminal"
        let s .= "$"
        let swd = getbufvar(buf, "shell_working_directory", "")
        if swd != ""
            let s .= ":"
            if stridx(swd, cwd) == 0
                " Shell in a subdirectory of vim's global working directory.
                let swd = swd[strlen(cwd) + 1:]
                if swd == ""
                    " Indicate current directory with ".".
                    let swd = "."
                endif
            else
                " Use ~ for the home directory.
                let swd = fnamemodify(swd, ':~')
            endif
            let s .= swd
        endif

    endif
    return s
endfunction
"@@

"@@
function! TabPanelBufferDescription(P, buf)
    let P = a:P
    let buf = a:buf
    let buftype = getbufvar(buf, "&buftype")
    if buftype == "terminal"
        " The async job which saves foreground process info uses
        " the runtime directories dirspace provides.
        " This is just for convenience, it is not really a "dirspace" feature.
        if exists("$DIRSPACE_VIM_RUNTIME")
            let shell_poller_runtime_subdir = getbufvar(buf, "shell_poller_runtime_subdir", "")
            if shell_poller_runtime_subdir != ""
                let dir = $DIRSPACE_VIM_RUNTIME.."/"..shell_poller_runtime_subdir
                if filereadable(dir.."/foreground_pid")
                    let foreground_pid = readfile(dir.."/foreground_pid")[0]
                    let job = term_getjob(buf)
                    let job_info = job_info(job)
                    let pid = job_info["process"]
                    let command = job_info["cmd"][0]
                    " Don't display description if the controlling process is
                    " a shell and it is currently the foreground proess.
                    " (todo: Check if it is any shell.)
                    if ( command != "bash" && command != "/bin/bash" ) || foreground_pid != pid
                        let comm = readfile(dir.."/foreground_comm")[0]

                        if comm == "lf" || comm == "lfnoshell"
                            " call AddPanelText(P, "    Files", "BufferDescriptionCommand")
                            " call FinishPanelLine(P)
                            let lf_cwd_file = $HOME.."/.local/share/lf/my_runtime/"..foreground_pid.."/cwd"
                            if filereadable(lf_cwd_file)
                                let lf_cwd = readfile(lf_cwd_file)[0]
                                " If a subdir, make it relative to the global cwd.
                                let global_cwd = getcwd(-1)
                                if stridx(lf_cwd, global_cwd) == 0
                                    let lf_cwd = lf_cwd[strlen(global_cwd) + 1:]
                                    if lf_cwd == ""
                                        let lf_cwd = "."
                                    endif
                                else
                                    " Use ~ if a subdir of home.
                                    let lf_cwd = fnamemodify(lf_cwd, ":~")
                                endif
                                call AddPanelText(P, "    "..lf_cwd, "BufferDescriptionFilesCWD")
                                call FinishPanelLine(P)
                            endif
                        elseif comm == "tig"
                            call AddPanelText(P, "    Git TUI", "BufferDescriptionCommand")
                            call FinishPanelLine(P)
                        else
                            call AddPanelText(P, "    "..comm, "BufferDescriptionCommand")
                            call FinishPanelLine(P)
                            let args = readfile(dir.."/foreground_args")
                            for arg in args
                                if arg != ""
                                    call AddPanelText(P, "    "..arg, "BufferDescriptionArgs")
                                    call FinishPanelLine(P)
                                endif
                            endfor
                        endif
                    endif
                endif
            endif
        endif
    endif
endfunction
"@@

" Store info so it doesn't have to recompute again.
" Set it to "" to reset on the next tab draw.
let g:tabpanel_directory_header = ""
let g:tabpanel_directory_header_is_dirspace = 0
let g:tabpanel_current_branch = ""
let g:tabpanel_vcs_author = ""
let g:tabpanel_vcs_project = ""
let g:tabpanel_debug = 0

augroup TabPanel
    autocmd!
    " Recalculate directory header on DirChanged.
    " (Vim is already refreshing the tab panel on DirChanged, I think.)
    autocmd DirChanged *
                    \   let g:tabpanel_directory_header = ""
                    \ | redrawtabpanel
    " TabPanel is showing hidden and unlisted buffers information, so update when that is changed.
    autocmd BufCreate * redrawtabpanel
    " BufDelete and BufWipeout are triggered before the deletion,
    " so the panel should be redrawn after a delay.
    " This is not ideal, todo: Is there any other way?
    " Note: The reason a function wrapping redrawtabpanel is run in a function wrapper,
    "       is that execute("redrawtabpanel") causes an error when redir at any time in execute() context.
    function! __TabPanel_BufDelete_After()
        call RedrawTabPanel()
    endfunction
    autocmd BufDelete,BufWipeout * call timer_start(10, {-> __TabPanel_BufDelete_After()})
augroup END

function! TabPanelDebug(str)
    if g:tabpanel_debug
        call DEBUGLOG(a:str)
    endif
endfunction

function! AddPanelText(P, text, ...)
    let l:highlight = get(a:000, 0, "")
    let a:P[1] += [[a:text, l:highlight]]
    call TabPanelDebug("["..a:text..", "..l:highlight.."]")
endfunction

function! FinishPanelLine(P)
    let panel_lines = a:P[0]
    let current_panel_line_description = a:P[1]
    call TabPanelDebug("Finish: "..string(current_panel_line_description))
    let a:P[0] += [copy(current_panel_line_description)]
    let a:P[1] = []
endfunction

function! TabPanel() abort
    let tab = g:actual_curtabpage
    let cwd = getcwd()
    let focus_winid = gettabvar(tab, "tabwindowfocus_winid_winenter")

    if tab == 1
        call TabPanelDebug("START")
        call TabPanelDebug("------------------------------")
    endif
    call TabPanelDebug("Tab: "..tab)

    let panel_lines = []
    let current_panel_line_description = []
    let P = [panel_lines, current_panel_line_description]

    "" Show total header (above the first tab).
    if tab == 1
        if g:tabpanel_directory_header == ""
            let dirspace_name = system("dirspace_get "..shellescape(fnamemodify(cwd, ":p")))
            if v:shell_error == 0
                let g:tabpanel_directory_header = dirspace_name
                let g:tabpanel_directory_header_is_dirspace = 1
            else
                let g:tabpanel_directory_header = fnamemodify(cwd, ":~")
                let g:tabpanel_directory_header_is_dirspace = 0
            endif
        endif
        if g:detail_view_active && g:tabpanel_directory_header_is_dirspace
            call AddPanelText(P, g:tabpanel_directory_header, "Header")
            call FinishPanelLine(P)
            call AddPanelText(P, "@ "..fnamemodify(cwd, ":~"), "HeaderEnd")
            call FinishPanelLine(P)
        else
            call AddPanelText(P, g:tabpanel_directory_header, "HeaderEnd")
            call FinishPanelLine(P)
        endif

        "TODO: Use vim builtin.
        call system("[ -d "..shellescape(cwd).."/.git ]")
        if v:shell_error == 0
            if g:tabpanel_current_branch == ""
                let g:tabpanel_current_branch = systemlist("gitcb")[0]
            endif
            if v:shell_error == 0
                call AddPanelText(P, g:tabpanel_current_branch, "Header2")
                call FinishPanelLine(P)
            endif
            if g:detail_view_active
                if g:tabpanel_vcs_author == ""
                    let g:tabpanel_vcs_author = systemlist("gitremoteproject -u")[0]
                endif
                if g:tabpanel_vcs_project == ""
                    let g:tabpanel_vcs_project = systemlist("gitremoteproject -p")[0]
                endif
                if v:shell_error == 0
                    let s = g:tabpanel_vcs_author.."/"..g:tabpanel_vcs_project
                    if strlen(s) > g:tabpanel_width
                        " Split over two lines
                        call AddPanelText(P, g:tabpanel_vcs_author, "Header2")
                        call FinishPanelLine(P)
                        call AddPanelText(P, "/"..g:tabpanel_vcs_project, "Header2")
                        call FinishPanelLine(P)
                    else
                        call AddPanelText(P, s, "Header2")
                        call FinishPanelLine(P)
                    endif
                endif
            endif
        endif
    endif

    " Show separator.
    call AddPanelText(P, "", "")
    call FinishPanelLine(P)

    " Show the tab.
    let winids = map(range(1, tabpagewinnr(tab, '$')), {_, winnr -> win_getid(winnr, tab)})
    for winid in winids
        let buf = Win_id2bufnr(winid)
        " s: Line for the window.
        let s = ""
        if buf == bufnr()
            if winid == win_getid()
                let highlight = "FocusLine"
            else
                let highlight = "Sel"
            endif
        else
            let highlight = ""
        endif
        let prefix = ' '
        if winid == focus_winid
            let s .= tab
        else
            let s .= ' '
        endif
        call AddPanelText(P, s, highlight)
        let buffer_flag_prefix = ' '
        if getbufvar(buf, "&modified", 0) == 1
            let buffer_flag_prefix = '+'
        endif
        call AddPanelText(P, buffer_flag_prefix.." ", "")

        if buf == bufnr()
            " Revert back from TabPanelFocusLine, so it doesn't cover the whole line,
            " only the marker characters.
            let highlight = "Sel"
        endif

        let bufname = GetTabPanelBufName(buf, cwd)
        call AddPanelText(P, bufname, highlight)
        call FinishPanelLine(P)
        call TabPanelBufferDescription(P, buf)
    endfor

    " Show total footer (below the last tab).
    if tab == tabpagenr('$')
        call AddPanelText(P, "", "")
        call FinishPanelLine(P)

        " Popup
        " NOTE: popup_list() only works with the current tab page.
        " TODO: Might not want to see most popups here.
        for winid in popup_list()
            let buf = Win_id2bufnr(winid)
            call AddPanelText(P, "[p]", "PopupIndicator")
            call AddPanelText(P, " "..GetTabPanelBufName(buf, cwd), "Footer")
            call FinishPanelLine(P)
            call TabPanelBufferDescription(P, buf)
            call AddPanelText(P, "", "")
            call FinishPanelLine(P)
        endfor

        " Hidden
        let num_hidden = NumHiddenBuffers()
        if num_hidden > 0
            " Show number hidden.
            "call AddPanelText(P, "("..num_hidden..")", "Footer")
            "call FinishPanelLine(P)
            
            call AddPanelText(P, "", "")
            call FinishPanelLine(P)

            let hidden_buffers = GetHiddenBuffers()
            for buf in hidden_buffers
                let buffer_flag_prefix = ' '
                if getbufvar(buf, "&modified", 0) == 1
                    let buffer_flag_prefix = '+'
                endif
                let s = " "..buffer_flag_prefix.." "..GetTabPanelBufName(buf, cwd)
                call AddPanelText(P, s, "Footer")
                call FinishPanelLine(P)
                call TabPanelBufferDescription(P, buf)
            endfor
        endif

        " Unlisted
        let num_unlisted = NumHiddenBuffers(1) - num_hidden
        if num_unlisted > 0
            call AddPanelText(P, "", "")
            call FinishPanelLine(P)
            call AddPanelText(P, "("..num_unlisted.." unlisted)", "Footer")
            call FinishPanelLine(P)
        endif
    endif

    call TabPanelDebug("Full: "..string(panel_lines))

    let num_panel_lines = len(panel_lines)
    let panel_string = ""
    for i in range(num_panel_lines)
        let line = panel_lines[i]
        let uncolored_line = ""
        let colored_line = ""
        let line_length = 0
        for entry in line
            let text = entry[0]
            let highlight = entry[1]
            let line_length += strlen(text)
            " Cut off the end of lines.
            if line_length > g:tabpanel_width - 2
                call TabPanelDebug("CUT")
                let cut_text_length = strlen(text) - (line_length - (g:tabpanel_width - 2))
                let text = text[:cut_text_length]
            endif
            let uncolored_line .= text
            let colored_line .= "%#TabPanel"..highlight.."#"..text
        endfor
        if i < num_panel_lines - 1
            let panel_string .= colored_line .. "\n"
        else
            let panel_string .= colored_line
        endif
    endfor
    return panel_string
endfunction
redrawtabpanel
set tabpanel=%!TabPanel()
" Custom highlights for tabpanel
highlight TabPanelFocusLine cterm=underline ctermfg=white ctermbg=black
highlight TabPanelHeader cterm=none ctermfg=blue ctermbg=black
highlight TabPanelHeaderEnd cterm=underline ctermfg=blue ctermbg=black
highlight TabPanelFooter ctermfg=grey ctermbg=black
highlight TabPanelHeader2 cterm=None ctermfg=grey ctermbg=black
highlight TabPanelBufferDescriptionCommand cterm=None ctermfg=blue ctermbg=black
highlight TabPanelBufferDescriptionArgs cterm=None ctermfg=blue ctermbg=black
highlight TabPanelBufferDescriptionFilesCWD cterm=None ctermfg=blue ctermbg=black
highlight TabPanelPopupIndicator cterm=None ctermfg=red ctermbg=black
"@@

"------------------------------------------------------------


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


">>>

" Basic mappings
"    inoremap jk <esc>
"    ...
"<<<
inoremap jk <esc>
let mapleader = "."
nmap Q @q
command! -nargs=0 Sv source ~/.vimrc

" Search for selected text
function! SearchSelected(prefix)
    call system("xdg-browser "..shellescape(a:prefix..@*).." &")
endfunction

let g:browser_query_prefix = "https://duckduckgo.com/?t=lm&q="
function! SearchSelectedBrowser()
    call system("xdg-browser "..shellescape(g:browser_query_prefix..@*).." &")
endfunction

let g:chatgpt_query_prefix = "https://chat.openai.com/?q="
function! SearchSelectedChatGPT()
    call system("xdg-browser "..shellescape(g:chatgpt_query_prefix..@*).." &")
endfunction

" Search for selected text
vnoremap gs :<c-u>call SearchSelectedBrowser()<cr>
vnoremap ga :<c-u>call SearchSelectedChatGPT()<cr>
" Search for line under cursor.
"todo: Operator, e.g. gsiw.
nnoremap gss V:<c-u>call SearchSelectedBrowser()<cr>
nnoremap gaa V:<c-u>call SearchSelectedChatGPT()<cr>
" Search for whole file.
" Useful for opening a scratch buffer to edit a search term.
" Then close the buffer.
" todo: Cleanup buffer from list.
nnoremap gS ggVG:<c-u>call SearchSelectedBrowser()<cr>gg:close<cr>
nnoremap gA ggVG:<c-u>call SearchSelectedChatGPT()<cr>gg:close<cr>

" "Smart unindent", don't flatten different preceding whitespaces.
" e.g. fully unindenting
" ```
"         def foo():
"             print("hi")
" ```
" becomes
" ```
" def foo():
"     print("hi")
" ```
" rather than
" ```XXX
" def foo():
" print("hi")
" ```XXX
function! SmartUnindent(lines, max_unindent)
    let unindent_amount = 9999
    for line in a:lines
        if line !~# '^\s*$'
            let len = strlen(matchstr(line, '^\s*'))
            if len < unindent_amount
                let unindent_amount = len
            endif
        endif
    endfor
    if unindent_amount >= a:max_unindent
        let unindent_amount = a:max_unindent
    endif
    " Remove this much whitespace from the beginning of each line.
    let unindented_lines = []
    for line in a:lines
        if line !~# '^\s*$'
            call add(unindented_lines, line[unindent_amount:])
        else
            call add(unindented_lines, line)
        endif
    endfor
    return unindented_lines
endfunction
function! SmartUnindentSelection(max_unindent)
    let from_line = getpos("'<")[1]
    let to_line = getpos("'>")[1]
    let lines = getline(from_line, to_line)
    let unindented_lines = SmartUnindent(lines, a:max_unindent)
    let line_number = from_line
    for line in lines
        if line !~# '^\s*$'
            call setline(line_number, unindented_lines[line_number - from_line])
        endif
        let line_number += 1
    endfor
endfunction
"vnoremap g< :<c-u>call SmartUnindentSelection(4)<cr>
"Unindent fully, useful for formatting copy-pastes into notes.
vnoremap g< :<c-u>call SmartUnindentSelection(9999)<cr>
"todo: text object, operator.
"Copy text to system clipboard with smart unindent.
vnoremap <M-Y> "+y:let @+ = join(SmartUnindent(getline(getpos("'<")[1], getpos("'>")[1]), 9999), "\n")<cr>

" Open a scratch buffer with selected text.
" This can be useful for modifying text before copying it.
function! SendSelectedToScratchBuffer()
    let l:tmp = @*
    tabnew
    set buftype=nofile
    execute "normal! O" l:tmp
    normal! gg
endfunction
vnoremap <silent> <M-t> :<c-u>call SendSelectedToScratchBuffer()<cr>
" Open scratch buffer and start insert.
" For editing text by itself.
nnoremap <silent> <M-t> :tabnew<cr>

" Duplicate this buffer view to another tab.
" This is useful for in-window navigation, for example opening tabs for
" important targets during tag search.
" This opens in the background.
nnoremap <silent> <M-T> :call DuplicateBufferView()<cr>
function! DuplicateBufferView()
    let curtab = tabpagenr()
    tab split

    if &buftype == "terminal"
        " Special behaviour for shells.
        " This "duplicates" the shell.
        let swd = getbufvar(bufnr(), "shell_working_directory", "")
        let cmd = $SHELL
        let term_options = {
            \ 'curwin': 1
            \ }
        if swd != ""
            let global_cwd = getcwd(-1)
            noautocmd execute "cd "..fnameescape(swd)
            call term_start(cmd, term_options)
            noautocmd execute "cd "..fnameescape(global_cwd)
        else
            call term_start(cmd, term_options)
        endif
    endif
    execute "tabnext" curtab
    unlet curtab
endfunction

" Copy text to system clipboard and close.
" Workflow intended for scratch buffer, quickly edit text to send to use
" elsewhere.
" (This is an insert mode mapping just so another keybinding doesn't have to be used.)
inoremap <silent> <M-t> <esc>:%yank<cr>:close<cr>

inoremap <tab> <space><space><space><space>
nnoremap j gj
nnoremap k gk
nnoremap gj gT
nnoremap gk gt
" Write
nnoremap <M-s> :w<cr>
inoremap <M-s> <Esc>:w<cr>a
" Use shift when in job mode.
" M-h,j,k,l are useful for bash prompt mappings,
" and M-H,J,K,L are less likely to be used by terminal programs.
"todo: M-J M-K is being used to exit.
"tnoremap <M-H> <C-w>h
"tnoremap <M-J> <C-w>j
"tnoremap <M-K> <C-w>k
"tnoremap <M-L> <C-w>l
" Close window
nnoremap <silent> <M-w><M-x> :quit<cr>
nnoremap <silent> <M-x> :quit<cr>
tnoremap <silent> <M-W><M-x> :quit<cr>
" And wipeout buffer, with prompt of file modified.
nnoremap <silent> <M-X> :bwipeout<cr>
" Force quit vim
nnoremap <silent> <M-w><M-w><M-x> :qa!<cr>
" Close tab
nnoremap <silent> <M-w><M-X> :tabclose<cr>
tnoremap <silent> <M-W><M-X> <C-w>:tabclose<cr>
" Quick new empty tab.
nnoremap <silent> <M-w><M-n> :tabnew<cr>
tnoremap <silent> <M-W><M-n> <C-w>:tabnew<cr>
tnoremap <silent> <M-W><M-N> <C-w>:tabnew<cr>
" Copy file path
"nnoremap .cp :let @" = expand("%:p")<cr>
" Copy file directory
"nnoremap .cd :let @" = expand("%:p:h")<cr>
" Move to first tab.
"nnoremap .q :tabm 0<cr>
" Move tab left and right.
nnoremap <silent> <M-w><M-.> :tabm +1<cr>
nnoremap <silent> <M-w><M-,> :tabm -1<cr>
tnoremap <silent> <M-w><M-.> <C-w>:tabm +1<cr>
tnoremap <silent> <M-w><M-,> <C-w>:tabm -1<cr>
" Scroll-wheel goes to terminal normal mode so can scroll in vim buffer.
"TODO: This should only be in the shell prompt, still want scroll in other
"programs e.g. man pages.
"tnoremap <ScrollWheelUp> <C-\><C-n>
"tnoremap <ScrollWheelDown> <C-\><C-n>

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

" Toggle numbers and relative numberrs.
" <M-m> : Toggle numbers, default to non-relative.
" <M-M> : Toggle relative. If no numbers are shown, show them first, then switch to relative.
nnoremap <silent> <M-m> :if &number == 1
                     \ \|    set nonumber
                     \ \|    set norelativenumber
                     \ \| else
                     \ \|    set number
                     \ \|    set norelativenumber
                     \ \| endif
                     \ <cr>
nnoremap <silent> <M-M> :if &number == 1
                     \ \|    set relativenumber!
                     \ \| else
                     \ \|    set number
                     \ \|    set relativenumber
                     \ \| endif
                     \ <cr>

function! CheckSwitchToTerminalMode()
    if exists("b:switch_to_terminal_mode") && b:switch_to_terminal_mode
        call feedkeys("i", 'n')
        unlet b:switch_to_terminal_mode
    endif
endfunction
function! SwitchTab(number)
    execute "normal!" a:number.."gt"
    call CheckSwitchToTerminalMode()
endfunction

" Tab metakeys.
for index in [1,2,3,4,5,6,7,8,9]
    " Go to tab
    "execute "nnoremap <silent> <M-".index."> :normal! ".index."gt<cr>"
    "execute "tnoremap <silent> <M-".index."> <C-\\><C-n>:normal! ".index."gt<cr>"
    execute "nnoremap <silent> <M-".index."> :call SwitchTab(".index.")<cr>"
    execute 'tnoremap <silent> <M-'.index.'> <C-w>:call SwitchTab('.index.')<cr>'
    " Move window to tab
    "TODO
    "execute "nnoremap <silent> <M-w><M-".index."> :normal! ".index."gt<cr>"
    "execute "tnoremap <silent> <M-W><M-".index."> <C-\\><C-n>:normal! ".index."gt<cr>"
endfor

"TODO: This is very slow.
"autocmd BufEnter * if &buftype ==# 'terminal' | call CheckSwitchToTerminalMode() | endif
"autocmd TabEnter * if &buftype ==# 'terminal' | call CheckSwitchToTerminalMode() | endif

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
" Move window to tab.
function! MoveCurrentWindowToTab(target_tab)
    let l:current_tab = tabpagenr()
    if l:current_tab == a:target_tab
        " If this window is already at the target tab,
        " don't do anything, don't even rearrange windows.
        return
    endif
    let l:buf = bufnr('%')
    let l:current_winid = win_getid()
    execute "tabnext ".a:target_tab
    execute "sbuffer ".l:buf
    call win_execute(l:current_winid, "close")
endfunction
for i in range(1,9)
    execute "nnoremap <silent> <M-w>"..i.." :call MoveCurrentWindowToTab("..i..")<cr>"
endfor
nnoremap <silent> <M-w><M-t> :call MoveCurrentWindowToNewTab(0)<cr>
tnoremap <silent> <M-W><M-t> <cmd>call MoveCurrentWindowToNewTab(0)<cr>
nnoremap <silent> <M-w><M-T> :call MoveCurrentWindowToNewTab(1)<cr>
tnoremap <silent> <M-W><M-T> <cmd>call MoveCurrentWindowToNewTab(1)<cr>

" Create splits
nnoremap <silent> <M-\> :vsp<cr>
nnoremap <silent> <M--> :sp<cr>

" Be careful...
" todo: Better than this. Popup, or general terminal, pager.
"nnoremap .! :execute "!".getline(".")<cr>

" Scroll offset trick to make search navigation centered (auto-zz).
" https://vim.fandom.com/wiki/Make_search_results_appear_in_the_middle_of_the_screen
"todo: Disable this in non-file.
"set scrolloff=5

">>>

" Plugins
"    ...
"<<<

if PluginEnabled("vim-surround")
    " Use the s key as the surround operator.
    " (note: s is also a common prefix for vim-sneak/leap.nvim plugins which I might want to use.)
    nmap s ys
    vmap s S
endif

if PluginEnabled("undoquit.vim")
    let g:undoquit_mapping = '<M-w><M-u>'
    let g:undoquit_tab_mapping = '<M-w><M-U>'
endif

if PluginEnabled("vim-EnhancedJumps")

    " Timeout for the double Ctrl-I/Ctrl-O in milliseconds when travelling between buffers.
    let g:stopFirstAndNotifyTimeoutLen = 2000

    " Disable navigation through tabs.
    " I want jump list navigation to restrict to one window anyway.
    let g:EnhancedJumps_UseTab = 0

    " Do the mappings myself.
    let g:EnhancedJumps_no_mappings = 1
    nnoremap <C-o> <Plug>EnhancedJumpsOlder
    nnoremap <C-i> <Plug>EnhancedJumpsNewer
    nnoremap <M-o> <Plug>EnhancedJumpsRemoteOlder
    nnoremap <M-i> <Plug>EnhancedJumpsRemoteNewer
endif

if PluginEnabled("vim-easymotion")
    " EasyMotion options
    " Disable messages like "Jumped to ..." and "EasyMotion cancelled."
    let g:EasyMotion_verbose = 0

    " extension options
    let g:easymotion_option_override_default_search_mappings = 0

    " EasyMotion search utilities.
    "
    " Feature: Search in visible part of buffer, then jump.
    " This is basically a rudimentary version of https://github.com/ggandor/leap.nvim hacked from EasyMotion.
    "
    "

    " Note:
    "     Hack to get cursor position restore.
    "     Need to use feedkeys for some reason...
    function! __EasyMotionSearchJump()
        " Restore cursor position.
        call setpos('.', g:easymotion_tmp_cursor_pos)
        unlet g:easymotion_tmp_cursor_pos
        call feedkeys("\<Plug>(easymotion-bd-n)", "m")
    endfunction
    nnoremap <Plug>(my-easymotion-search-jump) :call __EasyMotionSearchJump()<cr>

    let g:easymotion_EasyMotionFirstCmdlineChange_counter = 0
    let g:easymotion_EasyMotionFirstCmdlineChange_target = 0
    function! __EasyMotionFirstCmdlineChange()
        if g:easymotion_EasyMotionFirstCmdlineChange_counter < g:easymotion_EasyMotionFirstCmdlineChange_target
            let g:easymotion_EasyMotionFirstCmdlineChange_counter += 1
            if g:easymotion_EasyMotionFirstCmdlineChange_counter == g:easymotion_EasyMotionFirstCmdlineChange_target
                set incsearch
                set hlsearch
                augroup EasyMotionEasyMotionSearchCmdlineChanged
                    autocmd!
                augroup END
            endif
        endif
    endfunction

    function! __EasyMotionSearchPrevious()
        " Only run if no characters have been typed on the search.
        if g:easymotion_EasyMotionFirstCmdlineChange_counter != g:easymotion_EasyMotionFirstCmdlineChange_target
            return
        endif
        call feedkeys(g:easymotion_tmp_previous_search.."\<cr>", 'n')
    endfunction

    function! __EasyMotionSearchFinished()
        
        "TODO: Bug workaround here, ++once autocmd is called multiple times.
        if !exists("g:easymotion_tmp_easymotionsearchfinished_to_trigger")
            return
        endif
        unlet g:easymotion_tmp_easymotionsearchfinished_to_trigger

        " Restore settings.
        let &hlsearch = g:easymotion_tmp_hlsearch
        unlet g:easymotion_tmp_hlsearch
        let &incsearch = g:easymotion_tmp_incsearch
        unlet g:easymotion_tmp_incsearch

        " Restore mappings
        if g:easymotion_tmp_cancel_cmap != {}
            call mapset('c', 0, g:easymotion_tmp_cancel_cmap)
        else
            silent! cunmap "<C-c>"
        endif
        unlet g:easymotion_tmp_cancel_cmap
        if g:easymotion_tmp_search_previous_cmap != {}
            call mapset('c', 0, g:easymotion_tmp_search_previous_cmap)
        else
            silent! cunmap "<M-/>"
        endif
        unlet g:easymotion_tmp_search_previous_cmap

        " Handle cancel
        if exists("g:easymotion_search_cancelled")
            unlet g:easymotion_search_cancelled
            " Restore the search string register on cancel.
            " This matches with normal / and ? search behaviour.
            let @/ = g:easymotion_tmp_previous_search
            unlet g:easymotion_tmp_previous_search
            return
        endif
        unlet g:easymotion_tmp_previous_search

        let l:cmdline = getcmdline()[g:easymotion_EasyMotionFirstCmdlineChange_target:]
        " Note: Not sure why need to delay.
        call timer_start(10, {-> setreg("/", l:cmdline)})

        " Trigger the easymotion jump keys prompt.
        nohlsearch
        
        call feedkeys("\<Plug>(my-easymotion-search-jump)", "m")
        " Restore scrolloff
        let &scrolloff = g:easymotion_tmp_scrolloff
        unlet g:easymotion_tmp_scrolloff
    endfunction

    function! __EasyMotionSearch(search_char)
        " Args:
        "     search_char: '/' or '?'

        " Save settings to restore.
        let g:easymotion_tmp_hlsearch = &hlsearch 
        let g:easymotion_tmp_incsearch = &incsearch 
        let g:easymotion_tmp_scrolloff = &scrolloff
        " Save cursor position to restore, so incsearch doesn't clobber it.
        let g:easymotion_tmp_cursor_pos = getpos(".")
        "TODO: Bug workaround here, ++once autocmd is called multiple times.
        let g:easymotion_tmp_easymotionsearchfinished_to_trigger = 1
        autocmd CmdlineLeave /,\? ++once call __EasyMotionSearchFinished()
        set scrolloff=0
        let g:easymotion_tmp_previous_search = @/
        let @/ = ""

        " Search only the visible lines in the window
        " using line number regex matching.
        " This will be feedkey'd into the search command prompt.
        let search_prefix = "\\%>".(line('w0')-1)."l\\%<".(line('w$')+1)."l"

        " NOTE: Ungodly hack to make hlsearch activate only when the actual
        "       input string is being written, not the prefix regex
        set noincsearch
        set nohlsearch
        let g:easymotion_EasyMotionFirstCmdlineChange_counter = 0
        let g:easymotion_EasyMotionFirstCmdlineChange_target = len(search_prefix)
        augroup EasyMotionEasyMotionSearchCmdlineChanged
            autocmd!
            autocmd CmdlineChanged /,\? call __EasyMotionFirstCmdlineChange()
        augroup END

        " Bind Ctrl-C in the search command to set a global indicator
        " that the search was cancelled.
        " This means the CmdlineLeave handler can handle command line leaving
        " for cancellations versus acceptance.
        " NOTE:
        "    This assumes the only way to cancel the search is to press Ctrl-C.
        let g:easymotion_tmp_cancel_cmap = maparg('<C-c>', 'c', 0, 1)
        cnoremap <expr> <C-c> execute("let g:easymotion_search_cancelled = 1") ? "\<C-c>" : "\<C-c>"

        " Bind Alt-/ to redo for the previous search.
        let g:easymotion_tmp_search_previous_cmap = maparg('<M-/>', 'c', 0, 1)
        cnoremap <expr> <M-/> __EasyMotionSearchPrevious() ? "" : ""

        " Start the interactive search.
        call feedkeys(a:search_char . search_prefix, 'n')
    endfunction

    " Mappings
    if g:easymotion_option_override_default_search_mappings
        " Override default / ? mappings
        nnoremap / :call __EasyMotionSearch('/')<cr>
        nnoremap ? :call __EasyMotionSearch('?')<cr>
        " Hold alt to get normal search.
        nnoremap <M-/> /
        nnoremap <M-?> ?
    else
        nnoremap <M-/> :call __EasyMotionSearch('/')<cr>
        nnoremap <M-?> :call __EasyMotionSearch('?')<cr>
    endif
endif

" Rebindings for the search (/ and ?) command line.
"
" Note:
"     This pattern of save and restore with maparg is useful, should move to a
"     general utility.
augroup SearchMappings
    autocmd!

    let g:__SearchMappings_mappings = {}
    function! __SearchMappings_Save(lhs)
        let g:__SearchMappings_mappings[a:lhs] =  [a:lhs, maparg(a:lhs, 'c', 0, 1)]
    endfunction

    function! __SearchMappings_Restore()
        for [key, val] in items(g:__SearchMappings_mappings)
            let lhs = val[0]
            let dict = val[1]
            if dict != {}
                call mapset('c', 0, dict)
            else
                execute "silent! cunmap "..lhs
            endif
        endfor
    endfunction

    function! __SearchMappings_CmdlineEnter()
        call __SearchMappings_Save('<M-d>')
        cnoremap <M-d> \d\+\(\.\d\+\)\?
    endfunction

    function! __SearchMappings_CmdlineLeave()
        call __SearchMappings_Restore()
    endfunction

    autocmd CmdlineEnter /,\? call __SearchMappings_CmdlineEnter()
    autocmd CmdlineLeave /,\? call __SearchMappings_CmdlineLeave()
augroup END

if PluginEnabled("vim-highlightedyank")
    " measured in milliseconds
    let g:highlightedyank_highlight_duration = 200
endif

if PluginEnabled("tagbar")
    nnoremap <leader>t :Tagbar<cr>
endif

if PluginEnabled("bufexplorer")
    nnoremap <silent> <M-'> :ToggleBufExplorer<CR>
    tnoremap <silent> <M-'> <C-w>:ToggleBufExplorer<CR>
endif

"if PluginEnabled("quickpeek")
let g:quickpeek_auto = 1
let g:quickpeek_popup_options = {
    \ 'border': [0,0,0,0],
    \ 'title': ''
    \ }
"let g:quickpeek_window_settings = ["wincolor=Window"]
"endif

"if PluginEnabled("tig-explorer.vim")
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

"if PluginEnabled("vim-gitgutter")
"    let g:gitgutter_enabled = 0
"    let g:gitgutter_preview_win_floating = 0
"
"    nnoremap <space>p :GitGutterToggle<cr>
"    nnoremap <space>P :GitGutterPreviewHunk<cr>
"
"    function! RefreshGitGutter()
"        if g:gitgutter_enabled == 1
"            GitGutterAll
"        endif
"    endfunction
"    augroup GitGutterAuGroup
"        autocmd!
"        autocmd BufWritePost * :call RefreshGitGutter()
"    augroup END
"endif

if PluginEnabled("vim-lsp")
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

if PluginEnabled("targets")
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

" Like json_decode but use jq to pretty-print the json string.
function! JsonEncodePretty(obj)

    let l:json = json_encode(a:obj)

    if !executable("jq")
        echoerr "json_encode_pretty: jq not found"
        return
    endif

    let l:output = system("jq . 2>/dev/null", l:json)
    if v:shell_error
        echoerr "json_encode_pretty: jq failed"
        return
    endif
    return l:output
endfunction

hi debugPC ctermbg=white
"hi SignColumn ctermbg=blue
"nnoremap .T :Termdebug<cr><Esc><C-w>h<C-w>L<C-w>h<C-w>j<C-w>100-<C-w>15+<C-w>1000<<C-w>58><C-w>k
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
        # Limit quickfix window size.
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

"nnoremap .1 :call QuickfixCallstackFromGDB()<cr>
"nnoremap .S :call QuickfixCallstackFromGDB()<cr>


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

" 2D movement.
" Horizontal: Left-right splits movement, tabs
function! SpaceMove(vertical, amount, skip_splits)
    if a:amount == 0
        " Don't have to move.
        return
    endif
    if a:amount < 0
        if a:vertical
            let l:tabcmd = "tabnext"
            let l:winkey = "j"
            let l:winotherkey = "k"
            let l:absolute_amount = -a:amount
        else
            let l:tabcmd = "tabprevious"
            let l:winkey = "h"
            let l:winotherkey = "l"
            let l:absolute_amount = -a:amount
        endif
    else
        if a:vertical
            let l:tabcmd = "tabprevious"
            let l:winkey = "k"
            let l:winotherkey = "j"
            let l:absolute_amount = a:amount
        else
            let l:tabcmd = "tabnext"
            let l:winkey = "l"
            let l:winotherkey = "h"
            let l:absolute_amount = a:amount
        endif
    endif

    if a:skip_splits == 1
        if a:vertical == g:use_tabpanel
            if (     ((a:amount < 0) != a:vertical) && tabpagenr() > 1
                \ || ((a:amount > 0) != a:vertical) && tabpagenr() < tabpagenr('$'))
                execute l:tabcmd
            endif
        else
            " todo, optional: Some other navigation, like "dirspace" navigation.
        endif
    else
        if a:vertical == g:use_tabpanel
            let l:prev_wingetid = win_getid()
            for i in range(l:absolute_amount)
                execute "wincmd ".l:winkey
                if win_getid() == l:prev_wingetid
                    if (     ((a:amount < 0) != a:vertical) && tabpagenr() > 1
                        \ || ((a:amount > 0) != a:vertical) && tabpagenr() < tabpagenr('$'))
                        execute l:tabcmd
                        " Go to the left-or-rightmost split, so e.g. navigation to the right 
                        let l:prev_winnr = -1
                        while l:prev_winnr != winnr()
                            let l:prev_winnr = winnr()
                            execute "wincmd ".l:winotherkey
                        endwhile
                    endif
                endif
            endfor
        else
            for i in range(l:absolute_amount)
                execute "wincmd ".l:winkey
            endfor
        endif
    endif
    call CheckSwitchToTerminalMode()
endfunction!
function! SpaceMoveHorizontal(amount, skip_splits)
    call SpaceMove(0, a:amount, a:skip_splits)
endfunction
function! SpaceMoveVertical(amount, skip_splits)
    call SpaceMove(1, a:amount, a:skip_splits)
endfunction

tnoremap <M-J><M-K> <C-\><C-n>
tnoremap <M-W><M-W> <C-\><C-n>
if 1
    " Switch jk and lh for space movement.
    " Horizontal is jk, vertical is lh.
    tnoremap <silent> <M-w><M-l> <C-w>:call SpaceMoveHorizontal(-1, 0)<cr>
    tnoremap <silent> <M-w><M-;> <C-w>:call SpaceMoveHorizontal(1, 0)<cr>
    tnoremap <silent> <M-W><M-L> <C-w>:call SpaceMoveHorizontal(-1, 1)<cr>
    tnoremap <silent> <M-W><M-:> <C-w>:call SpaceMoveHorizontal(1, 1)<cr>
    tnoremap <silent> <M-w><M-j> <C-w>:call SpaceMoveVertical(-1, 0)<cr>
    tnoremap <silent> <M-w><M-k> <C-w>:call SpaceMoveVertical(1, 0)<cr>
    tnoremap <silent> <M-W><M-J> <C-w>:call SpaceMoveVertical(-1, 1)<cr>
    tnoremap <silent> <M-W><M-K> <C-w>:call SpaceMoveVertical(1, 1)<cr>
    nnoremap <silent> <C-c> :call CtrlCHandler()<cr>
    nnoremap <silent> <M-w><M-l> :call SpaceMoveHorizontal(-1, 0)<cr>
    nnoremap <silent> <M-w><M-;> :call SpaceMoveHorizontal(1, 0)<cr>
    nnoremap <silent> <M-W><M-L> :call SpaceMoveHorizontal(-1, 1)<cr>
    nnoremap <silent> <M-W><M-:> :call SpaceMoveHorizontal(1, 1)<cr>
    nnoremap <silent> <M-w><M-j> :call SpaceMoveVertical(-1, 0)<cr>
    nnoremap <silent> <M-w><M-k> :call SpaceMoveVertical(1, 0)<cr>
    nnoremap <silent> <M-W><M-J> :call SpaceMoveVertical(-1, 1)<cr>
    nnoremap <silent> <M-W><M-K> :call SpaceMoveVertical(1, 1)<cr>
elseif 1
    " Switch jk and lh for space movement.
    " Horizontal is jk, vertical is lh.
    tnoremap <silent> <M-w><M-j> <C-w>:call SpaceMoveHorizontal(-1, 0)<cr>
    tnoremap <silent> <M-w><M-k> <C-w>:call SpaceMoveHorizontal(1, 0)<cr>
    tnoremap <silent> <M-W><M-J> <C-w>:call SpaceMoveHorizontal(-1, 1)<cr>
    tnoremap <silent> <M-W><M-K> <C-w>:call SpaceMoveHorizontal(1, 1)<cr>
    tnoremap <silent> <M-w><M-l> <C-w>:call SpaceMoveVertical(-1, 0)<cr>
    tnoremap <silent> <M-w><M-h> <C-w>:call SpaceMoveVertical(1, 0)<cr>
    tnoremap <silent> <M-W><M-L> <C-w>:call SpaceMoveVertical(-1, 1)<cr>
    tnoremap <silent> <M-W><M-H> <C-w>:call SpaceMoveVertical(1, 1)<cr>
    nnoremap <silent> <C-c> :call CtrlCHandler()<cr>
    nnoremap <silent> <M-w><M-j> :call SpaceMoveHorizontal(-1, 0)<cr>
    nnoremap <silent> <M-w><M-k> :call SpaceMoveHorizontal(1, 0)<cr>
    nnoremap <silent> <M-W><M-J> :call SpaceMoveHorizontal(-1, 1)<cr>
    nnoremap <silent> <M-W><M-K> :call SpaceMoveHorizontal(1, 1)<cr>
    nnoremap <silent> <M-w><M-l> :call SpaceMoveVertical(-1, 0)<cr>
    nnoremap <silent> <M-w><M-h> :call SpaceMoveVertical(1, 0)<cr>
    nnoremap <silent> <M-W><M-L> :call SpaceMoveVertical(-1, 1)<cr>
    nnoremap <silent> <M-W><M-H> :call SpaceMoveVertical(1, 1)<cr>
else
    tnoremap <silent> <M-w><M-h> <C-w>:call SpaceMoveHorizontal(-1, 0)<cr>
    tnoremap <silent> <M-w><M-l> <C-w>:call SpaceMoveHorizontal(1, 0)<cr>
    tnoremap <silent> <M-W><M-H> <C-w>:call SpaceMoveHorizontal(-1, 1)<cr>
    tnoremap <silent> <M-W><M-L> <C-w>:call SpaceMoveHorizontal(1, 1)<cr>
    tnoremap <silent> <M-w><M-j> <C-w>:call SpaceMoveVertical(-1, 0)<cr>
    tnoremap <silent> <M-w><M-k> <C-w>:call SpaceMoveVertical(1, 0)<cr>
    tnoremap <silent> <M-W><M-J> <C-w>:call SpaceMoveVertical(-1, 1)<cr>
    tnoremap <silent> <M-W><M-K> <C-w>:call SpaceMoveVertical(1, 1)<cr>
    nnoremap <silent> <C-c> :call CtrlCHandler()<cr>
    nnoremap <silent> <M-w><M-h> :call SpaceMoveHorizontal(-1, 0)<cr>
    nnoremap <silent> <M-w><M-l> :call SpaceMoveHorizontal(1, 0)<cr>
    nnoremap <silent> <M-W><M-H> :call SpaceMoveHorizontal(-1, 1)<cr>
    nnoremap <silent> <M-W><M-L> :call SpaceMoveHorizontal(1, 1)<cr>
    nnoremap <silent> <M-w><M-j> :call SpaceMoveVertical(-1, 0)<cr>
    nnoremap <silent> <M-w><M-k> :call SpaceMoveVertical(1, 0)<cr>
    nnoremap <silent> <M-W><M-J> :call SpaceMoveVertical(-1, 1)<cr>
    nnoremap <silent> <M-W><M-K> :call SpaceMoveVertical(1, 1)<cr>
endif
" Open a terminal below.
function! LowerTerminal()
    if v:count == 0
        let height = 12
    else
        let height = v:count
    endif
    execute "set termwinsize=".string(height)."x0"
    botright terminal
    set termwinsize=
endfunction
nnoremap <silent> <M-c> <cmd>call LowerTerminal()<cr>
" Open a terminal in the current window.
nnoremap <silent> <M-C> :set termwinsize= \| term ++curwin<cr>

nnoremap <silent> <M-Q> :call GoToPrimaryShell(0)<cr>
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
        let card_filename = "/home/lucas/drive/dev/magic_the_gathering/images/".card_name.".jpg"
        if !filereadable(card_filename)
            echo "Magic card image not found: ".card_name
        else
            let screen_width = 2160
            let screen_height = 1350
            let width = 488
            let height = 680
            let start_x = float2nr(floor(screen_width/2.0 - width/2.0))
            let start_y = float2nr(floor(screen_height/2.0 - height/2.0))
            let g:magic_card_was_hovering = 1
            let cmd = ["bash", "-c", "pgrep feh | xargs kill -9 ; FOCUS=$(xdotool getwindowfocus) ; feh --scale-down -g ".width."x".height."+".start_x."+".start_y." \"".card_filename."\" > /dev/null 2>&1 & sleep 0.1 ; xdotool windowfocus $FOCUS > /dev/null 2>&1"]
            "todo: Is this working async? Why is vim still taking a while?
            call job_start(cmd)
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
        let card_filename = "/home/lucas/drive/dev/magic_the_gathering/images/".card_name.".jpg"
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
    autocmd Filetype notes nnoremap <buffer> <M-w><M-w><cr> :call NotesFollowLinkUnderCursor(0)<cr>
    autocmd Filetype notes nnoremap <buffer> <M-w><cr> :call NotesFollowLinkUnderCursor(1)<cr>
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

"nnoremap .. :call CycleNotesFiles(1)<cr>
"nnoremap .> :call CycleNotesFiles(1, 1)<cr>
"nnoremap ., :call YankNotesTextLink()<cr>

function! GoToLetterboxdMovie()
    let movie_name = getline(".")
    let movie_name_modified = system("echo \"".movie_name."\" | tr ' ' '-' | tr A-Z a-z")
    let url = "https://letterboxd.com/film/".movie_name_modified
    call system("qutebrowser \"".url."\" &")
endfunction
"nnoremap .<M-m> :call GoToLetterboxdMovie()<cr>
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
hi StatusLine term=NONE cterm=NONE ctermfg=blue ctermbg=black guibg=red
hi StatusLineNC term=NONE cterm=NONE ctermfg=blue ctermbg=black guibg=green
hi StatusLineTerm term=NONE cterm=NONE ctermfg=blue ctermbg=black guibg=red
hi StatusLineTermNC term=NONE cterm=NONE ctermfg=blue ctermbg=black guibg=green

" patch-9.0.0340
"     a2a8973e51a0052bb52e43a2b22e7ecdecc32003
"     Removes cmdheight=0.
if exists("&cmdheight") == 1
    if has("patch-9.0.0340") == 1
        set cmdheight=1
        let g:cmdheight_default=1
    else
        "EDIT: Temporarily off until patch cmdheight=0 onto current vim and
        "      fix UI problems like lack of echos.
        " Hide the command line by default.
        "set cmdheight=0
        "let g:cmdheight_default=0
        set cmdheight=1
        let g:cmdheight_default=1
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
    tnoremap <silent> <M-W><M-C> <C-w>:call ToggleCmdHeight()<cr>
endif

set wincolor=Window
hi clear Window
hi clear Normal
"hi Window ctermbg=0 ctermfg=white
hi Window ctermbg=0 ctermfg=grey
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
inoremap <silent> <M-p> <C-r>+
" Helper for pasting and indenting text for notes.
function! SystemPasteLineAndFormatNote()
    call SystemPasteLine()
    normal! `[V`]gq
    normal! `[V`]>
    "todo: Add - breaks.
endfunction
nnoremap <silent> <M-P> :call SystemPasteLineAndFormatNote()<cr>
" wipe the selection's lines then paste a line.
" Note that this doesn't care about column-level selection precision, it just
" wipes all of the lines which the selection spans.
" Select the line at the end so the '< and '> marks are intuitively reset to
" the 'collapsed' selection.
vnoremap <silent> <M-p> <C-c>'<V'>"_c<Esc>:call SystemPasteLine()<cr>V<Esc>
" paste in terminal job mode
tnoremap <silent> <M-p> <C-w>"+
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

" Select the last inserted text.
"todo: Seems to not be accurate.
"Also, maybe trimming whitespace would be intuitive.
nnoremap <M-v><M-i> `[v`]

" VimTerminalEditor
" Called remotely by the vim-terminal-editor script which can be assigned as
" the EDITOR/VISUAL/GIT_EDITOR, etc.

function __VimTerminalEditor_Finish(mode)
    let l:signal = "SIGUSR"..(a:mode == "success" ? "1" : "2")
    call system("kill -"..l:signal.." "..string(getbufvar(str2nr(expand('<abuf>')), "vim_terminal_editor_requesting_pid")))
    call win_gotoid(getbufvar(str2nr(expand('<abuf>')), "launcher_winid"))
    if &buftype ==# 'terminal'
        let b:switch_to_terminal_mode = 1
    endif
    if a:mode == "success" || a:mode == "cancel"
        execute "bwipeout! ".expand('<abuf>')
    endif
    call CheckSwitchToTerminalMode()
endfunction
function! VimTerminalEditor(filename, requesting_pid)
    let l:launcher_winid = bufwinid(bufnr('%'))
    execute "tabnew ".fnameescape(a:filename)
    let b:launcher_winid = l:launcher_winid

    " Pass this onto the buffer so it can use it on autocmd.
    " todo: Can autocmds easily contain evaluating expressions at definition time? e.g. closures.
    let b:vim_terminal_editor_requesting_pid = a:requesting_pid

    " Cancel when Ctrl-C is pressed in normal mode.
    nnoremap <silent> <buffer> <C-c> :call __VimTerminalEditor_Finish("cancel")<cr>
    
    autocmd! * <buffer>
    " Saving finishes the edit.
    autocmd BufWritePost <buffer> call __VimTerminalEditor_Finish("success")
    " Cancel when the buffer is wiped.
    autocmd BufWipeout <buffer> call __VimTerminalEditor_Finish("wipeout")
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

" Close the quickfix if it is the last window.
augroup QFClose
  autocmd!
  " https://stackoverflow.com/questions/7476126/how-to-automatically-close-the-quick-fix-window-when-leaving-a-file
  " Note: Comment below gives attempt fix for vim >=9.1.18, but doesn't work for me.
  " Just using a timer for now to circumvent...
  " I think the reasoning is this would create recursive autocmd triggers, but really
  " I think that should be the responsibility of the user.
  " The below autocmd does trigger again but then the if statement fails.
  autocmd WinEnter *
              \   if winnr('$') == 1 && &buftype == "quickfix"
              \ |     call timer_start(10, {-> execute("quit")})
              \ | endif
augroup END

" Reader mode
" helpful when reading.
" todo: More robust.
function! ToggleReaderMode()
    let val = &t_ve
    if empty(val)
        set t_ve&vim
        nnoremap j gj
        nnoremap k gk
        nunmap u
        nunmap i
    else
        set t_ve=
        " reading with right hand keys
        nnoremap j <C-e>
        nnoremap k <C-y>
        nnoremap u <C-d>
        nnoremap i <C-u>
    endif
endfunction
nnoremap <silent> <M-F> :call ToggleReaderMode()<cr>

"https://vi.stackexchange.com/questions/17262/iedit-behaviour-in-vim/17272#17272
"--------------------------------------------------------------------------------
"function! GetTextObject(type, is_visual)
"    let sel_save = &selection
"    let &selection = "inclusive"
"    let reg_save = @@
"    if a:is_visual
"      silent execute "normal! gvy"
"    elseif a:type == 'line'
"      silent execute "normal! '[V']y"
"    else
"      silent execute "normal! `[v`]y"
"    endif
"    let text = @@
"    let &selection = sel_save
"    let @@ = reg_save
"    return text
"endfunction
"
"function! ReplaceOperator(type, ...)
"    let text = GetTextObject(a:type, a:0)
"    call feedkeys(":%s/".text."//g\<left>\<left>", "n")
"endfunction
"nnoremap gr :set opfunc=ReplaceOperator<cr>g@
"vnoremap gr :<C-u>call ReplaceOperator(visualmode(), 1)<cr>
"
"function! AppendReplaceOperator(type, ...)
"    let text = GetTextObject(a:type, a:0)
"    call feedkeys(":%s/".text."/".text."/g\<left>\<left>", "n")
"endfunction
"nnoremap gA :set opfunc=AppendReplaceOperator<cr>g@
"vnoremap gA :<C-u>call AppendReplaceOperator(visualmode(), 1)<cr>
"
"function! PrependReplaceOperator(type, ...)
"    let text = GetTextObject(a:type, a:0)
"    call feedkeys(":%s/".text."/".text."/g".repeat("\<left>", len(text) + 2), "n")
"endfunction
"nnoremap gI :set opfunc=PrependReplaceOperator<cr>g@
"vnoremap gI :<C-u>call PrependReplaceOperator(visualmode(), 1)<cr>
"--------------------------------------------------------------------------------

nnoremap <M-n> :!nsup -n<cr><cr>
nnoremap <M-N> :!nsup<cr><cr>

" temporary-----
" Because xterm colors have light background which hurts my eyes
nnoremap <C-9> :hi Normal ctermbg=0<cr>

function! DTCommand(command)
    if &buftype ==# 'terminal'
        let b:switch_to_terminal_mode = 1
    endif
    tabnew
    let l:options = {
        \ 'term_name': a:command,
        \ 'curwin': 1
        \ }
    call term_start("runsummary "..a:command, l:options)
    let b:custom_terminal_buffer_name = 1
endfunction

function! DTFCommand(command)
    if &buftype ==# 'terminal'
        let b:switch_to_terminal_mode = 1
    endif
    tabnew
    let l:options = {
        \ 'term_name': a:command,
        \ 'curwin': 1,
        \ 'term_finish': 'close'
        \ }
    call term_start(a:command, l:options)
    let b:custom_terminal_buffer_name = 1
endfunction

"TODO: Quote correctly
"command! -nargs=* DTCommand call DTCommand(<q-args>)
"command! -nargs=* DTFCommand call DTFCommand(<q-args>)

" Window focus history
let g:window_focus_history_max_length = 100
if !exists('g:window_focus_history')
    let g:window_focus_history = []
endif

augroup WindowFocusHistory
    autocmd!
    autocmd WinEnter * call s:track_window_focus()
augroup END

function! s:track_window_focus()
    let id = win_getid()
    if empty(g:window_focus_history) || g:window_focus_history[-1] != id
        call add(g:window_focus_history, id)
    endif
    let length = len(g:window_focus_history)
    if length > g:window_focus_history_max_length
        for i in range(length - g:window_focus_history_max_length)
            call remove(g:window_focus_history, 0)
        endfor
    endif
endfunction

" Easier redir use.
" Keybindings in command mode to insert or system yank (clip) the output.
" Commands are run with :silent.
function! ClipExCommand(...)
    redir @+>
    silent execute join(a:000, ' ')
    redir END
endfunction
function! InsertExCommand(...)
    " Note: Having problems with using redirection to local variables. Bug?
    " Workaround: Using @+ redirection instead.
    let l:tmp = @+
    redir @+
    silent execute join(a:000, ' ')
    redir END
    put +
    let @+ = l:tmp
endfunction
command! -nargs=* ClipExCommand call ClipExCommand(<f-args>)
command! -nargs=* InsertExCommand call InsertExCommand(<f-args>)
cnoremap <M-y> <C-\>e"ClipExCommand ".getcmdline()<cr><cr>
cnoremap <M-i> <C-\>e"InsertExCommand ".getcmdline()<cr><cr>

" System paste in command mode.
cnoremap <M-p> <C-r>=@+<cr>

" Print runtimepath
command! -bar -nargs=0 Runtimepath echo substitute(&runtimepath, ",", "\n", "g")
" Print packpath
command! -bar -nargs=0 Packpath echo substitute(&packpath, ",", "\n", "g")
" Print both runtimepath and packpath
command! -bar -nargs=0 Vimpath echo "runtimepath" | Runtimepath | echo "packpath" | Packpath
command! -bar -nargs=0 Vimpath
            \   echo join(map(split(substitute(&runtimepath, ",", "\n", "g"), "\n"), {_, v -> "runtimepath: " . v}), "\n")
            \ | echo join(map(split(substitute(&packpath, ",", "\n", "g"), "\n"), {_, v -> "packpath: " . v}), "\n")

"------------------------------------------------------------
" Manipulate hidden buffers

function! GetHiddenBuffers(...)
    let l:include_unlisted = get(a:000, 0, 0)
    
    " (Note: Using :ls output because there doesn't seem to be a "bufhidden()" available.
    let l:hidden_buffers = []
    redir => l:ls
    if l:include_unlisted
        silent ls!
    else
        silent ls
    endif
    redir END
    let l:ls_lines = split(l:ls, "\n")
    for line in l:ls_lines
        let line = split(line, "\"")[0]
        let match = matchlist(line, '\v\s+(\d+)(.*)')
        if empty(match)
            continue
        endif
        let bufnr = match[1]
        let flags = match[2]

        let unlisted_flag = flags[0] == "u"
        let hidden_flag = flags[2] == "h"
        let active_flag = flags[2] == "a"

        if hidden_flag || (unlisted_flag && !active_flag)
            let hidden_buffers += [str2nr(bufnr)]
        endif
    endfor
    return l:hidden_buffers
endfunction

" Count the number of hidden buffers.
function! NumHiddenBuffers(...)
    let l:include_unlisted = get(a:000, 0, 0)
    return len(GetHiddenBuffers(l:include_unlisted))
endfunction

function! CleanHiddenBuffers(...)
    " If set, also delete unlisted hidden buffers.
    let l:include_unlisted = get(a:000, 0, 0)

    let l:hidden_buffers = GetHiddenBuffers(l:include_unlisted)

    let l:successfully_deleted_bufs = []
    let l:successfully_deleted_bufnames = []
    for bufnr in l:hidden_buffers
        if !getbufvar(bufnr, '&modified') && getbufvar(bufnr, '&buftype') !=# 'terminal'
            let v:errmsg = ""
            let bufname = bufname(bufnr)
            if l:include_unlisted
                execute 'bwipeout' bufnr
            else
                execute 'bdelete' bufnr
            endif
            if v:errmsg != ""
                echo "Buffer delete failed: "..v:errmsg
                let v:errmsg = ""
            else
                let l:successfully_deleted_bufs += [bufnr]
                let l:successfully_deleted_bufnames += [bufname]
            endif
        endif
    endfor

    let l:msg0 = l:include_unlisted ? "Wiped out" : "Deleted"
    echo "CleanHiddenBuffers: "..l:msg0 l:successfully_deleted_bufnames
endfunction

" CleanHiddenBuffers
"     Delete all hidden buffers which are not modified and are not terminals.
" CleanHiddenBuffers!
"     Do the same, but include unlisted buffers, and wipeout the buffers instead of delete.
command! -bang -nargs=0 CleanHiddenBuffers call CleanHiddenBuffers(<bang>0)
" Keybindings
nnoremap <M-b><M-q> :CleanHiddenBuffers<cr>
nnoremap <M-b><M-Q> :CleanHiddenBuffers!<cr>
nnoremap <M-B><M-Q> :CleanHiddenBuffers!<cr>

"------------------------------------------------------------

"------------------------------------------------------------
" Execute selected vimscript
vnoremap <M-e><M-e> :source<cr>
" Execute vimscript line
nnoremap <M-e><M-e> :.source<cr>
" Execute selected bash.
vnoremap <M-e><M-b> :w !bash<cr>
" Execute bash line
nnoremap <M-e><M-b> :.w !bash<cr>
"------------------------------------------------------------

"------------------------------------------------------------
" Keep track of which window was last focused in a tab.
" The effect is that each tab has a persistent "focus window"
" which can be displayed in the UI, e.g. the tab panel.

" TabWindowFocus
let g:TabWindowFocus_debug = 0
function! TabWindowFocus_TabLeave()
    if g:TabWindowFocus_debug
        call DEBUGLOG("From: tab("..tabpagenr().."), win("..winnr()..")")
        call DEBUGLOG(string(t:winmru))
    endif
    let t:tabwindowfocus_winid_tableave = win_getid()
endfunction
function! TabWindowFocus_TabEnter()
    if g:TabWindowFocus_debug
        call DEBUGLOG("To: tab("..tabpagenr().."), win("..winnr()..")")
        call DEBUGLOG(string(t:winmru))
    endif
    if exists("t:tabwindowfocus_winid_tableave")
        let win = win_id2win(t:tabwindowfocus_winid_tableave)
        if win != 0
            execute win.."wincmd w"
        endif
        unlet t:tabwindowfocus_winid_tableave
    endif
endfunction
function! TabWindowFocus_WinEnter()
    let t:tabwindowfocus_winid_winenter = win_getid()
endfunction
augroup TabWindowFocus
    autocmd!
    autocmd TabLeave * silent call TabWindowFocus_TabLeave()
    autocmd TabEnter * silent call TabWindowFocus_TabEnter()
    autocmd WinEnter * silent call TabWindowFocus_WinEnter()
augroup END
" Call for the initial window.
" (see :help WinEnter, it doesn't trigger for the starting window.)
call TabWindowFocus_WinEnter()
"------------------------------------------------------------

" :help terminal-api
function! Tapi_vim_terminal_cd(buf, working_directory)
    " echo "wd: "..a:working_directory
    call setbufvar(a:buf, "shell_working_directory", a:working_directory)

    " Refresh the tab panel since it displays shell working directories.
    redrawtabpanel
endfunction
function! StartShellPoller()
    " Start an async poller for this terminal.
    let buf = bufnr('%')
    if getbufvar(buf, "shell_poller", v:null) == v:null
        let job = term_getjob(buf)
        if job != v:null
            let pid = job_info(job)["process"]
            let poller_options = {}
            let poller_command = [$HOME.."/config/vim/vim_terminal_shell_poller", string(pid), string(buf)]
            let poller = job_start(poller_command, poller_options)
            "TODO: Add buffer number to an autocommand BufDelete to delete poller.
            call setbufvar(buf, "shell_poller", poller)
            call setbufvar(buf, "shell_poller_runtime_subdir", "state/"..pid..":"..buf)
        endif
    endif
endfunction
augroup Poller
    autocmd!
    autocmd TerminalOpen * call timer_start(100, {-> StartShellPoller()})
augroup END

augroup Terminal_WinLeave
    autocmd!
    "TODO: This is failing with:
    "    :tab term ++close lf
    "TODO: This is inserting in non-terminal windows. Does :normal delay?
    "autocmd WinLeave *
    "          \   if &buftype == 'terminal' && mode() == 'n' && job_info(term_getjob(bufnr())).status ==# 'run'
    "          \ |     normal! i
    "          \ | endif
augroup END

" Resizing
" (May not be necessary when termwinsize is empty, e.g. vim automatically resizes its terminals.)
function! DoVimResize()
    for tab in gettabinfo()
        for window in get(tab, "windows")
            let buf = winbufnr(window)
            let buftype = getbufvar(buf, "&buftype")
            if buftype == "terminal"
                call term_setsize(buf, winheight(window), winwidth(window))
            endif
        endfor
    endfor
endfunction
augroup Resizing
    autocmd!
    autocmd VimResized * call DoVimResize()
augroup END

" File browsing
function! Lf_Popup_Callback(buf)
    " The popup is closed when moving it between tabs.
    " This option is set in that case, so skip this callback.
    if exists("g:has_left_popup_terminal_options")
        return
    endif
    
    "Note: Without an async timer, the wipeout gets the focus buffer.
    "    But the buffer is given explicitly.
    "    Unsure why this bug.
    "
    call timer_start(10, {-> execute("bwipeout! "..a:buf)})
    "bwipeout! "..a:buf
endfunction
function! Lf_Popup(launcher_winid, wd, ...)
    let wd = a:wd
    let launcher_winid = a:launcher_winid
    let launcher_buf = Win_id2bufnr(launcher_winid)
    let launcher_buftype = getbufvar(launcher_buf, "&buftype", "")
    let lf_options = get(a:000, 0, {})

    let launcher_file = ""
    let launcher_term = -1

    " Infer the launcher file from the current buffer.
    if launcher_buftype == ""
        let launcher_file = expand("%:p")
    elseif launcher_buftype == "terminal"
        let job = term_getjob(launcher_buf)
        if job == v:null
            return
        endif

        let swd = getbufvar(launcher_buf, "shell_working_directory", "")
        if swd == ""
            return
        endif

        let foreground_pid = -1
        if exists("$DIRSPACE_VIM_RUNTIME")
            let shell_poller_runtime_subdir = getbufvar(launcher_buf, "shell_poller_runtime_subdir", "")
            if shell_poller_runtime_subdir != ""
                let dir = $DIRSPACE_VIM_RUNTIME.."/"..shell_poller_runtime_subdir
                if filereadable(dir.."/foreground_pid")
                    let foreground_pid = readfile(dir.."/foreground_pid")[0]
                    let pid = job_info(job)["process"]
                    if foreground_pid == pid
                        let launcher_file = swd
                        call DEBUGLOG("launched from shell")
                        let launcher_term = launcher_buf
                    else
                        return
                    endif
                endif
            endif
        endif

        if foreground_pid == -1
            let launcher_file = swd
        endif
    else
        " Don't create the popup if can't infer the launcher file.
        return
    endif

    let global_cwd = getcwd(-1)
    noautocmd execute "cd "..fnameescape(wd)
    let cmd = ['lfnoshell']

    if launcher_term != -1
        let cmd += ["-command", "set user_launcher_term "..string(launcher_term)]
    endif

    if launcher_file != ""
        let cmd += ["-command", "set user_launcher_file "..shellescape(launcher_file)]
        if get(lf_options, 'focus_launcher_file', 0)
            let cmd += [launcher_file]
        endif
    endif

    let buf = term_start(cmd, #{hidden: 1, term_finish: 'close'})

    noautocmd execute "cd "..fnameescape(global_cwd)

    " NOTE: Bug workaround.
    "     Popup placement does not take into account tab panel.
    "     But all the other things like winheight, winwidth do, so if calculated from that,
    "     it will be placed incorrectly.
    let over_screen = 1
    let window_horizontal_ratio = 0.9
    " 2.13: Approximate terminal font aspect ratio, todo.
    let window_vertical_ratio = 1 - (1 - window_horizontal_ratio)*2.13
    let screen_horizontal_ratio = 0.65
    let screen_vertical_ratio = 1 - (1 - screen_horizontal_ratio)*2.13*0.5

    if over_screen == 1
        " Display the popup over the whole screen.
        " Note that popups cannot be displayed over the tab panel.
        " If they would be, vim just displays them shifted to the right
        " (or left if the tab panel is right aligned.)
        let cols = &columns
        let lines = &lines
        let height = float2nr(floor(lines * screen_vertical_ratio))
        let width  = float2nr(floor(cols * screen_horizontal_ratio))
        let line   = (lines - height)/2
        let col    = (cols - width)/2
    else
        " Display the popup over the current window.
        let winpos = win_screenpos(winnr())
        let height = float2nr(floor(winheight(0) * window_vertical_ratio))
        let width  = float2nr(floor(winwidth(0) * window_horizontal_ratio))
        let line   = winpos[0] + (winheight(0) - height) / 2
        let col    = winpos[1] + (winwidth(0) - width) / 2
    endif

    " Determine the title.
    " This can e.g. indicate the launcher file.
    let title = ""
    if launcher_file != ""
        let title .= "launcher: "
        let title .= launcher_file
    endif
    if launcher_term != -1
        if launcher_file != ""
            let title .= "    "
        endif
        let title .= "launcher_term: "
        let title .= string(launcher_term)..":"..bufname(launcher_term)
    endif

    let left_pillar = '▛'
    let right_pillar = '▜'
    let options = {
        \ 'callback' : {p -> Lf_Popup_Callback(buf)},
        \ 'line' : line,
        \ 'col'  : col,
        \ 'minheight' : height,
        \ 'maxheight' : height,
        \ 'minwidth' : width,
        \ 'maxwidth' : width,
        \ 'scrollbar' : 0,
        \ 'title' : title,
        \ 'cursorline' : 0,
        \ 'wrap' : 0,
        \ 'highlight' : 'hl-Normal',
        \ 'border' : [1, 1, 1, 1],
        \ 'borderchars': [' ', left_pillar, ' ', right_pillar, right_pillar, left_pillar, left_pillar, right_pillar],
        "\ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ 'borderhighlight' : ['TerminalBorder'],
        \ }
    call popup_create(buf, options)
endfunction

hi TerminalBorder cterm=underline ctermfg=darkgrey ctermbg=black
hi link Terminal Normal
nnoremap <silent> <M-;> :call Lf_Popup(win_getid(), getcwd(-1), {  })<cr>
nnoremap <silent> <M-:> :call Lf_Popup(win_getid(), "", { 'focus_launcher_file' : 1 })<cr>
tnoremap <silent> <M-;> <C-w>:call Lf_Popup(win_getid(), getcwd(-1), { })<cr>
tnoremap <silent> <M-:> <C-w>:call Lf_Popup(win_getid(), "", { 'focus_launcher_file' : 1 })<cr>

" This function should be called from lf in a vim terminal.
" It creates another lf with the same state in a horizontal split.
" If the window is a popup, it is created below the other windows below.
" lf does not have tabs or splits on purpose, the author intends people to DIY
" a workflow using multiple lfs with deletion/yank lists synchronized over
" ~/.local/share/lf/files.
" So, this is one implementation of the Midnight Commander style side-by-side.
function! Lf_Split(oldpwd, pwd, f)
    let oldpwd = a:oldpwd
    let pwd = a:pwd
    let f = a:f

    " If lf is run in a popup terminal,
    " then window creations can't be run while it is focused.
    " A workaround for this is to close the popup window, run the commands,
    " then re-open it with the same options.
    let winid = win_getid()
    let buf = bufnr()
    silent! let popup_options = popup_getoptions(win_getid())
    if popup_options != {}
        call popup_close(winid)
    endif

    let global_cwd = getcwd(-1)
    noautocmd execute "cd "..fnameescape(oldpwd)
    execute "botright term ++close lf -command \"cd "..shellescape(pwd).."\" -command \"select "..shellescape(f).."\""
    noautocmd execute "cd "..fnameescape(global_cwd)

    " Restore the popup window.
    if popup_options != {}
        call popup_create(buf, popup_options)
    endif
endfunction

function! Lf_Edit(f, mode, ...)
    let f = a:f
    let mode = a:mode
    let force_close_lf = get(a:000, 0, 0)

    if index(["left", "right", "up", "down", "tab", "here", "nop"], mode) == -1
        return
    endif
    
    " If lf is run in a popup terminal,
    " then window creations can't be run while it is focused.
    " A workaround for this is to close the popup window, run the commands,
    " then re-open it with the same options.
    let winid = win_getid()
    let buf = bufnr()
    silent! let popup_options = popup_getoptions(win_getid())
    if popup_options != {}
        " Indicate to popup callback not to trigger wipeout on close.
        if force_close_lf == 0
            let g:has_left_popup_terminal_options = popup_options
        endif
        call popup_close(winid)
    endif
    
    if mode == "left"
        execute "leftabove vsplit "..fnameescape(f)
    elseif mode == "right"
        execute "vsplit "..fnameescape(f)
    elseif mode == "up"
        execute "split "..fnameescape(f)
    elseif mode == "down"
        execute "rightbelow split "..fnameescape(f)
    elseif mode == "tab"
        execute "tabnew "..fnameescape(f)
    elseif mode == "here"
        execute "edit "..fnameescape(f)
    elseif mode == "nop"
        " Don't do anything.
        " This option is here to get all the rest of the effects,
        " such as force closing the popup window, without editing anything.
    endif
    "TODO: Alt key stuff is buggy, but this seems to fix some problems here.
    if mode != "nop"
        call ResetAltKeyMappings()
    endif
    
    " Restore the popup window.
    if popup_options != {}
        if force_close_lf == 0
            call popup_create(buf, popup_options)
            unlet g:has_left_popup_terminal_options
        endif
    endif
endfunction

augroup PopupTerminal
    autocmd!
    " Move popup terminal to the active tab.
    " Vim doesn't allow multiple popup terminals anyway, and does bring the
    " popup to this tab's window list even though it is not shown on this tab.
    " So it makes sense that a popup terminal should be over the screen, not a
    " single tab.
    " Note that a popup terminal steals all focus on its own tab.
    " So, it can safely be assumed that it is in focus on TabLeave.
    autocmd TabLeave *
              \   if &buftype == 'terminal'
              \ |     silent! let g:tmp_popup_options = popup_getoptions(win_getid())
              \ |     if g:tmp_popup_options != {}
              \ |        let g:has_left_popup_terminal_buffer = bufnr()
              \ |        let g:has_left_popup_terminal_options = g:tmp_popup_options
              \ |        call popup_close(win_getid())
              \ |     endif
              \ |     unlet g:tmp_popup_options
              \ | endif
    autocmd TabEnter *
              \   if exists("g:has_left_popup_terminal_options")
              \ |     call popup_create(g:has_left_popup_terminal_buffer, g:has_left_popup_terminal_options)
              \ |     unlet g:has_left_popup_terminal_buffer
              \ |     unlet g:has_left_popup_terminal_options
              \ | endif
augroup END



" Dirspace runs vim with an extra script passed on the command line.
" This script is meant to run after vim initialization,
" such as overriding the tabline/tabpanel behaviour.
" g;is_dirspace_vim is set when that script is source'd,
" so on the first vimrc source, the below won't be run.
" This mechanism is here so when I source my vimrc in a dirspace,
" vim runs RC scripts as it did when it was invoked in the command line.
if exists("g:is_dirspace_vim") && g:is_dirspace_vim == 1
    source ~/config/dirspace/dirspace_vimrc.vim
endif


