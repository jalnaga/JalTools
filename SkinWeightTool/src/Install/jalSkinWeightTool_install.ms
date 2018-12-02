(
local version = 1.0
local versionStr = version as string
local installFolderName = "jalSkinWeightTool"

local tempDir = (GetDir #temp) + "\\" + installFolderName
local userScriptDir = (GetDir #userScripts) + "\\" + installFolderName
local userStartupScriptDir = (GetDir #userStartupScripts) + "\\" + installFolderName
local userIconsDir = (GetDir #userIcons)

local prefsDir = (GetDir #userMacros) + "\\" + installFolderName + "\\ini"


fn print_exception executingFn exception =
(
    format "ScriptLauncher installer exception:\n%\n%\n" executingFn exception
)

fn clear_tempDir =
(
    local scriptStr = ("local d = (GetDir #temp) + \"/" + installFolderName + "
      if ((dotNetClass \"System.IO.Directory\").Exists d) do
         try ( (dotNetClass \"System.IO.Directory\").Delete d true ) catch ()")

   callbacks.removeScripts #preSystemShutdown id:#ScriptLauncher_installer
   callbacks.addScript #preSystemShutdown scriptStr id:#ScriptLauncher_installer
)

fn remove_script_files =
(
    local success = true

    local System_IO_Directory = dotNetClass "System.IO.Directory"

    local oldScriptLoaderDirs = #(((GetDir #startupScripts) + "\\" + installFolderName),
                              ((GetDir #Scripts) + "\\" + installFolderName),
                              ((GetDir #maxroot) + "\\stdplugs\\stdscripts\\" + installFolderName),
                              ((GetDir #ui) + "macroscripts/" + installFolderName),
                              ((GetDir #userMacros) + "\\" + installFolderName),
                              userScriptDir,
                              userStartupScriptDir,
                              prefsDir
                             )
    for d in oldScriptLoaderDirs do
    (
        if (System_IO_Directory.Exists d) do
        (
            try (
                System_IO_Directory.Delete d true
            ) catch
            (
                print_exception "remove_script_files" (getCurrentException())
                success = false
            )
        )
    )

    local otherStartupFiles = getFiles ((GetDir #maxroot) + "\\stdplugs\\stdscripts\\" + installFolderName)
    for f in otherStartupFiles do
    (
        if (not (deleteFile f)) do
            success = false
    )

    -- Remove icon files
    --old location
    local iconFiles = getFiles ((GetDir #ui) + "\\icons\\" + installFolderName + "*.bmp")
    for ico in iconFiles do
    (
        deleteFile ico
    )
    --new location
    iconFiles = getFiles (userIconsDir + "\\" + installFolderName + "*.bmp")
    for ico in iconFiles do
    (
        deleteFile ico
    )

    -- Remove user macros
    local userMacroDir = (GetDir #userMacros)
    local oldUserMacros = (getFiles (userMacroDir + "\\" + installFolderName + "*.mcr"))
    for mcr in oldUserMacros do
    (
        deleteFile mcr
    )

    success
)

fn check_max_version =
(
    --Returns true if version is equal to or above 10 (2008).
    ((maxVersion())[1] >= 11000)
)

fn check_dotnet_version =
(
    --Returns true if the .NET Framework 3.5 key could be opened.
    local rKey
    local success = registry.openkey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" key:&rKey accessright:#readonly
    if (success) do
        registry.closeKey rKey

    if (not success) do
    (
        success = registry.openkey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4" key:&rKey accessright:#readonly
        if (success) do
            registry.closeKey rKey
    )

    success
)

fn copy_directory sourceDir targetDir =
(
    local System_IO_Directory = dotNetClass "System.IO.Directory"
    local System_IO_SearchOption = dotNetClass "System.IO.SearchOption"
    local System_IO_File = dotNetClass "System.IO.File"
    local allFiles = System_IO_Directory.GetFiles sourceDir "*.*" System_IO_SearchOption.AllDirectories


    for sourceFile in allFiles do
    (
        local targetFile = targetDir + (substring sourceFile (sourceDir.count + 1) -1)
        local targetFileDir = getFilenamePath targetFile
        if (not (System_IO_Directory.Exists targetFileDir)) do
            System_IO_Directory.CreateDirectory targetFileDir
        System_IO_File.Copy sourceFile targetFile
    )
)

fn copy_script_files =
(
    local success = true

    local System_IO_Directory = dotNetClass "System.IO.Directory"
    local System_IO_File = dotNetClass "System.IO.File"

    try
    (
        copy_directory (tempDir + "\\script") userScriptDir
        copy_directory (tempDir + "\\startupScript") userStartupScriptDir
        copy_directory (tempDir + "\\ini") prefsDir

        local iconFiles = System_IO_Directory.getFiles (tempDir + "\\icons") (installFolderName + "*.bmp")
        for ico in iconFiles do
            System_IO_File.Move ico (userIconsDir + "\\" + (filenameFromPath ico))
    )
    catch
    (
        print_exception "copy_script_files" (getCurrentException())
        success = false
    )

    success
)

fn load_macro_scripts =
(
    local success = true
    try
    (
        colorman.reInitIcons()

        local files = GetFiles (tempDir + "\\Lib\\*.ms")
        for file in files do
            fileIn file

        files = GetFiles (tempDir + "\\macroscripts\\*.mcr")
        for file in files do
            fileIn file
    )
    catch
    (
        print_exception "load_macro_scripts" (getCurrentException())
        success = false
    )

    success
)

fn get_active_cuifile =
(
   local configFile = cui.getConfigFile()
   if (not (getFileSecurityInfo configFile #write)) then
   (
      configFile = pathConfig.appendPath userUIDir (filenameFromPath configFile)
   )

   cui.saveConfigAs configFile

   configFile
)

fn install =
(
    if (not check_max_version()) do
    (
        messageBox "맥스 버전이 낮어!!!!"
        return false
    )

    if (not check_dotnet_version()) do
    (
        messageBox "닷넷 버전이 낮어!!!!"
        return false
    )

--  load_dll()

    remove_script_files()

    copy_script_files()
    load_macro_scripts()
)

fn uninstall =
(
--  load_dll()
    remove_script_files()
)

local installMessageString = installFolderName + " 설치 완료!\n\n"
installMessageString += "설치가 완료되었습니다. 설치후 Customize - Customize User Interface - Toolbar 탭에서\n"
installMessageString += ("jal Tools 카테고리 선택 후, " + installFolderName + "를 툴바에 끌어다 놓아 주세요.")

local uninstallMessageString = installFolderName + " 제거 완료!\n\n"
uninstallMessageString += "제거가 완료되었습니다. 제거 후 툴바에 등록되어 있는\n"
uninstallMessageString += (installFolderName + " 버튼을 지워 주시고 맥스를 재시작 해주십시오.")


rollout ScriptLoaderInstall (installFolderName + " Installation")
(
    button install_btn "Install" width:60 offset:[0, 10] across:3
    button uninstall_btn "Uninstall" width:60 offset:[0, 10]
    button close_btn "Close" width:60 offset:[0, 10]

    rollout InstallCompleteRollout "Install Complete!"
    (
        label title_lbl installMessageString offset:[0, 5] height:55
        button finish_btn "OK" width:60 offset:[0, 10]

        on finish_btn pressed do
        (
            destroyDialog InstallCompleteRollout
            destroyDialog ScriptLoaderInstall
        )

        on InstallCompleteRollout close do
        (
            destroyDialog InstallCompleteRollout
            destroyDialog ScriptLoaderInstall
        )
    )

    rollout UninstallCompleteRollout "Uninstall Complete!"
    (
        label title_lbl uninstallMessageString offset:[0, 5] height:55
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

    on install_btn pressed do
    (
        install()
        clear_tempDir()
        createDialog InstallCompleteRollout 760 450 modal:true lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow)
    )

    on uninstall_btn pressed do
    (
        uninstall()
        clear_tempDir()
        createDialog UninstallCompleteRollout 350 110 modal:true lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow)
    )

    on close_btn pressed do
    (
        clear_tempDir()
        destroyDialog ScriptLoaderInstall
    )
)


createDialog ScriptLoaderInstall 400 200 modal:true lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow)
)
