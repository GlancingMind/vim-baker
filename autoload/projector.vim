
function! projector#GetMakeTargets(ArgumentLead,CmdLine,CursorPosition)
    "list of suggested completions
    let l:targetCompletions = []

    "get all makefiles in current directory as a list
    let l:makefiles = globpath(".", "[Mm]akefile", v:false, v:true)
    "remove all nonreadable makefiles from found makefiles (e.g. directories)
    let l:makefiles = filter(l:makefiles, "filereadable(v:val)")

    if empty(l:makefiles)
        echomsg "No makefile found. Cannot complete targets."
    endif

    "grep targets from all makefiles
    execute 'silent! vimgrep /^.*:/gj'.join(l:makefiles)
    "get found target entries from quickfixlist
    for l:item in filter(getqflist(), "v:val.text =~ \"^".a:ArgumentLead."\"")
        "strip trailing : from target name
        let l:striped = strcharpart(l:item.text, 0, strlen(l:item.text)-1)
        "add target to completionlist
        let l:targetCompletions = add(l:targetCompletions, l:striped)
    endfor

    return l:targetCompletions
endfunction

function! projector#ExecuteTargetRule(...)
    "check if a target was specified by user
    if a:0 < 1
        if exists("s:lastBuildCommand")
            echomsg "Executing last build command: ".s:lastBuildCommand
            execute "make ".s:lastBuildCommand
        else
            echomsg "No build command defined."
        endif
    else
        echomsg "Executing: ".a:1
        let s:lastBuildCommand = a:1
        execute "make ".s:lastBuildCommand
    endif
endfunction

