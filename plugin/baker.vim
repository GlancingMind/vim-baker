command! -complete=customlist,baker#GetMakeTargets -nargs=? Baker call baker#ExecuteTargetRule(<f-args>)

command!  BakerLs call baker#ListTargets()

