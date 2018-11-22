let s:makefile = {
            \'path': '',
            \'targets': []
            \}

function! s:QfEntryToTargets(entry)
    "removes content after :  from target name
    let l:target = trim(get(split(a:entry.text, ':', 'KeepEmpty'), 0, ''))
    "split targets up if multiple targetnames are specified before :
    "e.g.   hello world:    => ['hello', 'world']
    return split(l:target)
endfunction

function! s:ParseTargets(path)
    if !filereadable(a:path)
        echohl ErrorMsg
        echomsg string(a:path).' not readable!'
        echohl None
    endif

    "list of targets in makefile
    let l:targets = []
    let l:targetregex = '\m\C^[A-Za-z0-9][A-Za-z0-9_/. ]\+:\(\s\|$\)'

    "store old quickfix entries
    let l:oldqflist = getqflist()
    "grep all targets from makefiles
    noautocmd silent! execute 'vimgrep /'.l:targetregex.'/gj '.a:path
    "get found target entries from quickfixlist
    let l:qflist = getqflist()
    "restore old quickfix entries
    call setqflist(l:oldqflist)

    for l:entry in l:qflist
        "add targets to completionlist
        let l:targets += s:QfEntryToTargets(l:entry)
    endfor

    return l:targets
endfunction

function! s:makefile.GetPath() dict
    return self.path
endfunction

function! s:makefile.GetFilename() dict
    return fnamemodify(self.path, ':t')
endfunction

function! s:makefile.GetDirectory() dict
    return fnamemodify(self.path, ':h').'/'
endfunction

function! s:makefile.GetTargets() dict
    return self.targets
endfunction

function! Makefile#Parse(path)
    let l:self = copy(s:makefile)
    let l:self.path = a:path
    let l:self.targets = s:ParseTargets(a:path)
    return l:self
endfunction

