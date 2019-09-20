rollout cageGenRollout "Template - Cage Generator" (
    fn pickFilter inObj = classOf inObj == Editable_Poly
    pickButton scanMeshPickBtn "Pick Scanned mesh" enabled:true width:130 height:30 filter:pickFilter autoDisplay:true
    pickButton oriNeutralBtn "Pick Original FCage" height:30 autoDisplay:true filter:pickFilter enabled:false

    button genCageBtn "Generate Cage" height:25 offset:[0, 5] enabled:false

    local univMesh = undefined
    local oriFCageMesh = undefined

    fn load_vertMatchInfo = (
        local returnArray = #()
        jal.xml.load_file vertMatchXml
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
        local returnVal = undefined
        local vertMatchInfo = load_vertMatchInfo()
        local tempHMesh = snapshot univMesh
        local tempCageMesh = snapshot oriFCageMesh
        convertToPoly tempHMesh
        convertToPoly tempCageMesh
        match_vert_pos tempCageMesh tempHMesh vertMatchInfo
        tempCageMesh.name = tempHMesh.name + "_Cage"
        delete tempHMesh
        returnVal = tempCageMesh
        return returnVal
    )

    fn update_ui = (
        if univMesh == undefined then (
            oriNeutralBtn.enabled = false
            genCageBtn.enabled = false
        )
        else oriNeutralBtn.enabled = true

        if oriFCageMesh == undefined then (
            genCageBtn.enabled = false
        )
        else genCageBtn.enabled = true
    )

    on scanMeshPickBtn picked pickedObj do (
        univMesh = pickedObj
        update_ui()
    )

    on scanMeshPickBtn rightclick do (
        univMesh = undefined
        scanMeshPickBtn.object = undefined
        update_ui()
    )

    on oriNeutralBtn picked pickedObj do (
        oriFCageMesh = pickedObj
        update_ui()
    )

    on oriNeutralBtn rightclick do (
        oriFCageMesh = undefined
        oriNeutralBtn.object = undefined
        update_ui()
    )

    on genCageBtn pressed do (
        gen_facialCage()
    )
)
