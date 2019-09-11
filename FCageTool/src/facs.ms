struct _Facs (
    targetNum = 51,
    targetNameArray = #("browDownLeft", "browDownRight", "browInnerUp", "browOuterUpLeft", "browOuterUpRight", "cheekPuff", "cheekSquintLeft", "cheekSquintRight","eyeBlinkLeft", "eyeBlinkRight", "eyeLookDownLeft", "eyeLookDownRight", "eyeLookInLeft", "eyeLookInRight", "eyeLookOutLeft", "eyeLookOutRight", "eyeLookUpLeft", "eyeLookUpRight", "eyeSquintLeft", "eyeSquintRight", "eyeWideLeft", "eyeWideRight", "jawForward", "jawOpen", "jawLeft", "jawRight", "mouthClose", "mouthDimpleLeft", "mouthDimpleRight", "mouthFrownLeft", "mouthFrownRight", "mouthFunnel", "mouthLeft", "mouthRight", "mouthLowerDownLeft", "mouthLowerDownRight", "mouthPressLeft", "mouthPressRight", "mouthPucker", "mouthRollLower", "mouthRollUpper", "mouthShrugLower", "mouthShrugUpper", "mouthSmileLeft", "mouthSmileRight", "mouthStretchLeft", "mouthStretchRight", "mouthUpperUpLeft", "mouthUpperUpRight", "noseSneerLeft", "noseSneerRight"),
    oriTargetArray = #(),
    oriNeutralMesh = undefined,
    newNeutralMesh = undefined,
    highUnivMesh = undefined,
    highMeshArray = #(),
    matchInfo = #(),
    newTargetArray = #(),

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

    fn set_highUnivMesh inMesh = (
        local returnVal = false
        if classOf inMesh == Editable_Poly then (
            highUnivMesh = inMesh
            returnVal = true
        )
        returnVal
    ),

    fn sort_targetArray inArray inFilterStr = (
        local returnVal = false
        if inArray.count == targetNum then (
            oriTargetArray = #()
            local tempArray = for item in inArray collect item.name
            for i = 1 to tempArray.count do (
                for j = 1 to targetNameArray.count do (
                    local pattern = "*" + inFilterStr + targetNameArray[j] + inFilterStr + "*"
                    if (MatchPattern tempArray[i] pattern:pattern) then (
                        oriTargetArray[j] = inArray[i]
                        exit
                    )
                )
            )
            returnVal = true
        )
        returnVal
    ),

    fn set_oriTarget inArray inFilterStr = (
        local returnVal = false
        local tempArray = for item in inArray where (classOf item) == Editable_Poly collect item
        if tempArray.count == targetNum then (
            sort_targetArray tempArray inFilterStr
            returnVal = true
        )
        returnVal
    ),

    fn set_hightMeshArrah inArray = (
        local returnVal = false
        local tempArray = for item in inArray where (classOf item) == Editable_Poly collect item
        if tempArray.count == targetNum then (
            highMeshArray = deepCopy tempArray
            returnVal = true
        )
        returnVal
    ),

    fn modify_targets_to_newNeutralMesh = (
        local returnVal = #()
        if oriNeutralMesh == undefined or newNeutralMesh == undefined or oriTargetArray.count != targetNum then return returnVal
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
            if newTargetArray.count == targetNum then returnval = newTargetArray
            return returnVal
        )
    ),

    fn load_vertMatchInfo inXmlFile = (
        local returnVal = false
        matchInfo = #()
        jal.xml.load_file inXmlFile
        local rNode = jal.xml.get_root_node()
        local cageMeshNode = rNode.get_child 0
        local vertNum = (cageMeshNode.get_attribute "totalVertNum") as Integer
        for i = 0 to (vertNum-1) do (
            local vertNode = cageMeshNode.get_child i
            local lVert = (vertNode.get_attribute "index") as Integer
            local hVert = (vertNode.get_attribute "highMeshVertIndex") as Integer
            local tempArray = #(lVert, hVert)
            append matchInfo tempArray
        )
        returnVal = true
        return returnVal
    ),

    fn match_vert_pos inLMesh inHMesh inMatchInfo = (
        toolMode.coordsys #world
        for item in inMatchInfo do (
            local targetPos = polyop.getVert inHMesh item[2] node:inHMesh
            polyop.setVert inLMesh item[1] targetPos node:inLMesh
        )
    ),

    fn gen_targets_from_highMesh = (
        local returnval = false
        if highMeshArray.count == targetNum and oriTargetArray.count == targetNum and oriNeutralMesh != undefined and highUnivMesh != undefined and matchInfo.count != 0 then (
            newTargetArray = #()
            local tempUnivMesh = snapshot highUnivMesh
            tempUnivMesh = convertToPoly tempUnivMesh

            for i = 1 to oriTargetArray.count do (
                local tempFCage = snapshot oriNeutralMesh
                tempFCage = convertToPoly tempFCage
                local univMorphMod = Morpher()
                addModifier tempUnivMesh univMorphMod
                jal.mor.init tempUnivMesh
                jal.mor.add_target highMeshArray[i] 1
                jal.mor.set_channel_value_by_index 1 100.0
                convertToPoly tempUnivMesh
                match_vert_pos tempFCage tempUnivMesh matchInfo

                local fCageMorphMod = Morpher()
                addModifier oriTargetArray[i] fCageMorphMod
                jal.mor.init oriTargetArray[i]
                jal.mor.add_target tempFCage 1
                jal.mor.set_Channel_value_by_index 1 100.0
                newTargetArray[i] = convertToPoly oriTargetArray[i]

                delete tempFCage
            )
            delete tempUnivMesh
            returnVal = true
        )
        returnVal
    )
)
