function! baker#GetMakefiles(path)
    "get all makefiles in current directory as a list
    let l:makefiles = globpath(a:path, "[Mm]akefile", v:false, v:true)
    "remove all nonreadable files from matching files
    "e.g. a directory named 'makefile'
    return filter(l:makefiles, "filereadable(v:val)")
endfunction

function! baker#GetMakeTargets(ArgumentLead,CmdLine,CursorPosition)
    "list of suggested completions
    let l:targetCompletions = []

    let l:makefiles = baker#GetMakefiles(".")

    if empty(l:makefiles)
        echomsg "No makefile found. Cannot complete targets."
        return l:targetCompletions
    endif

    if len(l:makefiles) > 1
        let l:msg =  "Multiple makefiles found ".string(l:makefiles)
        "remove all makefiles starting with a 'm'
        "this ensures compliance to the make console command, which searches
        "for makefiles in order: GNUmakefile, makefile, Makefile
        let l:makefiles = filter(l:makefiles, "v:val =~# '^./m'")
        echomsg l:msg." Completing targets from: ".l:makefiles[0]
    endif

    "grep targets from all makefiles
    execute 'silent! vimgrep /^.*:/gj'.l:makefiles[0]
    "get found target entries from quickfixlist
    for l:item in filter(getqflist(), "v:val.text =~ \"^".a:ArgumentLead."\"")
        "strip trailing : from target name
        let l:striped = strcharpart(l:item.text, 0, strlen(l:item.text)-1)
        "add target to completionlist
        let l:targetCompletions = add(l:targetCompletions, l:striped)
    endfor

    return l:targetCompletions
endfunction

function! baker#ExecuteTargetRule(...)
    "check if a target was specified by user
    if a:0 < 1
        if exists("s:lastBuildCommand")
            echomsg "Executing last build command: ".s:lastBuildCommand
            execute "silent! make ".s:lastBuildCommand
            redraw!
        else
            echomsg "No build command defined."
        endif
    else
        echomsg "Executing: ".a:1
        let s:lastBuildCommand = a:1
        execute "silent! make ".s:lastBuildCommand
        redraw!
    endif
endfunction
