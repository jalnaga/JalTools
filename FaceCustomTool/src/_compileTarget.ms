__FaceCustomToolPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __FaceCustomToolPath
(
    include "ui_mainRollout.ms"
    --clearlistener()
    gc()
)
