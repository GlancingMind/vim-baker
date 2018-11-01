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
    let l:targets = makefile#ParseTargets(a:path)
    return makefile#Create(a:path, l:targets)
endfunction

function! makefile#ParseTargets(path)
    if !filereadable(a:path)
        echoerr string(a:path) ' not readable!'
    endif

    "list of targets in makefile
    let l:targets = []

    "grep all targets from makefiles
    execute 'silent! vimgrep /^\w\+:/gj '.a:path
    "get found target entries from quickfixlist
    for l:item in getqflist()
        "take text of qfentry and strip content after :  from target name
        let l:striped = trim(get(split(l:item.text, ':', 'KeepEmpty'), 0, ''))
        "add target to completionlist
        let l:targets = add(l:targets, l:striped)
    endfor

    return l:targets
endfunction
