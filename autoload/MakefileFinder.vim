function! s:GetFilename(path)
    return fnamemodify(expand(a:path), ':t')
endfunction

function! MakefileFinder#Find(path)
    let l:files = getcompletion(a:path, 'file')
    "filter out makefiles from all files
    call filter(l:files, 'index(g:Baker_MakefileNames, s:GetFilename(v:val)) >= 0')
    return map(l:files, 'Makefile#Parse(v:val)')
endfunction

