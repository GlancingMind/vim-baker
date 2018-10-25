if !exists('s:makefilesCache')
    let s:makefilesCache = {}
endif

function! baker#ShowCache()
    echo s:makefilesCache
endfunction

function! baker#ClearCache()
    let s:makefilesCache = {}
endfunction

function! baker#IndexMakefiles(path, ignoreCache)
    if has_key(s:makefilesCache, a:path) && !a:ignoreCache
        "echo 'cache hit makefiles index'
        return s:makefilesCache[a:path]
    endif

    for l:makefile in baker#GetMakefiles(a:path, a:ignoreCache)
        let l:targets = baker#GetTargets(l:makefile)
        let l:makefileName = fnamemodify(l:makefile, ":t")
        let l:newCacheEntry = {l:makefileName: l:targets}
        let l:oldCacheentry = get(s:makefilesCache, a:path, {})
        let s:makefilesCache[a:path] = extend(l:oldCacheentry, l:newCacheEntry)
    endfor
endfunction

function! baker#GetMakefiles(...)
    let l:path = get(a:, 1, ".")
    let l:filenamemodifier = get(a:, 2, "")
    let l:ignoreCache = get(a:, 3, v:false)

    if has_key(s:makefilesCache, l:path) && !l:ignoreCache
        "echo 'cache hit for makefiles in \"'.l:path.'"'
        return keys(s:makefilesCache[l:path])
    endif

    "get all makefiles in current directory as a list
    "and preserve the makefile order: GNUmakefile, makefile, Makefile
    let l:makefiles = globpath(l:path, "GNUmakefile", v:false, v:true)
    let l:makefiles += globpath(l:path, "makefile", v:false, v:true)
    let l:makefiles += globpath(l:path, "Makefile", v:false, v:true)

    "remove all nonreadable files from matching files
    "e.g. a directory named 'makefile'
    return = filter(l:makefiles, "filereadable(v:val)")
endfunction

function! baker#GetTargets(makefile)
    "list of targets in makefile
    let l:targets = []

    let l:path = fnamemodify(a:makefile, ":h")
    let l:filename = fnamemodify(a:makefile, ":t")
    if has_key(s:makefilesCache, l:path)
        if has_key(s:makefilesCache[l:path], l:filename)
            "echo 'cache hit for targets of "'.a:makefile.'"'
            return s:makefilesCache[l:path][l:filename]
        endif
    endif

    "grep all targets from makefiles
    execute 'silent! vimgrep /^.*:/gj '.a:makefile
    "get found target entries from quickfixlist
    for l:item in getqflist()
        "take text of qfentry and strip the trailing : from target name
        let l:striped = strcharpart(l:item.text, 0, strlen(l:item.text)-1)
        "add target to completionlist
        let l:targets = add(l:targets, l:striped)
    endfor

    return l:targets
endfunction

function! baker#CompleteMakeTargets(ArgumentLead, CmdLine, CursorPosition)
    "list of suggested completions
    let l:targetCompletions = []

    "makefiles of current directory
    let l:makefiles = baker#GetMakefiles(expand("%:h"))

    if empty(l:makefiles)
        echomsg 'No makefile found. Cannot complete targets.'
        return l:targetCompletions
    endif

    if len(l:makefiles) > 1
        echomsg  'Multiple makefiles found '.string(l:makefiles)
            \.'. Completing targets from: '.l:makefiles[0]
    endif

    let l:targets = baker#GetTargets(l:makefiles[0])
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

function! baker#ListTargets(path)

    if isdirectory(a:path)
        "get makefiles of current directory
        for l:makefile in baker#GetMakefiles(a:path)
            call baker#ListTargets(a:path.'/'.l:makefile)
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
    let l:completions += map(baker#GetMakefiles(l:path), "a:ArgumentLead.v:val")
    "remove all makefiles and directories that don't match users given argument
    return filter(l:completions, "v:val =~ \"^".a:ArgumentLead."\"")
endfunction
