function! s:IsArgumentComplete(argument, argseperator)
    "determine if given argument has been completed by checking, that the last
    "character matches argument seperator
    return a:argument[-1:] is# a:argseperator
endfunction

function! s:GetArguments(cmdline, argseperator)
    "return all arguments except the command name (first argument)
    return split(a:cmdline, a:argseperator, 1)[1:]
endfunction

function! s:ExtractArgLead(arguments, argseperator)
    if len(a:arguments) > 0 && !s:IsArgumentComplete(a:arguments[-1], a:argseperator)
        return remove(a:arguments, -1)
    endif
    return ''
endfunction

function! s:CallCompletionFunction(compfuncs, index, args)
    let l:range = 0
    for l:compfunc in a:compfuncs
        let l:quantifier = get(l:compfunc, 'quantifier', 0)
        if l:quantifier is# '*'
            return call(l:compfunc.Complete, a:args)
        endif

        let l:range += str2nr(l:quantifier)
        if l:range > a:index
            return call(l:compfunc.Complete, a:args)
        endif
    endfor
    return []
endfunction

function! ComComp#Complete(cmdline, compfuncs, argseperator)
    let l:arguments = s:GetArguments(a:cmdline, a:argseperator)
    let l:arglead = s:ExtractArgLead(l:arguments, a:argseperator)
    let l:argcount = len(l:arguments)

    return s:CallCompletionFunction(a:compfuncs, l:argcount,
                \ [l:arguments, l:arglead, a:argseperator])
endfunction
