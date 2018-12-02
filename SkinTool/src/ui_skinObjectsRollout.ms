rollout skinObjectRollout "Skin Objects" (
    button selSkinObjBtn "Select Skin Objects"
    listBox objListLst "Objects:" height:5
    button copySkinBtn "Copy Skin" across:2
    button pasteSkinBtn "Paste Skin" enabled:false
    button removeUnusedBonesBtn "Remove Unused Bones"
    button selZeroWeightVertBtn "Select Zero Weight Verts"

    local skinObjNameArray = #()

    fn update_bone_rollout = (
        if selSkinObj != undefined then (
            jalSkin.get_all_bones selSkinObj
            boneRoll.boneListLst.items = jalSkin.allBoneNamesArray
            boneRoll.selObjNameLab.text = "Object: " + selSkinObj.name
            boneRoll.selBoneNumLab.text = "Bones Num: " + (jalSkin.allBonesArray.count as String)
        )
    )

    on selSkinObjBtn pressed do (
        skinObjArray = #()
        skinObjNameArray = #()

        local selObjArray = getCurrentSelection()

        if selObjArray.count > 0 then (
            for item in selObjArray do (
                if (jalSkin.find_skin item) != 0 then (
                    append skinObjArray item
                    append skinObjNameArray item.name
                )
            )

        )
        objListLst.items = skinObjNameArray
        selSkinObj = skinObjArray[1]
        update_bone_rollout()
    )

    on objListLst selected inSelIndex do (
        selSkinObj = skinObjArray[inSelIndex]
        update_bone_rollout()

        pasteSkinBtn.enabled = false
    )

    on removeUnusedBonesBtn pressed do (
        if selSkinObj != undefined then (
            jalSkin.remove_unused_bones selSkinObj
            update_bone_rollout()
        )
    )

    on copySkinBtn pressed do (
        if selSkinObj != undefined then (
            pasteSkinBtn.enabled = true
        )
    )

    on pasteSkinBtn pressed do (
        if selSkinObj != undefined then (
            if selection.count == 1 then (
                local targetObj = (getCurrentSelection())[1]
                if (getNumVerts selSkinObj) == (getNumVerts targetObj) then jalSkin.copy_skin selSkinObj targetObj
                else messageBox "Select a same vertex number object!"
            )
        )
    )

    on selZeroWeightVertBtn pressed do (
        if selSkinObj != undefined then (
            jalSkin.select_zeroWeight_vertex selSkinObj
            update_bone_rollout()
        )
    )
)
