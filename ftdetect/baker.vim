function! s:UpdateCache(path)
    echomsg "Baker: update cache for ".a:path
    let l:makefile = Makefile#Parse(a:path)
    call MakefileCache#Add(l:makefile)
endfunction

"disable the init autocmd in this script
autocmd! filetypedetect VimEnter
if !exists("g:Baker_MakefileNames")
    "following command will reparse this file after vim is fully initilized.
    "this will guarentee that g:Baker_MakefileNames is initilized otherwise
    "the later defined autocmds won't get proper filenames.
    autocmd VimEnter * source <sfile>
    finish
endif
echomsg "resourced ".expand('<sfile>')

let s:makefilenames = get(g:, 'Baker_MakefileNames')

"if current buffer  matches a makefilename, then set filetype to makefile
if index(s:makefilenames, expand("%:t:r")) != -1
    "When a makefile is opened from the commandline, the filetype has to be
    "set without relying on the autocmd. Otherwise the filetype won't be set
    "for this makefile. As the autocmd to set the filetype will be first
    "activated after the buffer is already presented.
    setfiletype make
endif

let s:makefilenames = join(s:makefilenames, ',')
execute 'autocmd BufNewFile,BufRead '.s:makefilenames.' setfiletype make'
execute 'autocmd FileWritePost '.s:makefilenames.' call s:UpdateCache(expand("%"))'
execute 'autocmd BufWritePost '.s:makefilenames.' call s:UpdateCache(expand("%"))'
