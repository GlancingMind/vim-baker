let s:makefile = {
            \'path': '',
            \'filename': '',
            \'targets': []
            \}

function! Makefile#Create(path, targets)
    let l:self = copy(s:makefile)
    let l:self.path = fnamemodify(a:path, ':h').'/'
    let l:self.filename = fnamemodify(a:path, ':t')
    let l:self.targets = a:targets

    return l:self
endfunction

function! Makefile#Parse(path)
    let l:targets = Makefile#ParseTargets(a:path)
    return Makefile#Create(a:path, l:targets)
endfunction

function! Makefile#IsPhonyTarget(target)
    return a:target[0] is# '.'
endfunction

function! Makefile#QfEntryToTargets(entry)
    "removes content after :  from target name
    let l:target = trim(get(split(a:entry, ':', 'KeepEmpty'), 0, ''))
    "split targets up if multiple targetnames are specified before :
    "e.g.   hello world:    => ['hello', 'world']
    return split(l:target)
endfunction

function! Makefile#ParseTargets(path)
    if !filereadable(a:path)
        echoerr string(a:path).' not readable!'
    endif

    "list of targets in makefile
    let l:targets = []

    "grep all targets from makefiles
    noautocmd execute 'silent! vimgrep /\m\C^\S[A-Za-z0-9_/. ]\+:/gj '.a:path
    "get found target entries from quickfixlist
    for l:entry in getqflist()
        "add targets to completionlist
        let l:targets += Makefile#QfEntryToTargets(l:entry.text)
    endfor

    "remove phony targets
    call filter(l:targets, '!Makefile#IsPhonyTarget(v:val)')

    return l:targets
endfunction
