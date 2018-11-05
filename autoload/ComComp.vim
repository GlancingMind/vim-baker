
function! ComComp#Complete(ArgumentLead, CmdLine, CursorPosition, compFuncs)
    let l:argumentSeperator = ' '
    "determine if given argument has been completed
    let l:ArgComplete = a:CmdLine[a:CursorPosition - 1] == l:argumentSeperator
    let l:arguments = split(a:CmdLine)
    "remove commandname from arguments
    call remove(l:arguments, 0)
    let l:argCount = len(l:arguments)


    if !l:ArgComplete
        let l:argCount = l:argCount - 1
    endif

    if (l:argCount >= len(a:compFuncs))
        "out of range
        echo 'No comp functions defined'
        return []
    endif

    let l:argslead = ''
    if !empty(l:arguments) && !l:ArgComplete
        let l:argslead = remove(l:arguments, -1)
    endif

    let l:func = get(a:compFuncs, l:argCount)
    let l:completion = copy(function(l:func)(l:arguments, l:argslead))
    if empty(l:completion)
        echo 'No completion found'
    endif

    return map(l:completion, 'v:val . l:argumentSeperator')
endfunction
