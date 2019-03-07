struct __HairChunk (
    guideLine,
    oriChunk,
    chunk,

    fn reset = (
        guideLine = undefined
        oriChunk = undefined
        chunk = undefined
    ),

    fn set_oriChunk inMesh = (
        returnVal = false
        if (classOf inMesh) == Editable_Poly then (
            oriChunk = inMesh
            returnVal = true
        )

        returnVal
    ),

    fn add_custAtt = (
        returnVal = false
        if oriChunk == undefined then returnVal = true
        else (
            local oriChunkHolderCA = attributes oriChunkAtt (
                parameters param (
                    oriChunk type:#node
                )
            )
            oriChunkHolderCA.oriChunk = inMesh
            chunk = copy inMesh
            custAttributes.add chunk oriChunkHolderCA
        )

        returnVal
    )
)
