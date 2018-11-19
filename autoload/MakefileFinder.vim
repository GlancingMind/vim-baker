
function! MakefileFinder#Finder(path)
    let l:files = getcompletion(a:path, 'file')
    "filter out makefiles from all files
    return filter(l:files, 'index(g:Baker_MakefileNames, s:GetFilename(v:val)) >= 0')
endfunction

