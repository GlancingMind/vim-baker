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
    "TODO: change makefile back to non dict function -> can call
    "Makefile#DirPath and filename
    let l:path = fnamemodify(a:path, ':h').'/'
    let l:filename = fnamemodify(a:path, ':t')
    if has_key(s:cache, l:path)
        if has_key(s:cache[l:path], l:filename)
            let l:targets = s:cache[l:path][l:filename]
            return Makefile#Create(a:path, l:targets)
        endif
    endif

    return {}
endfunction
