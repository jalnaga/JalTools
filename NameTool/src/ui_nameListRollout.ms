rollout nameListRollout "Name List" (
    multiListBox nameListLst "Selected Objects:" height:10

    fn update_UI = (
        local selArray = getCurrentSelection() as array
        if selArray.count > 0 then (
            local selNameArray = #()
            for item in selArray do (
                if (jal.name.get_index item.name) == "" then appendIfUnique selNameArray ((jal.name.get_string item.name) + "*")
                else appendIfUnique selNameArray (jal.name.replace_index item.name "*")
            )
            nameListLst.items = selNameArray

            if nameListLst.items.count > 0 then (
                renameObjArray = #()
                local selName = nameListLst.items[1]
                renameObjArray = for item in selArray where (matchPattern item.name pattern:selName) collect item
                __namingRollout.update_UI()
            )
        )
        else (
            nameListLst.items = #()
            renameObjArray = #()
            __namingRollout.update_UI()
        )
    )

    on nameListRollout open do (
        callbacks.addScript #selectionSetChanged "__nameListRollout.update_UI()" id:#jalnameListRolloutUIUpdate
    )

    on nameListRollout close do (
        callbacks.removeScripts id:#jalnameListRolloutUIUpdate
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
        __namingRollout.update_UI()
    )
)
