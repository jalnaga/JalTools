macroscript jal_boneOn category:"jalTools" tooltip:"Bone On Selection" autoUndoEnabled:true (
    jal.bone.set_bone_on_selection()
)

macroscript jal_boneOff category:"jalTools" tooltip:"Bone Off Selection" autoUndoEnabled:true (
    jal.bone.set_bone_off_selection()
)

macroscript jal_boneCreate category:"jalTools" tooltip:"Bone Create" autoUndoEnabled:true (
    local boneName = "Bip001 TempBone 0"
    local boneNameSetted = false
    local selArray = getCurrentSelection() as Array
    local simpleBoneLength = 5

    rollout boneNameRollout "Bone Name" (
        editText boneBaseNameTxt "Base Name:" text:"Bip001"
        editText boneNameTxt "Name:" text:"TempBone"
        radiobuttons sideRdo "Side:" align:#left labels:#("(None)", "L", "R", "F", "B") offsets:#([30, -16], [30, -16], [30, -16], [30, -16], [30, -16])
        radiobuttons filteringCharRdo "Filtering:" align:#left labels:#("(Blank)", "_") offsets:#([45, -16], [45, -16])
        editText resultTxt "Result:" readOnly:true text:"Bip001 TempBone 0" labelOnTop:true offset:[0, 10]
        button okBtn "OK" across:2 width:50
        button cancelBtn "Cancel" width:50

        local defaultBoneName = ""
        local boneNameSide = ""
        local boneNameFilteringChar = " "

        fn update_boneNameResult = (
            local indexStr = jal.name.convert_digit_into_padding_string 0
            boneName = jal.name.combine inBase:boneBaseNameTxt.text inSide:boneNameSide inRealName:boneNameTxt.text inIndex:indexStr inFilChar:boneNameFilteringChar
            resultTxt.text = boneName
            boneName = jal.name.replace_index boneName ""
        )

        on boneNameRollout open do (
            local baseIdf = jal.name.idfManager.get_idf "Base"
            boneBaseNameTxt.text = baseIdf.char[1]

            local sideRdoLabels = #("(None)")
            local sideIdf = jal.name.idfManager.get_idf "Left"
            local frontBackIdf = jal.name.idfManager.get_idf "Front"
            for item in sideIdf.char do append sideRdoLabels item
            for item in frontBackIdf.char do append sideRdoLabels item
            sideRdo.labels = sideRdoLabels

            defaultBoneName = jal.name.combine inBase:boneBaseNameTxt.text inSide:boneNameSide inRealName:boneNameTxt.text inIndex:indexStr inFilChar:boneNameFilteringChar

            update_boneNameResult()

            boneNameSetted = false
        )

        on boneBaseNameTxt changed inText do update_boneNameResult()
        on boneNameTxt changed inText do update_boneNameResult()

        on sideRdo changed state do (
            case state of (
                1: boneNameSide = ""
                2: boneNameSide = "L"
                3: boneNameSide = "R"
                4: boneNameSide = "F"
                5: boneNameSide = "B"
            )
            update_boneNameResult()
        )
        on filteringCharRdo changed state do (
            case state of (
                1: boneNameFilteringChar = " "
                2: boneNameFilteringChar = "_"
            )
            update_boneNameResult()
        )

        on okBtn pressed do (
            update_boneNameResult()

            local isBoneExist = 0
            local nameCheckBonesArray = for item in objects where (classOf item) == BoneGeometry collect item
            for item in nameCheckBonesArray do (
                if (matchPattern item.name pattern:(boneName + (jal.str.get_filteringChar boneName) + "*")) then isBoneExist += 1
            )
            if isBoneExist > 0 then (
                messageBox "Same Name Bones already exist!"
                boneNameSetted = false
            )
            else (
                boneNameSetted = true
                destroydialog boneNameRollout
            )
        )

        on cancelBtn pressed do (
            boneNameSetted = false
            boneName = defaultBoneName
            destroydialog boneNameRollout
        )
    )
    createDialog boneNameRollout style:#(#style_titlebar, #style_border) escapeEnable:false modal:true

    if boneNameSetted then (
        if selArray.count == 0 or selArray.count == 1 then (
            local genBones = jal.bone.create_simple_bone simpleBoneLength boneName
            if selArray.count == 1 then genBones[1].transform = selArray[1].transform
        )
        if selArray.count > 1 then (
            jal.bone.create_bone selArray boneName delPoint:true
        )
    )
)

macroscript jal_boneNubCreate category:"jalTools" tooltip:"Bone Nub Create" autoUndoEnabled:true (
    undo "Jal Nub Create" on (
        local selArray = getCurrentSelection() as Array
        if selArray.count > 0 then (
            local lastBoneArray = #()
            local nonBoneArray = #()

            for item in selArray do (
                if (classOf item == BoneGeometry) then append lastBoneArray item
                else append nonBoneArray item
            )

            for item in lastBoneArray do (
                if keyboard.controlPressed then jal.bone.create_end_bone item
                else if item.children.count == 0 then jal.bone.create_end_bone item
            )
            for item in nonBoneArray do jal.bone.create_nub_bone_on_obj item
        )
        else (
            local filChar = jal.str.get_filteringChar boneName
            local tempBoneName = ""
            if boneNameFilteringChar == filChar then tempBoneName = boneName
            else tempBoneName = boneName + boneNameFilteringChar + (jal.name.get_nubStr())
            jal.bone.create_nub_bone tempBoneName 2
        )
    )
)
