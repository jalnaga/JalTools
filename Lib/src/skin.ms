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
    xml,

    prog,

    skinMod,
    modIndex = 0,
    allBoneNamesArray = #(),
    allBonesArray = #(),
    skinWeightsArray = #(),

    fn find_skin inputObj = (
        local returnVal = 0
        if inputObj.modifiers.count == 0 then return returnVal
        for i = 1 to inputObj.modifiers.count do (
            if (classof inputObj.modifiers[i]) == Skin then (
                skinMod = inputObj.modifiers[i]
                modIndex = i
                returnVal = i
            )
        )

        returnVal
    ),

    fn select_skinObj inputObj = (
        local returnVal = false
        if (find_skin inputObj) == 0 then return returnVal

        max modify mode
        select inputObj
        modPanel.setCurrentObject inputObj.modifiers[modIndex]
        subobjectLevel = 1
        returnVal = true
        returnVal
    ),

    fn remove_unused_bones inputObj weightThresh:0.0001 = (
        local returnVal = false
        if not(select_skinObj inputObj) then return returnVal

        local vertCount = skinOps.GetNumberVertices skinMod
        local bonesCount = skinOps.GetNumberBones skinMod
        local unusedBones = #{1..bonesCount}

        for v = 1 to vertCount do (
            local vertWeightCount = skinOps.GetVertexWeightCount skinMod v

            for i = 1 to vertWeightCount do (
                local weight = skinOps.GetVertexWeight skinMod v i
                if weight >= weightThresh then (
                    local boneID = skinOps.GetVertexWeightBoneID skinMod v i
                    unusedBones[boneID] = false
                )
            )
        )

        for i = bonesCount to 1 by -1 where unusedBones[i] do (
            skinOps.SelectBone skinMod i
            skinOps.RemoveBone skinMod
        )

        returnVal = true
        returnVal
    ),

    fn get_all_bones inputObj = (
        local returnVal = #()
        if not(select_skinObj inputObj) then return returnVal

        allBoneNamesArray = #()
        allBonesArray = #()

        allBoneNamesArray = for i = 1 to skinOps.GetNumberBones skinMod collect skinOps.GetBoneName skinMod i 0
        allBonesArray = for i = 1 to allBoneNamesArray.count collect getNodeByName allBoneNamesArray[i]

        returnVal = deepCopy allBonesArray
        returnVal
    ),

    fn get_bone_index inputObj targetBone = (
        local returnVal = 0
        if allBonesArray.count > 0 then (
            local boneID = findItem allBonesArray targetBone
            returnVal = boneID
        )

        returnVal
    ),

    fn round_number num precision:3 = (
        local multiplier = 10 ^ precision
        ( floor ( (num * multiplier) + 0.5) ) / multiplier
    ),

    fn get_selected_skinVerts inputObj = (
        local returnVal = #()
        if not(select_skinObj inputObj) then return returnVal
        returnVal = for v = 1 to skinOps.GetNumberVertices skinMod where skinOps.IsVertexSelected skinMod v == 1 collect v

        returnVal
    ),

    fn get_vert_weight inputObj inVertIndex = (
        local returnVal = _SkinVert()
        if skinMod == undefined then return returnVal
        if allBonesArray.count == 0 then (
            get_all_bones inputObj
            if allBonesArray.count == 0 then return returnVal
        )

        local boneArray = #()
        local boneIDArray = #()
        local boneNameArray = #()
        local weightArray = #()
        local boneNum = skinOps.getVertexWeightCount skinMod inVertIndex

        for i = 1 to boneNum do (
            local boneID = skinOps.getVertexWeightBoneID skinMod inVertIndex i
            local boneName = skinOps.GetBoneName skinMod boneID 0
            local boneSysID = findItem allBoneNamesArray boneName
            local boneWeight = skinOps.getVertexWeight skinMod inVertIndex i
            append boneArray allBonesArray[boneSysID]
            append boneIDArray boneID
            append boneNameArray boneName
            append weightArray (round_number boneWeight)
        )

        returnVal.index = inVertIndex
        returnVal.boneArray = deepCopy boneArray
        returnVal.boneIDArray = deepCopy boneIDArray
        returnVal.boneNameArray = deepCopy boneNameArray
        returnVal.weightArray = deepCopy weightArray

        returnVal
    ),

    fn get_skin_weights inputObj = (
        if (get_all_bones inputObj) then (
            skinWeightsArray = #()

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
            )
        )
    ),

    fn get_skin_weights inputObj = (
        local returnVal = #()
        if allBonesArray.count > 0 then (
            skinWeightsArray = #()
            local numVerts = skinOps.GetNumberVertices skinMod
            for i = 1 to numVerts do (
                append skinWeightsArray (get_vert_weight inputObj i)
            )
            returnVal = deepCopy skinWeightsArray
        )
        returnVal
    ),

    fn select_zeroWeight_vertex inputObj = (
        local returnArray = #()
        if not(select_skinObj inputObj) then return returnArray

        local numVerts = skinOps.GetNumberVertices skinMod
        for v = 1 to numVerts do (
            local weights = (get_vert_weight inputObj v).weightArray
            local weightVal = 0.0
            for item in weights do if item != undefined then weightVal += item
            if weightVal == 0.0 then append returnArray v
        )
        skinOps.SelectVertices skinMod returnArray
        redrawViews()

        returnArray
    ),

    fn replace_bone inputObj oriBone newBone removeOldBone:true = (
        if (find_skin inputObj) == 0 then return false
        skinOps.addbone skinMod newBone 1
        get_all_bones inputObj
        if allBonesArray.count < 2 then return false

        get_skin_weights inputObj
        local prevSkinWeightsArray = deepCopy skinWeightsArray
        local oriBoneIndex = get_bone_index inputObj oriBone
        if oriBoneIndex == 0 then return false
        local newBoneIndex = get_bone_index inputObj newBone
        local vertNum = skinOps.GetNumberVertices skinMod

        for v = 1 to vertNum do (
            local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
            if finedBoneID != 0 then (
                prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
            )
        )
        if removeOldBone == true then skinOps.removebone skinMod oriBoneIndex

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

        for v = 1 to vertNum do (
            local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
            if finedBoneID != 0 then (
                prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
            )
        )
        if removeOldBone == true then skinOps.removebone skinMod oriBoneIndex

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
            )

            for i = allBonesArray.count to 1 by -1 where (delBones[i] == false) do (
                skinOps.SelectBone skinMod i
                skinOps.RemoveBone skinMod
            )
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

    /*fn copy_skin sourceObj targetObj = (
        get_skin_weights sourceObj
        max modify mode
        select targetObj
        addModifier targetObj (copy skinMod)

        local targetSkinMod
        for i = 1 to targetObj.modifiers.count do (
            if (classof targetObj.modifiers[i]) == Skin then targetSkinMod = targetObj.modifiers[i]
        )
        local targetObjNumVert = skinOps.GetNumberVertices targetSkinMod
        for v = 1 to targetObjNumVert do (
            skinOps.ReplaceVertexWeights targetSkinMod v skinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray

        )
    ),*/

    fn copy_skin sourceObj targetObj = (
        local skinBoneArray = get_all_bones sourceObj
        get_skin_weights sourceObj
        max modify mode
        select targetObj
        addModifier targetObj (Skin())

        local targetSkinMod
        for i = 1 to targetObj.modifiers.count do (
            if (classof targetObj.modifiers[i]) == Skin then targetSkinMod = targetObj.modifiers[i]
        )
        for item in skinBoneArray do skinOps.addbone targetSkinMod item 1
        local targetObjNumVert = skinOps.GetNumberVertices targetSkinMod
        for v = 1 to targetObjNumVert do (
            skinOps.ReplaceVertexWeights targetSkinMod v skinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
        )
    ),

    fn save_to_file sourceObj inFileName selectedVertOnly:false = (
        get_all_bones sourceObj
        get_skin_weights sourceObj

        xml.create_file inFileName
        local rNode = xml.get_root_node()
        local skinNode = xml.create_node "Skin"

        local allBoneNode = xml.create_node "AllBoneArray"
        local allBoneArrayStr = "#("
        for item in allBonesArray do (
            allBoneArrayStr += "$"
            allBoneArrayStr += item.name
            allBoneArrayStr += ","
        )
        allBoneArrayStr[allBoneArrayStr.count] = ")"
        allBoneNode.set_text allBoneArrayStr
        skinNode.append_child_node allBoneNode

        local processSkinWeightArray = #()
        if selectedVertOnly then (
            local selVertArray = get_selected_skinVerts sourceObj
            processSkinWeightArray = for vertIndex in selVertArray collect skinWeightsArray[vertIndex]
        )
        else (
            processSkinWeightArray = for skinWeight in skinWeightsArray collect skinWeight
        )

        for skinWeight in processSkinWeightArray do (
            local skinVertNode = xml.create_node "Vert"
            skinVertNode.add_attribute "index" (skinWeight.index as String)
            local boneArrayNode = xml.create_node "BoneArray"
            local boneIDNode = xml.create_node "BoneIDArray"
            local boneNameNode = xml.create_node "BoneNameArray"
            local weightNode = xml.create_node "WeightArray"

            local boneArrayStr = "#("
            for skinBone in skinWeight.boneArray do (
                boneArrayStr += "$"
                boneArrayStr += skinBone.name
                boneArrayStr += ","
            )
            boneArrayStr[boneArrayStr.count] = ")"
            boneArrayNode.set_text boneArrayStr

            local boneIDArrayStr = "#("
            for skinBoneID in skinWeight.boneIDArray do (
                boneIDArrayStr += (skinBoneID as String)
                boneIDArrayStr += ","
            )
            boneIDArrayStr[boneIDArrayStr.count] = ")"
            boneIDNode.set_text boneIDArrayStr

            local boneNameArrayStr = "#("
            for boneName in skinWeight.boneNameArray do (
                boneNameArrayStr += boneName
                boneNameArrayStr += ","
            )
            boneNameArrayStr[boneNameArrayStr.count] = ")"
            boneNameNode.set_text boneNameArrayStr

            weightArrayStr = "#("
            for weight in skinWeight.weightArray do (
                weightArrayStr += (weight as String)
                weightArrayStr += ","
            )
            weightArrayStr[weightArrayStr.count] = ")"
            weightNode.set_text weightArrayStr

            skinVertNode.append_child_node boneArrayNode
            skinVertNode.append_child_node boneIDNode
            skinVertNode.append_child_node boneNameNode
            skinVertNode.append_child_node weightNode

            skinNode.append_child_node skinVertNode
        )
        rNode.append_child_node skinNode
        xml.save_pretty()
    ),

    fn load_from_file targetObj inFileName selectedVertOnly:false = (
        xml.load_file inFileName
        max modify mode
        local targetSkinMod
        select targetObj
        if not(selectedVertOnly) then (
            addModifier targetObj (Skin())
        )

        for i = 1 to targetObj.modifiers.count do (
            if (classof targetObj.modifiers[i]) == Skin then targetSkinMod = targetObj.modifiers[i]
        )

        local rNode = xml.get_root_node()
        local skinNode = rNode.get_child 0
        local allBoneArrayNode = skinNode.get_child 0
        local loadedAllBoneArray = execute (allBoneArrayNode.get_text())

        if not(selectedVertOnly) then (
            for item in loadedAllBoneArray do skinOps.addbone targetSkinMod item 1
        )
        local processVertNum = (skinNode.get_children()).count - 1
        for i = 1 to processVertNum do (
            local skinVertNode = skinNode.get_child i
            local vertIndex = (skinVertNode.get_attribute "index") as Integer
            local boneIDArrayNode = skinVertNode.get_child 1
            local weightArrayNode = skinVertNode.get_child 3
            local loadedBoneArray = execute (boneIDArrayNode.get_text())
            local loadedWeightArray = execute (weightArrayNode.get_text())
            skinOps.ReplaceVertexWeights targetSkinMod vertIndex loadedBoneArray loadedWeightArray
        )
    ),

    fn select_bone inObj inBoneObj = (
        local returnVal = false

        local boneIndex = get_bone_index inObj inBoneObj
        if boneIndex > 0 then (
            skinOps.SelectBone skinMod boneIndex
            returnVal = true
        )

        returnVal
    ),

    fn pare_mirror_bones inObj = (
        get_all_bones inObj
        if allBonesArray.count > 0 then (
            local lBoneArray = for item in allBonesArray where (name.is_left item.name) collect item
            local rBoneArray = for item in allBonesArray where (name.is_right item.name) collect item
            local cBoneArray = for item in allBonesArray where (not(name.is_left item.name) and not(name.is_right item.name)) collect item
            local paredBoneArray = #()
            while lBoneArray.count == 0 do (
                for item in lBoneArray do (
                    local targetBoneName = name.replace_side item.name name.get_rightStr()
                )
            )
        )
    )
)
