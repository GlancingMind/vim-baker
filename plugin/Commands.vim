command! -complete=customlist,Baker#CompleteMakefilesAndTargets
            \ -bang -nargs=* Baker
            \ call Baker#SetMakeprg(<q-args>) | make<bang> | redraw!

command! -complete=customlist,Baker#CompleteMakefiles -nargs=1
            \ BakerEditMakefile edit <args>

command! BakerClearCache call MakefileCache#Clear()

