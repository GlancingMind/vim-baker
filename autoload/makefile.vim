let s:makefile = {
            \'path': "",
            \'filename': '',
            \'targets': []
            \}

function! makefile#Create(path, targets)
    let l:self = copy(s:makefile)
    let l:self.path = fnamemodify(a:path, ":h").'/'
    let l:self.filename = fnamemodify(a:path, ":t")
    let l:self.targets = a:targets

    return l:self
endfunction

function! makefile#Parse(path)
    let l:makefile = makefilecache#GetByPath(a:path)
    if empty(l:makefile)
        let l:targets = makefile#ParseTargets(a:path)
        let l:makefile = makefile#Create(a:path, l:targets)
        call makefilecache#Add(l:makefile)
    endif

    return l:makefile
endfunction

function! makefile#ParseTargets(path)
    if !filereadable(a:path)
        echoerr string(a:path) ' not readable!'
    endif

    "list of targets in makefile
    let l:targets = []

    "grep all targets from makefiles
    execute 'silent! vimgrep /^.*:/gj '.a:path
    "get found target entries from quickfixlist
    for l:item in getqflist()
        "take text of qfentry and strip the trailing : from target name
        let l:striped = strcharpart(l:item.text, 0, strlen(l:item.text)-1)
        "add target to completionlist
        let l:targets = add(l:targets, l:striped)
    endfor

    return l:targets
endfunction
