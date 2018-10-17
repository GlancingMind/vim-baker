if !exists("s:did_load")
    let s:did_load = 1

    command! -complete=customlist,GetMakeTargets -nargs=? ProjectorBuild call ExecuteTargetRule(<f-args>)
    execute 'autocmd FuncUndefined Projector* source '.expand('<sfile>')
    finish
endif

let s:lastBuildCommand = ''

function! Projector_GetMakeTargets(ArgumentLead,CmdLine,CursorPosition)
    "grep targets from makefile
    vimgrep /^.*:/gj makefile
    "list where a
    let l:targetCompletions = []
    "get found target entries from quickfixlist
    for l:item in filter(getqflist(), "v:val.text =~ \"^".a:ArgumentLead."\"")
        "strip trailing : from target name
        let l:striped = strcharpart(l:item.text, 0, strlen(l:item.text)-1)
        let l:targetCompletions = add(l:targetCompletions, l:striped)
    endfor
    return l:targetCompletions
endfunction

function! Projector_ExecuteTargetRule(...)
    if a:0 < 1
        echomsg "Executing last build command: ".s:lastBuildCommand
    else
        echomsg "Executing: ".a:1
        let s:lastBuildCommand = a:1
    endif
endfunction
