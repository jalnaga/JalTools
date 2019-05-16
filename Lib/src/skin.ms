/**************************************/
/* Skin Library
/**************************************/

struct _SkinVert (
    index,
    boneArray = #(),
    boneIDArray = #(),
    boneNameArray = #(),
    weightArray = #()
)

struct _Skin (
    name,

    prog,

    skinMod,
    modIndex = 0,
    allBoneNamesArray = #(),
    allBonesArray = #(),
    skinWeightsArray = #(),

    fn find_skin inputObj = (
        if inputObj.modifiers.count == 0 then return 0
        for i = 1 to inputObj.modifiers.count do (
            if (classof inputObj.modifiers[i]) == Skin then (
                skinMod = inputObj.modifiers[i]
                modIndex = i
                max modify mode
                select inputObj
                modPanel.setCurrentObject inputObj.modifiers[modIndex]
                return i
            )
        )

        return 0
    ),

    fn remove_unused_bones inputObj weightThresh:0.0001 = (
        if (find_skin inputObj) == 0 then return false
        max modify mode
        select inputObj
        modPanel.setCurrentObject inputObj.modifiers[modIndex]

        local vertCount = skinOps.GetNumberVertices skinMod
        local bonesCount = skinOps.GetNumberBones skinMod
        local unusedBones = #{1..bonesCount}

        --prog.start_progress "Get Skin vertex weight..." totalStep:2
        for v = 1 to vertCount do (
            local vertWeightCount = skinOps.GetVertexWeightCount skinMod v

            for i = 1 to vertWeightCount do (
                local weight = skinOps.GetVertexWeight skinMod v i
                if weight >= weightThresh then (
                    local boneID = skinOps.GetVertexWeightBoneID skinMod v i
                    unusedBones[boneID] = false
                )
            )
            --prog.update_progress v vertCount inProgressText:"" inCurrentStep:1
        )

        for i = bonesCount to 1 by -1 where unusedBones[i] do (
            skinOps.SelectBone skinMod i
            skinOps.RemoveBone skinMod

            --prog.update_progress (bonesCount - i + 1) bonesCount inProgressText:"Remove Unused bones..." inCurrentStep:2
        )
        --prog.end_progress()

        return true
    ),

    fn get_all_bones inputObj = (
        if (find_skin inputObj) == 0 then return false

        allBoneNamesArray = #()
        allBonesArray = #()

        if modIndex != 0 then (
            max modify mode
            select inputObj
            modPanel.setCurrentObject inputObj.modifiers[modIndex]
            allBoneNamesArray = for i = 1 to skinOps.GetNumberBones skinMod collect skinOps.GetBoneName skinMod i 0
            allBonesArray = for i = 1 to allBoneNamesArray.count collect getNodeByName allBoneNamesArray[i]
            return true
        )
        else return false
    ),

    fn get_bone_index inputObj targetBone = (
        if allBonesArray.count > 0 then (
            local boneID = findItem allBonesArray targetBone
            return boneID
        )
        else return 0
    ),

    fn get_skin_weights inputObj = (
        if (get_all_bones inputObj) then (
            skinWeightsArray = #()

            --prog.start_progress "Get Skin vertex weight"
            local numVerts = skinOps.GetNumberVertices skinMod
            for v = 1 to numVerts do (
                local boneArray = #()
                local boneIDArray = #()
                local boneNameArray = #()
                local weightArray = #()
                local boneNum = skinOps.getVertexWeightCount skinMod v

                for i = 1 to boneNum do (
                    local boneID = skinOps.getVertexWeightBoneID skinMod v i
                    local boneName = skinOps.GetBoneName skinMod boneID 0
                    local boneSysID = findItem allBoneNamesArray boneName
                    local boneWeight = skinOps.getVertexWeight skinMod v i
                    append boneArray allBonesArray[boneSysID]
                    append boneIDArray boneID
                    append boneNameArray boneName
                    append weightArray boneWeight
                )
                append skinWeightsArray (_SkinVert index:v boneArray:boneArray boneIDArray:boneIDArray boneNameArray:boneNameArray weightArray:weightArray)
                --prog.update_progress v numVerts
            )
            --prog.end_progress()
        )
    ),

    fn replace_bone inputObj oriBone newBone removeOldBone:true = (
        if (find_skin inputObj) == 0 then return false
        skinOps.addbone skinMod newBone 1

        get_skin_weights inputObj
        local prevSkinWeightsArray = deepCopy skinWeightsArray
        local oriBoneIndex = get_bone_index inputObj oriBone
        if oriBoneIndex == 0 then return false
        local newBoneIndex = get_bone_index inputObj newBone
        local vertNum = skinOps.GetNumberVertices skinMod

        --prog.start_progress "Replace Bones..."
        for v = 1 to vertNum do (
            local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
            if finedBoneID != 0 then (
                prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
            )
            --prog.update_progress v vertNum
        )
        if removeOldBone == true then skinOps.removebone skinMod oriBoneIndex
        --prog.end_progress()

        return true
    ),

    fn copy_weight_between_bones_in_skin inputObj oriBone newBone removeOldBone:false = (
        if (find_skin inputObj) == 0 then return false

        get_skin_weights inputObj
        local prevSkinWeightsArray = deepCopy skinWeightsArray
        local oriBoneIndex = get_bone_index inputObj oriBone
        if oriBoneIndex == 0 then return false
        local newBoneIndex = get_bone_index inputObj newBone
        local vertNum = skinOps.GetNumberVertices skinMod

        --prog.start_progress "Copy weights..."
        for v = 1 to vertNum do (
            local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
            if finedBoneID != 0 then (
                prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
            )
            --prog.update_progress v vertNum
        )
        if removeOldBone == true then skinOps.removebone skinMod oriBoneIndex
        --prog.end_progress()

        return true
    ),

    fn replace_multi_bones inputObj oriBoneArray newBoneArray = (
        if oriBoneArray.count == newBoneArray.count then (
            if (find_skin inputObj) == 0 then return false

            for item in newBoneArray do (
                skinOps.addbone skinMod item 1
            )

            get_skin_weights inputObj
            local delBones = #{1..allBonesArray.count}
            local prevSkinWeightsArray = deepCopy skinWeightsArray

            --prog.start_progress "Replace multi bones..." totalStep:2
            local vertNum = skinOps.GetNumberVertices skinMod
            for i= 1 to oriBoneArray.count do (
                local oriBoneIndex = get_bone_index inputObj oriBoneArray[i]
                local newBoneIndex = get_bone_index inputObj newBoneArray[i]
                if oriBoneIndex != 0 then (
                    delBones[oriBoneIndex] = false
                    for v = 1 to vertNum do (
                        local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
                        if finedBoneID != 0 then (
                            prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                            skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
                        )
                    )
                )
                --prog.update_progress i oriBoneArray.count
            )

            for i = allBonesArray.count to 1 by -1 where (delBones[i] == false) do (
                skinOps.SelectBone skinMod i
                skinOps.RemoveBone skinMod
                --prog.update_progress (allBonesArray.count - i + 1) allBonesArray.count inCurrentStep:2
            )
            --prog.end_progress()
            return true
        )

        return false
    ),

    fn replace_bones_by_baseName inObj inNewBaseName = (
        if (find_skin inObj) == 0 then return false
        get_all_bones inObj

        if allBonesArray.count != 0 then (
            local newBoneNamesArray = #()
            for item in allBoneNamesArray do (
                local newBoneName = name.replace_base item.name inNewBaseName
                append newBoneNamesArray newBoneName
            )

            local newBonesArray = #()
            for item in newBoneNamesArray do (
                local tempNewBone = getNodeByName item
                if tempNewBone != undefined then append newBonesArray tempNewBone
                else (
                    format "Cant Find %\n" item
                    return false
                )
            )

            replace_multi_bones inObj allBonesArray newBonesArray

            return true
        )

        return false
    ),

    fn copy_skin sourceObj targetObj = (
        get_skin_weights sourceObj
        max modify mode
        select targetObj
        addModifier targetObj (copy skinMod)

        local targetSkinMod
        for i = 1 to targetObj.modifiers.count do (
            if (classof targetObj.modifiers[i]) == Skin then targetSkinMod = targetObj.modifiers[i]
        )
        --prog.start_progress "Paste Skin..."
        local targetObjNumVert = skinOps.GetNumberVertices targetSkinMod
        for v = 1 to targetObjNumVert do (
            skinOps.ReplaceVertexWeights targetSkinMod v skinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray

            --prog.update_progress v targetObjNumVert
        )
        --prog.end_progress()
    ),

    fn select_bone inObj inBoneObj = (
        local returnVal = false

        local boneIndex = get_bone_index inObj inBoneObj
        if boneIndex > 0 then (
            skinOps.SelectBone skinMod boneIndex
            returnVal = true
        )

        returnVal
    )
)
