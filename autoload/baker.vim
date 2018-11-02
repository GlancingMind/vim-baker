if !exists("s:makefileNames")
    let s:makefileNames = ['GNUmakefile', 'makefile', 'Makefile']
endif

let s:makefileLookupPath = "%"

function! baker#GetDirectoryPath(path)
    if isdirectory(a:path)
        return a:path
    endif

    return fnamemodify(expand(a:path), ":h").'/'
endfunction

function! baker#FindInDirectory(directory, patterns) abort
    if !isdirectory(a:directory)
        echoerr "Given path isn't a directory"
    endif

    let l:makefiles = []

    "get all makefiles that match pattern in given directory as a list
    "and preserve the makefile order: GNUmakefile, makefile, Makefile
    for l:pattern in a:patterns
        let l:makefiles += globpath(a:directory, l:pattern, 0, 1)
    endfor

    "remove all nonreadable files from matching files
    "e.g. a directories matching given patterns
    return filter(l:makefiles, "filereadable(v:val)")
endfunction

function! baker#GetMakefiles(...)
    let l:path = baker#GetDirectoryPath(get(a:, 1, s:makefileLookupPath))

    let l:makefiles = makefilecache#GetMakefileNamesByPath(l:path)
    if empty(l:makefiles)
        let l:makefiles = baker#FindInDirectory(l:path, s:makefileNames)
        "parse matching makefiles and add them to the cache
        call map(copy(l:makefiles), "makefilecache#Add(makefile#Parse(v:val))")
    endif

    return l:makefiles
endfunction

function! baker#GetTargets(makefile)
    let l:makefile = makefilecache#GetByPath(a:makefile)
    if empty(l:makefile)
        let l:makefile = makefile#Parse(a:makefile)
        call makefilecache#Add(l:makefile)
    endif

    return l:makefile.targets
endfunction

function! baker#Complete(ArgumentLead, CmdLine, CursorPosition)
    let l:arguments = split(a:CmdLine)
    let l:makefile = get(l:arguments, 1, "")
    let l:target = get(l:arguments, 2, "")
    let l:completions = []

    let l:makefileArgComplete = !empty(l:makefile) && a:CmdLine[a:CursorPosition - 1] == ' '
    if !l:makefileArgComplete && empty(l:target)
        "complete makefiles
        let l:completions = baker#CompleteMakefile(l:makefile)
        "append space to completion, to prevent user from typing it
        let l:completions = map(l:completions, 'v:val." "')
        if empty(l:completions)
            echo "No matching makefile found"
        endif
        return l:completions
    endif

    let l:targetArgComplete = !empty(l:target) && a:CmdLine[a:CursorPosition - 1] == ' '
    if !l:targetArgComplete
        "complete targets
        let l:completions = baker#CompleteTarget(l:makefile, l:target)
        if empty(l:completions)
            echo "No matching target found in : ".l:makefile
        endif
        return l:completions
    endif

    return l:completions
endfunction

function! baker#CompleteMakefile(ArgumentLead)
    let l:makefiles = baker#GetMakefiles()
    "get filenames of makefiles by removing the path
    let l:makefiles = map(l:makefiles, 'fnamemodify(v:val, ":t")')
    "remove all makefiles  that don't match users given argument
    return filter(l:makefiles, 'v:val =~ "'.a:ArgumentLead.'"')
endfunction

function! baker#CompleteTarget(makefile, ArgumentLead)
        let l:makefile = baker#GetDirectoryPath(s:makefileLookupPath).a:makefile
        let l:targets = baker#GetTargets(l:makefile)
        "remove all targets  that don't match users given argument
        return filter(l:targets, 'v:val =~ "'.a:ArgumentLead.'"')
endfunction

function! baker#ExecuteTargetRule(...)

    if a:0 >= 3
        echoerr "Too many arguments given"
        return
    endif

    "check if a target was specified by user
    if a:0 < 1
        if exists("s:lastBuildCommand")
            echomsg 'Executing last build command:'
            execute s:lastBuildCommand
            redraw!
        else
            echomsg 'No build command defined.'
        endif
    else
        let l:makefile = baker#GetDirectoryPath(s:makefileLookupPath).get(a:, 1, "")
        let l:target = get(a:, 2, "")
        echomsg 'Executing: '.l:target.' from '.l:makefile
        let s:lastBuildCommand = 'make -f '.l:makefile.' '.l:target
        execute s:lastBuildCommand
        redraw!
    endif
endfunction
