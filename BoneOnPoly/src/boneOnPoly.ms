struct _BoneOnPoly (
    cageMesh = undefined,
    placerArray = #(),
    boneArray = #(),

    fn reset = (
        cageMesh = undefined
        placerArray = #()
        boneArray = #()
    ),

    fn convert_point3_to_array inP3 = (
        #(inP3.x, inP3.y, inP3.z)
    ),

    fn get_first_item_from_bitArray inBitArray item:0 = (
        for i in inBitArray while Not item > 0 do item = i
        item
    ),

    fn gen_rot_const inVertIndex = (
        local rotConst = rotation_script()
        local scriptStr = ""
        rotConst.AddNode "cageMesh" cageMesh
        rotConst.AddConstant "vertIndex" inVertIndex
        scriptStr += "local selMesh = cageMesh.mesh\n"
        scriptStr += "local vertPos = (getVert selMesh vertIndex) * cageMesh.objectTransform\n"
        scriptStr += "local helperMatrix = matrix3 [1,0,0] [0,1,0] [0,0,1] vertPos\n"
        scriptStr += "local row1 = (getNormal selMesh vertIndex) * cageMesh.objectTransform.rotation\n"
        scriptStr += "local row2 = normalize (cross row1 [0,0,-1])\n"
        scriptStr += "local row3 = normalize (cross row1 row2)\n"
        scriptStr += "helperMatrix = matrix3 row1 row2 row3 vertPos\n"
        scriptStr += "helperMatrix.rotationpart\n"
        rotConst.script = scriptStr

        rotConst
    ),

    fn get_filtered_vertex_by_vertexColor inFilterColor inChannel:0 = (
        local returnVal = #()
        if (classOf cageMesh) == Editable_Poly or (classOf cageMesh) == PolyMeshObject then (
            local balckVertArray = polyop.getVertsByColor cageMesh inFilterColor 0 0 0 channel:inChannel
            balckVertArray = -balckVertArray
            returnVal = for vertIndex in balckVertArray where vertIndex == true collect vertIndex
        )
        returnVal
    ),

    fn get_filtered_vertex_by_vertexSelection = (
        local returnVal = #()
        if (classOf cageMesh) == Editable_Poly or (classOf cageMesh) == PolyMeshObject then (
            local selVertBitArray = polyop.getVertSelection cageMesh
            returnVal = for vertIndex in selVertBitArray where vertIndex == true collect vertIndex
        )
        returnVal
    ),

    fn gen_placer_on_vertex inVertSel alignToNormal:true = (
        local returnPointArray = #()
        if superClassOf cageMesh == GeometryClass then (
            local selMesh = cageMesh.mesh

            for vertIndex in inVertSel do (
                local vertPos = (getVert selMesh vertIndex) * cageMesh.objectTransform
                local helperMatrix = matrix3 [1,0,0] [0,1,0] [0,0,1] vertPos
                if alignToNormal then (
                    local row1 = (getNormal selMesh vertIndex) * cageMesh.objectTransform.rotation
                    local row2 = normalize (cross row1 [0,0,-1])
                    local row3 = normalize (cross row1 row2)

                    helperMatrix = matrix3 row1 row2 row3 vertPos
                )
                local genPoint = jal.helper.create_point (jal.name.gen_uniqueName "Point") size:0.3
                genPoint.transform = helperMatrix
                append returnPointArray genPoint
            )

            placerArray = deepCopy returnPointArray
        )
        returnPointArray
    ),

    fn attach_controller_to_helper inHelperArray inVertSel addRotConst:false = (
        local returnVal = false
        if superClassOf cageMesh == GeometryClass then (
            if inHelperArray.count == inVertSel.count then (
                local selMesh = cageMesh.mesh
                for i = 1 to inHelperArray.count do (
                    local face = get_first_item_from_bitArray (meshop.getFacesUsingVert selMesh inVertSel[i])
                    local faceVerts = convert_point3_to_array (getFace selMesh face)
                    local attachConst = Attachment node:cageMesh
                    attachConst.align = false

                    inHelperArray[i].position.controller = attachConst
                    local key = AttachCtrl.addNewKey attachConst 0
                    key.face = face - 1
                    key.coord = #([1,0], [0,1], [0,0])[findItem faceVerts inVertSel[i]]

                    if addRotConst then inHelperArray[i].rotation.controller = gen_rot_const inVertSel[i]
                    returnVal = true
                )
            )
        )
        returnVal
    ),

    fn gen_placer_on_face alignToNormal:true = (
        local returnPointArray = #()
        if superClassOf cageMesh == GeometryClass then (
            --local selMesh = cageMesh.mesh
            local selMesh = cageMesh
            local faceNum = getNumFaces selMesh

            --jal.prog.start_progress "Placer Generating..." useDialog:true
            local facesArray = for val = 1 to faceNum collect val
            while facesArray.count != 0 do (
                local faceArray = #(facesArray[1])
                local polyBitArray = meshop.getPolysUsingFace selMesh faceArray
                local vertBitArray = meshop.getVertsUsingFace selMesh polyBitArray
                setVertSelection selMesh vertBitArray
                local selCenterPos = AverageSelVertCenter selMesh
                local polyCenterPos = selCenterPos * cageMesh.objectTransform
                setVertSelection selMesh #()
                local genPoint = jal.helper.create_point (jal.name.gen_uniqueName "Point") size:0.3
                genPoint.pos = polyCenterPos

                append returnPointArray genPoint
                facesArray = ((facesArray as bitarray)-polyBitArray) as array
                --jal.prog.update_progress (faceNum - facesArray.count) faceNum
            )
            --jal.prog.end_progress()

            placerArray = deepCopy returnPointArray
        )
        returnPointArray
    ),

    fn gen_bone_on_placer = (
        local returnBoneArray = #()
        jal.prog.start_progress "Bone Generating..." useDialog:true
        for i = 1 to placerArray.count do (
            local genBone = jal.bone.create_simple_bone 0.25 (placerArray[i].name) size:0.2
            genBone[1].transform = placerArray[i].transform
            jal.anim.rotate_local genBone[1] 90 0 0
            genBone[1].parent = placerArray[i]
            append returnBoneArray genBone[1]
            append returnBoneArray genBone[2]

            jal.prog.update_progress i placerArray.count
        )
        jal.prog.end_progress()

        boneArray = deepCopy returnBoneArray
        returnBoneArray
    )
)
