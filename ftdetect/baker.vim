autocmd BufNewFile,BufRead *
            \    if MakefileFinder#IsMakefile(expand("%"))
            \ |     setfiletype make
            \ |  else
            \ |     setfiletype none
            \ |     silent noautocmd filetype detect
            \ |  endif

