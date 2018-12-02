__TemplateScriptPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __TemplateScriptPath
(
    include "ui_mainRollout.ms"
    clearlistener()
    gc()
)
