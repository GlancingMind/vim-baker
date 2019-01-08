function! s:GetFilename(path)
    return fnamemodify(a:path, ':t:r')
endfunction

function! MakefileFinder#IsMakefile(path)
    let l:globes = get(g:, 'Baker_MakefileGlobes')
    "construct a regex for each glob pattern and concatenate these with OR-op.
    let l:pattern = join(map(copy(l:globes), 'glob2regpat(v:val)'), '\|')
    return s:GetFilename(a:path) =~ l:pattern
endfunction

function! MakefileFinder#Find(path)
    let l:files = getcompletion(a:path, 'file')
    "filter out makefiles from all files
    return filter(l:files, 'MakefileFinder#IsMakefile(v:val)')
endfunction

