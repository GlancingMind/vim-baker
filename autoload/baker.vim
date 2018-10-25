function! baker#GetMakefiles(...)
    let l:path = get(a:, 1, ".")
    let l:fnamemodifier = get(a:, 2, "")

    let l:makefiles = makefilecache#GetMakefileNamesByPath(l:path)
    if empty(l:makefiles)
        "get all makefiles in current directory as a list
        "and preserve the makefile order: GNUmakefile, makefile, Makefile
        let l:makefiles = globpath(l:path, "GNUmakefile", v:false, v:true)
        let l:makefiles += globpath(l:path, "makefile", v:false, v:true)
        let l:makefiles += globpath(l:path, "Makefile", v:false, v:true)

        "remove all nonreadable files from matching files
        "e.g. a directory named 'makefile'
        let l:makefiles = filter(l:makefiles, "filereadable(v:val)")
        call map(copy(l:makefiles), "makefile#Parse(v:val)")
    endif

    return map(l:makefiles, "fnamemodify(v:val, l:fnamemodifier)")
endfunction

function! baker#GetTargets(makefile)
    return makefile#Parse(a:makefile).targets
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
        "get filename of makefile by removing the path
        let l:filenames = map(copy(l:makefiles), 'fnamemodify(v:val, ":t")')
        echo 'Multiple makefiles found '.string(l:filenames)
                    \.' in '.fnamemodify(l:makefiles[0], ":h").'/'
                    \.' Completing targets from: '.l:filenames[0]
    endif

    let l:targets = baker#GetTargets(l:makefiles[0])
    if empty(l:targets)
        echomsg 'No targets for '.string(l:makefiles[0]).' defined'
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
