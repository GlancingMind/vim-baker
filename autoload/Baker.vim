function! s:EchoError(msg)
    echohl ErrorMsg
    echomsg msg
    echohl None
endfunction

function! s:GetDirectoryPath(path)
    return fnamemodify(expand(a:path), ':p:.:h').'/'
endfunction

function! s:ReconstructMakefilePath(makefile)
    return s:GetDirectoryPath(g:Baker_MakefileLookupPath).a:makefile
endfunction

function! s:FindInDirectory(directory, patterns)
    if !isdirectory(a:directory)
        s:EchoError('Given path is not a directory')
        return []
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

function! s:CompleteTarget(arguments, argLead)
    let l:makefile = s:ReconstructMakefilePath(a:arguments[-1])
    let l:targets = s:GetTargets(l:makefile)
    "remove all targets  that don't match users given argument
    return filter(copy(l:targets), 'v:val =~ a:argLead')
endfunction

function! s:CompleteMakefile(arguments, argLead)
    let l:makefiles = s:GetMakefilesInDirectory()
    "get filenames of makefiles by removing the path
    let l:makefiles = map(l:makefiles, 'fnamemodify(v:val, ":t")')
    "remove all makefiles  that don't match users given argument
    return filter(copy(l:makefiles), 'v:val =~ a:argLead')
endfunction

function! Baker#Complete(argLead, cmdLine, curPos)
    let l:CompMakefile = funcref('s:CompleteMakefile')
    let l:CompTarget = funcref('s:CompleteTarget')
    let l:compFuncs = [l:CompMakefile, l:CompTarget]
    let l:completion = ComComp#Complete(a:cmdLine, l:compFuncs, ' ')

    if empty(l:completion)
        echo 'No completion found'
    endif

    return l:completion
endfunction

function! s:GetMakefilesInDirectory(...)
    let l:path = s:GetDirectoryPath(get(a:, 1, g:Baker_MakefileLookupPath))

    let l:makefiles = MakefileCache#GetMakefileNamesByPath(l:path)
    if empty(l:makefiles)
        let l:makefiles = s:FindInDirectory(l:path, g:Baker_MakefileNames)
        "parse matching makefiles and add them to the cache
        call map(copy(l:makefiles), 'MakefileCache#Add(Makefile#Parse(v:val))')
    endif

    return l:makefiles
endfunction

function! s:GetTargets(makefile)
    let l:makefile = MakefileCache#GetByPath(a:makefile)
    if empty(l:makefile)
        let l:makefile = Makefile#Parse(a:makefile)
        if !empty(l:makefile)
            call MakefileCache#Add(l:makefile)
        endif
    endif

    return l:makefile.targets
endfunction

function! Baker#SetMakeprg(args)
    if empty(a:args)
        return
    endif

    "prepand makefile with: make -f <project-path>
    let l:prepand = 'make -f '.s:GetDirectoryPath(g:Baker_MakefileLookupPath)
    let l:args = substitute(a:args, '\(.*\)\s', l:prepand.'\1 ', '')
    let &makeprg=l:args
endfunction

