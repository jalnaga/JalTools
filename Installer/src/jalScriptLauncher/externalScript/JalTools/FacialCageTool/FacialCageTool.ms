(
    try(destroydialog jal.tools.facialCageTool) catch()
    rollout mainRollout "Facial Cage Tool" width:300 height:400 (
        SubRollout mainSub "" align:#center height:385
    
        local minWidth = 300
        local minHeight = 400
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        local facialCageMaxVertNum = 500
    
        struct _FacialCage (
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

        local fCage = _FacialCage()
    
        rollout facialBoneRollout "Bone Generator" (
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

    
        on mainRollout open do
        (
            AddSubRollout mainSub facialBoneRollout
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
    
            jal.roll.update_subroll_when_resized mainSub facialBoneRollout
        )
    )
    jal.tools.facialCageTool = mainRollout
    createDialog jal.tools.facialCageTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)

    clearlistener()
    gc()
)
