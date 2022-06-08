(
    try(destroydialog jal.tools.handyTool) catch()
    rollout mainRollout "Handy Tools" width:280 height:820 (
        SubRollout mainSub "" align:#center height:805
    
        local minWidth = 280
        local minHeight = 820
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        rollout helperToolsRollout "Helper" (
            button createParentHelperBtn "Parent" width:60 across:3
            button createHelperBtn "Helper" width:60 toolTip:"R Click: Create 2 helpers"
            button createExpHelperBtn "ExpTM" width:60
            checkbox mirrorCkb "Mirror" across:2 align:#right offset:[-5, 3]
            checkbutton createHelperOnSurfaceBtn "Create on Surface" width:120
            radioButtons helperTypeRdo labels:#("Box", "Cross", "Axis", "Center") across:2 columns:2
            spinner helperSizeSpn "Size:" offset:[0, 10]
        
            struct _HelperOnSurface (
                targetNode = undefined,
                helperSize = 1,
                bMirror = false,
                helperGenTool,
                toggleBtn = createHelperOnSurfaceBtn,
        
                fn make_helper inHit = (
                    if inHit != undefined and targetNode != undefined then (
                        local pointName = (jal.helper.gen_helper_name_from_obj targetNode)[1]
                        local genPoint = jal.helper.create_point pointName size:helperSize boxToggle:true pointColor:(color 14 255 2) pos:[0,0,0]
        
                        local zVector = inHit.Dir
                        local yVector = [0,0,1]
                        local xVector = normalize (cross yVector zVector)
                        yVector = normalize (cross zVector xVector)
                        genPoint.transform = matrix3 xVector yVector zVector inHit.pos
                        
                        if bMirror then (
                            if genPoint.position.x > 0 then genPoint.name = jal.name.replace_side genPoint.name "L"
                            if genPoint.position.x < 0 then genPoint.name = jal.name.replace_side genPoint.name "R"
                        )
                        genPoint.name = jal.name.gen_uniqueName genPoint.name
                    )
                ),
        
                fn stop_tool = (
                    stopTool helperGenTool
                    toggleBtn.checked = false
                ),
        
                fn run_tool = (
                    helperGenTool = tool mouseHit (
                        on mousePoint clickNo do (
                            if clickNo > 1 then (
                                local r = (mapScreenToWorldRay mouse.pos)
        
                                local hit = intersectRay targetNode r
                                make_helper hit
        
                                if bMirror then (
                                    hit = intersectRay targetNode (ray (r.pos*[-1,1,1]) (r.dir*[-1,1,1]))
                                    make_helper hit
                                )
                            )
                        )
        
                        on mouseAbort clickNo do (
                            if clickNo > 1 then stop_tool()
                        )
                    )
                    startTool helperGenTool
                )
            )
        
            fn create_average_pos_transform inTargetArray = (
                local posConstDum = Point()
        
                jal.const.assign_pos_const_multi posConstDum inTargetArray
                
                local returnTransform = copy posConstDum.transform
                delete posConstDum
        
                returnTransform
            )
        
            fn create_average_rot_transform inTargetArray = (
                local rotConstDum = Point()
        
                jal.const.assign_rot_const_multi rotConstDum inTargetArray
                
                local returnTransform = copy rotConstDum.transform
                delete rotConstDum
        
                returnTransform
            )
        
            local helperOnSurf = _HelperOnSurface()
        
            on createParentHelperBtn pressed do (
                undo on (
                    jal.helper.create_parent_helper()
                )
            )
        
            on createHelperBtn pressed do (
                undo on (
                    local selArray = getCurrentSelection()
                    local tempTransform = matrix3 1
                    local keyPressed = 0
                    
                    if keyboard.shiftPressed then (
                        tempTransform.rotation = (create_average_rot_transform selArray).rotation
                        keyPressed += 1
                    )
                    if keyboard.controlPressed then (
                        tempTransform.pos = (create_average_pos_transform selArray).pos
                        keyPressed += 1
                    )
                    
                    if keyPressed > 0 then (
                        local dumName = jal.helper.gen_helper_name_from_obj selArray[1]
                        local dumShape = jal.helper.gen_helper_shape_from_obj selArray[1]
                        #(helperSize, crossToggle, boxToggle)
                        local averageDum = jal.helper.create_point dumName[1] size:dumShape[1] boxToggle:dumShape[3] crossToggle:dumShape[2]
                        averageDum.transform = tempTransform
                    )
                    else jal.helper.create_helper()
                )
            )
        
            on createHelperBtn rightclick do (
                undo on (
                    jal.helper.create_helper makeTwo:true
                )
            )
        
            on createExpHelperBtn pressed do (
                undo on (
                    jal.helper.create_expTm()
                )
            )
        
            on createHelperOnSurfaceBtn changed state do (
                if state then (
                    if selection.count == 1 then (
                        helperOnSurf.targetNode = (getCurrentSelection() as Array)[1]
                        helperOnSurf.bMirror = mirrorCkb.checked
                        helperOnSurf.run_tool()
                    )
                )
                else (
                    if helperOnSurf.targetNode != undefined then (
                        helperOnSurf.stop_tool()
                        createHelperOnSurfaceBtn.checked = false
                    )
                )
            )
        
            on helperSizeSpn changed val do (
                undo on (
                    if selection.count > 0 then (
                        for item in selection do jal.helper.set_size item val
                    )
                )
            )
        
            on helperTypeRdo changed state do (
                undo on (
                    if selection.count > 0 then (
                        #("Box", "Cross", "Axis", "Center")
                        case state of (
                            1: for item in selection do jal.helper.set_shape_to_box item
                            2: for item in selection do jal.helper.set_shape_to_cross item
                            3: for item in selection do jal.helper.set_shape_to_axis item
                            4: for item in selection do jal.helper.set_shape_to_center item
                        )
                    )
                )
            )
        )

        rollout nameSelToolsRollout "Name Select" (
            editText findNameTxt "" align:#left offset:[0, 0] across:2 width:180
            checkbutton fuzzToggleBtn "Fz." checked:false align:#right offset:[0, 0]
            multiListBox nameListLst "Selected Objects:" height:8
        
            local findedObjNameArray = #()
            local namePattern = "*"
        
            fn gen_namePattern inTxt = (
                local returnNamePattern = "*"
                for i = 1 to inTxt.count do (
                    returnNamePattern += inTxt[i]
                    returnNamePattern += "*"
                )
        
                returnNamePattern
            )
        
            fn refill_nameList_with_nodes = (
                findedObjNameArray = for item in objects collect item.name
                nameListLst.items = findedObjNameArray
                findNameTxt.text = ""
            )
        
            on nameSelToolsRollout open do (
                refill_nameList_with_nodes()
                nameListLst.selection = 0
            )
        
            on nameSelToolsRollout rolledUp stat do (
                if stat == false then refill_nameList_with_nodes()
            )
        
            on fuzzToggleBtn changed state do (
                nameListLst.selection = 0
            )
        
            on findNameTxt changed inTxt do (
                local enteredNamePattern = gen_namePattern inTxt
        
                if enteredNamePattern.count > namePattern.count then (
                    namePattern = enteredNamePattern
                    nameListLst.items = for item in nameListLst.items where (MatchPattern item pattern:namePattern) collect item
                )
                else (
                    namePattern = enteredNamePattern
                    nameListLst.items = for item in objects where (MatchPattern item.name pattern:namePattern) collect item.name
                )
        
                nameListLst.selection = 0
                if fuzzToggleBtn.checked then (
                    local selArray = for item in nameListLst.items where (getNodeByName item) != undefined collect (getNodeByName item)
                    select selArray
                )
            )
        
            on nameListLst selectionEnd do (
                local selNameIndexArray = nameListLst.selection as Array
                local selArray = #()
                for index in selNameIndexArray do (
                    local tempNode = getNodeByName nameListLst.items[index]
                    if tempNode != undefined then append selArray tempNode
                )
                select selArray
            )
        )

        rollout boneCreateRollout "Bone Tools" (
            group "Bone Create" (
                checkbutton paintCreateBoneBtn "P" across:3 width:25
                button createBtn "Create Bone" width:100 align:#center
                button nubCreateBtn "Nub" width:40 align:#right
            )
            group "Bone Edit" (
                checkbox boneOnCkb "Bone On" across:2 align:#left
                checkbutton editModeBtn "Edit Mode" width:120 height:25 align:#right
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
        
            on boneOnCkb changed state do (
                if state then jal.bone.set_bone_on_selection()
                else jal.bone.set_bone_off_selection()
            )
        
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
            on turn90Btn rightclick do (
                undo "Jal Bone Turn" on (
                    local turnVal = -90
                    if keyboard.controlPressed then turnVal = 90
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
            on turn45Btn rightclick do (
                undo "Jal Bone Turn" on (
                    local turnVal = -45
                    if keyboard.controlPressed then turnVal = 45
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
            on turn5Btn rightclick do (
                undo "Jal Bone Turn" on (
                    local turnVal = -5
                    if keyboard.controlPressed then turnVal = 5
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

        rollout skinBoneRollout "Skin Bone Tool" (
            button genBaseSkelBtn "Create Base Skeleton" width:120
            group "Base Sekeleton <-> Biped" (
                button linkBipBtn "Link" across:2 width:80
                button unLinkBipBtn "UnLink" width:80
            )
            button genSkinBoneBtn "Create Skin Bones" width:120
        
            on genBaseSkelBtn pressed do (
                local selObjs = getCurrentSelection() as array
                if selObjs.count > 0 then (
                    if jal.bip.get_bip_coms_num() == 1 then (
                        jal.bone.create_skin_bone_from_bip selObjs
                    )
                    else (
                        messageBox "There are too many Bips! It should be one!"
                    )
                )
                else (
                    messageBox "Select Bip objects!"
                )
            )
        
            on linkBipBtn pressed do (
                if jal.bip.get_bip_coms_num() == 1 then jal.bip.link_base_skeleton()
                else messageBox "There are too many Bips! It should be one!"
            )
        
            on unLinkBipBtn pressed do (
                if jal.bip.get_bip_coms_num() == 1 then jal.bip.unlink_base_skeleton()
                else messageBox "There are too many Bips! It should be one!"
            )
        
            on genSkinBoneBtn pressed do (
                local selObjs = getCurrentSelection() as array
                if selObjs.count > 0 then (
                    local targetBones = for item in selObjs where classof item == BoneGeometry collect item
                    jal.bone.create_skin_bone targetBones
                )
            )
        )

        rollout constraintsRollout "Constraints" (
            group "Position" (
                button posConstBtn "Pos Const"
            )
            group "Rotation" (
                button rotConstBtn "Rotation Const" width:80 across:2
                button rotScriptConstBtn "Rot Script" width:80
            )
            group "LookAt" (
                button lookAtBtn "LookAt" across:3
                button fliplessLookAtBtn "Flipless"
                button scriptedLookAtBtn "Script"
            )
        
            on posConstBtn pressed do (
                undo on (
                    if selection.count >1 then (
                        local selArray = getCurrentSelection()
                        local oriObj = selArray[1]
                        local targetObjArray = #()
        
                        for i = 2 to selArray.count do (
                            append targetObjArray selArray[i]
                        )
        
                        jal.const.assign_pos_const_multi oriObj targetObjArray
                    )
                )
            )
        
            on rotConstBtn pressed do (
                undo on (
                    if selection.count >1 then (
                        local selArray = getCurrentSelection()
                        local oriObj = selArray[1]
                        local targetObjArray = #()
        
                        for i = 2 to selArray.count do (
                            append targetObjArray selArray[i]
                        )
        
                        jal.const.assign_rot_const_multi oriObj targetObjArray
                    )
                )
            )
        
            on rotScriptConstBtn pressed do (
                undo on (
                    if selection.count == 2 then (
                        local selArray = getCurrentSelection()
                        local oriObj = selArray[1]
                        local targetObj = selArray[2]
        
                        jal.const.assign_rot_const_scripted oriObj targetObj
                    )
                )
            )
        
            on lookAtBtn pressed do (
                undo on (
                    if selection.count >1 then (
                        local selArray = getCurrentSelection()
                        local oriObj = selArray[1]
                        local targetObjArray = #()
        
                        for i = 2 to selArray.count do (
                            append targetObjArray selArray[i]
                        )
        
                        jal.const.assign_lookat_multi oriObj targetObjArray
                    )
                )
            )
        
            on fliplessLookAtBtn pressed do (
                undo on (
                    if selection.count == 2 then (
                        local selArray = getCurrentSelection()
                        local oriObj = selArray[1]
                        local targetObj = selArray[2]
        
                        jal.const.assign_lookat_flipless oriObj targetObj
                    )
                )
            )
        
            on scriptedLookAtBtn pressed do (
                undo on (
                    if selection.count > 1 then (
                        local selArray = getCurrentSelection()
                        local oriObj = selArray[1]
                        local targetObjArray = #()
        
                        for i = 2 to selArray.count do (
                            append targetObjArray selArray[i]
                        )
        
                        jal.const.assign_scripted_lookat oriObj targetObjArray
                    )
                )
            )
        )

        rollout muscleBoneRollout "Muscle Bones" (
            pickButton splinePickBtn "Spline Object" autoDisplay: true width:180 height:30
            editText muscleBoneNameTxt "Name:" text:"MuscleBone"
            spinner linkNumSpn "BoneNum:" range:[1, 100, 2] type:#integer
            spinner boneSizeSpn "Size:" range:[1.0, 100, 2.0] type:#float
            checkbox squashCkb "Squash"
            button createBtn "Create Muscle Bones"
            button delBtn "Delete"
        
            on createBtn pressed do (
                if isValidNode splinePickBtn.object then (
                    if classOf splinePickBtn.object == line or classOf splinePickBtn.object == SplineShape then (
                        undo on (
                            local muscleBoneName = muscleBoneNameTxt.text
                            jal.muscleBone.init muscleBoneName splinePickBtn.object linkNumSpn.value boneSizeSpn.value squashCkb.checked
        
                            jal.muscleBone.create()
                        )
                    )
                )
            )
        
            on delBtn pressed do (
                undo on (
                    jal.muscleBone.delAll()
                )
            )
        )

    
        on mainRollout open do
        (
            AddSubRollout mainSub nameSelToolsRollout
            AddSubRollout mainSub helperToolsRollout
            AddSubRollout mainSub boneCreateRollout
            AddSubRollout mainSub skinBoneRollout
            AddSubRollout mainSub constraintsRollout
            AddSubRollout mainSub muscleBoneRollout
    
            constraintsRollout.open = false
            muscleBoneRollout.open = false
            nameSelToolsRollout.open = false
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
    
            jal.roll.update_subroll_when_resized mainSub nameSelToolsRollout
            jal.roll.update_subroll_when_resized mainSub helperToolsRollout
            jal.roll.update_subroll_when_resized mainSub boneCreateRollout
            jal.roll.update_subroll_when_resized mainSub skinBoneRollout
            jal.roll.update_subroll_when_resized mainSub constraintsRollout
            jal.roll.update_subroll_when_resized mainSub muscleBoneRollout
        )
    )
    
    jal.tools.handyTool = mainRollout
    try(destroydialog jal.tools.handyTool) catch()
    createDialog jal.tools.handyTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)

    clearlistener()
    gc()
)

