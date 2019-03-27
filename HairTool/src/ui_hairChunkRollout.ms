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
