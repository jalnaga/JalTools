(
    try(destroydialog jal.tools.facialCageTool) catch()
    rollout mainRollout "Facial Cage Tool" width:300 height:400 (
        SubRollout mainSub "" align:#center height:385
    
        local minWidth = 300
        local minHeight = 400
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        local facialCageMeshFullName = ""
        local fCageMeshName = "FCage_000"
        local univFaceMeshName = "UnivHead_000"
    
        local xmlFile = ""
    
        --local facialCageMaxVertNum = 500
        --struct _FacialCage (
    cageMesh = undefined,
    skinMesh = undefined,
    placerArray = #(),
    boneArray = #(),
    headBone = #(),
    neckBone = #(),
    jawBone = #(),
    bipHead = undefined,
    bipNeck = undefined,

    fn reset = (
        cageMesh = undefined
        skinMesh = undefined
        placerArray = #()
        boneArray = #()
        headBone = #()
        neckBone = #()
        jawBone = #()
        bipHead = undefined
        bipNeck = undefined
    ),

    fn convert_point3_to_array inP3 = (
        #(inP3.x, inP3.y, inP3.z)
    ),

    fn get_first_item_from_bitArray inBitArray item:0 = (
        for i in inBitArray while Not item > 0 do item = i
        item
    ),

    fn create_skinMesh = (
        if cageMesh != undefined and (classOf cageMesh.baseObject) == Editable_Poly then (
            skinMesh = copy cageMesh
            convertTo skinMesh Editable_Poly

            addModifier skinMesh (Skin())
        )
    ),

    fn add_skinBone = (
        if skinMesh != undefined then (
            local skinIndex = jal.skin.find_skin skinMesh
            if skinIndex != 0 then (
                max modify mode
                select skinMesh
                modPanel.setCurrentObject skinMesh.modifiers[skinIndex]
                local skinMod = skinMesh.modifiers[1]

                for i = 1 to boneArray.count by 2 do (
                    skinOps.addbone skinMod boneArray[i] 1
                )
            )
        )
    ),

    fn set_skinWeight = (
        if skinMesh != undefined then (
            max modify mode
            select skinMesh
            modPanel.setCurrentObject skinMesh.modifiers[1]
            local skinMod = skinMesh.modifiers[1]

            local targetObjNumVert = skinOps.GetNumberVertices skinMod
            for v = 1 to targetObjNumVert do (
                skinOps.ReplaceVertexWeights skinMod v v 1.0
            )
        )
    ),

    fn gen_rot_const inVertIndex = (
        local rotConst = rotation_script()
        local scriptStr = ""
        rotConst.AddNode "cageMesh" cageMesh
        rotConst.AddConstant "vertIndex" inVertIndex
        scriptStr += "local selMesh = cageMesh.mesh\n"
        scriptStr += "local vertPos = (getVert selMesh vertIndex) * cageMesh.objectTransform\n"
        scriptStr += "local helperMatrix = matrix3 [1,0,0] [0,1,0] [0,0,1] vertPos\n"
        scriptStr += "local row1 = (getNormal selMesh vertIndex) * cageMesh.objectTransform.rotation\n"
        scriptStr += "local row2 = normalize (cross row1 [0,0,-1])\n"
        scriptStr += "local row3 = normalize (cross row1 row2)\n"
        scriptStr += "helperMatrix = matrix3 row1 row2 row3 vertPos\n"
        scriptStr += "helperMatrix.rotationpart\n"
        rotConst.script = scriptStr

        rotConst
    ),

    fn gen_placer_on_vertex alignToVertexNormal:true useRotConst:false = (
        local returnPointArray = #()
        if classOf cageMesh.baseObject == Editable_Poly then (
            local selMesh = cageMesh.mesh

            jal.prog.start_progress "Placer Generating..." useDialog:true
            for i = 1 to cageMesh.numverts do (
                local vertPos = (getVert selMesh i) * cageMesh.objectTransform
                local helperMatrix = matrix3 [1,0,0] [0,1,0] [0,0,1] vertPos
                if alignToVertexNormal then (
                    local row1 = (getNormal selMesh i) * cageMesh.objectTransform.rotation
                    local row2 = normalize (cross row1 [0,0,-1])
                    local row3 = normalize (cross row1 row2)

                    helperMatrix = matrix3 row1 row2 row3 vertPos
                )

                local genPoint = jal.helper.create_point (jal.name.gen_uniqueName "Point") size:0.3
                genPoint.transform = helperMatrix

                local face = get_first_item_from_bitArray (meshop.getFacesUsingVert selMesh i)
                local faceVerts = convert_point3_to_array (getFace selMesh face)
                local attachConst = Attachment node:cageMesh
                attachConst.align = false

                genPoint.position.controller = attachConst
                local key = AttachCtrl.addNewKey attachConst 0
                key.face = face - 1
                key.coord = #([1,0], [0,1], [0,0])[findItem faceVerts i]

                if useRotConst then genPoint.rotation.controller = (gen_rot_const i)

                append returnPointArray genPoint
                jal.prog.update_progress i cageMesh.numverts
            )
            jal.prog.end_progress()

            placerArray = deepCopy returnPointArray
        )
        returnPointArray
    ),

    fn gen_bone_on_placer = (
        local returnBoneArray = #()
        jal.prog.start_progress "Bone Generating..." useDialog:true
        for i = 1 to placerArray.count do (
            local genBone = jal.bone.create_simple_bone 0.25 (placerArray[i].name) size:0.2
            genBone[1].transform = placerArray[i].transform
            jal.anim.rotate_local genBone[1] 90 0 0
            genBone[1].parent = placerArray[i]
            append returnBoneArray genBone[1]
            append returnBoneArray genBone[2]

            jal.prog.update_progress i placerArray.count
        )
        jal.prog.end_progress()

        boneArray = deepCopy returnBoneArray
        returnBoneArray
    ),

    fn set_bipHead inObj = (
        bipHead = inObj
    ),

    fn set_bipNeck inObj = (
        bipNeck = inObj
    ),

    fn gen_headBone = (
        local returnVal = false
        if bipHead != undefined then (
            headBone = jal.bone.create_simple_bone 10 "Head Root 0" end:true size:3
            headBone[1].transform = bipHead.transform
            returnVal = true
        )

        returnVal
    ),

    fn gen_jawBone inStart inEnd = (
        local returnVal = false
        if bipHead != undefined and inStart != undefined and inEnd != undefined then (
            jawBone = jal.bone.create_bone #(inStart, inEnd) "Jaw" end:true size:1 delPoint:false
            returnVal = true
        )
    )
)

        --local fCage = _FacialCage()
    
        --rollout facialBoneRollout "Bone Generator" (
    fn filter_facialCageMesh inObj = classOf inObj.baseObject == Editable_Poly and inObj.mesh.numverts < facialCageMaxVertNum
    pickbutton meshPickBtn "Pick Facial Cage Mesh" autoDisplay:true filter:filter_facialCageMesh width:160 height:40 across:2 align:#left
    button genPlacerBtn "Gen. Placer" enabled:false width:70 height:40 align:#right
    checkBox alignNormalCkb "Align to Normal" across:2
    checkBox rotConstCkb "Rotation"
    button genBoneBtn "Generate Bone"
    button assignSkinBtn "Assign Skin"

    local facialCageLayerName = "FCage"
    local facialPlacerLayerName = "FCage_Placer"
    local facialBoneLayerName = "FCage_Bone"

    fn reset_ui = (
        meshPickBtn.object = undefined
        meshPickBtn.text = "Pick Facial Cage Mesh"
    )

    fn reset_layer = (
    )

    on meshPickBtn picked inObj do (
        if inObj != undefined then fCage.cageMesh = inObj
        genPlacerBtn.enabled = true
        jal.layer.create_layer_from_array #(fCage.cageMesh) facialCageLayerName
    )

    on meshPickBtn rightclick do (
        if meshPickBtn.object != undefined then (
            if (queryBox ("Delete " + meshPickBtn.object.name + "?")) then delete fCage.cageMesh
        )
        if (jal.layer.get_layer_number facialPlacerLayerName) != false then jal.layer.delete_layer facialPlacerLayerName forceDelete:true
        if (jal.layer.get_layer_number facialBoneLayerName) != false then jal.layer.delete_layer facialBoneLayerName forceDelete:true

        fCage.cageMesh = undefined
        fCage.reset()
        jal.layer.delete_layer facialCageLayerName forceDelete:false
        reset_ui()
    )

    on genPlacerBtn pressed do (
        max create mode
        fCage.gen_placer_on_vertex alignToVertexNormal:alignNormalCkb.checked useRotConst:rotConstCkb.checked
        jal.layer.create_layer_from_array fCage.placerArray facialPlacerLayerName
        jal.layer.set_parent_layer facialPlacerLayerName facialCageLayerName
        gc()
    )

    on genPlacerBtn rightclick do (
        jal.layer.delete_layer facialPlacerLayerName forceDelete:true
        fCage.placerArray = #()
        disable_bipPick_ui()
        gc light:true
    )

    on genBoneBtn pressed do (
        fCage.gen_bone_on_placer()
        if not(alignNormalCkb.checked) and not(rotConstCkb.checked) then (
            for i = 1 to fCage.boneArray.count by 2 do (
                jal.anim.rotate_local fCage.boneArray[i] 0 -90 0
            )
        )
        jal.layer.create_layer_from_array fCage.boneArray facialBoneLayerName
        jal.layer.set_parent_layer facialBoneLayerName facialCageLayerName
    )

    on assignSkinBtn pressed do (
        fCage.create_skinMesh()
        fCage.add_skinBone()
        fCage.set_skinWeight()
    )
)

        rollout facialCageInfoGenRollout "Facial Cage Info Genereator" (
            fn pickFilter inObj = classOf inObj == Editable_Poly
            group "Steps" (
                label step1Lbl "1. " across:2 offset:[-10, 8]
                pickButton avgMeshPickBtn "Pick Average Face mesh" enabled:true width:130 height:30 align:#left offset:[-40, 0] filter:pickFilter autoDisplay:true
                label step2Lbl "2. " across:2 offset:[-10, 8]
                pickButton fCageMeshPickBtn "Pick Facial Cage mesh" enabled:false width:130 height:30 align:#left offset:[-40, 0] filter:pickFilter autoDisplay:true
                label step3Lbl "3. " across:2 offset:[-10, 8]
                button boneSelBtn "Select Facial Bones" enabled:false width:130 height:30 align:#left offset:[-40, 0]
            )
        
            button saveXmlBtn "Save FCage Info" height:25 offset:[0, 5] enabled:false
        
            local univMesh = undefined
            local fCageMesh = undefined
            local staticFacialBoneNum = 189
            local facialBoneArray = #()
        
            fn update_ui = (
                if univMesh == undefined then (
                    fCageMeshPickBtn.enabled = false
                    fCageMesh = undefined
                    facialBoneArray = #()
                )
                else fCageMeshPickBtn.enabled = true
        
                if fCageMesh == undefined then (
                    boneSelBtn.enabled = false
                    facialBoneArray = #()
                )
                else boneSelBtn.enabled = true
        
                if facialBoneArray.count == 0 then (
                    saveXmlBtn.enabled = false
                    boneSelBtn.caption = "Select Facial Bones"
                )
                else (
                    saveXmlBtn.enabled = true
                    boneSelBtn.caption = "189 bones are selected"
                )
            )
        
            on avgMeshPickBtn picked pickedObj do (
                univMesh = pickedObj
                update_ui()
            )
        
            on avgMeshPickBtn rightclick do (
                univMesh = undefined
                avgMeshPickBtn.object = undefined
                update_ui()
            )
        
            on fCageMeshPickBtn picked pickedObj do (
                fCageMesh = pickedObj
                update_ui()
            )
        
            on fCageMeshPickBtn rightclick do (
                fCageMesh = undefined
                fCageMeshPickBtn.object = undefined
                update_ui()
            )
        
            on boneSelBtn pressed do (
                local selBoneArray = for item in selection where classOf item == BoneGeometry collect item
                if selBoneArray.count == staticFacialBoneNum then (
                    facialBoneArray = deepCopy selBoneArray
                )
                else (
                    if selBoneArray.count > staticFacialBoneNum then messageBox "Select facial bones only!\nSome non relative bones are selected."
                    if selBoneArray.count < staticFacialBoneNum then messageBox "Select every facial bones!"
                )
                update_ui()
            )
        
            on boneSelBtn rightclick do (
                facialBoneArray = #()
                update_ui()
            )
        
            on saveXmlBtn pressed do (
                if univMesh != undefined and fCageMesh != undefined and facialBoneArray.count == staticFacialBoneNum then (
                    local distThresh = 0.02905
        
                    local lMeshVertCount = polyop.getNumVerts fCageMesh
                    local hMeshVertCount = polyop.getNumVerts univMesh
        
                    local matchVertsArray = #()
                    local matchBonesArray = #()
        
                    toolMode.coordsys #world
        
                    for i = 1 to lMeshVertCount do (
                        local lMeshVertPos = polyop.getVert fCageMesh i node:fCageMesh
                        for k = 1 to hMeshVertCount do (
                            local pairVertArray = #()
        
                            local hMeshVertPos = polyop.getVert univMesh k node:univMesh
                            local vertDist = distance lMeshVertPos hMeshVertPos
                            if vertDist <= distThresh then (
                                append pairVertArray i
                                append pairVertArray k
                                append matchVertsArray pairVertArray
                                exit
                            )
                        )
                        for j = 1 to facialBoneArray.count do (
                            local pairBoneArray = #()
        
                            local bonePos = in coordsys world (facialBoneArray[j].transform.position)
                            local boneDist = distance lMeshVertPos bonePos
                            if boneDist <= distThresh then (
                                append pairBoneArray i
                                append pairBoneArray facialBoneArray[j].name
                                append matchBonesArray pairBoneArray
                                exit
                            )
                        )
                    )
        
                    jal.xml.create_file xmlFile
                    local rNode = jal.xml.get_root_node()
                    local cageNode = jal.xml.create_node "CageMesh"
        
                    cageNode.add_attribute "totalVertNum" "189"
                    for i = 1 to matchVertsArray.count do (
                        local matchBoneName = matchBonesArray[i][2]
                        local side = ""
                        if (MatchPattern matchBoneName pattern:"L_*") then side = "L"
                        if (MatchPattern matchBoneName pattern:"R_*") then side = "R"
                        if (MatchPattern matchBoneName pattern:"C_*") then side = "C"
                        local boneName = (FilterString matchBoneName "_")[2]
                        local vertInfoNode = jal.xml.create_node "VertInfo"
                        vertInfoNode.add_attribute "index" (matchVertsArray[i][1] as String)
                        vertInfoNode.add_attribute "highMeshVertIndex" (matchVertsArray[i][2] as String)
                        vertInfoNode.add_attribute "side" side
                        vertInfoNode.add_attribute "boneName" boneName
        
                        cageNode.append_child_node vertInfoNode
                    )
                    rNode.append_child_node cageNode
                    jal.xml.save_pretty()
                )
                else messageBox "Not enough components!\nPick\n- Average Mesh\n- Facial Cage Mesh\n- Facial Bones"
            )
        )

        rollout facialCageGeneratorRollout "Facial Cage Genereator" (
            button addHMeshBtn "Add High polygon Head meshes..." height:30
            MultiListBox addHMeshLst "" height:10
            button genFCageBtn "Make Facial Cages" height:50
        
            local mergedFCage = undefined
            local mergedUnivMesh = undefined
            local hMeshArray = #()
        
            fn get_merged_obj inMergeFile nameArray:#() = (
                local currentObjNum = objects.count
                local returnVal = #()
                if nameArray.count == 0 then mergeMaxFile inMergeFile #neverReparent #AutoRenameDups
                else mergeMaxFile inMergeFile nameArray #neverReparent #AutoRenameDups
                if objects.count > currentObjNum then (
                    local lasObjNum = objects.count
                    returnVal = for objIndex = (currentObjNum+1) to lasObjNum collect (objects[objIndex])
                )
        
                returnVal
            )
        
            fn load_vertMatchInfo = (
                local returnArray = #()
                jal.xml.load_file xmlFile
                local rNode = jal.xml.get_root_node()
                local cageMeshNode = rNode.get_child 0
                local vertNum = (cageMeshNode.get_attribute "totalVertNum") as Integer
                for i = 0 to (vertNum-1) do (
                    local vertNode = cageMeshNode.get_child i
                    local lVert = (vertNode.get_attribute "index") as Integer
                    local hVert = (vertNode.get_attribute "highMeshVertIndex") as Integer
                    local tempArray = #(lVert, hVert)
                    append returnArray tempArray
                )
                return returnArray
            )
        
            fn match_vert_pos inLMesh inHMesh inMatchInfo = (
                toolMode.coordsys #world
                for item in inMatchInfo do (
                    local targetPos = polyop.getVert inHMesh item[2] node:inHMesh
                    polyop.setVert inLMesh item[1] targetPos node:inLMesh
                )
            )
        
            on addHMeshBtn pressed do (
                hMeshArray = #()
                local excludeObjArray = #()
                local mergedMeshArray = get_merged_obj facialCageMeshFullName nameArray:#(univFaceMeshName)
                local testMorphMod = Morpher()
                if mergedMeshArray.count == 1 then (
                    mergedUnivMesh = mergedMeshArray[1]
                    addModifier mergedUnivMesh testMorphMod
                    jal.mor.init mergedUnivMesh
                )
                else (
                    messageBox "Data File Error!\n There is no UnivHead for Merging!!"
                    destroydialog jal.tools.facialCageTool
                )
        
                local ePolyMeshArray = for item in selection where classOf item == Editable_Poly collect item
                if ePolyMeshArray.count > 0 then (
                    for i = 1 to ePolyMeshArray.count do (
                        local result = jal.mor.add_target ePolyMeshArray[i] i
                        if result then append hMeshArray ePolyMeshArray[i]
                        else append excludeObjArray ePolyMeshArray[i]
                    )
                    if hMeshArray.count > 0 then addHMeshLst.items = for item in hMeshArray collect item.name
                    if excludeObjArray.count > 0 then (
                        local mssgStr = ""
                        for item in excludeObjArray do mssgStr += (item.name + "\n")
                        mssgStr += "are not added."
                        messageBox mssgStr
                    )
                )
                else messageBox "There is no Editable_Poly Object"
                delete mergedUnivMesh
                mergedUnivMesh = undefined
            )
        
            on genFCageBtn pressed do (
                if addHMeshLst.items.count > 0 then (
                    local vertMatchInfo = load_vertMatchInfo()
                    local mergedMeshArray = get_merged_obj facialCageMeshFullName nameArray:#(fCageMeshName)
                    local generatedFCageMeshArray = #()
                    if mergedMeshArray.count == 1 then (
                        mergedFCage = mergedMeshArray[1]
                        for i = 1 to hMeshArray.count do (
                            local tempHMesh = snapshot hMeshArray[i]
                            local tempCageMesh = snapshot mergedFCage
                            convertToPoly tempHMesh
                            convertToPoly tempCageMesh
                            match_vert_pos tempCageMesh tempHMesh vertMatchInfo
                            tempCageMesh.name = tempHMesh.name + "_FCage"
                            append generatedFCageMeshArray tempCageMesh
                            delete tempHMesh
                        )
                        delete mergedFCage
                        mergedFCage = undefined
                        select generatedFCageMeshArray
                    )
                )
            )
        )

    
        on mainRollout open do
        (
            local tool_path = getINISetting ((GetDir #userMacros) + "\\jalScriptLauncher\\ini\\scriptPath.ini") "ExternalScript" "ScriptPath"
            tool_path = tool_path + "\\JalTools\\FacialCageTool"
            facialCageMeshFullName = tool_path + "\\maxScene\\FCage.max"
            xmlFile = tool_path + "\\data\\fCageInfo.xml"
    
            AddSubRollout mainSub facialCageInfoGenRollout
            AddSubRollout mainSub facialCageGeneratorRollout
    
            facialCageInfoGenRollout.open = false
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
    
            jal.roll.update_subroll_when_resized mainSub facialCageInfoGenRollout
            jal.roll.update_subroll_when_resized mainSub facialCageGeneratorRollout
        )
    )
    jal.tools.facialCageTool = mainRollout
    createDialog jal.tools.facialCageTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)

    clearlistener()
    gc()
)
