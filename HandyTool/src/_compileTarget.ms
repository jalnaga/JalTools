__HandyToolPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __HandyToolPath
(
    include "ui_mainRollout.ms"
    clearlistener()
    gc()
)

