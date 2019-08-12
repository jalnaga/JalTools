macroscript jalScriptLauncher category:"jalTools" icon:#("jalToolbarIcon", 1)
(
rollout scriptLauncherRollout "Script Launcher" (
    dotNetControl imageListview "System.Windows.Forms.ListView" width:360 height:550

    local toolRootPath = getINISetting ((GetDir #userMacros) + "\\jalScriptLauncher\\ini\\scriptPath.ini") "ExternalScript" "ScriptPath"
    local tool_path = toolRootPath + "\\JalTools\\"
    local imglist_obj = dotNetObject "System.Windows.Forms.ImageList"

    fn fill_listview lv fileNames bitmapSize:128 =
    (
        lv.Clear()
        lv.items.Clear()
        lv.Refresh()
        imglist_obj.images.Clear()
        imglist_obj.Dispose()

        imglist_obj.ColorDepth = imglist_obj.ColorDepth.Depth32bit
        imglist_obj.ImageSize = dotNetObject "System.Drawing.Size" bitmapSize bitmapSize

        local thumbs = #()
        local items = #()

        for i = 1 to fileNames.count do
        (
            local filePrefix = (getFilenamePath fileNames[i]) + (getFilenameFile fileNames[i])

            local thumbFile =  filePrefix + ".png"
            local scriptFile = filePrefix + ".ms"

            append thumbs ((dotNetClass "System.Drawing.Image").fromFile thumbFile)

            local item = dotNetObject "System.Windows.Forms.ListViewItem" (filenameFromPath scriptFile)
            item.name = scriptFile

            item.imageIndex = i - 1
            lv.items.add item
        )

        imglist_obj.images.addrange thumbs

        lv.LargeImageList = imglist_obj
        lv.SmallImageList = imglist_obj

        for t in thumbs do t.dispose()
    )

    fn init_listview lv =
    (
        lv.View = (dotNetClass "System.Windows.Forms.View").LargeIcon
        lv.Multiselect = false
        lv.Scrollable = true

        local m_dnColor = dotNetClass "System.Drawing.Color"
        local hColor = (((colorman.getColor #window)*255) as color)
        local windowColor = m_dnColor.fromARGB hColor.r hColor.g hColor.b
        hColor = (((colorman.getColor #text  )*255) as color)
        local textColor   = m_dnColor.fromARGB hColor.r hColor.g hColor.b

        lv.backColor = windowColor
        lv.foreColor = textColor
    )

    fn get_script_fullnames toolPath =
    (
        local scriptFullnames = #()
        scriptFolders = getDirectories (toolPath + "*")

        for folder in scriptFolders do
        (
            local iconFiles = getFiles (folder + "*.png")
            for iconFile in iconFiles do append scriptFullnames iconFile
        )

        scriptFullnames
    )

    on scriptLauncherRollout open do
    (
        local scriptFiles = get_script_fullnames tool_path
        init_listview imageListview
        fill_listview imageListview scriptFiles bitmapSize:64
    )

    on imageListview mouseUp arg do
    (
        hit=(imageListview.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
        if(hit != undefined AND hit.item != undefined) then
        (
            -- hit.item.name has full path of max scene
            filein hit.item.name
            DestroyDialog scriptLauncherRollout
        )
    )

    on scriptLauncherRollout close do
    (
        imglist_obj.dispose()
    )
)
createDialog scriptLauncherRollout 385 560 style:#(#style_toolwindow, #style_sysmenu) pos:[mouse.screenpos[1] - 50, mouse.screenpos[2] - 10]
)
