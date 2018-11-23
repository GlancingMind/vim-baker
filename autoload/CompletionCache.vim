if !exists('s:cache')
    let s:cache = {}
endif

function! s:PreparePath(path)
     return resolve(a:path)
endfunction

function! CompletionCache#Show()
    echo s:cache
endfunction

function! CompletionCache#Clear()
    let s:cache = {}
endfunction

function! CompletionCache#Add(arguments, completions)
    if !CompletionCache#Has(a:arguments)
        echomsg 'cache: '.string(a:arguments).' '.string(a:completions)
        let s:cache[string(a:arguments)] = a:completions
    endif
endfunction

function! CompletionCache#Has(arguments)
    echomsg 'has: '.string(a:arguments)
    return has_key(s:cache, string(a:arguments))
endfunction

function! CompletionCache#Get(arguments)
    return get(s:cache, string(a:arguments) , [])
endfunction
