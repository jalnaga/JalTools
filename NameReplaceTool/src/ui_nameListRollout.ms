rollout nameListRollout "Name List" (
    multiListBox nameListLst "Selected Objects:" height:10

    fn update_ui = (
        renameObjArray = #()
        local selArray = getCurrentSelection() as array
        if selArray.count > 0 then (
            local selNameArray = for item in selArray collect item.name
            nameListLst.items = jal.str.sort_by_alphabet selNameArray
        )
        else nameListLst.items = #()
        nameListLst.selection = #{}

        __nameRepNameReplaceRollout.update_UI()
    )

    on nameListRollout open do (
        callbacks.addScript #selectionSetChanged "jal.tools.nameReplaceTool.nameListRollout.update_UI()" id:#jalnameRepNameListRolloutUIUpdate
        update_ui()
    )

    on nameListRollout close do (
        callbacks.removeScripts id:#jalnameRepNameListRolloutUIUpdate
    )

    on nameListLst selectionEnd do (
        local selArray = getCurrentSelection() as Array
        renameObjArray = #()
        local selNameIndexArray = nameListLst.selection as array
        for index in selNameIndexArray do (
            local selName = nameListLst.items[index]
            local tempObjCollection = for item in selArray where (matchPattern item.name pattern:selName) collect item
            join renameObjArray tempObjCollection
        )
        jal.tools.nameReplaceTool.replaceNameRollout.update_UI()
    )
)
