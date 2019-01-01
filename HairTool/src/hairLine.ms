struct __HairLine (
    hairMesh = undefined,
    hairEmitMesh = undefined,
    modify = undefined,
    rootFaceBitArray = #{},
    rootVertPosArray = #(),
    guideEdgeBitArrayArray = #(),
    guideLine = undefined,
    lineArray = #(),

    fn reset = (
        hairMesh = undefined
        hairEmitMesh = undefined
        modify = undefined
        rootFaceBitArray = #{}
        rootVertPosArray = #()
        guideEdgeBitArrayArray = #()
        guideLine = undefined
        lineArray = #()
        gc()
    ),

    fn is_valid_hairMesh inMesh = (
        rootFaceBitArray = #{}
        if (classOf inMesh) == Editable_Poly then hairMesh = inMesh
        else return false

        local matID2FaceNum = 0

        polyop.unHideAllFaces hairMesh
        polyop.setEdgeSelection hairMesh #{}
        polyop.setFaceSelection hairMesh #{}
        polyop.setVertSelection hairMesh #{}

        for i = 1 to hairMesh.getNumFaces() do (
            rootFaceBitArray[i] = false
            if (polyop.getFaceMatID hairMesh i) == 2 then (
                rootFaceBitArray[i] = true
                matID2FaceNum += 1
            )
        )

        if matID2FaceNum > 0 then return true
        else (
            hairMesh = undefined
            rootFaceBitArray = #{}
            return false
        )
    ),

    fn set_hairMesh inMesh = (
        local returnMesh = undefined
        if not(is_valid_hairMesh inMesh) then return returnMesh

        hairMesh = inMesh
        returnMesh = hairMesh

        returnMesh
    ),

    fn get_rootVertPosArray = (
        local returnArray = #()
        if hairMesh == undefined or rootFaceBitArray.count == 0 then return returnArray

        SetCommandPanelTaskMode #modify

        polyop.unHideAllFaces hairMesh
        polyop.setEdgeSelection hairMesh #{}
        polyop.setFaceSelection hairMesh #{}
        polyop.setVertSelection hairMesh #{}

        for i = 1 to rootFaceBitArray.count do (
            if rootFaceBitArray[i] == true then (
                local selFaceVerts = polyop.getFaceVerts hairMesh i
                for k = 1 to selFaceVerts.count do append returnArray (polyop.getVert hairMesh selFaceVerts[k])
            )
        )

        rootVertPosArray = returnArray

        return returnArray
    ),

    fn get_guideEdgeBitArrayArray = (
        local returnArray = #()
        if hairMesh == undefined or rootFaceBitArray.count == 0 or rootVertPosArray.count == 0 then return returnArray

        SetCommandPanelTaskMode #modify
        local selEdgeBitArray = #{}

        polyop.unHideAllFaces hairMesh
        polyop.setEdgeSelection hairMesh #{}
        polyop.setFaceSelection hairMesh #{}
        polyop.setVertSelection hairMesh #{}

        polyop.setFaceSelection hairMesh rootFaceBitArray
        polyop.setEdgeSelection hairMesh (polyop.getEdgesUsingFace hairMesh rootFaceBitArray)
        hairMesh.EditablePoly.SelectEdgeRing()
        selEdgeBitArray = polyop.getEdgeSelection hairMesh
        selEdgeBitArray = -selEdgeBitArray

        local firstEdgeIndex = 0
        for i in selEdgeBitArray while Not firstEdgeIndex > 0 do firstEdgeIndex = i

        local firstEdgeLoopBitArray = #{}
        for i = 1 to selEdgeBitArray.count do firstEdgeLoopBitArray[i] = false
        firstEdgeLoopBitArray[firstEdgeIndex] = true
        polyop.setEdgeSelection hairMesh firstEdgeLoopBitArray
        hairMesh.EditablePoly.SelectEdgeLoop()
        firstEdgeLoopBitArray = polyop.getEdgeSelection hairMesh

        for i = 1 to selEdgeBitArray.count do selEdgeBitArray[i] = false
        selEdgeBitArray[firstEdgeIndex] = true
        polyop.setEdgeSelection hairMesh selEdgeBitArray
        hairMesh.EditablePoly.SelectEdgeRing()
        selEdgeBitArray = polyop.getEdgeSelection hairMesh
        local guideLineNum = 1
        for i = 1 to selEdgeBitArray.count do if selEdgeBitArray[i] then guideLineNum += 1

        returnArray = #()
        append returnArray firstEdgeLoopBitArray
        polyop.setEdgeSelection hairMesh firstEdgeLoopBitArray
        for i = 2 to (guideLineNum - 1) do (
            local tempGuideEdgeBitArray
            hairMesh.setRingShift 1 true false
            tempGuideEdgeBitArray = polyop.getEdgeSelection hairMesh
            append returnArray tempGuideEdgeBitArray
        )
        guideEdgeBitArrayArray = returnArray

        return returnArray
    ),

    fn create_guideLine_shape = (
        local hairGuideLine = undefined
        local hairGuideLineName = uniqueName "GuideLine"

        hairGuideLine = SplineShape name:hairGuideLineName
        for item in guideEdgeBitArrayArray do (
            polyop.createShape hairMesh item smooth:true name:"tempHairGuideLine"
            local tempGuideLine = $tempHairGuideLine
            addAndWeld hairGuideLine tempGuideLine 0.0
        )
        updateShape hairGuideLine
        guideLine = hairGuideLine

        for i = 1 to (numSplines hairGuideLine) do (
            for k = 1 to rootVertPosArray.count do (
                local firstVertexPos = getKnotPoint hairGuideLine i 1
                if (findItem rootVertPosArray firstVertexPos) == 0 then (
                    reverse hairGuideLine i
                    updateShape hairGuideLine
                )
            )
        )

        hairGuideLine
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

    fn create_guideLine inMesh = (
        if (set_hairMesh inMesh) == undefined then return false
        else (
            get_rootVertPosArray()
            get_guideEdgeBitArrayArray()
            create_guideLine_shape()
            return true
        )
    ),

    fn detach_spline_to_hairLine inSpline = (
        local returnArray = #()
        if superclassof inSpline == shape do (
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
