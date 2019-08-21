rollout facialCageGeneratorRollout "Facial Cage Genereator" (
    button addHMeshBtn "Add High polygon Head meshes..." height:30
    MultiListBox addHMeshLst "" height:10
    button genFCageBtn "Make Facial Cages" height:50

    local mergedFCage = undefined
    local mergedUnivMesh = undefined
    local hMeshArray = #()

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

    on addHMeshBtn pressed do (
        hMeshArray = #()
        local excludeObjArray = #()
        local mergedMeshArray = get_merged_obj facialCageMeshFullName nameArray:#(univFaceMeshName)
        local testMorphMod = Morpher()
        if mergedMeshArray.count == 1 then (
            mergedUnivMesh = mergedMeshArray[1]
            addModifier mergedUnivMesh testMorphMod
            jal.mor.init mergedUnivMesh
        )
        else (
            messageBox "Data File Error!\n There is no UnivHead for Merging!!"
            destroydialog jal.tools.facialCageTool
        )

        local ePolyMeshArray = for item in selection where classOf item == Editable_Poly collect item
        if ePolyMeshArray.count > 0 then (
            for i = 1 to ePolyMeshArray.count do (
                local result = jal.mor.add_target ePolyMeshArray[i] i
                if result then append hMeshArray ePolyMeshArray[i]
                else append excludeObjArray ePolyMeshArray[i]
            )
            if hMeshArray.count > 0 then addHMeshLst.items = for item in hMeshArray collect item.name
            if excludeObjArray.count > 0 then (
                local mssgStr = ""
                for item in excludeObjArray do mssgStr += (item.name + "\n")
                mssgStr += "are not added."
                messageBox mssgStr
            )
        )
        else messageBox "There is no Editable_Poly Object"
        delete mergedUnivMesh
        mergedUnivMesh = undefined
    )

    on genFCageBtn pressed do (
        if addHMeshLst.items.count > 0 then (
            local vertMatchInfo = load_vertMatchInfo()
            local mergedMeshArray = get_merged_obj facialCageMeshFullName nameArray:#(fCageMeshName)
            local generatedFCageMeshArray = #()
            if mergedMeshArray.count == 1 then (
                mergedFCage = mergedMeshArray[1]
                for i = 1 to hMeshArray.count do (
                    local tempHMesh = snapshot hMeshArray[i]
                    local tempCageMesh = snapshot mergedFCage
                    convertToPoly tempHMesh
                    convertToPoly tempCageMesh
                    match_vert_pos tempCageMesh tempHMesh vertMatchInfo
                    tempCageMesh.name = tempHMesh.name + "_FCage"
                    append generatedFCageMeshArray tempCageMesh
                    delete tempHMesh
                )
                delete mergedFCage
                mergedFCage = undefined
                select generatedFCageMeshArray
            )
        )
    )
)