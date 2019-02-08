__FacialCageToolPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __FacialCageToolPath
(
    include "ui_mainRollout.ms"
    clearlistener()
    gc()
)
