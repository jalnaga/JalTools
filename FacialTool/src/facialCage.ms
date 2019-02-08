struct _FacialCage (
    cageMesh = undefined,
    skinMesh = undefined,
    placerArray = #(),
    boneArray = #(),

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

    fn gen_placer_on_vertex alignToVertexNormal:true = (
        if classOf cageMesh == Editable_Poly then (
            local selMesh = cageMesh.mesh
            local returnPointArray = #()

            for i = 1 to cageMesh.numverts do (
                local vertPos = (getVert selMesh i) * cageMesh.objectTransform
                local helperMatrix = matrix3 [1,0,0] [0,1,0] [0,0,1] vertPos
                if alignToVertexNormal then (
                    local row1 = (getNormal selMesh i) * cageMesh.objectTransform.rotation
                    local row2 = normalize (cross row1 [0,0,-1])
                    local row3 = normalize (cross row1 row2)
                )
                else helperMatrix = matrix3 row1 row2 row3 vertPos

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

                append returnPointArray genPoint
            )

            placerArray = deepCopy returnPointArray
        )
    ),

    fn gen_bone_on_placer = (
        local returnBoneArray = #()
        for item in placerArray do (
            local genBone = jal.bone.create_simple_bone 0.25 (item.name) size:0.2
            genBone[1].transform = item.transform
            jal.anim.rotate_local genBone[1] 90 0 0
            genBone[1].parent = item
            append returnBoneArray genBone[1]
            append returnBoneArray genBone[2]
        )

        boneArray = deepCopy returnBoneArray
    )
)
