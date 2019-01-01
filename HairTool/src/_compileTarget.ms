__HairToolSciptPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __HairToolSciptPath
(
    include "ui_mainRollout.ms"
    clearlistener()
    gc()
)
