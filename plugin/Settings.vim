if !exists('g:Baker_MakefileNames')
    let g:Baker_MakefileNames = ['GNUmakefile', 'makefile', 'Makefile']
endif

if !exists('g:Baker_MakefileLookupPath')
    let g:Baker_MakefileLookupPath = '%'
endif

if !exists('g:Baker_CompleteDirectories')
    let g:Baker_CompleteDirectories = 1
endif
