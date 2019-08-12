(
    try(destroydialog jal.tools.hairTool) catch()
    rollout mainRollout "Hair Tools" width:320 height:900 (
        SubRollout mainSub "" align:#center height:885
    
        local minWidth = 320
        local minHeight = 900
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        global __hairChunkRollout
    
        struct __HairLine (
            hairMesh = undefined,
            detachedHairMeshArray = #(),
            hairEmitMesh = undefined,
            modify = undefined,
            guideLine = undefined,
            lineArray = #(),
        
            fn reset = (
                hairMesh = undefined
                detachedHairMeshArray = #()
                hairEmitMesh = undefined
                modify = undefined
                guideLine = undefined
                lineArray = #()
                gc()
            ),
        
            fn is_valid_hairMesh inMesh = (
                if (classOf inMesh) == Editable_Poly then hairMesh = inMesh
                else return false
        
                local matID2FaceNum = 0
        
                polyop.unHideAllFaces hairMesh
                polyop.setEdgeSelection hairMesh #{}
                polyop.setFaceSelection hairMesh #{}
                polyop.setVertSelection hairMesh #{}
        
                for i = 1 to hairMesh.getNumFaces() do (
                    if (polyop.getFaceMatID hairMesh i) == 2 then matID2FaceNum += 1
                )
        
                if matID2FaceNum > 0 then return true
                else (
                    hairMesh = undefined
                    detachedHairMeshArray = #()
                    return false
                )
            ),
        
            fn detach_hairMesh = (
                if hairMesh != undefined do (
                    detachedHairMeshArray = #()
                    local copyHairMesh = copy hairMesh
                    while polyOp.getNumFaces copyHairMesh != 0 do (
                        local f_list = polyOp.getElementsUsingFace copyHairMesh #{1}
                        local elemName = uniqueName hairMesh.name
                        polyOp.detachFaces copyHairMesh f_list asNode:true name:elemName
                        local elem = getNodeByName elemName
                        append detachedHairMeshArray elem
                    )
                    delete copyHairMesh
                )
            ),
        
            fn set_hairMesh inMesh = (
                local returnMesh = undefined
                if not(is_valid_hairMesh inMesh) then return returnMesh
        
                hairMesh = inMesh
                returnMesh = hairMesh
        
                returnMesh
            ),
        
            fn get_rootFaceBitArray inMesh = (
                local returnBitArray = #{}
                for i = 1 to inMesh.getNumFaces() do (
                    returnBitArray[i] = false
                    if (polyop.getFaceMatID inMesh i) == 2 then (
                        returnBitArray[i] = true
                    )
                )
        
                returnBitArray
            ),
        
            fn get_rootVertPosArray inMesh inRootFaceBitArray = (
                local returnArray = #()
                if hairMesh == undefined or inRootFaceBitArray.count == 0 then return returnArray
        
                SetCommandPanelTaskMode #modify
        
                polyop.unHideAllFaces inMesh
                polyop.setEdgeSelection inMesh #{}
                polyop.setFaceSelection inMesh #{}
                polyop.setVertSelection inMesh #{}
        
                for i = 1 to inRootFaceBitArray.count do (
                    if inRootFaceBitArray[i] == true then (
                        local selFaceVerts = polyop.getFaceVerts hairMesh i
                        for k = 1 to selFaceVerts.count do append returnArray (polyop.getVert hairMesh selFaceVerts[k])
                    )
                )
        
                return returnArray
            ),
        
            fn get_guideEdgeBitArrayArray inMesh inRootFaceBitArray = (
                local returnArray = #()
                if inMesh == undefined or inRootFaceBitArray.count == 0 then return returnArray
        
                SetCommandPanelTaskMode #modify
                local selEdgeBitArray = #{}
        
                polyop.unHideAllFaces inMesh
                polyop.setEdgeSelection inMesh #{}
                polyop.setFaceSelection inMesh #{}
                polyop.setVertSelection inMesh #{}
        
                polyop.setFaceSelection inMesh inRootFaceBitArray
                polyop.setEdgeSelection inMesh (polyop.getEdgesUsingFace inMesh inRootFaceBitArray)
                inMesh.EditablePoly.SelectEdgeRing()
                selEdgeBitArray = polyop.getEdgeSelection inMesh
                selEdgeBitArray = -selEdgeBitArray
        
                polyop.setEdgeSelection inMesh selEdgeBitArray
        
                local firstEdgeIndex = 0
                for i in selEdgeBitArray while Not firstEdgeIndex > 0 do firstEdgeIndex = i
        
                local firstEdgeLoopBitArray = #{}
                for i = 1 to selEdgeBitArray.count do firstEdgeLoopBitArray[i] = false
                firstEdgeLoopBitArray[firstEdgeIndex] = true
                polyop.setEdgeSelection inMesh firstEdgeLoopBitArray
                inMesh.EditablePoly.SelectEdgeLoop()
                firstEdgeLoopBitArray = polyop.getEdgeSelection inMesh
        
                for i = 1 to selEdgeBitArray.count do selEdgeBitArray[i] = false
                selEdgeBitArray[firstEdgeIndex] = true
                polyop.setEdgeSelection inMesh selEdgeBitArray
                inMesh.EditablePoly.SelectEdgeRing()
                selEdgeBitArray = polyop.getEdgeSelection inMesh
                local guideLineNum = 1
                for i = 1 to selEdgeBitArray.count do if selEdgeBitArray[i] then guideLineNum += 1
        
                returnArray = #()
                append returnArray firstEdgeLoopBitArray
                polyop.setEdgeSelection inMesh firstEdgeLoopBitArray
                for i = 2 to (guideLineNum - 1) do (
                    local tempGuideEdgeBitArray
                    inMesh.setRingShift 1 true false
                    tempGuideEdgeBitArray = polyop.getEdgeSelection inMesh
                    append returnArray tempGuideEdgeBitArray
                )
        
                return returnArray
            ),
        
            fn create_guideLine_shape inMesh inGuideEdgeBitArrayArray inRootVertPosArray = (
                local hairGuideLine = undefined
                local hairGuideLineName = uniqueName "GuideLine"
        
                hairGuideLine = SplineShape name:hairGuideLineName
                for item in inGuideEdgeBitArrayArray do (
                    polyop.createShape inMesh item smooth:true name:"tempHairGuideLine"
                    local tempGuideLine = $tempHairGuideLine
                    addAndWeld hairGuideLine tempGuideLine 0.0
                )
                updateShape hairGuideLine
        
                for i = 1 to (numSplines hairGuideLine) do (
                    for k = 1 to inRootVertPosArray.count do (
                        local firstVertexPos = getKnotPoint hairGuideLine i 1
                        if (findItem inRootVertPosArray firstVertexPos) == 0 then (
                            reverse hairGuideLine i
                            updateShape hairGuideLine
                        )
                    )
                )
        
                hairGuideLine
            ),
        
            fn create_guideLine inMesh = (
                if (set_hairMesh inMesh) == undefined then return false
                else (
                    detach_hairMesh()
                    for item in detachedHairMeshArray do (
                        local rootFaceBitArray = get_rootFaceBitArray item
                        local rootVertPosArray = get_rootVertPosArray item rootFaceBitArray
                        local guideEdgeBitArrayArray = get_guideEdgeBitArrayArray item rootFaceBitArray
                        create_guideLine_shape item guideEdgeBitArrayArray rootVertPosArray
                    )
                    delete detachedHairMeshArray
                    return true
                )
            ),
        
            fn create_emitter = (
                local emitMesh = copy hairMesh
                local nonEmitFaceBitArray = #{}
                SetCommandPanelTaskMode #modify
                select emitMesh
                subobjectlevel = 4
                emitMesh.selectByMaterial 2 clearCurrentSelection:true
                nonEmitFaceBitArray = polyop.getFaceSelection emitMesh
                emitMesh.EditablePoly.flipNormals 1
                nonEmitFaceBitArray = -nonEmitFaceBitArray
                polyop.deleteFaces emitMesh nonEmitFaceBitArray
                subobjectlevel = 0
                clearSelection()
        
                hairEmitMesh = emitMesh
                emitMesh
            ),
        
            fn add_hair_modifier = (
                select hairEmitMesh
                max modify mode
                modify = HairMod()
                addModifier hairEmitMesh modify
                modify.HairCount = 20
                modify.HairSegments = 15
                modify.HairPasses = 1
                modify.HairDensity = 100
                modify.HairScale = 100
                modify.HairCutLength = 100
                modify.HairRandScale = 3
                modify.HairRootThickness = 12
                modify.HairTipThickness = 0.1
                modify.HairDisplacement = 0
                modify.HairInterpolateGuides = on
                modify.MaterialOccludedAmb = 40
                modify.MaterialHueVariation = 12
                modify.MaterialValueVariation = 35
                modify.MaterialSpecular = 30
                modify.MaterialGlossness = 95
                modify.MaterialSelfShadow = 100
                modify.MaterialGeomShadow = 100
                modify.MaterialGeomMtlID = 1
                modify.FrizzRoot = 15
                modify.FrizzTip = 0.5
                modify.FrizzFreqX = 14
                modify.FrizzFreqY = 14
                modify.FrizzFreqZ = 14
                modify.FrizzAnim = 0
                modify.FrizzAnimSpeed = 0
                modify.KinkRoot = 0
                modify.KinkFreqX = 2.3
                modify.KinkFreqY = 2.3
                modify.KinkFreqZ = 2.3
                modify.MultiStrandCount = 1
                modify.MultiStrandRootSplay = 0.73
                modify.MultiStrandTipSplay = 0.002
                modify.MultiRandomize = 0.1
                modify.DisplayHairPercent = 100
                modify.DisplayMaxHairs = 10000
                modify.displayShowHairs = on
                modify.displayHairAsGeometry = off
        
                modify.RecombFromSplines guideLine
            ),
        
            fn detach_spline_to_hairLine inSpline = (
                local returnArray = #()
                if superclassof inSpline == shape then (
                    local splineWireColor = inSpline.wireColor
                    convertToSplineShape inSpline
                    local splineNum = numsplines inSpline
                    for splineIndex in splineNum to 2 by -1 do (
                        c = (for k in splineNum to 1 by -1 collect k)
                        local detachedSpline = copy inSpline
                        deleteitem c (splineNum - splineIndex + 1)
                        for iii in c do (
                            deleteSpline detachedSpline iii
                        )
                        updateshape detachedSpline
                        detachedSpline.wireColor = splineWireColor
                        append returnArray detachedSpline
                    )
                    for iiii in splineNum to 2 by -1 do (
                        deletespline inSpline iiii
                    )
                    updateshape inSpline
                    append returnArray inSpline
                )
        
                returnArray
            ),
        
            fn create_hairLine inMesh = (
                create_guideLine inMesh
                if guideLine != undefined then (
                    local tempHairLine = copy guideLine
                    tempHairLine.name = uniqueName "hairLine_"
                    lineArray = detach_spline_to_hairLine tempHairLine
                    delete guideLine
                )
                reset()
            ),
        
            fn create_guideline_from_hairMod inMesh = (
                create_guideLine inMesh
                create_emitter()
                hide hairMesh
                hide guideLine
                add_hair_modifier()
            ),
        
            fn create_hairline_from_hairMode = (
                if modify != undefined then (
                    select hairEmitMesh
                    local tempHairLine = modify.convertHairsToSplines instance:hairEmitMesh
                    tempHairLine.name = uniqueName "hairLine_"
                    lineArray = detach_spline_to_hairLine tempHairLine
                    delete guideLine
                    delete hairEmitMesh
                    reset()
                )
            )
        )

        struct __HairChunkShpae (
            oriChunk,
            hairLine,
            percent,
            stretch,
            rotation,
            twist,
            uniform,
            xOffset,
            yOffset,
            DrivingScaleScale
        )
        
        struct __HairChunk (
            oriChunkArray = #(),
        
            fn reset = (
                oriChunkArray = #()
            ),
        
            fn add_oriChunk inMesh = (
                returnVal = false
                if (classOf inMesh) == Editable_Poly then (
                    appendIfUnique oriChunkArray inMesh
                    returnVal = true
                )
        
                returnVal
            ),
        
            fn remove_oriChunk inMeshIndex = (
                returnVal = false
                if oriChunkArray[inMeshIndex] != undefined then (
                    local beforeOriChunkArray = deepCopy oriChunkArray
                    oriChunkArray = deleteItem beforeOriChunkArray inMeshIndex
                )
            ),
        
            fn copy_oriChunk inOriChunkIndex = (
                local returnMesh = undefined
                if oriChunkArray[inOriChunkIndex] != undefined then returnMesh = reference oriChunkArray[inOriChunkIndex]
        
                returnMesh
            ),
        
            fn add_custAtt inMesh inOriChunk inHairLine = (
                local returnVal = false
                local attHolderMod = EmptyModifier()
                attHolderMod.name = "ChunkInfo"
                local oriChunkHolderCA = attributes oriChunkAtt (
                    parameters param (
                        origin type:#node
                        hairLine type:#node
                    )
                )
        
                if (for m in inMesh.modifiers where m.name == "ChunkInfo" collect m).count == 0 then (
                    addModifier inMesh attHolderMod
                    custAttributes.add inMesh.modifiers["ChunkInfo"] oriChunkHolderCA
                    inMesh.modifiers["ChunkInfo"].origin = inOriChunk
                    inMesh.modifiers["ChunkInfo"].hairLine = inHairLine
                    returnVal = true
                )
        
                returnVal
            ),
        
            fn add_pathDeform inMesh inHairLine inAxis:2 inFlip:true = (
                local returnVal = false
                if (for m in inMesh.modifiers where m.name == "ChunkInfo" collect m).count == 1 then (
                    if (for m in inMesh.modifiers where m.name == "HairPathDeform" collect m).count == 0 then (
                        local meshLength = inMesh.max.z - inMesh.min.z
                        local slArray = getSegLengths inHairLine 1
                        local pathLength = slArray[slArray.count]
                        local stretchAmount = pathLength / meshLength
        
                        local pathDeformMod = Path_Deform2()
                        pathDeformMod.name = "HairPathDeform"
                        pathDeformMod.spline = inHairLine
                        pathDeformMod.AdaptiveUpVector = on
                        pathDeformMod.auto_stretch = off
                        pathDeformMod.percent_along_path = 0
                        pathDeformMod.axis = inAxis
                        pathDeformMod.Flip = inFlip
                        pathDeformMod.Stretch = stretchAmount
                        pathDeformMod.rotation = 170
                        pathDeformMod.ScaleEnable = on
                        pathDeformMod.uniform = on
        
                        addModifier inMesh pathDeformMod
        
                        returnVal = true
                    )
                )
                returnVal
            ),
        
            fn gen_hairChunk inOriChunkIndex inHairLine = (
                local returnChunk = undefined
                local hairChunk = copy_oriChunk inOriChunkIndex
                if hairChunk != undefined then (
                    add_custAtt hairChunk oriChunkArray[inOriChunkIndex] inHairLine
                    add_pathDeform hairChunk inHairLine inAxis:2 inFlip:true
        
                    returnChunk = hairChunk
                )
        
                returnChunk
            ),
        
            fn is_hairChunk inMesh = (
                local returnVal = false
                if inMesh.modifiers["ChunkInfo"] != undefined and inMesh.modifiers["HairPathDeform"] != undefined then returnVal = true
                returnVal
            ),
        
            fn get_chunk inMesh = (
                local returnVal = undefined
                if is_hairChunk inMesh then (
                    returnVal = inMesh
                )
                returnVal
            ),
        
            fn get_chunk_shape inMesh = (
                local returnVal = undefined
                if (is_hairChunk inMesh) then (
                    local returnChunkShape = __HairChunkShpae()
                    returnChunkShape.oriChunk = inMesh.modifiers["ChunkInfo"].origin
                    returnChunkShape.hairLine = inMesh.modifiers["ChunkInfo"].hairLine
                    returnChunkShape.percent = inMesh.modifiers["HairPathDeform"].percent_along_path
                    returnChunkShape.stretch = inMesh.modifiers["HairPathDeform"].Stretch
                    returnChunkShape.rotation = inMesh.modifiers["HairPathDeform"].rotation
                    returnChunkShape.twist = inMesh.modifiers["HairPathDeform"].twist
                    returnChunkShape.uniform = inMesh.modifiers["HairPathDeform"].Uniform
                    returnChunkShape.xOffset = inMesh.modifiers["HairPathDeform"].x_offset
                    returnChunkShape.yOffset = inMesh.modifiers["HairPathDeform"].y_offset
                    returnChunkShape.DrivingScaleScale = inMesh.modifiers["HairPathDeform"].DrivingScaleScale
        
                    returnVal = returnChunkShape
                )
        
                returnVal
            ),
        
            fn set_chunk_shape inMesh inChunkShape = (
                local returnVal = false
                if (is_hairChunk inMesh) then (
                    inMesh.modifiers["ChunkInfo"].origin = inChunkShape.oriChunk
                    inMesh.modifiers["ChunkInfo"].hairLine = inChunkShape.hairLine
                    inMesh.modifiers["HairPathDeform"].percent_along_path = inChunkShape.percent
                    inMesh.modifiers["HairPathDeform"].Stretch = inChunkShape.stretch
                    inMesh.modifiers["HairPathDeform"].rotation = inChunkShape.rotation
                    inMesh.modifiers["HairPathDeform"].twist = inChunkShape.twist
                    inMesh.modifiers["HairPathDeform"].Uniform = inChunkShape.uniform
                    inMesh.modifiers["HairPathDeform"].x_offset = inChunkShape.xOffset
                    inMesh.modifiers["HairPathDeform"].y_offset = inChunkShape.yOffset
                    inMesh.modifiers["HairPathDeform"].DrivingScaleScale = inChunkShape.DrivingScaleScale
        
                    returnVal = true
                )
        
                returnVal
            ),
        
            fn replace_oriChunk inMesh inNewChunkIndex = (
                local returnVal = undefined
                if (is_hairChunk inMesh) then (
                    local previousChunkName = inMesh.name
                    local previousChunkShape = get_chunk_shape inMesh
                    if oriChunkArray[inNewChunkIndex] != undefined and oriChunkArray[inNewChunkIndex] != previousChunkShape.oriChunk then (
                        previousChunkShape.oriChunk = oriChunkArray[inNewChunkIndex]
                        delete inMesh
                        local newChunk = gen_hairChunk inNewChunkIndex previousChunkShape.hairLine
                        if newChunk != undefined then (
                            set_chunk_shape newChunk previousChunkShape
                            newChunk.name = previousChunkName
        
                            returnVal = newChunk
                        )
                    )
                )
        
                returnVal
            ),
        
            fn get_hairLine inMesh = (
                local returnVal = undefined
                if (is_hairChunk inMesh) then returnVal = inMesh.modifiers["ChunkInfo"].hairLine
                returnVal
            )
        )

    
        local jalHairLine = __HairLine()
        local jalHairChunk = __HairChunk()
    
        rollout hairLineRollout "Guide Line" (
            pickButton hairMeshPickBtn "Pick Hair Mesh" autoDisplay:true height:35 width:160
            button createLineBtn "Create Line" enabled:false
            group "Generate from Hair Modifier" (
                button createGuideLineFromHairModBtn "Create Line from Hair" enabled:false across:2 align:#left
                button genLineFromHairBtn "Gen Line" enabled:false align:#right
            )
            group "Utility" (
                button splineDetachBtn "Detach Spline" across:2
                button selUsedLineBtn "Sel. Used Line"
            )
        
            fn reset_ui = (
                hairMeshPickBtn.object = undefined
                hairMeshPickBtn.text = "Pick Hair Mesh"
                createLineBtn.enabled = false
                createGuideLineFromHairModBtn.enabled = false
                genLineFromHairBtn.enabled = false
            )
        
            on hairMeshPickBtn picked inArg do (
                if (jalHairLine.is_valid_hairMesh inArg) then (
                    jalHairLine.set_hairMesh inArg
                    createLineBtn.enabled = true
                    createGuideLineFromHairModBtn.enabled = true
                )
                else (
                    jalHairLine.reset()
                    reset_ui()
                    messageBox "Please Select...\n   -Editable Poly which has\n   -Material ID 2"
                )
            )
        
            on hairMeshPickBtn rightclick do (
                jalHairLine.reset()
                reset_ui()
            )
        
            on splineDetachBtn pressed do (
                local selSpline = for item in selection where (classOf item == SplineShape) collect item
                for item in selSpline do (
                    jalHairLine.detach_spline_to_hairLine item
                )
            )
        
            on selUsedLineBtn pressed do (
                local usedHairLineArray = for item in selection where (item.modifiers["ChunkInfo"] != undefined and item.modifiers["HairPathDeform"] != undefined) collect item.modifiers["ChunkInfo"].hairLine
                select usedHairLineArray
            )
        
            on createLineBtn pressed do (
                jalHairLine.create_guideLine hairMeshPickBtn.object
                reset_ui()
            )
        )

        rollout hairChunkRollout "Chunk" (
            button addChunkBtn "Add" across:2 height:28 width:100
            button removeChunkBtn "Remove" height:28 width:100
            listbox oriChunkLst "Chunks:" height:10
            button genHairChunkBtn "Gen Hair Chunk" height:32 width:160
        
            label chunkSelStatLabel "0 Chunk Selected" offset:[0, 20] align:#left
        
            group "PathDeform" (
                button replaceOriMeshBtn "Replace" across:3 height:28 width:80
                button randomOriMeshBtn "Random" height:28 width:80
                button selOriMeshBtn "sel. OriChunk" height:28
                checkButton editSplineCkBtn "Edit HairLine" height:28 width:245
                spinner chunckPercentSpn "Percent:" range:[-200,200,0] type:#float scale:0.01
                checkbox chunkUniformCkb "Uniform"
                spinner chunkStretchSpn "Stretch:" range:[-20,20,0] type:#float scale:0.001
            )
            group "Rotation" (
                spinner chunkRotSpn "Amount:" range:[-1000,1000,0] type:#float scale:0.1
                spinner chunkTwistSpn "Twist:" range:[-1000,1000,0] type:#float scale:0.1
            )
            group "Offset" (
                spinner chunkXOffsetSpn "X:" range:[-100,100,0] type:#float scale:0.01
                spinner chunkYOffsetSpn "Y:" range:[-100,100,0] type:#float scale:0.01
            )
            group "Scale" (
                spinner chunkScaleSpn "Scale:" range:[0,100,1] type:#float scale:0.01
                button openScaleCurveBtn "Open Scale Curve Editor" enabled:false height:28
            )
        
            local chunkSelArray = #()
            local chunkShapeArray = #()
        
            rollout chunkScaleCurveEditRollout "Hair Cunk Scale Editor" (
                CurveControl chunkScaleCrv "Scale" numCurves:1 displayModes:#{1} x_range:[0.0, 1.0] y_range:[0.0, 5.0]
        
                on chunkScaleCurveEditRollout open do (
                    local selArray = for item in selection where (item.modifiers["HairPathDeform"] != undefined) collect item
                    if selArray.count > 0 then (
                        local chunkCrv = chunkScaleCrv.curves[1]
                        selArray[1].modifiers["HairPathDeform"].scaleCurve.Curve_1 = chunkCrv
                        zoom chunkScaleCrv #all
                    )
                )
            )
        
            fn filtering_hairChunk_from_selection = (
                local returnArray = for item in selection where (item.modifiers["ChunkInfo"] != undefined and item.modifiers["HairPathDeform"] != undefined) collect item
        
                returnArray
            )
        
            fn set_UI_to_chunk_shape = (
                local selArray = filtering_hairChunk_from_selection()
                if selArray.count == 1 then (
                    chunkSelStatLabel.text = (selArray.count as String) + " Chunks selected"
                    local previousChunkShape = jalHairChunk.get_chunk_shape selArray[1]
                    chunckPercentSpn.value = previousChunkShape.percent
                    chunkStretchSpn.value = previousChunkShape.stretch
                    chunkRotSpn.value = previousChunkShape.rotation
                    chunkTwistSpn.value = previousChunkShape.twist
                    chunkUniformCkb.checked = previousChunkShape.uniform
                    chunkXOffsetSpn.value = previousChunkShape.xOffset
                    chunkYOffsetSpn.value = previousChunkShape.yOffset
                    chunkScaleSpn.value = previousChunkShape.DrivingScaleScale
                )
                if selArray.count > 1 then (
                    chunkSelStatLabel.text = (selArray.count as String) + " Chunks selected"
                    local previousChunkShape = jalHairChunk.get_chunk_shape selArray[selArray.count]
                    chunckPercentSpn.value = 0
                    chunkStretchSpn.value = 0
                    chunkRotSpn.value = 0
                    chunkTwistSpn.value = 0
                    chunkUniformCkb.checked = previousChunkShape.uniform
                    chunkXOffsetSpn.value = 0
                    chunkYOffsetSpn.value = 0
                    chunkScaleSpn.value = previousChunkShape.DrivingScaleScale
                )
                if selArray.count == 0 then (
                    chunkSelStatLabel.text = "0 Chunks selected"
                    chunckPercentSpn.value = 0
                    chunkStretchSpn.value = 0
                    chunkRotSpn.value = 0
                    chunkTwistSpn.value = 0
                    chunkUniformCkb.checked = true
                    chunkXOffsetSpn.value = 0
                    chunkYOffsetSpn.value = 0
                    chunkScaleSpn.value = 1
                )
            )
        
            fn set_chunk_array = (
                chunkSelArray = #()
                chunkSelArray = filtering_hairChunk_from_selection()
                chunkShapeArray = #()
                chunkShapeArray = for item in chunkSelArray collect (jalHairChunk.get_chunk_shape item)
            )
        
            fn update_hairChunk_shape inSelArray inShapeArray inPercent inUniform inStretch inAmount inTwist inX inY inScale = (
                if inSelArray.count == 1 then (
                    local previousChunkShape = jalHairChunk.get_chunk_shape inSelArray[1]
                    previousChunkShape.percent = inPercent
                    previousChunkShape.stretch = inStretch
                    previousChunkShape.rotation = inAmount
                    previousChunkShape.twist = inTwist
                    previousChunkShape.uniform = inUniform
                    previousChunkShape.xOffset = inX
                    previousChunkShape.yOffset = inY
                    previousChunkShape.DrivingScaleScale = inScale
        
                    jalHairChunk.set_chunk_shape inSelArray[1] previousChunkShape
                )
                if inSelArray.count > 1 then (
                    for i = 1 to inSelArray.count do (
                        local newShape = __HairChunkShpae()
                        newShape.oriChunk = inShapeArray[i].oriChunk
                        newShape.hairLine = inShapeArray[i].hairLine
                        newShape.percent = inShapeArray[i].percent + inPercent
                        newShape.stretch = inShapeArray[i].stretch + inStretch
                        newShape.rotation = inShapeArray[i].rotation + inAmount
                        newShape.twist = inShapeArray[i].twist + inTwist
                        newShape.uniform = inUniform
                        newShape.xOffset = inShapeArray[i].xOffset + inX
                        newShape.yOffset = inShapeArray[i].yOffset + inY
                        newShape.DrivingScaleScale = inScale
        
                        jalHairChunk.set_chunk_shape inSelArray[i] newShape
                    )
                )
            )
        
            on addChunkBtn pressed do (
                local selArray = getCurrentSelection() as Array
                for item in selArray do (
                    jalHairChunk.add_oriChunk item
                )
                oriChunkLst.items = for item in jalHairChunk.oriChunkArray collect item.name
            )
        
            on removeChunkBtn pressed do (
                jalHairChunk.remove_oriChunk oriChunkLst.selection
                oriChunkLst.items = for item in jalHairChunk.oriChunkArray collect item.name
            )
        
            on genHairChunkBtn pressed do (
                local selArray = for item in selection where (superClassOf item) == shape collect item
                if oriChunkLst.selection > 0 then (
                    local resultChunkArray = #()
                    for item in selArray do (
                        append resultChunkArray (jalHairChunk.gen_hairChunk oriChunkLst.selection item)
                    )
                    select resultChunkArray
                )
            )
        
            on replaceOriMeshBtn pressed do (
                local selArray = filtering_hairChunk_from_selection()
                if selArray.count > 0 and oriChunkLst.selection > 0 then (
                    local resultChunkArray = #()
                    for item in selArray do (
                        append resultChunkArray (jalHairChunk.replace_oriChunk item oriChunkLst.selection)
                    )
                    select resultChunkArray
                )
            )
        
            on randomOriMeshBtn pressed do (
                local selArray = filtering_hairChunk_from_selection()
                if selArray.count > 0 then (
                    local resultChunkArray = #()
                    for item in selArray do (
                        local randomIndex = random 1 oriChunkLst.items.count
                        append resultChunkArray (jalHairChunk.replace_oriChunk item randomIndex)
                    )
                    select resultChunkArray
                )
            )
        
            on selOriMeshBtn pressed do (
                local selArray = filtering_hairChunk_from_selection()
                if selArray.count > 0 then (
                    select selArray[1].modifiers["ChunkInfo"].origin
                )
            )
        
            on editSplineCkBtn changed startSplineEdit do (
                if startSplineEdit then (
                    set_chunk_array()
                    if chunkSelArray.count > 0 then (
                        local chunkLineArray = for item in chunkSelArray collect (jalHairChunk.get_hairLine item)
                        max modify mode
                        select chunkLineArray
                        modPanel.addModToSelection (Edit_Spline ()) ui:on
                    )
                )
                else (
                    if chunkSelArray.count > 0 then (
                        local chunkLineArray = for item in chunkSelArray collect (jalHairChunk.get_hairLine item)
                        convertToSplineShape chunkLineArray
                        select chunkSelArray
                    )
                )
            )
        
            on chunckPercentSpn buttonDown do set_chunk_array()
            on chunckPercentSpn buttonUp do set_UI_to_chunk_shape()
            on chunckPercentSpn changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on chunkUniformCkb changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on chunkStretchSpn buttonDown do set_chunk_array()
            on chunkStretchSpn buttonUp do set_UI_to_chunk_shape()
            on chunkStretchSpn changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on chunkRotSpn buttonDown do set_chunk_array()
            on chunkRotSpn buttonUp do set_UI_to_chunk_shape()
            on chunkRotSpn changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on chunkTwistSpn buttonDown do set_chunk_array()
            on chunkTwistSpn buttonUp do set_UI_to_chunk_shape()
            on chunkTwistSpn changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on chunkXOffsetSpn buttonDown do set_chunk_array()
            on chunkXOffsetSpn buttonUp do set_UI_to_chunk_shape()
            on chunkXOffsetSpn changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on chunkYOffsetSpn buttonDown do set_chunk_array()
            on chunkYOffsetSpn buttonUp do set_UI_to_chunk_shape()
            on chunkYOffsetSpn changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on chunkScaleSpn buttonDown do set_chunk_array()
            on chunkScaleSpn buttonUp do set_UI_to_chunk_shape()
            on chunkScaleSpn changed inVal do (
                update_hairChunk_shape chunkSelArray chunkShapeArray chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
            )
        
            on openScaleCurveBtn pressed do (
                createDialog chunkScaleCurveEditRollout width:500
            )
        )

    
        on mainRollout open do (
            __hairChunkRollout = hairChunkRollout
    
            AddSubRollout mainSub hairLineRollout
            AddSubRollout mainSub hairChunkRollout
    
            callbacks.addScript #selectionSetChanged " __hairChunkRollout.set_UI_to_chunk_shape()" id:#jalHairChunkRolloutUIUpdate
            __hairChunkRollout.set_UI_to_chunk_shape()
        )
    
        on mainRollout close do (
            callbacks.removeScripts id:#jalHairChunkRolloutUIUpdate
        )
    )
    jal.tools.hairTool = mainRollout
    createDialog jal.tools.hairTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)

    clearlistener()
    gc()
)
