command! -complete=customlist,baker#Complete -nargs=* Baker call baker#ExecuteTargetRule(<f-args>)

command! -complete=customlist,baker#CompleteDirectoryOrMakefile -nargs=? BakerLs call baker#ListTargets("<args>")

