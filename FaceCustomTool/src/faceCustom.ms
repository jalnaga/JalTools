struct _FaceCustom (
    univMesh = undefined,
    regionNameArray = #(),
    regionMatArray = #(),
    scanMeshArray = #(),

    fn set_univMesh inMesh = (
        returnVal = false
        if (classOf inMesh) == Editable_mesh or (classOf inMesh) == Editable_Poly then (
            univMesh = convertToPoly inMesh
            returnVal = true
        )

        returnVal
    ),

    fn set_region inReionNameArray = (
        regionNameArray = deepCopy inReionNameArray
        local currentRegionMatArray = #()
        local currentRegionMatNameArray = #()
        for item in scenematerials do (
            if (findItem regionNameArray item.name) != 0 then (
                append currentRegionMatArray item
                append currentRegionMatNameArray item.name
            )
        )
        format "Mat:%\n" currentRegionMatArray
        format "Name:%\n" currentRegionMatNameArray
    ),

    fn get_verts_by_mat inMesh inMat = (
        local returnVal = #()
        if (classOf inMesh) == Editable_Poly then (
            local totalVertNum = polyop.getNumVerts inMesh
        )
    )
)
