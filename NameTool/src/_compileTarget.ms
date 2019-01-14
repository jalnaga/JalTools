__NameToolPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __NameToolPath
(
    include "ui_mainRollout.ms"
    clearlistener()
    gc()
)
