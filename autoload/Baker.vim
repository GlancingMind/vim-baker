function! s:GetDirectoryPath(path)
    if isdirectory(a:path)
        return a:path
    endif
    return fnamemodify(expand(a:path), ':~:.:h').'/'
endfunction

function! s:GetFilename(path)
    return fnamemodify(expand(a:path), ':t')
endfunction

function! s:GetTargets(makefile)
    return Makefile#Parse(a:makefile).targets
endfunction

function! s:CompleteMakefilesAndDirectories(arguments, arglead, argseperator)
    "when a file is given return this path as only completion
    if filereadable(g:Baker_MakefileLookupPath)
        return [g:Baker_MakefileLookupPath.' ']
    endif

    let l:path = a:arglead
    if empty(a:arglead)
        let l:path = s:GetDirectoryPath(g:Baker_MakefileLookupPath)
    endif

    let l:directories = getcompletion(l:path, 'dir')
    let l:files = getcompletion(l:path, 'file')
    "filter out makefiles from all files
    let l:makefiles = filter(l:files, 'index(g:Baker_MakefileNames, s:GetFilename(v:val)) >= 0')
    "add argument seperator to trigger completion of next completion function
    let l:makefiles = map(l:makefiles, 'v:val.a:argseperator')
    return l:makefiles + l:directories
endfunction

function! s:CompleteTarget(arguments, arglead, argseperator)
    let l:makefile = a:arguments[0]
    let l:targets = s:GetTargets(l:makefile)
    "remove all targets  that don't match users given argument
    let l:targets = filter(l:targets, 'v:val =~ a:arglead')
    "remove all previous specified targets; the completion should not encourage
    "user to select the same target multiple times
    for l:target in a:arguments[1:]
        call remove(l:targets, index(l:targets, l:target))
    endfor
    return map(l:targets, 'v:val.a:argseperator')
endfunction

function! Baker#Complete(arglead, cmdline, curpos)
    let l:CompMakefile = funcref('s:CompleteMakefilesAndDirectories')
    let l:CompTarget = funcref('s:CompleteTarget')
    let l:compFuncs = [{'Complete': l:CompMakefile, 'quantifier': 1},
                \ {'Complete': l:CompTarget, 'quantifier': '*'}]
    let l:completion = ComComp#Complete(a:cmdline, l:compFuncs, ' ')

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

    let &makeprg='make -f '.l:makefile.' '.join(l:targets)

    echohl MoreMsg
    echomsg 'Set makeprg to '.&makeprg
    echohl None
endfunction

