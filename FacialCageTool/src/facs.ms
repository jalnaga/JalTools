struct _Facs (
    staticNum = 51,
    oriTargetArray = #(),
    newTargetArray = #(),
    oriNeutralMesh = undefined,
    newNeutralMesh = undefined,

    fn set_oriNeutralMesh inMesh = (
        local returnVal = false
        if classOf inMesh == Editable_Poly then (
            oriNeutralMesh = inMesh
            returnVal = true
        )
        returnVal
    ),

    fn set_newNeutralMesh inMesh = (
        local returnVal = false
        if classOf inMesh == Editable_Poly then (
            newNeutralMesh = inMesh
            returnVal = true
        )
        returnVal
    ),

    fn set_oriTarget inArray = (
        local returnVal = false
        local tempArray = for item in inArray where (classOf item) == Editable_Poly collect item
        if tempArray.count == staticNum then (
            oriTargetArray = deepCopy tempArray
            returnVal = true
        )
        returnVal
    ),

    fn gen_newTargetArray = (
        local returnVal = #()
        if oriNeutralMesh == undefined or newNeutralMesh == undefined or oriTargetArray.count != staticNum then return returnVal
        else (
            for i = 1 to oriTargetArray.count do (
                local newFacsMorphMod = Morpher()
                local newFacs = snapshot oriNeutralMesh
                local oriFacs = snapshot oriTargetArray[i]
                addModifier newFacs newFacsMorphMod
                jal.mor.init newFacs
                jal.mor.add_targets #(oriFacs, newNeutralMesh)
                jal.mor.set_channel_value_by_index 1 100.0
                jal.mor.set_channel_value_by_index 2 100.0
                newFacs = convertToPoly newFacs

                local oriFacsMorphMod = Morpher()
                addModifier oriTargetArray[i] oriFacsMorphMod
                jal.mor.init oriTargetArray[i]
                jal.mor.add_target newFacs 1
                jal.mor.set_channel_value_by_index 1 100.0
                newTargetArray[i] = convertToPoly oriTargetArray[i]

                delete newFacs
                delete oriFacs
            )
            if newTargetArray.count == staticNum then returnval = newTargetArray
            return returnVal
        )
    )
)
