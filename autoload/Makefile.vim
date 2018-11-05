let s:makefile = {
            \'path': '',
            \'filename': '',
            \'targets': []
            \}

function! s:Create(path, targets)
    let l:self = copy(s:makefile)
    let l:self.path = fnamemodify(a:path, ':h').'/'
    let l:self.filename = fnamemodify(a:path, ':t')
    let l:self.targets = a:targets

    return l:self
endfunction

function! s:QfEntryToTargets(entry)
    "removes content after :  from target name
    let l:target = trim(get(split(a:entry, ':', 'KeepEmpty'), 0, ''))
    "split targets up if multiple targetnames are specified before :
    "e.g.   hello world:    => ['hello', 'world']
    return split(l:target)
endfunction

function! s:ParseTargets(path)
    "list of targets in makefile
    let l:targets = []

    "grep all targets from makefiles
    noautocmd silent! execute 'vimgrep /\m\C^[A-Za-z0-9][A-Za-z0-9_/. ]\+:/gj '.a:path
    "get found target entries from quickfixlist
    for l:entry in getqflist()
        "add targets to completionlist
        let l:targets += s:QfEntryToTargets(l:entry.text)
    endfor

    return l:targets
endfunction

function! Makefile#Parse(path)
    if !filereadable(a:path)
        echohl ErrorMsg
        echomsg string(a:path).' not readable!'
        echohl None
    endif

    let l:targets = s:ParseTargets(a:path)
    return s:Create(a:path, l:targets)
endfunction
