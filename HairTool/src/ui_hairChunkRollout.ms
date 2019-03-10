rollout hairChunkRollout "Chunk" (
    button addChunkBtn "Add" across:2 height:28 width:100
    button removeChunkBtn "Remove" height:28 width:100
    listbox oriChunkLst "Chunks:" height:10
    button genHairChunkBtn "Gen Hair Chunk" height:32 width:160

    group "PathDeform" (
        button replaceOriMeshBtn "Replace" across:3 height:28 width:80
        button randomOriMeshBtn "Random" height:28 width:80
        button selOriMeshBtn "sel. OriChunk" height:28
        checkButton editSplineCkBtn "Edit HairLine" height:28 width:240
        spinner chunckPercentSpn "Percent:"
        checkbox chunkUniformCkb "Uniform"
        spinner chunkStretchSpn "Stretch:"
    )
    group "Rotation" (
        spinner chunkRotSpn "Amount:"
        spinner chunkTwistSpn "Twist:"
    )
    group "Offset" (
        spinner chunkXOffsetSpn "X:"
        spinner chunkYOffsetSpn "Y:"
    )
    group "Scale" (
        spinner chunkScaleSpn "Scale:"
        button openScaleCurveBtn "Open Scale Curve Editor" enabled:false height:28
    )

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

    fn update_hairChunk_shape inPercent inUniform inStretch inAmount inTwist inX inY inScale = (
        local selArray = filtering_hairChunk_from_selection()
        if selArray.count == 1 then (
        )
        if selArray.count > 1 then (
            for item in selArray do (
                local previousChunkShape = jalHairChunk.get_chunk_shape item
                previousChunkShape.percent += inPercent
                previousChunkShape.stretch += inStretch
                previousChunkShape.rotation += inAmount
                previousChunkShape.twist += inTwist
                previousChunkShape.uniform = inUniform
                previousChunkShape.xOffset += inX
                previousChunkShape.yOffset += inY
                previousChunkShape.DrivingScaleScale += inScale

                jalHairChunk.set_chunk_shape item previousChunkShape
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
            for item in selArray do (
                jalHairChunk.gen_hairChunk oriChunkLst.selection item
            )
        )
    )

    on replaceOriMeshBtn pressed do (
        local selArray = filtering_hairChunk_from_selection()
        if selArray.count > 0 and oriChunkLst.selection > 0 then (
            for item in selArray do (
                jalHairChunk.replace_oriChunk item oriChunkLst.selection
            )
        )
    )

    on randomOriMeshBtn pressed do (
        local selArray = filtering_hairChunk_from_selection()
        if selArray.count > 0 then (
            for item in selArray do (
                local randomIndex = random 1 oriChunkLst.items.count
                jalHairChunk.replace_oriChunk item randomIndex
            )
        )
    )

    on selOriMeshBtn pressed do (
        local selArray = filtering_hairChunk_from_selection()
        if selArray.count > 0 then (
            select selArray[1].modifiers["ChunkInfo"].origin
        )
    )

    on chunckPercentSpn entered inSpinVal inCacel do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
    on chunckPercentSpn buttonup do chunckPercentSpn.value = 0.0

    on chunkUniformCkb changed inVal do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value

    on chunkStretchSpn entered do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
    on chunkStretchSpn buttonup do chunkStretchSpn.value = 0.0

    on chunkRotSpn entered do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
    on chunkRotSpn buttonup do chunkRotSpn.value = 0.0

    on chunkTwistSpn entered do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
    on chunkTwistSpn buttonup do chunkTwistSpn.value = 0.0

    on chunkXOffsetSpn entered do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
    on chunkXOffsetSpn buttonup do chunkXOffsetSpn.value = 0.0

    on chunkYOffsetSpn entered do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
    on chunkYOffsetSpn buttonup do chunkYOffsetSpn.value = 0.0

    on chunkScaleSpn entered do update_hairChunk_shape chunckPercentSpn.value chunkUniformCkb.checked chunkStretchSpn.value chunkRotSpn.value chunkTwistSpn.value chunkXOffsetSpn.value chunkYOffsetSpn.value chunkScaleSpn.value
    on chunkScaleSpn buttonup do chunkScaleSpn.value = 0.0

    on openScaleCurveBtn pressed do (
        createDialog chunkScaleCurveEditRollout width:500
    )
)
