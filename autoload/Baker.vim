function! s:EchoError(msg)
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction

function! s:ContainsPathSpecifier(path)
    return a:path =~? '[./]'
endfunction

function! s:GetDirectoryPath(path)
    if isdirectory(a:path)
        return a:path
    endif
    return fnamemodify(expand(a:path), ':~:.:h').'/'
endfunction

function! s:ReconstructMakefilePath(makefile)
    return s:GetDirectoryPath(g:Baker_MakefileLookupPath).a:makefile
endfunction

function! s:FindInDirectory(directory, patterns)
    let l:matches = []

    "get all files which filenames match given patterns in specified directory
    "and return them as list while preserving the order as given via patterns
    "e.g. first patter matches are before second pattern matches in the list
    for l:pattern in a:patterns
        let l:matches += globpath(a:directory, l:pattern, 0, 1)
    endfor

    return l:matches
endfunction

function! s:ExtractReadableFiles(files)
    return filter(a:files, 'filereadable(v:val)')
endfunction

function! s:GetMakefilesInDirectory(directory)
    let l:makefiles = s:FindInDirectory(a:directory, g:Baker_MakefileNames)
    "remove all nonreadable files from matching files
    "e.g. a directories matching given patterns
    return s:ExtractReadableFiles(l:makefiles)
endfunction

function! s:GetDirectoriesInDirectory(directory)
    return s:FindInDirectory(a:directory, ['*/'])
endfunction

function! s:GetTargets(makefile)
    return Makefile#Parse(a:makefile).targets
endfunction

function! s:CompleteMakefile(arguments, arglead, argseperator)
    let l:pattern = resolve(a:arglead)
    let l:dir = s:GetDirectoryPath(l:pattern)
    let l:mfformat = 'v:val.a:argseperator'

    "when in lookup directory remove leading path from filenames
    if !s:ContainsPathSpecifier(a:arglead)
        let l:dir = s:GetDirectoryPath(g:Baker_MakefileLookupPath)
        let l:mfformat = 'fnamemodify(v:val, ":t").a:argseperator'
    endif

    "when path to file
    if s:ContainsPathSpecifier(l:pattern) && !isdirectory(l:pattern)
        let l:pattern = l:pattern[2:]
    endif

    let l:makefiles = s:GetMakefilesInDirectory(l:dir)

    "add argseperator and optionaly extract filenames of makefiles
    let l:makefiles = map(l:makefiles, l:mfformat)
    "remove all completions  that don't match users given argument
    return filter(l:makefiles, 'v:val =~ resolve(l:pattern)')
endfunction

function! s:CompleteDirectories(arguments, arglead, argseperator)
    let l:dir = resolve(a:arglead)
    let l:pattern = l:dir
    if empty(a:arglead)
        let l:dir = s:GetDirectoryPath(g:Baker_MakefileLookupPath)
    endif

    let l:dir = s:GetDirectoryPath(l:dir)
    let l:directories = s:GetDirectoriesInDirectory(l:dir)

    if s:ContainsPathSpecifier(a:arglead) && !isdirectory(a:arglead)
        let l:pattern = l:pattern[2:]
    endif

    "remove all completions  that don't match users given argument
    return filter(l:directories, 'v:val =~ l:pattern')
endfunction

function! s:CompleteMakefilesAndDirectories(arguments, arglead, argseperator)
    "when a file is given return this path as only completion
    if filereadable(g:Baker_MakefileLookupPath)
        return [g:Baker_MakefileLookupPath.' ']
    endif

    let l:makefiles = s:CompleteMakefile(a:arguments, a:arglead, a:argseperator)
    let l:dirs = s:CompleteDirectories(a:arguments, a:arglead, a:argseperator)
    return l:makefiles + l:dirs
endfunction

function! s:CompleteTarget(arguments, argLead, argseperator)
    if s:ContainsPathSpecifier(a:arguments[-1])
        "is already path to a makefile
        let l:makefile = a:arguments[-1]
    else
        "only makefile name given, reconstruct path from project root
        let l:makefile = s:ReconstructMakefilePath(a:arguments[-1])
    endif

    let l:targets = s:GetTargets(l:makefile)
    "remove all targets  that don't match users given argument
    let l:targets = filter(copy(l:targets), 'v:val =~ a:argLead')
    return map(l:targets, 'v:val . a:argseperator')
endfunction

function! Baker#Complete(argLead, cmdLine, curPos)
    let l:CompMakefile = funcref('s:CompleteMakefilesAndDirectories')
    let l:CompTarget = funcref('s:CompleteTarget')
    let l:compFuncs = [l:CompMakefile, l:CompTarget]
    let l:completion = ComComp#Complete(a:cmdLine, l:compFuncs, ' ')

    if empty(l:completion)
        "echo 'No completion found'
    endif

    return l:completion
endfunction

function! Baker#SetMakeprg(args)
    if empty(a:args)
        return
    endif

    let l:arguments = split(a:args)
    let l:makefile = l:arguments[0]
    let l:targets = l:arguments[1:]

    if !s:ContainsPathSpecifier(l:makefile)
        "only makefile name given, reconstruct path from project root
        let l:makefile = s:GetDirectoryPath(g:Baker_MakefileLookupPath).l:makefile
    endif

    let &makeprg='make -f '.l:makefile.' '.join(l:targets)

    echohl MoreMsg
    echomsg 'Set makeprg to '.&makeprg
    echohl None
endfunction

