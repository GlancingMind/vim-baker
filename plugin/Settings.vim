if !exists('g:Baker_MakefileNames')
    let g:Baker_MakefileNames = ['GNUmakefile', 'makefile', 'Makefile']
endif

if !exists('g:Baker_MakefileLookupPath')
    let g:Baker_MakefileLookupPath = '%'
endif
