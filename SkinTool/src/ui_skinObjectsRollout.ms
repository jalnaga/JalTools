rollout skinObjectRollout "Skin Objects" (
    button selSkinObjBtn "Select Skin Objects"
    listBox objListLst "Objects:" height:5
    button copySkinBtn "Copy Skin" across:2
    button pasteSkinBtn "Paste Skin" enabled:false
    button removeUnusedBonesBtn "Remove Unused Bones"
    button selZeroWeightVertBtn "Select Zero Weight Verts"
    group "Save/Load" (
        button saveSkinBtn "Save" across:2 height:30 width:60
        button loadSkinBtn "Load" height:30 width:60
    )

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
        )
    )

    on saveSkinBtn pressed do (
        if selSkinObj != undefined and (isValidObj selSkinObj) then (
            if isproperty selSkinObj #Skin and selSkinObj.skin != undefined then (
                local selPath = (getdir #animations + "\\skindata")
                makedir selPath
                local fileName = selSkinObj.name + " [v" + selSkinObj.mesh.verts.count as string + "] [t" + selSkinObj.mesh.faces.count as string + "].skin"
                local saveSkinFile = selPath + "\\" + fileName
                jal.skin.save_skin selSkinObj (jal.skin.get_skin_mod obj:selSkinObj)[1] saveSkinFile
            )
        )
    )

    on saveSkinBtn rightclick do (
        if (isvalidNode selSkinObj) and (isproperty selSkinObj #Skin and selSkinObj.skin != undefined) then (
            makedir (getdir #animations + "\\skindata")
            local fileName = selSkinObj.name + " [v" + selSkinObj.mesh.verts.count as string + "] [t" + selSkinObj.mesh.faces.count as string + "].skin"
            local skinFile = ((getdir #animations + "\\skindata") + "\\" + fileName)
            skinFile = getSaveFileName caption:"Save Skin" filename:skinFile
            if skinFile != undefined then jal.skin.save_skin selSkinObj (jal.skin.get_skin_mod obj:selSkinObj)[1] skinFile
        )
    )

    on loadSkinBtn pressed do (
        local selObjs = getCurrentSelection() as Array
        local skinFiles = getfiles ((getdir #animations + "\\skindata") + "\\*.skin")
        skinFileName = for f in skinFiles collect (getfilenamefile f)

        if selObjs.count == 1 and (canConvertTo selObjs[1] Mesh) then (
            local obj = selObjs[1]
            local fileNameFile = obj.name + " [v" + obj.mesh.verts.count as string + "] [t" + obj.mesh.faces.count as string + "].skin"
            local fileName = ((getdir #animations + "\\skindata") + "\\" + fileNameFile)
            if doesFileExist fileName then (
                select obj
                jal.skin.load_skin obj fileName
            )
            else messageBox "There is no matched skin file"
        )
        else messageBox "Select only 1 skinned mesh"
    )

    on loadSkinBtn rightclick do (
        local selObj = $
        if (isvalidNode selObj) and (canConvertTo selObj Mesh) then (
            makedir (getdir #animations + "\\skindata")
            local fileName = selObj.name + " [v" + selObj.mesh.verts.count as string + "] [t" + selObj.mesh.faces.count as string + "].skin"
            local skinFile = ((getdir #animations + "\\skindata") + "\\" + fileName)
            skinFile = getOpenFileName caption:"Load Skin" filename:skinFile
            if skinFile != undefined then (
                jal.skin.load_skin selObj skinFile
            )
        )
    )
)
