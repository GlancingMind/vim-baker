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
    let l:oldCacheEntry = get(s:cache, a:makefile.path, {})
    let l:newCacheEntry = { a:makefile.filename : a:makefile.targets }
    let s:cache[a:makefile.path] = extend(l:oldCacheEntry, l:newCacheEntry)
endfunction

function! MakefileCache#GetByPath(path)
    let l:path = fnamemodify(a:path, ':h').'/'
    let l:filename = fnamemodify(a:path, ':t')
    if has_key(s:cache, l:path)
        if has_key(s:cache[l:path], l:filename)
            let l:targets =  s:cache[l:path][l:filename]
            return Makefile#Create(a:path, l:targets)
        endif
    endif

    return {}
endfunction

function! MakefileCache#GetMakefileNamesByPath(path)
    if has_key(s:cache, a:path)
        return keys(s:cache[a:path])
    endif

    return []
endfunction
