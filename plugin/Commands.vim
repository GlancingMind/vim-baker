command! -complete=customlist,Baker#Complete -nargs=* Baker call Baker#SetMakeprg(<q-args>) | make | redraw!
