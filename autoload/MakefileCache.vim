if !exists('s:cache')
    let s:cache = {}
endif

function! MakefileCache#Show()
    echo s:cache
endfunction

function! MakefileCache#Clear()
    let s:cache = {}
endfunction

function! s:PreparePath(path)
     return resolve(a:path)
endfunction

function! MakefileCache#Add(makefile)
    let l:path = s:PreparePath(a:makefile.GetPath())
    let l:oldCacheEntry = get(s:cache, l:path, {})
    let l:newCacheEntry = {a:makefile.GetFilename() : a:makefile.GetTargets()}
    let s:cache[l:path] = extend(l:oldCacheEntry, l:newCacheEntry)
endfunction

function! MakefileCache#GetByPath(path)
    let l:path = s:PreparePath(fnamemodify(a:path, ':h').'/')
    let l:filename = fnamemodify(a:path, ':t')
    if has_key(s:cache, l:path)
        if has_key(s:cache[l:path], l:filename)
            let l:targets =  s:cache[l:path][l:filename]
            return Makefile#Create(l:path, l:targets)
        endif
    endif

    return {}
endfunction

function! MakefileCache#GetFilenamesByPath(path)
    let l:path = s:PreparePath(a:path)
    if has_key(s:cache, l:path)
        return keys(s:cache[l:path])
    endif

    return []
endfunction
