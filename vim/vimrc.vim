"
"
"
"
"
"
"
"

function! ResolveIncludeFile(file_identifier)
    " Given a file path, extracted from an include statement, search
    " for the relevant installed file.
    " If none is found, return the empty string.

    " Try the -/weta/code metadata.
    let l:cmd = g:STUFF."weta/code/bin/resolve_include \"".a:file_identifier."\" -f \"".expand('%')."\""
    let l:resolved_include = system(l:cmd)
    if !empty(l:resolved_include)
        return l:resolved_include
    endif
    
    return ''
endfunction

function! ExtractLink(line_number)
    " Extract a link from the given line, if there is one.
    " Returns a string of the form /path/to/file:line_number,
    " or the empty string if there is no link.
    let l:line = getline(a:line_number)

    " Try to extract an include link.
    if l:line =~# '^\s*#include <.*>'
        let l:file_identifier = matchstr(l:line, '^\s*#include <\zs.*\ze>')
        if !empty(l:file_identifier)
            let l:resolved_file = ResolveIncludeFile(l:file_identifier)
            if !empty(l:resolved_file)
                " Return a link to the first line.
                return l:resolved_file.":1"
            endif
        endif
    endif

    " Try to extract a file location from a line of the form
    " /path/to/file line_number
    let l:list = split(l:line)
    if len(l:list) == 2
        let l:path = get(l:list, 0, "")
        let l:line_number_string = get(l:list, 1, "")
        if l:line_number_string =~# '^\d\+$'
            let l:line_number = str2nr(l:line_number_string)
            return l:path.":".l:line_number
        endif
    endif

    return ''
endfunction

function! FollowLinks(make_new_tab) range
    " Try to interpret the current line as a link to a file location.
    " let l:link = ExtractLink()
    " if empty(l:link)
    "     return
    " endif
    " let l:parts = split(l:link, ':')
    " let l:path = get(l:parts, 0, "")
    " let l:line_number = get(l:parts, 1, "")

    " if a:make_new_tab == 1
    "     execute "tabnew ".l:path
    " else
    "     execute "e ".l:path
    " endif
    " call cursor(l:line_number,1)

    let l:line_index = a:firstline

    let l:commands_to_run = []
    while l:line_index != a:lastline + 1
        
        let l:link = ExtractLink(l:line_index)
        if empty(l:link)
            return
        endif
        let l:parts = split(l:link, ':')
        let l:path = get(l:parts, 0, "")
        let l:line_number = get(l:parts, 1, "")

        if l:line_index > a:firstline || a:make_new_tab == 1
            " Make a new tab for for each file after the first.
            " If make_new_tab is 1, then a new tab is also created for the first.
            call add(l:commands_to_run, "tabnew ".l:path)
        else
            call add(l:commands_to_run, "e ".l:path)
        endif

        call add(l:commands_to_run, "call cursor(".l:line_number.",1)")

        let l:line_index += 1
    endwhile

    " Commands are deferred because something goes wrong with the range if the buffer is switched.
    " (?)
    for l:command in l:commands_to_run
        execute l:command
    endfor
endfunction
nnoremap <leader>/ :call FollowLinks(0)<cr>
nnoremap <leader>? :call FollowLinks(1)<cr>
vnoremap <leader>/ :.call FollowLinks(0)<cr>
vnoremap <leader>? :.call FollowLinks(1)<cr>
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
nnoremap <leader>cp :call YankFilePath()<cr>
nnoremap <leader>CP :call YankWordAndFilePath()<cr>
vnoremap <leader>cp :call YankSelectionAndFilePath()<cr>
nnoremap <leader>cb :call YankBreakPoint()<cr>

" Settings
"    syntax on
"    ...
"<<<
syntax on
filetype plugin indent on
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
" set autochdir
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
" set showtabline=2
set showtabline=1
set splitright
" Don't resize splits when closing a window.
set noequalalways
" Alt key mappings
" If terminal is sending modifiers as esc-key.
" For some reason, the below works!
" TODO: Do this without autocmds, setlocal not working?
let g:alphabet = "abcdefghijklmnopqrstuvwxyz"
function! ResetAltKeyMappings()
    if &buftype != "terminal"
        for char in g:alphabet
            execute "setlocal <M-".char.">=\e".char
        endfor
    else
        for char in g:alphabet
            execute "setlocal <M-".char.">="
        endfor
    endif
endfunction
function! UnsetAltKeyMappings()
    for char in g:alphabet
        execute "setlocal <M-".char.">="
    endfor
