function! s:UpdateCache(path)
    let l:makefile = Makefile#Parse(a:path)
    call MakefileCache#Add(l:makefile)
endfunction

autocmd BufNewFile,BufRead *
            \    if MakefileFinder#IsMakefile(expand("%"))
            \ |     setfiletype make
            \ |  else
            \ |     setfiletype none
            \ |     silent noautocmd filetype detect
            \ |  endif

autocmd FileWritePost,BufWritePost *
            \   if MakefileFinder#IsMakefile(expand("%"))
            \ |     call s:UpdateCache(expand("%"))
            \ | endif
