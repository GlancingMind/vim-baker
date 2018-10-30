if !exists("s:makefileNames")
    let s:makefileNames = ['GNUmakefile', 'makefile', 'Makefile']
endif

function! baker#GetMakefiles(...)
    let l:path = get(a:, 1, ".")

    let l:makefiles = makefilecache#GetMakefileNamesByPath(l:path)
    if empty(l:makefiles)
        "get all makefiles in current directory as a list
        "and preserve the makefile order: GNUmakefile, makefile, Makefile
        for l:makefile in s:makefileNames
            let l:makefiles += globpath(l:path, l:makefile, v:false, v:true)
        endfor

        "remove all nonreadable files from matching files
        "e.g. a directory named 'makefile'
        let l:makefiles = filter(l:makefiles, "filereadable(v:val)")
        call map(copy(l:makefiles), "makefile#Parse(v:val)")
    endif

    return l:makefiles
endfunction

function! baker#GetTargets(makefile)
    return makefile#Parse(a:makefile).targets
endfunction

function! baker#ListTargets(path)
    if isdirectory(a:path)
        "get makefiles of current directory
        for l:makefile in baker#GetMakefiles(a:path)
            call baker#ListTargets(l:makefile)
        endfor
    endif

    "when path points to a potential makefile
    if filereadable(a:path)
        "all filename of makefile to output
        let l:index = 0
        echo fnamemodify(a:path, ":t")."\n"
        for l:target in baker#GetTargets(a:path)
            echo printf("%2d:\t%s", l:index, l:target)
            let l:index += 1
        endfor
    endif
endfunction

function! baker#CompleteDirectoryOrMakefile(ArgumentLead, CmdLine, CursorPosition)
    let l:path = "."
    if !empty(a:ArgumentLead)
        let l:path = a:ArgumentLead
    endif

    "add directories to list of suggested completions
    let l:completions = globpath(l:path, "*/", v:false, v:true)
    "add makefiles of current directory
    let l:completions += baker#GetMakefiles(l:path)
    "remove all makefiles and directories that don't match users given argument
    return filter(l:completions, "v:val =~ \"^".a:ArgumentLead."\"")
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
    "get makefiles of current directory
    let l:makefiles = baker#GetMakefiles(".")
    "get filenames of makefiles by removing the path
    let l:makefiles = map(l:makefiles, 'fnamemodify(v:val, ":t")')
    "remove all makefiles  that don't match users given argument
    return filter(l:makefiles, 'v:val =~ "'.a:ArgumentLead.'"')
endfunction

function! baker#CompleteTarget(makefile, ArgumentLead)
        let l:targets = baker#GetTargets(a:makefile)
        "remove all targets  that don't match users given argument
        return filter(l:targets, 'v:val =~ "'.a:ArgumentLead.'"')
endfunction

function! baker#ExecuteTargetRule(...)
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
        "TODO: makefile seems to be empty. Maybe not passed from prev
        "funciton?
        let l:makefile = get(a:000, 0, "")
        let l:target = get(a:000, 1, "")
        echomsg 'Executing: '.l:target.' from '.l:makefile
        let s:lastBuildCommand = 'make -f '.l:makefile.' '.l:target
        execute s:lastBuildCommand
    endif
endfunction

"function! Select(path)
"    let l:entries = baker#Filter(a:path)
"    call inputsave()
"    call input(join(l:entries, "\n")."\n", "default", "customlist,SelectTarget")
"    call inputrestore()
"endfunction
"
"function! SelectTarget(A, L, P)
"    let l:completions =  ['this', 'are', 'targets']
"    return baker#Filter()
"endfunction
