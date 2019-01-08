function! s:UpdateCache(path)
    let l:makefile = Makefile#Parse(a:path)
    call MakefileCache#Add(l:makefile)
endfunction

function! s:IsMakefile(path)
    let l:filename = fnamemodify(a:path, ':t:r')
    let l:globes = get(g:, 'Baker_MakefileNames')
    let l:pattern = join(map(copy(l:globes), 'glob2regpat(v:val)'), '\|')
    return l:filename =~ l:pattern
endfunction

autocmd BufNewFile,BufRead *
            \   if s:IsMakefile(expand("%"))
            \ |  setfiletype make
            \ | endif

autocmd FileWritePost,BufWritePost *
            \   if s:IsMakefile(expand("%"))
            \ |  call s:UpdateCache(expand("%"))
            \ | endif
