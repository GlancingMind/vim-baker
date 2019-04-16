let s:completion = {'definitions': []}

function! s:IsArgumentComplete(argument, argseperator)
    "determine if given argument has been completed by checking, that the last
    "character matches argument seperator
    return a:argument[-1:] is# a:argseperator
endfunction

function! s:GetArguments(cmdline, argseperator)
    "Get all arguments from cmdline except the command name (first argument)
    return split(a:cmdline, a:argseperator, 1)[1:]
endfunction

function! s:ExtractArgumentLead(arguments, argseperator)
    if !empty(a:arguments) && !s:IsArgumentComplete(a:arguments[-1], a:argseperator)
        return remove(a:arguments, -1)
    endif
    return ''
endfunction

"Return all completions for the current argument.
"Params:
"cmdline is the same as in a custom command completion.
"   See :help :command-completion-custom
"argseperator a string used to split the cmdline in seperate arguments
function! s:completion.Complete(cmdline, argseperator) dict
    let l:arguments = s:GetArguments(a:cmdline, a:argseperator)
    let l:arglead = s:ExtractArgumentLead(l:arguments, a:argseperator)

    let l:completions = []
    for l:definition in self.definitions
        let l:completions += l:definition.Complete(l:arguments, l:arglead, a:argseperator)
    endfor

    return l:completions
endfunction

"Add a completion function to completion.
"Params:
"funcref is a completion function in following form:
"   function! s:CompleteDirectory(arguments, arglead, argseperator)
"   arguments is a list of every argument in cmdline.
"   arglead is the leading portion of the argment currently being completed
"       on.
"   argseperator is the seperator with wich the arguments where extracted from
"       the cmdline.
"startid is an integer, which indicates on which argument the funcref will be
"   invoked. When 0, funcref will be invoked to complete the first argument.
"[endid] indicates when the funcref won't be invoked. This can be an integer
"   or the '*' character. When 1, funcref won't be called for the second
"   argument. When '*', end is unspecified. When endid isn't set, '*' will be
"   assumed.
function! s:completion.AddDefinition(funcref, startid, ...) dict
    let l:definition = CompletionDefinition#Create(a:funcref, a:startid, get(a:, 1, '*'))
    call add(self.definitions, l:definition)
endfunction

"Returns a new instance of completion object.
function! Completion#CreateCompletion()
    return deepcopy(s:completion)
endfunction
