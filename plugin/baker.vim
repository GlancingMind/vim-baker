command! -complete=customlist,baker#GetMakeTargets -nargs=? Baker call baker#ExecuteTargetRule(<f-args>)

