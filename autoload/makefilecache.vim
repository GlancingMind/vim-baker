if !exists('s:cache')
    let s:cache = {}
endif

function! makefilecache#Show()
    echo s:cache
endfunction

function! makefilecache#Clear()
    let s:cache = {}
endfunction

function! makefilecache#Add(makefile)
    let l:oldCacheEntry = get(s:cache, a:makefile.path, {})
    let l:newCacheEntry = { a:makefile.filename : a:makefile.targets }
    let s:cache[a:makefile.path] = extend(l:oldCacheEntry, l:newCacheEntry)
endfunction

function! makefilecache#GetByPath(path)
    let l:path = fnamemodify(a:path, ":h")
    let l:filename = fnamemodify(a:path, ":t")
    if has_key(s:cache, l:path)
        if has_key(s:cache[l:path], l:filename)
            let l:targets =  s:cache[l:path][l:filename]
            return makefile#Create(a:path, l:targets)
        endif
    endif

    return {}
endfunction

function! makefilecache#GetMakefileNamesByPath(path)
    let l:path = fnamemodify(a:path, ":h")
    if has_key(s:cache, l:path)
        return keys(s:cache[l:path])
    endif

    return []
endfunction