endfunction
autocmd TerminalOpen * silent! call UnsetAltKeyMappings()
autocmd WinEnter * silent! call ResetAltKeyMappings()
autocmd TabEnter * silent! call ResetAltKeyMappings()
autocmd BufEnter * silent! call ResetAltKeyMappings()

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
nnoremap .ev :edit ~/.vimrc<cr>
nnoremap .sv :source ~/.vimrc<cr>
inoremap <tab> <space><space><space><space>
nnoremap j gj
nnoremap k gk
nnoremap gj gT
nnoremap gk gt
" Source selection
vnoremap <leader>S :<C-u>@*<cr>
" Quick write
nnoremap <M-w> :w<cr>
inoremap <M-w> <Esc>:w<cr>
" Quick navigate windows
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
" Quick close window
nnoremap <M-x> :q<cr>
">>>

" Plugins
"    execute pathogen#infect()
"    ...
"<<<
execute pathogen#infect()
execute pathogen#helptags()
function! PluginEnabled(plugin_name)
    let l:path = expand("~")."/.vim/bundle/".a:plugin_name
    return filereadable(l:path) || isdirectory(l:path)
endfunction

if PluginEnabled("vim-surround") == 1
    nmap s ys
endif

if PluginEnabled("tagbar") == 1
    nnoremap <leader>T :Tagbar<cr>
endif

if PluginEnabled("tig-explorer.vim") == 1
    let g:tig_explorer_use_builtin_term = 0

    let g:tig_explorer_keymap_edit_e  = 'e'
    let g:tig_explorer_keymap_edit    = 'e'
    let g:tig_explorer_keymap_tabedit = 'E'
    let g:tig_explorer_keymap_split   = '_'
    let g:tig_explorer_keymap_vsplit  = '|'
    
    "let g:tig_explorer_keymap_commit_edit    = 'o'
    "let g:tig_explorer_keymap_commit_tabedit = 'O'
    "let g:tig_explorer_keymap_commit_split   = '<C-_>'
    "let g:tig_explorer_keymap_commit_vsplit  = '<C-o>'

    nnoremap <M-p> :Tig<cr>
    nnoremap <M-o> :TigOpenCurrentFile<cr>
    nnoremap .bl :TigBlame<cr>
endif

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

">>>

" Colors and syntax highlighting
"    set colorscheme ...
"    ...
"<<<
colorscheme solarized
set background=dark
hi LineNr ctermbg=None
hi Normal ctermbg=None
"hi Normal ctermfg=White
"hi Comment ctermfg=Blue
set fillchars=eob:\ 
set signcolumn=auto
hi SignColumn ctermbg=none
">>>

" Cursor styles
"    ...
"<<<
" Change between cursor modes.
" https://vi.stackexchange.com/questions/7306/vim-normal-and-insert-mode-cursor-not-changing-in-gnu-screen
if &term =~ "screen."
    let &t_ti.="\eP\e[1 q\e\\"
    let &t_SI.="\eP\e[5 q\e\\"
    let &t_EI.="\eP\e[1 q\e\\"
    let &t_te.="\eP\e[0 q\e\\"
else
    let &t_ti.="\<Esc>[1 q"
    let &t_SI.="\<Esc>[5 q"
    let &t_EI.="\<Esc>[1 q"
    let &t_te.="\<Esc>[0 q"
endif
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

" Vim server
" ...
"<<<
"if $NO_VIM_SERVER != "1"
"    nnoremap <C-z> :call SuspendNoVimDir()<cr>
"    " Suspend and save vimdir so bash scripts can cd to it.
"    nnoremap <leader>z :call SuspendNoVimDir()<cr>
"    nnoremap <leader>Z :call Suspend()<cr>
"    nnoremap <leader>Z :call Suspend()<cr>
"    " Alt-q is much easier to press. Also can bind Alt-q to re-open vim session in readline.
"    execute "set <M-q>=\eq"
"    nnoremap <M-q> :call SuspendNoVimDir()<cr>
"    
"    function! Suspend()
"        call SaveDir()
"        suspend
"    endfunction
"    function! SaveDir()
"        silent! execute "!echo \"".expand("%:p:h")."\" > /tmp/vimdir"
"    endfunction
"    
"    function! SuspendNoVimDir()
"        silent! execute "!rm /tmp/vimdir"
"        suspend
"    endfunction
"    
"    autocmd VimLeave * :!echo "1" > /tmp/${VIM_SERVER_ID}_vim_server_closed
"endif
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
    sleep 50m
    "call TermDebugSendCommand("json_serialize_breakpoints")
    TermdebugSendCommand json_serialize_breakpoints
    sleep 50m
    call BreakpointsQuickfix()
    Source
