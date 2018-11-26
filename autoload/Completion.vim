let s:completion = {'definitions': []}

function! s:IsArgumentComplete(argument, argseperator)
    "determine if given argument has been completed by checking, that the last
    "character matches argument seperator
    return a:argument[-1:] is# a:argseperator
endfunction

function! s:GetArguments(cmdline, argseperator)
    "return all arguments except the command name (first argument)
    return split(a:cmdline, a:argseperator, 1)[1:]
endfunction

function! s:ExtractArgumentLead(arguments, argseperator)
    if !empty(a:arguments) && !s:IsArgumentComplete(a:arguments[-1], a:argseperator)
        return remove(a:arguments, -1)
    endif
    return ''
endfunction

function! s:completion.Complete(cmdline, argseperator) dict
    let l:arguments = s:GetArguments(a:cmdline, a:argseperator)
    let l:arglead = s:ExtractArgumentLead(l:arguments, a:argseperator)

    let l:completions = []
    for l:definition in self.definitions
        let l:completions += l:definition.Complete(l:arguments, l:arglead, a:argseperator)
    endfor

    return l:completions
endfunction

function! s:completion.AddDefinition(funcref, startid, ...) dict
    let l:definition = CompletionDefinition#Create(a:funcref, a:startid, get(a:, 1, '*'))
    call add(self.definitions, l:definition)
endfunction

function! Completion#CreateCompletion()
    return copy(s:completion)
endfunction
