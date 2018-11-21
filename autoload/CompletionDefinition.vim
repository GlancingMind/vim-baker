let s:definition = {'Funcref': 0, 'startid': 0, 'endid': 0}

function! s:CanBeCalled(self, argid)
    if a:self.startid <= a:argid && a:self.endid is# '*'
        return 1
    elseif a:self.startid <= a:argid && a:argid < a:self.endid
        return 1
    endif

    return 0
endfunction

function! s:definition.Complete(arguments, arglead, argseperator) dict
    if s:CanBeCalled(self, len(a:arguments))
        return self.Funcref(a:arguments, a:arglead, a:argseperator)
    endif
    return []
endfunction

function! CompletionDefinition#Create(funcref, startid, ...)
    let l:definition = copy(s:definition)
    let l:definition.Funcref = a:funcref
    let l:definition.startid = a:startid
    let l:definition.endid = get(a:, 1, '*')
    return l:definition
endfunction