endfunction
function! DoTermdebugCodeMove(cmd)
    execute a:cmd
    sleep 50m
    "call TermDebugSendCommand("json_serialize_stacktrace")
    TermdebugSendCommand json_serialize_stacktrace
    sleep 50m
    call QuickfixCallstackFromGDB()
    Source
endfunction
nnoremap <space>b :call DoTermdebugBreakpointModify("Break")<cr>
nnoremap <space>B :call DoTermdebugBreakpointModify("Clear")<cr>
nnoremap <space>u :call DoTermdebugCodeMove("Until")<cr>
nnoremap <space>n :call DoTermdebugCodeMove("Over")<cr>
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
    call TermDebugSendCommand("__vim_write_selected_frame_number")
    " Note: Apparently there is a race condition...
    sleep 25m
    let l:frame_number = readfile("/tmp/gdb__vim_write_selected_frame_number")[0]
    call TermDebugSendCommand("select-frame ".(l:frame_number+a:jump))

    " Todo: Simplify this, don't require multiple calls.
    " -- To do this, need to query max frame number.
    call TermDebugSendCommand("__vim_write_selected_frame_number")
    sleep 25m
    let l:frame_number = readfile("/tmp/gdb__vim_write_selected_frame_number")[0]
    execute "cc ".(l:frame_number+1)

    "--------------------------------------------------------------------------------
    " pwndbg
    " call TermDebugSendCommand("context")
endfunction

nnoremap [f :call GDBRelativeFrame(-1)<cr>zz
nnoremap ]f :call GDBRelativeFrame(1)<cr>zz

function! ToggleQuickFix()
    " https://stackoverflow.com/questions/11198382/how-to-create-a-key-map-to-open-and-close-the-quickfix-window-in-vim
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        copen
        let l:quickfix_list_length = len(getqflist())
        let l:quickfix_window_height = min([l:quickfix_list_length, 12])
        execute "resize ".l:quickfix_window_height
    else
        cclose
    endif
endfunction
nnoremap <space>w :call ToggleQuickFix()<cr>

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

    augroup filetype_qf
        autocmd!
        autocmd Filetype qf setlocal nonumber
        autocmd Filetype qf setlocal statusline=%{QuickfixCallstackStatusLine()}
    augroup END

    cclose
    call ToggleQuickFix()
    copen

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

    augroup filetype_qf
        autocmd!
        autocmd Filetype qf setlocal nonumber
        autocmd Filetype qf setlocal statusline=%{BreakpointsQuickfixStatusLine()}
    augroup END

    cclose
    call ToggleQuickFix()
    copen
endfunction

function! BreakpointsQuickfixStatusLine()
    return "  Breakpoints"
endfunction

function! BreakpointsQuickfixSyncGdb()
    call TermDebugSendCommand("json_serialize_breakpoints")
    sleep 150m
    call BreakpointsQuickfix()
endfunction

nnoremap .2 :call BreakpointsQuickfixSyncGdb()<cr>


">>>

" Terminal
" ...
"<<<

function! VimTerminalHostStart()
    let g:terminal_host_primary_shell_buffer = term_start('bash', {
        \ 'term_name' : 'shell',
        \ 'curwin' : 1
        \ })
    let g:terminal_host_primary_shell_winid = win_getid(winnr())
endfunction

function! GoToPrimaryShell()
    call win_gotoid(g:terminal_host_primary_shell_winid)
    normal! A
endfunction

function! CtrlCHandler()
    if &buftype == "terminal"
        " Note: startinsert is ineffective in terminal mode.
        execute "normal! i"
    else
        execute "normal! <C-c>"
    endif
endfunction

"tnoremap JK <C-\><C-n>
tnoremap <C-j><C-k> <C-\><C-n>
nnoremap <C-c> :call CtrlCHandler()<cr>
tnoremap <C-w><C-j> <C-w>gT
tnoremap <C-w><C-k> <C-w>gt
nnoremap <C-w><C-j> gT
nnoremap <C-w><C-k> gt
nnoremap <space>c :term ++curwin<cr>
nnoremap <space>C :tabnew<cr>:term ++curwin<cr>
nnoremap <M-q> :call GoToPrimaryShell()<cr>
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

" Source the syncer'd mappings.
source $CONFIG_DIR/scripts/syncer_files/syncer-vim.vim
