__TemplateScriptPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __TemplateScriptPath
(
include "jalLibHeader.ms"

global jal = _JalLib()

jal.name.load_setting_from_ini()
jal.tools.delete_unwantedScripts()
callbacks.removeScripts id:#jalRemoveGlobalAttributes
callbacks.addScript #filePreSave "jal.tools.delete_persistanceGlobal()" id:#jalRemoveGlobalAttributes
)
