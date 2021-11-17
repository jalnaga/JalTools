(
local tempInstallDir = (GetDir #temp) + "\\jalInstaller"
local installIniFile = tempInstallDir + "\\installINi.ini"

local versionStr = getINISetting installIniFile "Install" "Version"
local externalDestDir = getINISetting installIniFile "Install" "InstallDestination"
local installScriptName = getINISetting installIniFile "Install" "ScriptName"
local categoryName = getINISetting installIniFile "Install" "Category"
local libName = getINISetting installIniFile "Install" "LibName"
local iconName = getINISetting installIniFile "Install" "IconName"
local macroName = getINISetting installIniFile "Install" "MacroName"
local installerTitleBitmap = openBitMap (tempInstallDir + "\\InstallTitle.bmp")

local tempDir = tempInstallDir + "\\" + installScriptName
local externalScriptIniFile = tempDir + "\\ini\\scriptPath.ini"

local userScriptDir = (GetDir #userScripts) + "\\" + installScriptName
local userStartupScriptDir = (GetDir #userStartupScripts) + "\\" + installScriptName
local userIconsDir = (GetDir #userIcons)
local prefsDir = (GetDir #userMacros) + "\\" + installScriptName+"\\ini"
local userMcrDir = (GetDir #userMacros) + "\\" + installScriptName

fn print_exception executingFn exception = (
    format "ScriptLauncher installer exception:\n%\n%\n" executingFn exception
)

fn clear_tempDir = (
    local scriptStr = ""
    scriptStr += "local installDir = (GetDir #temp) + \"/jalInstaller\"\n"
    scriptStr += "local d = installDir + \"/" + installScriptName + "\"\n"
    scriptStr += "if ((dotNetClass \"System.IO.Directory\").Exists d) then(\n"
    scriptStr += "    try ( (dotNetClass \"System.IO.Directory\").Delete installDir true ) catch ()\n"
    scriptStr += "    try ( (dotNetClass \"System.IO.Directory\").Delete d true ) catch ()\n"
    scriptStr += ")\n"

    callbacks.removeScripts #preSystemShutdown id:#ScriptLauncher_installer
    callbacks.addScript #preSystemShutdown scriptStr id:#ScriptLauncher_installer
)

fn remove_script_files = (
    local success = true

    local System_IO_Directory = dotNetClass "System.IO.Directory"

    local oldScriptLoaderDirs = #(((GetDir #startupScripts) + "\\" + installScriptName),
        ((GetDir #Scripts) + "\\" + installScriptName),
        ((GetDir #maxroot) + "\\stdplugs\\stdscripts\\" + installScriptName),
        ((GetDir #ui) + "macroscripts/" + installScriptName),
        ((GetDir #userMacros) + "\\" + installScriptName),
        userScriptDir,
        userStartupScriptDir,
        prefsDir
    )
    for d in oldScriptLoaderDirs do (
        if (System_IO_Directory.Exists d) then (
            try (
                System_IO_Directory.Delete d true
            )
            catch (
                print_exception "remove_script_files" (getCurrentException())
                success = false
            )
        )
    )

    local otherStartupFiles = getFiles ((GetDir #maxroot) + "\\stdplugs\\stdscripts\\" + libName)
    for f in otherStartupFiles do (
        if (not (deleteFile f)) then success = false
    )

    -- Remove icon files
    --old location
    local iconFiles = getFiles ((GetDir #ui) + "\\icons\\" + iconName)
    for ico in iconFiles do deleteFile ico
    --new location
    iconFiles = getFiles (userIconsDir + "\\" + iconName)
    for ico in iconFiles do deleteFile ico

    -- Remove user macros
    local userMacroDir = (GetDir #userMacros)
    local oldUserMacros = (getFiles (userMacroDir + "\\" + macroName))
    for mcr in oldUserMacros do deleteFile mcr

    success
)

fn check_max_version = (
    --Returns true if version is equal to or above 10 (2008).
    ((maxVersion())[1] >= 11000)
)

fn check_dotnet_version = (
    --Returns true if the .NET Framework 3.5 key could be opened.
    local rKey
    local success = registry.openkey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" key:&rKey accessright:#readonly
    if (success) do registry.closeKey rKey
    if (not success) do (
        success = registry.openkey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4" key:&rKey accessright:#readonly
        if (success) do registry.closeKey rKey
    )
    success
)

fn copy_directory sourceDir targetDir = (
    local System_IO_Directory = dotNetClass "System.IO.Directory"
    local System_IO_SearchOption = dotNetClass "System.IO.SearchOption"
    local System_IO_File = dotNetClass "System.IO.File"
    local allFiles = System_IO_Directory.GetFiles sourceDir "*.*" System_IO_SearchOption.AllDirectories

    for sourceFile in allFiles do (
        local targetFile = targetDir + (substring sourceFile (sourceDir.count + 1) -1)
        local targetFileDir = getFilenamePath targetFile
        if (not (System_IO_Directory.Exists targetFileDir)) do System_IO_Directory.CreateDirectory targetFileDir
        System_IO_File.Copy sourceFile targetFile
    )
)

fn copy_script_files = (
    local success = true

    local System_IO_Directory = dotNetClass "System.IO.Directory"
    local System_IO_File = dotNetClass "System.IO.File"

    try (
        copy_directory (tempDir + "\\startupScript") userStartupScriptDir
        copy_directory (tempDir + "\\ini") prefsDir
        copy_directory (tempDir + "\\macroscripts") userMcrDir

        local iconFiles = System_IO_Directory.getFiles (tempDir + "\\icons") iconName
        for ico in iconFiles do System_IO_File.Move ico (userIconsDir + "\\" + (filenameFromPath ico))
    )
    catch (
        print_exception "copy_script_files" (getCurrentException())
        success = false
    )

    success
)

fn copy_external_scripts inFolder = (
    local success = true
    try (
        copy_directory (tempDir + "\\externalScript") inFolder
    )
    catch (
        print_exception "copy_external_scripts" (getCurrentException())
        success = false
    )

    success
)

fn install inFolder = (
    local returnVal = false
    if (not check_max_version()) then (
        messageBox "맥스 버전이 낮어!!!!"
        returnVal = false
        return returnVal
    )

    if (not check_dotnet_version()) then (
        messageBox "닷넷 버전이 낮어!!!!"
        returnVal = false
        return returnVal
    )

    returnVal = remove_script_files()
    returnVal = copy_script_files()
    returnVal = copy_external_scripts inFolder

    returnVal
)

fn uninstall = (
    remove_script_files()
)


rollout ScriptLoaderInstall "Script Launcher Installation" (
    ImgTag titleImg "" pos:[0, 0] bitmap:installerTitleBitmap
    editText externalDestDirTxt "" across:2 align:#left text:externalDestDir readOnly:true fieldWidth:320 offset:[0, 3]
    button setDestBtn "..." align:#right
    button install_btn "Install" width:60 offset:[0, 10] across:3 enabled:false
    button uninstall_btn "Uninstall" width:60 offset:[0, 10]
    button close_btn "Close" width:60 offset:[0, 10]

    rollout InstallCompleteRollout "Install Complete!"
    (
        label title_lbl "jal Tool 설치 완료!" offset:[0, 5]
        label descr_lbl "설치가 완료되었습니다. 설치후 Customize - Customize User Interface - Toolbar 탭에서" offset:[0, 5]
        label descr_lbl2 "jal Tools 카테고리 선택 후, jalTool Launcher를 툴바에 끌어다 놓아 주세요." offset:[0, -2]
        button finish_btn "OK" width:60 offset:[0, 10]

        on finish_btn pressed do (
            destroyDialog InstallCompleteRollout
            destroyDialog ScriptLoaderInstall
        )

        on InstallCompleteRollout close do (
            destroyDialog InstallCompleteRollout
            destroyDialog ScriptLoaderInstall
        )
    )

    rollout UninstallCompleteRollout "Uninstall Complete!"
    (
        label title_lbl "jal Tool 제거 완료!" offset:[0, 5]
        label descr_lbl "제거가 완료되었습니다. 제거 후 툴바에 등록되어 있는" offset:[0, 5]
        label descr_lbl2 "jalTool Launcher 버튼을 지워 주시고 맥스를 재시작 해주십시오." offset:[0, -2]
        button finish_btn "OK" width:60 offset:[0, 10]

        on finish_btn pressed do
        (
            destroyDialog UninstallCompleteRollout
            destroyDialog ScriptLoaderInstall
        )

        on UninstallCompleteRollout close do
        (
            destroyDialog UninstallCompleteRollout
            destroyDialog ScriptLoaderInstall
        )
    )

    on setDestBtn pressed do (
        local newDestDir = getSavePath caption:"Install To..." initialDir:externalDestDir

        if newDestDir != undefined then (
            externalDestDirTxt.text = newDestDir
            setINISetting installIniFile "Install" "InstallDestination" newDestDir
            externalDestDir = getINISetting installIniFile "Install" "InstallDestination"
            setINISetting externalScriptIniFile "ExternalScript" "ScriptPath" externalDestDir
            install_btn.enabled = true
        )
    )

    on install_btn pressed do
    (
        if (install externalDestDir) == true then (
            createDialog InstallCompleteRollout modal:true lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow) width:450 height:100
        )
        clear_tempDir()
    )

    on uninstall_btn pressed do
    (
        uninstall()
        clear_tempDir()
        createDialog UninstallCompleteRollout modal:true lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow) width:450 height:100
    )

    on close_btn pressed do
    (
        clear_tempDir()
        destroyDialog ScriptLoaderInstall
    )
)


createDialog ScriptLoaderInstall 400 230 modal:true lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow)
)
