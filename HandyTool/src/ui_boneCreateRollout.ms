rollout boneCreateRollout "Bone Tools" (
    group "Bone Create" (
        checkbutton paintCreateBoneBtn "P" across:3 width:25
        button createBtn "Create Bone" width:100 align:#center
        button nubCreateBtn "Nub" width:40 align:#right
    )
    group "Bone Edit" (
        checkbutton editModeBtn "Edit Mode" width:150 height:25
        checkButton refineBtn "Refine" across:2 width:80
        button removeBtn "Remove" width:80
        button turn90Btn "90" width:40 across:3
        button turn45Btn "45" width:40
        button turn5Btn "5" width:40
    )
    group "Bone Shape" (
        checkbox finOnCkb "Fin" across:2
        spinner finSizeSpn "Fin Size:" range:[0.0, 100.0, 2.0]
        spinner sizeSpn "Size:" across:2 range:[0.0, 100.0, 2.0]
        spinner taperSpn "Taper:" range:[0.0, 100.0, 90.0]
    )
    button resetXformBtn "Reset Xform" width:120 across:2
    button boneToolBtn "Bone Tool" align:#right

    local boneName = "Bip001 TempBone 0"
    local boneNameSetted = false
    local ctrlKeyPressed = false

    local boneSet = #(sizeSpn.value, taperSpn.value)
    local sideSet = #(finOnCkb.checked, finSizeSpn.value, 0, 0)
    local frontSet = #(finOnCkb.checked, finSizeSpn.value, 0, 0)
    local backSet = #(false, finSizeSpn.value, 0, 0)

    fn turn_bone inRot = (
        local selArray = getCurrentSelection() as Array
        local isBone = 1
        for item in selArray do if classOf item == BoneGeometry then isBone *= 1 else isBone *= 0
        if selArray.count > 0 and (isBone == 1) then (
            maxops.affectchildren = false
            for item in selArray do (
                local itemParent = undefined
                if item.parent != undefined then itemParent = maxOps.getNodeByHandle item.parent.handle
                local itemChildrenArray = for child in item.children collect (maxOps.getNodeByHandle child.handle)

                item.parent = undefined
                for child in itemChildrenArray do child.parent = undefined
                jal.anim.rotate_local item inRot 0 0
                for child in itemChildrenArray do child.parent = item
                item.parent = itemParent
            )
            maxops.affectchildren = true
        )
    )

    rollout boneNameRollout "Bone Name" (
        editText boneBaseNameTxt "Base Name:" text:"Bip001"
        editText boneNameTxt "Name:" text:"TempBone"
        radiobuttons sideRdo "Side:" align:#left labels:#("(None)", "L", "R", "F", "B") offsets:#([30, -16], [30, -16], [30, -16], [30, -16], [30, -16])
        radiobuttons filteringCharRdo "Filtering:" align:#left labels:#("(Blank)", "_") offsets:#([45, -16], [45, -16])
        editText resultTxt "Result:" readOnly:true text:"Bip001 TempBone 0" labelOnTop:true offset:[0, 10]
        button okBtn "OK" across:2 width:50
        button cancelBtn "Cancel" width:50

        local boneNameSide = ""
        local boneNameFilteringChar = " "

        fn update_boneNameResult = (
            boneName = jal.name.combine inBase:boneBaseNameTxt.text inSide:boneNameSide inRealName:boneNameTxt.text inIndex:"0" inFilChar:boneNameFilteringChar
            resultTxt.text = boneName
            boneName = jal.name.replace_index boneName ""
        )

        on boneNameRollout open do boneNameSetted = false

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
                if (matchPattern item.name pattern:(boneName + (jal.name.get_filteringChar boneName) + "*")) then isBoneExist += 1
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
            boneName = "Bip001 TempBone 0"
            destroydialog boneNameRollout
        )
    )

    timer createBoneTimer interval:100 active:true

    on paintCreateBoneBtn changed state do (
        if state then (
            local createdBonesArray = #()
            createDialog boneNameRollout style:#(#style_titlebar, #style_border) escapeEnable:false modal:true

            if boneNameSetted then (
                createdBonesArray = StartObjectCreation Bones returnNewNodes:true
            )
            else paintCreateBoneBtn.state = false
        )
        else (
            if isCreatingObject Bones then (
                StopCreating()
            )
        )

        if createdBonesArray.count > 0 then (
            for i = 1 to (createdBonesArray.count - 1) do createdBonesArray[i].name = jal.name.replace_index boneName ((i-1) as String) keepPadding:false
            createdBonesArray[createdBonesArray.count].name = jal.name.set_index_as_nub boneName
        )
    )

    on createBoneTimer tick do (
        if not isCreatingObject Bones then paintCreateBoneBtn.checked = false
        else paintCreateBoneBtn.checked = true
    )

    on createBtn pressed do (
        undo "Jal Create Bone" on (
            local selArray = getCurrentSelection() as Array
            local simpleBoneLength = 5
            if keyboard.controlPressed then ctrlKeyPressed = true
            createDialog boneNameRollout style:#(#style_titlebar, #style_border) escapeEnable:false modal:true

            if boneNameSetted then (
                if ctrlKeyPressed then (
                    if selArray.count == 0 or selArray.count == 1 then (
                        local tempStartPointName = jal.name.replace_type boneName "Dum"
                        tempStartPointName = jal.name.replace_index tempStartPointName "0" keepPadding:false
                        local tempEndPointName = jal.name.replace_type boneName "Dum"
                        tempEndPointName = jal.name.replace_index tempEndPointName "1" keepPadding:false

                        local tempStartPoint = jal.helper.create_point tempStartPointName pos:[0,0,0]
                        local tempEndPoint = jal.helper.create_point tempEndPointName pos:[simpleBoneLength,0,0]

                        if selArray.count == 1 then (
                            local endTm = tempEndPoint.transform
                            tempStartPoint.transform = selArray[1].transform
                            tempEndPoint.transform = endTm * tempStartPoint.transform
                        )
                        jal.bone.create_simple_stretch_bone tempStartPoint tempEndPoint boneName
                    )

                    if selArray.count > 1 then (
                        local pointNameArray = #()
                        local stretchBonePointArray = #()

                        for i = 1 to selArray.count do (
                            local tempPointName = jal.name.replace_type boneName "Dum"
                            tempPointName = jal.name.replace_index tempPointName ((i - 1) as String) keepPadding:false
                            append pointNameArray tempPointName
                        )
                        for i = 1 to selArray.count do (
                            if (classOf selArray[i] == Point) or (classOf selArray[i] == Dummy) then (
                                append stretchBonePointArray selArray[i]
                                selArray[i].name = pointNameArray[i]
                            )
                            else (
                                local tempPoint = jal.helper.create_point pointNameArray[i]
                                tempPoint.transform = selArray[i].transform
                                append stretchBonePointArray tempPoint
                            )
                        )
                        jal.bone.create_stretch_bone stretchBonePointArray boneName
                    )
                )
                else (
                    if selArray.count == 0 or selArray.count == 1 then (
                        local genBones = jal.bone.create_simple_bone simpleBoneLength boneName
                        if selArray.count == 1 then genBones[1].transform = selArray[1].transform
                    )
                    if selArray.count > 1 then (
                        jal.bone.create_bone selArray boneName delPoint:true
                    )
                )
            )

            ctrlKeyPressed = false
        )
    )

    on nubCreateBtn pressed do (
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
            else jal.bone.create_nub_bone "Temp Nub" 2
        )
    )


    timer boneEditModeTimer interval:100 active:true

    on editModeBtn changed state do (
        if (editModeBtn.state == true) then (
            maxops.affectchildren = false
            if isCreatingObject Bones then StopCreating()
        )
        else (
            maxops.affectchildren = true
        )
    )

    on boneEditModeTimer tick do (
        if (editModeBtn.state == maxops.affectChildren) do editModeBtn.state = (not maxops.affectChildren)
        if (editModeBtn.enabled == animButtonState) do editModeBtn.enabled = (not animButtonState)
    )

    timer refineBoneTimer interval:100 active:false

    on refineBtn changed state do (
        bonesys.RefineBone()

        if state then refineBoneTimer.active = true
    )

    on refineBoneTimer tick do (
        if toolmode.commandmode != #pick and toolmode.commandmode != #viewport then (
            refineBtn.checked = false
            refineBoneTimer.active = false
        )
    )

    on removeBtn pressed do (
        if (selection.count == 1) and (classOf selection[1] == BoneGeometry) then (
            with Animate Off (
                with redraw off (
                    jal.bone.remove_ik $
                    if keyboard.shiftPressed == false then (
                        local parent = $.parent

                        if parent != undefined do parent.ResetBoneStretch()

                        for i=1 to $.children.count do (
                            local   chl = $.children [1]
                            jal.bone.remove_ik chl
                            if (classOf chl == BoneGeometry) do chl.pivot = $.transform.translation
                            chl.parent=parent
                            chl.ResetBoneStretch()
                        )

                        $.parent=undefined
                        delete $
                    )
                    else (
                        local chlArr=#()
                        local chlAsm=#()

                        for i=1 to $.children.count do (
                            append chlArr $.children[i]
                            append chlAsm $.children[i].assemblyMember
                            jal.bone.remove_ik $.children[i]
                        )

                        local chl=$.children[1]
                        local prt=$.parent

                        local asmMbr = $.assemblyMember
                        $.pivot=chl.transform.translation

                        for i=1 to chlArr.count do(
                            chlArr[i].parent=prt
                            if ( asmMbr and chlAsm[i] ) do jal.bone.put_child_into_bone_assembly chlArr[i]
                        )
                        delete $
                        if ( prt != undefined ) do (
                            prt.realignBoneToChild()
                            prt.ResetBoneStretch()
                        )
                    )
                )  -- with Redraw Off bracket close
                redrawviews()
            ) -- with Animate Off bracket close
        )
    )

    on turn90Btn pressed do (
        undo "Jal Bone Turn" on (
            local turnVal = 90
            if keyboard.controlPressed then turnVal = -90
            turn_bone turnVal
        )
    )

    on turn45Btn pressed do (
        undo "Jal Bone Turn" on (
            local turnVal = 45
            if keyboard.controlPressed then turnVal = -45
            turn_bone turnVal
        )
    )

    on turn5Btn pressed do (
        undo "Jal Bone Turn" on (
            local turnVal = 5
            if keyboard.controlPressed then turnVal = -5
            turn_bone turnVal
        )
    )

    on finOnCkb changed state do (
        local selArray = getCurrentSelection() as array
        for item in selArray do (
            if state then jal.bone.set_fin_on item inSize:finSizeSpn.value
            else jal.bone.set_fin_off item
        )
    )

    on finSizeSpn changed val do (
        local selArray = getCurrentSelection() as array
        for item in selArray do jal.bone.set_fin_on item inSize:finSizeSpn.value
    )

    on sizeSpn changed val do (
        local selArray = getCurrentSelection() as array
        for item in selArray do jal.bone.set_bone_size item val
    )

    on taperSpn changed val do (
        local selArray = getCurrentSelection() as array
        for item in selArray do jal.bone.set_bone_taper item val
    )

    on resetXformBtn pressed do (
        local selArray = getCurrentSelection() as array
        for item in selArray do (
            if (classOf item == BoneGeometry) then (
                if item.children.count == 1 then (
                    item.realignBoneToChild()
                    jal.bone.correct_negative_stretch item true
                    item.ResetBoneStretch()
                )
            )
        )
        jal.bone.reset_scale_of_selected_bones true
    )
)
