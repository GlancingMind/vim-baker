function! baker#GetMakefiles(path)
    "get all makefiles in current directory as a list
    "and preserve the makefile order: GNUmakefile, makefile, Makefile
    let l:makefiles = globpath(a:path, "GNUmakefile", v:false, v:true)
    let l:makefiles += globpath(a:path, "makefile", v:false, v:true)
    let l:makefiles += globpath(a:path, "Makefile", v:false, v:true)

    "remove all nonreadable files from matching files
    "e.g. a directory named 'makefile'
    return filter(l:makefiles, "filereadable(v:val)")
endfunction

function! baker#GetTargetList(makefile)
    "list of targets in makefile
    let l:targets = []

    "grep all targets from makefiles
    execute 'silent! vimgrep /^.*:/gj'.a:makefile
    "get found target entries from quickfixlist
    for l:item in getqflist()
        "take text of qfentry and strip the trailing : from target name
        let l:striped = strcharpart(l:item.text, 0, strlen(l:item.text)-1)
        "add target to completionlist
        let l:targets = add(l:targets, l:striped)
    endfor

    return l:targets
endfunction

function! baker#GetMakeTargets(ArgumentLead,CmdLine,CursorPosition)
    "list of suggested completions
    let l:targetCompletions = []

    "makefiles of current directory
    let l:makefiles = baker#GetMakefiles(".")

    if empty(l:makefiles)
        echomsg 'No makefile found. Cannot complete targets.'
        return l:targetCompletions
    endif

    if len(l:makefiles) > 1
        echomsg  'Multiple makefiles found '.string(l:makefiles)
            \.'. Completing targets from: '.l:makefiles[0]
    endif

    let l:targets = baker#GetTargetList(l:makefiles[0])
    if empty(l:targets)
        echomsg 'No targets defined'
        return l:targetCompletions
    endif
    "remove all targets that don't match users given argument
    let l:targetCompletions = filter(l:targets, "v:val =~ \"^".a:ArgumentLead."\"")
    if empty(l:targetCompletions)
        echomsg 'No matching targets found'
        return l:targetCompletions
    endif

    return l:targetCompletions
endfunction

function! baker#ExecuteTargetRule(...)
    "check if a target was specified by user
    if a:0 < 1
        if exists("s:lastBuildCommand")
            echomsg 'Executing last build command: '.s:lastBuildCommand
            execute "silent! make ".s:lastBuildCommand
            redraw!
        else
            echomsg 'No build command defined.'
        endif
    else
        echomsg 'Executing: '.a:1
        let s:lastBuildCommand = a:1
        execute "silent! make ".s:lastBuildCommand
        redraw!
    endif
endfunction

