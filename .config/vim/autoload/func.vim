" {{{ checks if colorscheme is exists
"     read more at stackoverflow.com/a/5703164/5246998

function! func#has_colorscheme(name)
    let l:pat = 'colors/'.a:name.'.vim'
    return !empty(globpath(&rtp, l:pat))
endfunction

" }}}

" {{{ removes all trailing spaces

function! func#trim_spaces()
    let l:winview = winsaveview()
    %s/\s\+$//e
    call winrestview(l:winview)
endfunction

" }}}
