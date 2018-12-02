(
    rollout mainRollout "Skining Tool" width:300 height:630 (
        SubRollout mainSub "main" align:#center height:615
    
        local minWidth = 300
        local minHeight = 630
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        local jalSkin = jal.skin
        local skinObjArray = #()
        local selSkinObj = undefined
    
        local objRoll = undefined
        local boneRoll = undefined
    
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

        rollout skinBonesRollout "Skin Bones" (
            group "Info" (
                label selObjNameLab "Object:" align:#left across:2
                label selBoneNumLab "Bones Num:" align:#right
            )
            multiListBox boneListLst "Skin Bones:" height:20
            button copyWeightBtn "Copy" across:2
            button pasteWeightBtn "Paste" enabled:false
        
            local singleRoll = undefined
            local multiRoll = undefined
            local selIndexArray = #()
            local selBoneArray = #()
        
            fn get_sel_bones = (
                selIndexArray = boneListLst.selection as Array
                selBoneArray = #()
                if selIndexArray.count > 0 then (
                    for index in selIndexArray do (
                        append selBoneArray jalSkin.allBonesArray[index]
                    )
                )
            )
        
        /****************************************************************************/
            rollout replaceSingleRollout "Replace Single" (
                label lab1 "Copy From:" align:#left across:2
                label oriBoneNameLab "" style_sunkenedge:true width:206 height:16 offset:[-45, 0]
                listBox boneInSkinLst "Bones in Skin:" height:18
                group "Pick Bone not in Skin" (
                    checkbox removeOriCkb "Remove Original Bone" checked:true align:#left
                    pickButton pickReplaceBoneBtn "Pick a Bone from Scene" autoDisplay:true width:250
                )
                button okBtn "OK" across:2 width:50 offset:[0, 10]
                button cancelBtn "Cancel" width:50 offset:[0, 10]
        
                on replaceSingleRollout open do (
                    if selSkinObj != undefined then (
                        jalSkin.get_all_bones selSkinObj
                        boneInSkinLst.items = jalSkin.allBoneNamesArray
                        oriBoneNameLab.text = " " + selBoneArray[1].name
                    )
                )
        
                on replaceSingleRollout close do (
                    if selSkinObj != undefined then (
                        jalSkin.get_all_bones selSkinObj
                        boneListLst.items = jalSkin.allBoneNamesArray
                        pickReplaceBoneBtn.object = undefined --Dialog를 없애도 이전에 픽버튼으로 오브젝트를 선택 했으면 그대로 남아 있어서, 창을 새로 만들어도 그게 정보로 남아 있다. 꼭 초기화 해줄것!
        
                        pasteWeightBtn.enabled = false
                    )
                )
        
                on boneInSkinLst selected inSelIndex do (
                    if selSkinObj != undefined then (
                        get_sel_bones()
        
                        select selSkinObj
                        max modify mode
                        modPanel.setCurrentObject jalSkin.skinMod
                        subObjectLevel = 1
                        jalSkin.select_bone selSkinObj jalSkin.allBonesArray[inSelIndex]
                    )
                )
        
                on pickReplaceBoneBtn picked inPickObj do (
                    local findedIndex = finditem jalSkin.allBonesArray inPickObj
                    if findedIndex > 0 then (
                        messageBox "Select Bone which is not in Skin"
                        pickReplaceBoneBtn.object = undefined
                    )
                )
        
                on okBtn pressed do (
                    if boneInSkinLst.selection > 0 then (
                        if pickReplaceBoneBtn.object != undefined then (
                            jalSkin.replace_bone selSkinObj selBoneArray[1] pickReplaceBoneBtn.object removeOldBone:removeOriCkb.checked
        
                            destroydialog singleRoll
                        )
                        else (
                            if selBoneArray[1] != jalSkin.allBonesArray[boneInSkinLst.selection] then (
                                jalSkin.copy_weight_between_bones_in_skin selSkinObj selBoneArray[1] jalSkin.allBonesArray[boneInSkinLst.selection] removeOldBone:false
        
                                destroydialog singleRoll
                            )
                            else messageBox "Choose different bone with original one!"
                        )
                    )
                )
        
                on cancelBtn pressed do (
                    destroydialog singleRoll
                )
            )
        /****************************************************************************/
        
        /****************************************************************************/    
            rollout replaceMultiRollout "Replace Multi" (
                multiListBox sourceBoneListLst "Source:" across:2
                multiListBox targetBoneListLst "Target:"
                button okBtn "OK" across:2
                button cancelBtn "Cancel"
            )
        /****************************************************************************/
        
        
            on skinBonesRollout open do (
                singleRoll = replaceSingleRollout
                multiRoll = replaceMultiRollout
            )
        
            on boneListLst selectionEnd do (
                if selSkinObj != undefined then (
                    get_sel_bones()
        
                    select selSkinObj
                    max modify mode
                    modPanel.setCurrentObject jalSkin.skinMod
                    subObjectLevel = 1
                    jalSkin.select_bone selSkinObj selBoneArray[selBoneArray.count]
                )
            )
        
            on copyWeightBtn pressed do (
                get_sel_bones()
                pasteWeightBtn.enabled = true
            )
        
            on pasteWeightBtn pressed do (
                if selIndexArray.count == 1 then (
                    try(destroydialog singleRoll) catch()
                    try(destroydialog multiRoll) catch()
                    createDialog replaceSingleRollout width:300 height:400
                )
                
                /*if selIndexArray.count > 1 then (
                    try(destroydialog singleRoll) catch()
                    try(destroydialog multiRoll) catch()
                    createDialog replaceMultiRollout
                )*/
            )
        )

    
        on mainRollout open do
        (
            AddSubRollout mainSub skinObjectRollout
            AddSubRollout mainSub skinBonesRollout
    
            objRoll = skinObjectRollout
            boneRoll = skinBonesRollout
        )
    
        on mainRollout resized newSize do
        (
            if newSize[1] > minWidth then 
            mainSub.width = newSize[1] - subRollWidthOffset
            else (
                mainRollout.width = minWidth
                mainSub.width = minWidth - subRollWidthOffset
            )
            if newSize[2] > minHeight then mainSub.height = newSize[2] - subRollHeightOffset
            else (
                mainRollout.height = minHeight
                mainSub.height = minHeight - subRollHeightOffset
            )
            jal.roll.update_subroll_when_resized mainSub skinObjectRollout
            jal.roll.update_subroll_when_resized mainSub skinBonesRollout
        )
    )
    global __skiningToolRollout = mainRollout
    try(destroydialog __skiningToolRollout) catch()
    createDialog __skiningToolRollout style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)

    clearlistener()
    gc()
)
