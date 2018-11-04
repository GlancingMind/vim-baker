" refactor quickselect#Complete to generic functions, which takes
"multiple functions as parameter for each argument + a completion format!
"    e.g. complete("#make #target, {#MakeComplete: function...,
"                                    #TargerComplete: function...})

let s:makefileLookupPath = "%"
function! ComComp#CompleteTarget(arguments, lead)
    let l:makefile = a:arguments[-1]
    let l:makefile = baker#GetDirectoryPath(s:makefileLookupPath).l:makefile
    let l:targets = baker#GetTargets(l:makefile)
    "remove all targets  that don't match users given argument
    return filter(copy(l:targets), 'v:val =~ a:lead')
endfunction

function! ComComp#CompleteMakefile(arguments, lead)
    let l:makefiles = baker#GetMakefiles()
    "get filenames of makefiles by removing the path
    let l:makefiles = map(l:makefiles, 'fnamemodify(v:val, ":t")')
    "remove all makefiles  that don't match users given argument
    return filter(copy(l:makefiles), 'v:val =~ a:lead')
endfunction

function! ComComp#Complete(ArgumentLead, CmdLine, CursorPosition)
    let s:compFuncs = ['ComComp#CompleteMakefile', 'ComComp#CompleteTarget']
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

    if (l:argCount >= len(s:compFuncs))
        "out of range
        echo "No comp functions defined"
        return []
    endif

    let l:argslead = ""
    if !empty(l:arguments) && !l:ArgComplete
        let l:argslead = remove(l:arguments, -1)
    endif

    let l:func = get(s:compFuncs, l:argCount)
    "echo "completion for: ".string(l:func)
    let l:completion = copy(function(l:func)(l:arguments, l:argslead))
    return map(l:completion, 'v:val . l:argumentSeperator')
endfunction
