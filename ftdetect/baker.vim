autocmd BufNewFile,BufRead *
            \    if MakefileFinder#IsMakefile(expand("%"))
            \ |     setfiletype make
            \ |  else
            \ |     silent noautocmd filetype detect
            \ |  endif

