"
" dirspace_vim
"

let s:options = ""

let s:term_buf = term_start('bash', {
    \ 'curwin' : 1,
    \ 'term_finish' : 'close'
    \ })
