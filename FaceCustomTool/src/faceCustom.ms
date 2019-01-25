struct _SoftSelInfo (
    mesh = undefined,
    vertList = #{},
    ssUseEdgeDist = on,
    ssEdgeDist = 15,
    ssFallOff = 2.0
)
struct _FaceCustomRegion (
    name = "",
    matID = 0,
    diffuseColor = (color 128 128 128),
    ssInfo = _SoftSelInfo()
)
struct _FaceCustom (
    univMesh = undefined,
    regionMat = Multimaterial numsubs:1 name:"FaceCustomRegion" names:#("FaceBase") materialList:#(Standard name:"FaceBase"),
    regionArray = #(),
    regionMeshArray = #(),
    scanMeshArray = #(),

    fn reset = (
        univMesh = undefined
        regionMat = Multimaterial numsubs:1 name:"FaceCustomRegion" names:#("FaceBase") materialList:#(Standard name:"FaceBase")
        regionArray = #()
        if regionMeshArray.count > 0 then for item in regionMeshArray do delete item
        regionMeshArray = #()
        scanMeshArray = #()
    ),

    fn set_univMesh inMesh = (
        returnVal = false
        if ((classOf inMesh) == Editable_Poly) or ((classOf inMesh) == Editable_mesh) then (
            univMesh = convertToPoly inMesh

            returnVal = true
        )

        returnVal
    ),

    fn get_regionMat_name = (
        regionMat.name
    ),

    fn sort_multiSubMat_by_id inMat = (
        local returnVal = inMat
        if classof inMat == MultiMaterial then (
            local sorted = false
            while not sorted do (
                sorted = true
                for i = 1 to inMat.numsubs-1 do (
                    if inMat.materialIDList[i] != undefined and inMat.materialIDList[i+1] and inMat.materialIDList[i] > inMat.materialIDList[i+1] do (
                        tmp = inMat.materialList [i]
                        inMat.materialList [i] = inMat.materialList[i+1]
                        inMat.materialList[i+1] = tmp
                        tmp = inMat.materialIDList[i]
                        inMat.materialIDList[i] = inMat.materialIDList[i+1]
                        inMat.materialIDList[i+1] = tmp
                        tmp = inMat.mapEnabled[i]
                        inMat.mapEnabled[i] = inMat.mapEnabled[i+1]
                        inMat.mapEnabled[i+1] = tmp
                        tmp = inMat.names[i]
                        inMat.names[i] = inMat.names[i+1]
                        inMat.names[i+1] = tmp
                        sorted = false
                    )
                )
            )
            returnVal = inMat
        )

        returnVal
    ),

    fn match_names_in_multiSubMat inMat = (
        local returnVal = inMat
        if classof inMat == MultiMaterial then (
            for i = 1 to inMat.numsubs do (
                if returnVal.names[i] != returnVal.materialList[i].name then returnVal.materialList[i].name = returnVal.names[i]
            )
        )

        returnVal
    ),

    fn set_regionMat inMat = (
        local returnVal = false
        if ((classof inMat) == MultiMaterial) and inMat.numsubs > 0 then (
            regionMat = inMat
            returnVal = true
        )

        returnVal
    ),

    fn get_regionMat_in_scene = (
        local returnVal = undefined
        for item in scenematerials do (
            if (classOf item) == Multimaterial and item.name == regionMat.name then (
                returnVal = item
                exit
            )
        )
        returnVal
    ),

    fn get_regionMat_from_mesh inMesh = (
        local returnMat = undefined
        if ((classOf inMesh) == Editable_Poly) and ((classOf inMesh.material) == Multimaterial) then (
            returnMat = inMesh.material
        )
        returnMat
    ),

    fn gen_regionMat = (
        local sceneRegionMat = get_regionMat_in_scene()
        if sceneRegionMat != undefined then regionMat = sceneRegionMat

        regionMat
    ),

    fn gen_regionArray_from_mat inMat = (
        if (classOf inMat) == Multimaterial then (
            regionArray = #()
            regionMat = sort_multiSubMat_by_id inMat
            regionMat = match_names_in_multiSubMat regionMat
            for i = 1 to regionMat.numsubs do (
                local tempRegionMatColor = color 128 128 128
                try (tempRegionMatColor = regionMat.materialList[i].diffuse) catch ()
                local tempRegion = _FaceCustomRegion()
                tempRegion.name = regionMat.materialList[i].name
                tempRegion.matID = i
                tempRegion.diffuseColor = tempRegionMatColor
                append regionArray tempRegion
            )
        )

        regionArray
    ),

    fn apply_regionMat_to_mesh inMesh = (
        local returnVal = false
        if (classOf inMesh) == Editable_Poly then (
            if regionArray.count == 0 then gen_regionArray_from_mat regionMat
            inMesh.material = regionMat

            returnVal = true
        )

        returnVal
    ),

    fn gen_regionMeshArray initPos:[0,0,0] inPosOffset:[0,0,0] = (
        if univMesh != undefined and regionArray.count > 0 then (
            regionMeshArray = #()
            for i = 1 to regionArray.count do (
                local cloneMesh = copy univMesh
                cloneMesh.pos = initPos + ([inPosOffset.x*(i-1), inPosOffset.y*(i-1), inPosOffset.z*(i-1)])
                cloneMesh.name = jal.name.replace_base univMesh.name "Region"
                cloneMesh.name = jal.name.replace_type cloneMesh.name regionArray[i].name
                apply_regionMat_to_mesh cloneMesh
                appendIfUnique regionMeshArray cloneMesh
            )
            if regionMeshArray.count > 0 then jal.layer.create_layer_from_array returnArray "RegionMesh"
        )

        regionMeshArray
    ),

    fn get_region_from_mesh inMesh = (
        local meshRegionMat = get_regionMat_from_mesh inMesh
        if meshRegionMat == undefined then gen_regionMat()
        else regionMat = meshRegionMat

        gen_regionArray_from_mat regionMat

        regionArray
    ),

    fn set_regionName_in_regionMat inMatID inName = (
        local returnVal = false
        if regionMat.materialList[inMatID] != None then (
            regionMat.names[inMatID] = inName
            regionMat.materialList[inMatID].name = inName
            regionArray[inMatID].name = inName
            returnVal = true
        )

        returnVal
    ),

    fn get_regionName_by_matID inMatID = (
        local returnVal = ""
        returnVal = regionArray[inMatID].name
        returnVal
    ),

    fn get_regionMatID_by_name inName = (
        local returnVal = 0
        for item in regionArray do (
            if item.name == inName then (
                returnVal = item.matID
                exit
            )
        )

        returnVal
    ),

    fn get_verts_by_regionName inMesh inName = (
        local returnVal = #{}
        if (classOf inMesh) == Editable_Poly and inMesh.material == regionMat then (
            local regionMatID = get_regionMatID_by_name inName
            if regionMatID > 0 then (
                inMesh.selectByMaterial regionMatID
                local fList = polyop.getFaceSelection inMesh
                returnVal = polyop.getVertsUsingFace inMesh fList
            )
        )

        returnVal
    ),

    fn set_softSel_info_to_mesh inMesh inVerts inFalloff:2.0 inUseEdgeDist:on inEdgeDist:15 = (
        local returnVal = false
        if (classOf inMesh) == Editable_Poly and not(inVerts.isempty) then (
            polyOp.setVertSelection inMesh inVerts
            inMesh.useSoftSel = on
            inMesh.ssUseEdgeDist = inUseEdgeDist
            inMesh.ssEdgeDist = inEdgeDist
            inMesh.falloff = inFalloff

            returnVal = true
        )
        returnVal
    ),

    fn convert_softSel_to_vertexColor inMesh = (
        clearSelection()
        if not polyOp.getVDataChannelSupport inMesh 1 then return false

        local whiteVertList = polyOp.getVertSelection inMesh
        if whiteVertList.isempty then return false

        max modify mode
        select inMesh
        subObjectLevel = 1

        local grayVertList = -whiteVertList
        local grayValueArray = #()
        local grayIndex = 1

        polyOp.defaultMapFaces inMesh 0
        polyOp.setVertColor inMesh 0 whiteVertList white

        for v in grayVertList do (
            local softSelStrength = polyOp.getVDataValue inMesh 1 v
            if softSelStrength == 0 then deleteItem grayVertList v else append grayValueArray softSelStrength
        )

        local blackVertList = -whiteVertList - grayVertList
        polyop.setVertColor inMesh 0 blackVertList black

        for j in grayVertList do (
            polyop.setVertcolor inMesh 0 j (white*(grayValueArray[grayIndex]))
            grayIndex += 1
        )
        subObjectLevel = 0
    ),

    fn get_softSel_info_from_mesh inMesh = (
        local returnVal = _SoftSelInfo()
        if (classOf inMesh) == Editable_Poly and inMesh.useSoftSel == on then (
            returnVal.mesh = inMesh
            returnVal.vertList = polyop.getVertSelection inMesh
            returnVal.ssUseEdgeDist = inMesh.ssUseEdgeDist
            returnVal.ssEdgeDist = inMesh.ssEdgeDist
            returnVal.ssFallOff = inMesh.falloff
        )

        returnVal
    ),

    fn set_region inTargetRegionName inNewRegionName inColor inUseEdgeDist inEdgeDist inFallOff = (
        local returnVal = false
        local targetRegionMatID = get_regionMatID_by_name inTargetRegionName
        if targetRegionMatID > 0 then (
            regionArray[targetRegionMatID].name = inNewRegionName
            regionArray[targetRegionMatID].matID = targetRegionMatID
            regionArray[targetRegionMatID].diffuseColor = inColor
            regionArray[targetRegionMatID].ssInfo.ssUseEdgeDist = inUseEdgeDist
            regionArray[targetRegionMatID].ssInfo.ssEdgeDist = inEdgeDist
            regionArray[targetRegionMatID].ssInfo.ssFallOff = inFalloff

            returnVal = true
        )

        returnVal
    ),

    fn get_region inTargetRegionName = (
        local returnVal = _FaceCustomRegion()
        local targetRegionMatID = get_regionMatID_by_name inTargetRegionName
        if targetRegionMatID > 0 then (
            returnVal.name = regionArray[targetRegionMatID].name
            returnVal.matID = regionArray[targetRegionMatID].matID
            returnVal.diffuseColor = regionArray[targetRegionMatID].diffuseColor
            returnVal.ssInfo = regionArray[targetRegionMatID].ssInfo
        )

        returnVal
    ),

    fn set_regionMesh inTargetRegionName inMesh = (
        local returnVal = false
        local targetRegionMatID = get_regionMatID_by_name inTargetRegionName
        if targetRegionMatID > 0 then (
            if ((classof inMesh) == Editable_Poly) and (inMesh.useSoftSel == on) then (
                regionMeshArray[targetRegionMatID] = inMesh
                apply_regionMat_to_mesh inMesh

                returnVal = true
            )
        )

        returnVal
    ),

    fn get_regionMesh inTargetRegionName = (
        local returnVal = undefined
        local targetRegionMatID = get_regionMatID_by_name inTargetRegionName
        if targetRegionMatID > 0 then returnVal = regionMeshArray[targetRegionMatID]

        returnVal
    ),

    fn set_regionMesh_name inTargetRegionName = (
        local returnVal = false
        local targetRegionMatID = get_regionMatID_by_name inTargetRegionName
        if targetRegionMatID > 0 then (
            if regionMeshArray[targetRegionMatID] != undefined then (
                local meshName = regionMeshArray[targetRegionMatID].name
                meshName = jal.name.replace_base meshName "Region"
                meshName = jal.name.replace_type meshName regionArray[i].name
                jal.layer.create_layer_from_array #(regionMeshArray[targetRegionMatID]) "RegionMesh"

                returnVal = true
            )
        )

        returnVal
    ),

    fn bake_region_to_mesh inMesh inRegionName = (
        local returnVal = false
        local regionMatID = get_regionMatID_by_name inRegionName
        if regionMatID > 0 then (
            local vertList = get_verts_by_regionName inMesh inRegionName
            set_softSel_info_to_mesh inMesh vertList
            convert_softSel_to_vertexColor inMesh

            set_regionInfo inRegionName regionMatID inMesh
            returnVal = true
        )

        returnVal
    ),

    fn update_regionInfo inMesh inRegionName inNewRegionName:"" = (
        local returnVal = false
        if inNewRegionName == "" then inNewRegionName = inRegionName
        local regionMatID = get_regionMatID_by_name inRegionName
        if (regionMatID != 0) and (inMesh.useSoftSel == on) then (
            set_regionInfo inMesh regionMatID inNewRegionName
            convert_softSel_to_vertexColor inMesh

            returnVal = true
        )

        returnVal
    ),

    fn clone_univMesh_to_customTarget inPrefixName inLayerName inFalloff:2.0 initPos:[0,0,0] inPosOffset:[0,0,0] = (
        local returnArray = #()
        for i = 1 to regionArray.count do (
            local cloneMesh = copy univMesh
            cloneMesh.pos = initPos + ([inPosOffset.x*i, inPosOffset.y*i, inPosOffset.z*i])
            cloneMesh.name = jal.name.replace_base univMesh.name inPrefixName
            cloneMesh.name = jal.name.replace_type cloneMesh.name regionArray[i].name
            apply_regionMat_to_mesh cloneMesh
            bake_regionInfo cloneMesh regionArray[i].name inFalloff
            appendIfUnique returnArray cloneMesh
        )
        if returnArray.count > 0 then jal.layer.create_layer_from_array returnArray inLayerName
        regionMeshArray = returnArray

        returnArray
    ),

    fn set_scanMeshArray inArray = (
        scanMeshArray = deepCopy inArray
    ),

    fn apply_volumeSelect inMesh = (
        local targetMesh = convertToPoly inMesh
        local volSelMod = Vol__Select ()
        addModifier targetMesh volSelMod
        volSelMod.level = 1
        volSelMod.volume = 4
        volSelMod.map = 1
        volSelMod.texture = Vertex_Color ()
        volSelMod.method = 0

        targetMesh
    )
)
