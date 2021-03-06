if !exists('s:cache')
    let s:cache = {}
endif

function! MakefileCache#Show()
    echo s:cache
endfunction

function! MakefileCache#Clear()
    let s:cache = {}
endfunction

function! MakefileCache#Add(makefile)
    let l:path = a:makefile.GetDirectory()
    let l:oldCacheEntry = get(s:cache, l:path, {})
    let l:newCacheEntry = {a:makefile.GetFilename() : a:makefile.GetTargets()}
    let s:cache[l:path] = extend(l:oldCacheEntry, l:newCacheEntry)
endfunction

function! MakefileCache#GetByPath(path)
    let l:makefile = Makefile#Create(a:path)
    let l:dir = l:makefile.GetDirectory()
    let l:filename = l:makefile.GetFilename()
    if has_key(s:cache, l:dir)
        if has_key(s:cache[l:dir], l:filename)
            call l:makefile.SetTargets(s:cache[l:dir][l:filename])
            return l:makefile
        endif
    endif

    return {}
endfunction

function! MakefileCache#GetTargets(path, ...)
    let l:filter = get(a:, 1, '')
    let l:makefile = MakefileCache#GetByPath(a:path)
    if !empty(l:makefile)
        return l:makefile.GetTargets(l:filter)
    endif

    return []
endfunction
