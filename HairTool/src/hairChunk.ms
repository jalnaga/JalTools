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

    fn get_chunk_shape inMesh = (
        local returnVal = undefined
        if inMesh.modifiers["ChunkInfo"] != undefined and inMesh.modifiers["HairPathDeform"] != undefined then (
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
        if inMesh.modifiers["ChunkInfo"] != undefined and inMesh.modifiers["HairPathDeform"] != undefined then (
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
        local returnVal = false
        if inMesh.modifiers["ChunkInfo"] != undefined and inMesh.modifiers["HairPathDeform"] != undefined then (
            local previousChunkName = inMesh.name
            local previousChunkShape = get_chunk_shape inMesh
            if oriChunkArray[inNewChunkIndex] != undefined and oriChunkArray[inNewChunkIndex] != previousChunkShape.oriChunk then (
                previousChunkShape.oriChunk = oriChunkArray[inNewChunkIndex]
                delete inMesh
                local newChunk = gen_hairChunk inNewChunkIndex previousChunkShape.hairLine
                if newChunk != undefined then (
                    set_chunk_shape newChunk previousChunkShape
                    newChunk.name = previousChunkName

                    returnVal = true
                )
            )
        )

        returnVal
    )
)
