"
"
"
"

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
set number
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
nnoremap gj gT
nnoremap gk gt
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
">>>

" Colors and syntax highlighting
"    set colorscheme ...
"    ...
"<<<
colorscheme solarized
set background=dark
">>>


" Vim server
" ...
"<<<
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
">>>


" Debugging
" ...
"<<<
packadd termdebug
hi debugPC ctermbg=white
hi SignColumn ctermbg=blue
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
    sleep 50m
    call TermDebugSendCommand("frame ".(readfile("/tmp/gdb__vim_write_selected_frame_number")[0]+a:jump))
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

# Global variable for access by quickfixtextfunc.
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

    # Save globally so frame information can be accessed by the quickfixtextfunc.
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

    cclose
    call ToggleQuickFix()
    copen
    " Select the last ("latest") entry, and center the screen.
    " execute "cc ".len(l:qflist)

endfunction

function! QuickfixCallstackTextFuncGetLine(args)
    # args contains (help getqflist):
    #     bufnr	number of buffer that has the file name, use
    #             bufname() to get the name
    #     module	module name
    #     lnum	line number in the buffer (first line is 1)
    #     end_lnum
    #             end of line number if the item is multiline
    #     col	column number (first column is 1)
    #     end_col	end of column number if the item has range
    #     vcol	|TRUE|: "col" is visual column
    #             |FALSE|: "col" is byte index
    #     nr	error number
    #     pattern	search pattern used to locate the error
    #     text	description of the error
    #     type	type of the error, 'E', '1', etc.
    #     valid	|TRUE|: recognized error message
    return "HELLO"
endfunction

function! QuickfixCallstackTextFunc(args)
    let l:start = a:args["start_idx"]
    let l:end = a:args["end_idx"]
    
    let l:lines = []
    let l:index = l:start - 1
    while l:index != l:end
        let l:frame = g:quickfix_callstack_frame_dicts[l:index]
        call add(l:lines, l:frame["filename"])
        let l:index = l:index + 1
    endwhile
    return l:lines
endfunction

nnoremap .1 :call QuickfixCallstackFromGDB()<cr>


">>>


" Source the syncer'd mappings.
source ~/code/syncer/syncer-vim.vim
