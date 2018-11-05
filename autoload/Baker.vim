if !exists('s:makefileNames')
    let s:makefileNames = ['GNUmakefile', 'makefile', 'Makefile']
endif

if !exists('s:makefileLookupPath')
    let s:makefileLookupPath = '%'
endif

function! Baker#GetDirectoryPath(path)
    if isdirectory(a:path)
        return a:path
    endif

    return fnamemodify(expand(a:path), ':h').'/'
endfunction

function! Baker#FindInDirectory(directory, patterns) abort
    if !isdirectory(a:directory)
        echoerr 'Given path isn't a directory'
    endif

    let l:makefiles = []

    "get all makefiles that match pattern in given directory as a list
    "and preserve the makefile order: GNUmakefile, makefile, Makefile
    for l:pattern in a:patterns
        let l:makefiles += globpath(a:directory, l:pattern, 0, 1)
    endfor

    "remove all nonreadable files from matching files
    "e.g. a directories matching given patterns
    return filter(l:makefiles, 'filereadable(v:val)')
endfunction

function! Baker#GetMakefiles(...)
    let l:path = Baker#GetDirectoryPath(get(a:, 1, s:makefileLookupPath))

    let l:makefiles = Makefilecache#GetMakefileNamesByPath(l:path)
    if empty(l:makefiles)
        let l:makefiles = Baker#FindInDirectory(l:path, s:makefileNames)
        "parse matching makefiles and add them to the cache
        call map(copy(l:makefiles), 'Makefilecache#Add(Makefile#Parse(v:val))')
    endif

    return l:makefiles
endfunction

function! Baker#GetTargets(makefile)
    let l:makefile = Makefilecache#GetByPath(a:makefile)
    if empty(l:makefile)
        let l:makefile = Makefile#Parse(a:makefile)
        call Makefilecache#Add(l:makefile)
    endif

    return l:makefile.targets
endfunction

function! Baker#Complete(argLead, cmdLine, curPos)
    let l:compFuncs = ['Baker#CompleteMakefile', 'Baker#CompleteTarget']
    return ComComp#Complete(a:argLead, a:cmdLine, a:curPos, l:compFuncs)
endfunction

function! Baker#CompleteTarget(arguments, lead)
    let l:makefile = a:arguments[-1]
    let l:makefile = Baker#GetDirectoryPath(s:makefileLookupPath).l:makefile
    let l:targets = Baker#GetTargets(l:makefile)
    "remove all targets  that don't match users given argument
    return filter(copy(l:targets), 'v:val =~ a:lead')
endfunction

function! Baker#CompleteMakefile(arguments, lead)
    let l:makefiles = Baker#GetMakefiles()
    "get filenames of makefiles by removing the path
    let l:makefiles = map(l:makefiles, 'fnamemodify(v:val, ":t")')
    "remove all makefiles  that don't match users given argument
    return filter(copy(l:makefiles), 'v:val =~ a:lead')
endfunction

function! Baker#ExecuteTargetRule(...)

    if a:0 >= 3
        echoerr 'Too many arguments given'
        return
    endif

    "check if a target was specified by user
    if a:0 < 1
        if exists('s:lastBuildCommand')
            echomsg 'Executing last build command:'
            execute s:lastBuildCommand
            redraw!
        else
            echomsg 'No build command defined.'
        endif
    else
        let l:makefile = Baker#GetDirectoryPath(s:makefileLookupPath).get(a:, 1, '')
        let l:target = get(a:, 2, '')
        echomsg 'Executing: '.l:target.' from '.l:makefile
        let s:lastBuildCommand = 'make -f '.l:makefile.' '.l:target
        execute s:lastBuildCommand
        redraw!
    endif
endfunction
