command! -complete=customlist,projector#GetMakeTargets -nargs=? ProjectorBuild call projector#ExecuteTargetRule(<f-args>)

