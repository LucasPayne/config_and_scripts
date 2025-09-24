"
" dirspace_vimrc
"

if !exists("g:is_dirspace_vim") || g:is_dirspace_vim == 0
    " Do initialization for the whole session.
    " This is not re-source'd when the vimrc is sourced.

    if !exists("$DIRSPACE_VIM_RUNTIME")
        echoerr "DIRSPACE_VIM_RUNTIME is not set."
    endif
    
    " Clear the vim runtime state.
    if exists("$DIRSPACE_VIM_RUNTIME")
        let runtime_state_dir = $DIRSPACE_VIM_RUNTIME.."/state"
        call system("rm -r "..shellescape(runtime_state_dir.."/state"))
        call system("mkdir -p "..shellescape(runtime_state_dir.."/state"))
    endif

    " Update the dirspace UI.
    call system("dirspace_status")

    " Create the initial terminal
    let s:term_buf = term_start('bash', {
                \ 'curwin' : 1,
                \ 'term_finish' : 'close'
                \ })
    call setbufvar(s:term_buf, "main_shell", 1)
endif

" vimrc will source this file again
" if it is sourced and this is already set.
let g:is_dirspace_vim = 1

"------------------------------------------------------------
" Override the tab panel.
" Note: The logic depends on the vimrc, so if something goes
" wrong, check if it makes sense with the vimrc as well.
"------------------------------------------------------------
if g:use_tabpanel
    set tabline=%!TabLineDirspaceStatusBar()
    set showtabline=2
endif

function! ToggleTabPanel()
    let g:use_tabpanel = !g:use_tabpanel
    if g:use_tabpanel
        set showtabpanel=2
        set showtabline=2
        set tabline=%!TabLineDirspaceStatusBar()
    else
        set showtabpanel=0
        set showtabline=2
        set tabline=%!TabLine()
    endif
endfunction

let g:tabline_dirspace_status_bar_file = expand("$DIRSPACE_VIM_RUNTIME/tabline_dirspace_status_bar")
let g:tabline_dirspace_status_bar = ""
let g:tabline_dirspace_status_bar_dirty = 1
function! TabLineDirspaceStatusBar()
    if g:tabline_dirspace_status_bar_dirty
        if filereadable(g:tabline_dirspace_status_bar_file)
            let lines = readfile(g:tabline_dirspace_status_bar_file)
            if len(lines) > 0
                let g:tabline_dirspace_status_bar = lines[0]
            endif
        else
            let g:tabline_dirspace_status_bar = ""
        endif
        "TODO: Set dirty on status change.
        "      Might not even be worth it to save the file read.
        "let g:tabline_dirspace_status_bar_dirty = 0
        let g:tabline_dirspace_status_bar_dirty = 1
    endif
    return g:tabline_dirspace_status_bar
endfunction
" Not selected
highlight TabLineDirspace cterm=underline ctermfg=darkgrey ctermbg=black
highlight TabLineDirspaceNumber cterm=underline ctermfg=darkgrey ctermbg=black
" Selected
highlight TabLineDirspaceSelected cterm=underline ctermfg=grey ctermbg=black
highlight TabLineDirspaceNumberSelected cterm=underline ctermfg=black ctermbg=cyan

"------------------------------------------------------------
