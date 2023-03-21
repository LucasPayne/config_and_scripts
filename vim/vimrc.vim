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
">>>

" Plugins
"    execute pathogen#infect()
"    ...
"<<<
execute pathogen#infect()
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
    execute "set <M-p>=\ep"
    nnoremap <M-p> :Tig<cr>
    nnoremap .bl :TigBlame<cr>
    let g:tig_explorer_keymap_edit_e  = 'e'
    let g:tig_explorer_keymap_edit    = '<C-o>'
    let g:tig_explorer_keymap_tabedit = 'E'
    let g:tig_explorer_keymap_split   = '_'
    let g:tig_explorer_keymap_vsplit  = '|'
    
    let g:tig_explorer_keymap_commit_edit    = '<ESC>o'
    let g:tig_explorer_keymap_commit_tabedit = '<ESC>t'
    let g:tig_explorer_keymap_commit_split   = '<ESC>s'
    let g:tig_explorer_keymap_commit_vsplit  = '<ESC>v'
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
">>>

" Vim server
" ...
"<<<
if $NO_VIM_SERVER != "1"
    nnoremap <C-z> :call SuspendNoVimDir()<cr>
    " Suspend and save vimdir so bash scripts can cd to it.
    nnoremap <leader>z :call SuspendNoVimDir()<cr>
    nnoremap <leader>Z :call Suspend()<cr>
    nnoremap <leader>Z :call Suspend()<cr>
    " Alt-q is much easier to press. Also can bind Alt-q to re-open vim session in readline.
    execute "set <M-q>=\eq"
    nnoremap <M-q> :call SuspendNoVimDir()<cr>
    
    function! Suspend()
        call SaveDir()
        suspend
    endfunction
    function! SaveDir()
        silent! execute "!echo \"".expand("%:p:h")."\" > /tmp/vimdir"
    endfunction
    
    function! SuspendNoVimDir()
        silent! execute "!rm /tmp/vimdir"
        suspend
    endfunction
    
    autocmd VimLeave * :!echo "1" > /tmp/${VIM_SERVER_ID}_vim_server_closed
endif
">>>


" Debugging
" ...
"<<<
packadd termdebug
hi debugPC ctermbg=white
"hi SignColumn ctermbg=blue
nnoremap .F :Termdebug<cr>
"todo: Should have alt keybindings which also work in the gdb prompt.
" nnoremap .ff :Gdb<cr>
" nnoremap .fa :Asm<cr>
" nnoremap .fs :Source<cr>
" nnoremap .fp :Program<cr>

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
nnoremap .f :call ToggleQuickFix()<cr>

" Global variable for access by quickfixtextfunc.
let g:quickfix_callstack_frame_dicts = []

function! QuickfixCallstackFromGDB()
    let l:json_file_path = "/tmp/gdb__vim_serialize_stacktrace"
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
