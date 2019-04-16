function! s:GetMakefileCompletor()
    if exists('s:MakefileCompletor')
        return s:MakefileCompletor
    endif
    let s:MakefileCompletor = Completion#CreateCompletion()
    "first argument shall be makefiles and directories
    call s:MakefileCompletor.AddDefinition(funcref('s:CompleteMakefile'), 0, 1)
    call s:MakefileCompletor.AddDefinition(funcref('s:CompleteDirectory'), 0, 1)
    return s:MakefileCompletor
endfunction

function! s:GetMakefileAndTargetCompletor()
    if exists('s:MfAndTargetCompletor')
        return s:MfAndTargetCompletor
    endif
    let s:MfAndTargetCompletor = Completion#CreateCompletion()
    "first argument shall be makefiles and directories
    call s:MfAndTargetCompletor.AddDefinition(funcref('s:CompleteMakefile'), 0, 1)
    call s:MfAndTargetCompletor.AddDefinition(funcref('s:CompleteDirectory'), 0, 1)
    "second to n arguments will be targets of the makefile given as first arg
    call s:MfAndTargetCompletor.AddDefinition(funcref('s:CompleteTarget'), 1)
    return s:MfAndTargetCompletor
endfunction

function! s:CompleteDirectory(arguments, arglead, argseperator)
    let l:path = a:arglead
    if empty(a:arglead)
        let l:path = g:Baker_MakefileLookupPath
    endif

    return g:Baker_CompleteDirectories ? getcompletion(l:path, 'dir') : []
endfunction

function! s:CompleteMakefile(arguments, arglead, argseperator)
    "when a file is given return this path as only completion
    if filereadable(g:Baker_MakefileLookupPath)
        return [g:Baker_MakefileLookupPath.a:argseperator]
    endif

    let l:path = a:arglead
    if empty(a:arglead)
        let l:path = g:Baker_MakefileLookupPath
    endif

    let l:makefiles = MakefileFinder#Find(l:path)
    "add argument seperator to trigger completion of next completion function
    return map(l:makefiles, 'v:val.a:argseperator')
endfunction

function! s:CompleteTarget(arguments, arglead, argseperator)
    let l:targets = MakefileCache#GetTargets(a:arguments[0], a:arglead)
    if empty(l:targets)
        let l:makefile = Makefile#Parse(a:arguments[0])
        call MakefileCache#Add(l:makefile)
        let l:targets = l:makefile.GetTargets(a:arglead)
    endif
    "remove all previous specified targets; the completion should not encourage
    "user to select the same target multiple times
    call filter(l:targets, 'index(a:arguments[1:], v:val) == -1')

    "add argument seperator to trigger completion of next completion function
    return map(l:targets, 'v:val.a:argseperator')
endfunction

function Baker#CompleteMakefiles(arglead, cmdline, curpos)
    let l:completion = s:GetMakefileCompletor().Complete(a:cmdline, ' ')
    if empty(l:completion)
        echo 'No completion found'
    endif

    return l:completion
endfunction

function! Baker#CompleteMakefilesAndTargets(arglead, cmdline, curpos)
    let l:completion = s:GetMakefileAndTargetCompletor().Complete(a:cmdline, ' ')
    if empty(l:completion)
        echo 'No completion found'
    endif

    return l:completion
endfunction

function! Baker#SetMakeprg(args)
    if empty(a:args)
        return
    endif

    let l:arguments = split(a:args)
    let l:makefile = resolve(l:arguments[0])
    let l:targets = l:arguments[1:]

    if !empty(l:targets)
        echohl MoreMsg
        echomsg 'Set makeprg to '.&makeprg
        echohl None

        let &makeprg = 'make -f '.l:makefile.' '.join(l:targets)
    endif
endfunction
