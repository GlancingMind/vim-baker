function! s:GetFilename(path)
    return fnamemodify(expand(a:path), ':t')
endfunction

function! MakefileFinder#Find(path)
    let l:files = getcompletion(a:path, 'file')
    "filter out makefiles from all files
    return filter(l:files, 'index(g:Baker_MakefileNames, s:GetFilename(v:val)) >= 0')
endfunction

