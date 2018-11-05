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

function! makefile#IsPhonyTarget(target)
    return a:target[0] == '.'
endfunction

function! makefile#QfEntryToTargets(entry)
    "removes content after :  from target name
    let l:target = trim(get(split(a:entry, ':', 'KeepEmpty'), 0, ''))
    "split targets up if multiple targetnames are specified before :
    "e.g.   hello world:    => ['hello', 'world']
    return split(l:target)
endfunction

function! makefile#ParseTargets(path)
    if !filereadable(a:path)
        echoerr string(a:path) ' not readable!'
    endif

    "list of targets in makefile
    let l:targets = []

    "grep all targets from makefiles
    noautocmd execute 'silent! vimgrep /^\S[A-Za-z0-9_/. ]\+:/gj '.a:path
    "get found target entries from quickfixlist
    for l:entry in getqflist()
        "add targets to completionlist
        let l:targets += makefile#QfEntryToTargets(l:entry.text)
    endfor

    "remove phony targets
    call filter(l:targets, '!makefile#IsPhonyTarget(v:val)')

    return l:targets
endfunction
