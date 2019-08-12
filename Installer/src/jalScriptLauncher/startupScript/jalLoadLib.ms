(
    local tool_path = getINISetting ((GetDir #userMacros) + "\\jalScriptLauncher\\ini\\scriptPath.ini") "ExternalScript" "ScriptPath"
    local libFile = tool_path + "/JalLib/JalLib.ms"
    fileIn libFile

    local macro_path = tool_path + "/JalMacro"
    local macroFiles = getFiles (macro_path + "/jal_*.ms")
    for macroFile in macroFiles do fileIn macroFile
)
