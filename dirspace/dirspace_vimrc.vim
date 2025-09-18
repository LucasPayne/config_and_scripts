"
" dirspace_vimrc
"

" vimrc will source this file again
" if it is sourced and this is already set.
let g:is_dirspace_vim = 1

let s:options = ""

let s:term_buf = term_start('bash', {
    \ 'curwin' : 1,
    \ 'term_finish' : 'close'
    \ })

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

let g:tabline_dirspace_status_bar_file = expand("~/.local/share/dirspace/sessions/$DIRSPACE_SESSION_ID/tabline_dirspace_status_bar")
function! TabLineDirspaceStatusBar()
    if filereadable(g:tabline_dirspace_status_bar_file)
        let lines = readfile(g:tabline_dirspace_status_bar_file)
        if len(lines) > 0
            return lines[0]
        endif
    else
        return ""
    endif
endfunction
"------------------------------------------------------------
