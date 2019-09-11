rollout facialCageGeneratorRollout "Rigging" (
    button genFCageBtn "Make Facial Cages" height:50

    local mergedFCage = undefined
    local mergedUnivMesh = undefined
    local hMeshArray = #()

    local targetMesh = undefined
    local skinSourceMeshName = "FCage_SkinSourceHead"
    local skinSourceMesh = undefined
    local genFCageMesh = undefined


    fn get_merged_obj inMergeFile nameArray:#() = (
        local currentObjNum = objects.count
        local returnVal = #()
        if nameArray.count == 0 then mergeMaxFile inMergeFile #neverReparent #AutoRenameDups
        else mergeMaxFile inMergeFile nameArray #neverReparent #AutoRenameDups
        if objects.count > currentObjNum then (
            local lasObjNum = objects.count
            returnVal = for objIndex = (currentObjNum+1) to lasObjNum collect (objects[objIndex])
        )

        returnVal
    )

    fn load_vertMatchInfo = (
        local returnArray = #()
        jal.xml.load_file xmlFile
        local rNode = jal.xml.get_root_node()
        local cageMeshNode = rNode.get_child 0
        local vertNum = (cageMeshNode.get_attribute "totalVertNum") as Integer
        for i = 0 to (vertNum-1) do (
            local vertNode = cageMeshNode.get_child i
            local lVert = (vertNode.get_attribute "index") as Integer
            local hVert = (vertNode.get_attribute "highMeshVertIndex") as Integer
            local tempArray = #(lVert, hVert)
            append returnArray tempArray
        )
        return returnArray
    )

    fn match_vert_pos inLMesh inHMesh inMatchInfo = (
        toolMode.coordsys #world
        for item in inMatchInfo do (
            local targetPos = polyop.getVert inHMesh item[2] node:inHMesh
            polyop.setVert inLMesh item[1] targetPos node:inLMesh
        )
    )

    fn gen_facialCage = (
        genFCageMesh = undefined
        targetMesh = undefined
        local mergedMeshArray = get_merged_obj facialCageMeshFullName nameArray:#(univFaceMeshName)
        local testMorphMod = Morpher()
        if mergedMeshArray.count == 1 then (
            mergedUnivMesh = mergedMeshArray[1]
            addModifier mergedUnivMesh testMorphMod
            jal.mor.init mergedUnivMesh
        )
        local ePolyMeshArray = for item in selection where classOf item == Editable_Poly collect item
        if ePolyMeshArray.count > 0 then (
            for i = 1 to ePolyMeshArray.count do (
                local result = jal.mor.add_target ePolyMeshArray[i] i
                if result then targetMesh = ePolyMeshArray[i]
            )
        )
        else messageBox "There is no Editable_Poly Object"
        delete mergedUnivMesh
        mergedUnivMesh = undefined

        local vertMatchInfo = load_vertMatchInfo()
        local mergedMeshArray = get_merged_obj facialCageMeshFullName nameArray:#(fCageMeshName)
        local generatedFCageMeshArray = #()
        if mergedMeshArray.count == 1 then (
            mergedFCage = mergedMeshArray[1]
            local tempHMesh = snapshot targetMesh
            local tempCageMesh = snapshot mergedFCage
            convertToPoly tempHMesh
            convertToPoly tempCageMesh
            match_vert_pos tempCageMesh tempHMesh vertMatchInfo
            tempCageMesh.name = tempHMesh.name + "_FCage"
            append generatedFCageMeshArray tempCageMesh
            delete tempHMesh
            delete mergedFCage
            mergedFCage = undefined

            genFCageMesh = generatedFCageMeshArray[1]
        )
    )

    fn merge_rig = (
        skinSourceMesh = undefined

        local rigObjArray = get_merged_obj facialRigFullName nameArray:#()
        local rigObjNameArray = for item in rigObjArray collect item.name
        local rigFCageIndex = findItem rigObjNameArray "Avg_FaceCustom_Cage"
        local rigFCage = rigObjArray[rigFCageIndex]

        local skinSourceIndex = findItem rigObjNameArray skinSourceMeshName
        skinSourceMesh = rigObjArray[skinSourceIndex]

        jal.mor.init rigFCage
        jal.mor.add_target genFCageMesh 1
        jal.mor.set_channel_value_by_index 1 100.0
        delete genFCageMesh
        genFCageMesh = undefined
    )

    fn copy_skin = (
        select targetMesh
        jal.skin.find_skin skinSourceMesh
        jal.skin.get_all_bones skinSourceMesh
        jal.skin.copy_skin skinSourceMesh targetMesh
        delete skinSourceMesh
        skinSourceMesh = undefined
    )

    on genFCageBtn pressed do (
        local selObjArray = getCurrentSelection() as Array
        if selObjArray.count == 1 then (
            local prcStart = timeStamp()
            gen_facialCage()
            merge_rig()
            copy_skin()
            local prcEnd = timeStamp()
            local msg = "Done!\n It takes " + (((prcEnd - prcStart) / 1000.0) as String) + " seconds."
            messageBox msg
        )
    )
)
