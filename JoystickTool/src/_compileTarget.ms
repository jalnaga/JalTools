__JoystickToolPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __JoystickToolPath
(
include "ui_mainRollout.ms"
clearlistener()
gc()
)
