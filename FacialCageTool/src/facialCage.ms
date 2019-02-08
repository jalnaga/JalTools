struct _FacialCage (
    cageMesh = undefined,
    skinMesh = undefined,
    placerArray = #(),
    boneArray = #(),
    headBone = #(),
    neckBone = #(),
    jawBone = #(),
    bipHead = undefined,
    bipNeck = undefined,

    fn reset = (
        cageMesh = undefined
        skinMesh = undefined
        placerArray = #()
        boneArray = #()
        headBone = #()
        neckBone = #()
        jawBone = #()
        bipHead = undefined
        bipNeck = undefined
    ),

    fn convert_point3_to_array inP3 = (
        #(inP3.x, inP3.y, inP3.z)
    ),

    fn get_first_item_from_bitArray inBitArray item:0 = (
        for i in inBitArray while Not item > 0 do item = i
        item
    ),

    fn create_skinMesh = (
        if cageMesh != undefined and (classOf cageMesh) == Editable_Poly then skinMesh = copy cageMesh
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

    fn gen_placer_on_vertex alignToVertexNormal:true = (
        local returnPointArray = #()
        if classOf cageMesh == Editable_Poly then (
            local selMesh = cageMesh.mesh

            jal.prog.start_progress "Placer Generating..." useDialog:true
            for i = 1 to cageMesh.numverts do (
                local vertPos = (getVert selMesh i) * cageMesh.objectTransform
                local helperMatrix = matrix3 [1,0,0] [0,1,0] [0,0,1] vertPos
                if alignToVertexNormal then (
                    local row1 = (getNormal selMesh i) * cageMesh.objectTransform.rotation
                    local row2 = normalize (cross row1 [0,0,-1])
                    local row3 = normalize (cross row1 row2)

                    helperMatrix = matrix3 row1 row2 row3 vertPos
                )

                local genPoint = jal.helper.create_point (jal.name.gen_uniqueName "Point") size:0.3
                genPoint.transform = helperMatrix

                local face = get_first_item_from_bitArray (meshop.getFacesUsingVert selMesh i)
                local faceVerts = convert_point3_to_array (getFace selMesh face)
                local attachConst = Attachment node:cageMesh
                attachConst.align = false

                genPoint.position.controller = attachConst
                local key = AttachCtrl.addNewKey attachConst 0
                key.face = face - 1
                key.coord = #([1,0], [0,1], [0,0])[findItem faceVerts i]

                genPoint.rotation.controller = (gen_rot_const i)

                append returnPointArray genPoint
                jal.prog.update_progress i cageMesh.numverts
            )
            jal.prog.end_progress()

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
    ),

    fn set_bipHead inObj = (
        bipHead = inObj
    ),

    fn set_bipNeck inObj = (
        bipNeck = inObj
    ),

    fn gen_headBone = (
        local returnVal = false
        if bipHead != undefined then (
            headBone = jal.bone.create_simple_bone 10 "Head Root 0" end:true size:3
            headBone[1].transform = bipHead.transform
            returnVal = true
        )

        returnVal
    ),

    fn gen_jawBone inStart inEnd = (
        local returnVal = false
        if bipHead != undefined and inStart != undefined and inEnd != undefined then (
            jawBone = jal.bone.create_bone #(inStart, inEnd) "Jaw" end:true size:1 delPoint:false
            returnVal = true
        )
    )
)
