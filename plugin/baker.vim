command! -complete=customlist,baker#CompleteMakeTargets -nargs=? Baker call baker#ExecuteTargetRule(<f-args>)

command!  BakerLs call baker#ListTargets()

