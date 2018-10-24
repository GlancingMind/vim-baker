command! -complete=customlist,baker#CompleteMakeTargets -nargs=? Baker call baker#ExecuteTargetRule(<f-args>)

command! -complete=dir -nargs=? BakerLs call baker#ListTargets("<args>")

