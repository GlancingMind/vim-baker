command! -complete=customlist,Baker#Complete -bang -nargs=* Baker
            \ call Baker#SetMakeprg(<q-args>) | make | redraw!
