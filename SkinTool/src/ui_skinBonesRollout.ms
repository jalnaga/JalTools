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
                messageBox "Selected Bone is in Skin.\nSelect Bone which is not in Skin."
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
