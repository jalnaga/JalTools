__FacialMocapTool = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __FacialMocapTool
(
    include "ui_mainRollout.ms"
    clearlistener()
    gc()
)
