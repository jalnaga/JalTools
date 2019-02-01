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
struct _CustomMorphTarget (
    baseName = "",
    scanMesh = undefined,
    regionMeshArray = #()
)
struct _FaceCustom (
    univMesh = undefined,
    regionMat = Multimaterial numsubs:1 name:"FaceCustomRegion" names:#("FaceBase") materialList:#(Standard name:"FaceBase"),
    regionArray = #(),
    regionMeshArray = #(),
    scanMeshArray = #(),
    customMorphTargetArray = #(),

    fn reset = (
        univMesh = undefined
        regionMat = Multimaterial numsubs:1 name:"FaceCustomRegion" names:#("FaceBase") materialList:#(Standard name:"FaceBase")
        regionArray = #()
        if regionMeshArray.count > 0 then for item in regionMeshArray do delete item
        regionMeshArray = #()
        scanMeshArray = #()
        customMorphTargetArray = #()
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
            struct s_Mat (id, name, material, mapEnabled)
            local mats = for i = 1 to returnVal.numSubs where returnVal.materialIDList[i] != undefined collect s_Mat returnVal.materialIDList[i] returnVal.names[i] returnVal.materialList[i] returnVal.mapEnabled[i]
            fn sortFN s1 s2 = (
                if s1.id > s2.id then 1
                else if s1.id < s2.id then -1
                else 0
            )
            qsort mats sortFN

            returnVal.numSubs = mats.count
            returnVal.materialIDList = for i in mats collect i.id
            returnVal.names = for i in mats collect i.name
            returnVal.materialList = for i in mats collect i.material
            returnVal.mapEnabled = for i in mats collect i.mapEnabled
            returnVal.numSubs = mats.count
        )

        returnVal
    ),

    fn match_names_in_multiSubMat inMat = (
        local returnVal = inMat
        if classof inMat == MultiMaterial then (
            for i = 1 to returnVal.materialList.count do (
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
            for i = 1 to regionMat.materialList.count do (
                local tempRegionMatColor = color 128 128 128
                try (tempRegionMatColor = regionMat.materialList[i].diffuse) catch ()
                local tempRegion = _FaceCustomRegion()
                tempRegion.name = regionMat.materialList[i].name
                tempRegion.matID = regionMat.materialIDList[i]
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

    fn get_region_from_mesh inMesh = (
        local meshRegionMat = get_regionMat_from_mesh inMesh
        if meshRegionMat == undefined then gen_regionMat()
        else regionMat = meshRegionMat

        gen_regionArray_from_mat regionMat

        regionArray
    ),

    fn get_regionName_by_matID inMatID = (
        local returnVal = ""
        for item in regionArray do (
            if item.matID == inMatID then (
                returnVal = item.name
                exit
            )
        )
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

    fn get_index_from_regionArray_by_matID inMatID = (
        local returnVal = 0
        for i = 1 to regionArray.count do (
            if regionArray[i].matID == inMatID then (
                returnVal = i
                exit
            )
        )
        returnVal
    ),

    fn get_index_from_regionArray_by_name inName = (
        local returnVal = 0
        for i = 1 to regionArray.count do (
            if regionArray[i].name == inName then (
                returnVal = i
                exit
            )
        )
        returnVal
    ),

    fn set_regionName_in_regionMat inTargetName inNewName = (
        local returnVal = false
        local matIndex = get_index_from_regionArray_by_name inTargetName
        if regionMat.materialList[matIndex] != undefined then (
            regionMat.names[matIndex] = inNewName
            regionMat.materialList[matIndex].name = inNewName
            regionArray[matIndex].name = inNewName
            returnVal = true
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
        local targetMesh = inMesh

        if not polyOp.getVDataChannelSupport targetMesh 1 then return false

        local whiteVertList = polyOp.getVertSelection targetMesh
        if whiteVertList.isempty then return false

        local grayVertList = -whiteVertList
        local grayValueArray = #()
        local grayIndex = 1

        polyOp.defaultMapFaces targetMesh 0
        polyOp.setVertColor targetMesh 0 whiteVertList white

        for v in grayVertList do (
            local softSelStrength = polyOp.getVDataValue targetMesh 1 v
            if softSelStrength == 0 then deleteItem grayVertList v else append grayValueArray softSelStrength
        )

        local blackVertList = -whiteVertList - grayVertList
        polyop.setVertColor targetMesh 0 blackVertList black

        for j in grayVertList do (
            polyop.setVertcolor targetMesh 0 j (white*(grayValueArray[grayIndex]))
            grayIndex += 1
        )
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

    fn gen_regionMesh inRegionName initPos:[0,0,0] inPosOffset:[0,0,0] = (
        local returnVal = undefined
        if univMesh != undefined and regionArray.count > 0 then (
            local regionIndex = get_index_from_regionArray_by_name inRegionName
            if regionIndex > 0 then (
                maxOps.CloneNodes univMesh newNodes:&cloneMeshArray
                local cloneMesh = cloneMeshArray[1]
                cloneMesh.pos = initPos + inPosOffset
                cloneMesh.name = jal.name.replace_base univMesh.name "Univ"
                cloneMesh.name = jal.name.replace_type cloneMesh.name "Reg"
                cloneMesh.name = jal.name.replace_realName cloneMesh.name regionArray[regionIndex].name
                cloneMesh.name = jal.name.replace_index cloneMesh.name "0"
                apply_regionMat_to_mesh cloneMesh
                local vertList = get_verts_by_regionName cloneMesh regionArray[regionIndex].name
                set_softSel_info_to_mesh cloneMesh vertList inFalloff:2.0 inUseEdgeDist:on inEdgeDist:15
                local selInfo = get_softSel_info_from_mesh cloneMesh
                regionArray[regionIndex].ssInfo = selInfo

                returnVal = cloneMesh
            )
        )

        returnVal
    ),

    fn gen_regionMeshArray initPos:[0,0,0] inPosOffset:[0,0,0] = (
        if univMesh != undefined and regionArray.count > 0 then (
            regionMeshArray = #()
            for i = 1 to regionArray.count do (
                gen_regionMesh regionArray[i].name initPos:initPos inPosOffset:[inPosOffset.x * (i-1), inPosOffset.y * (i-1), inPosOffset.z * (i-1)]
                appendIfUnique regionMeshArray cloneMesh
            )

            if regionMeshArray.count > 0 then jal.layer.create_layer_from_array regionMeshArray "RegionMesh"
        )

        regionMeshArray
    ),

    fn set_region inTargetRegionName inNewRegionName inColor inFallOff inUseEdgeDist inEdgeDist = (
        local returnVal = false
        local targetIndex = get_index_from_regionArray_by_name inTargetRegionName
        if targetIndex > 0 then (
            regionArray[targetIndex].name = inNewRegionName
            regionArray[targetIndex].diffuseColor = inColor
            regionArray[targetIndex].ssInfo.ssUseEdgeDist = inUseEdgeDist
            regionArray[targetIndex].ssInfo.ssEdgeDist = inEdgeDist
            regionArray[targetIndex].ssInfo.ssFallOff = inFalloff

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

    fn add_region inName inMatID inColor:(color 128 128 128) inFallOff:2.0 inUseEdgeDist:on inEdgeDist:15 = (
        local returnVal = false
        local duplicatedNameIndex = get_index_from_regionArray_by_name inName
        local duplicatedMatIDIndex = get_index_from_regionArray_by_matID inMatID
        if duplicatedNameIndex == 0 and duplicatedMatIDIndex == 0 and regionArray.count > 0 then (
            struct s_Mat (id, name, material, mapEnabled)
            local mats = for i = 1 to regionMat.materialList.count collect s_Mat regionMat.materialIDList[i] regionMat.names[i] regionMat.materialList[i] regionMat.mapEnabled[i]

            local addedRegionMat = Standardmaterial name:inName diffuse:inColor
            append mats (s_Mat inMatID inName addedRegionMat true)

            regionMat.materialIDList = for i in mats collect i.id
            regionMat.names = for i in mats collect i.name
            regionMat.materialList = for i in mats collect i.material
            regionMat.mapEnabled = for i in mats collect i.mapEnabled

            gen_regionArray_from_mat regionMat

            returnVal = true
        )
        returnVal
    ),

    fn delete_region inName = (
        local returnVal = false
        local targetIndex = get_index_from_regionArray_by_name inName
        if targetIndex > 0 then (
            struct s_Mat (id, name, material, mapEnabled)
            local mats = #()
            for i = 1 to regionMat.materialList.count do (
                if i != targetIndex then (
                    local subMat = s_Mat regionMat.materialIDList[i] regionMat.names[i] regionMat.materialList[i] regionMat.mapEnabled[i]
                    append mats subMat
                )
            )
            regionMat.materialList = for item in mats collect item.material
            regionMat.materialIDList = for item in mats collect item.id
            regionMat.names = for item in mats collect item.name

            gen_regionArray_from_mat regionMat

            returnVal = true
        )

        returnVal
    ),

    fn get_max_matID = (
        local returnVal = 0
        if regionArray.count > 0 then (
            local lastIndex = regionArray.count
            local maxMatID = regionArray[lastIndex].matID
            if maxMatID > 0 then returnVal = regionArray[lastIndex].matID
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

            returnVal = true
        )

        returnVal
    ),

    fn update_regionInfo inMesh inRegionName inNewRegionName:"" = (
        local returnVal = false
        if inNewRegionName == "" then inNewRegionName = inRegionName
        local regionMatID = get_regionMatID_by_name inRegionName
        if (regionMatID != 0) and (inMesh.useSoftSel == on) then (
            convert_softSel_to_vertexColor inMesh

            returnVal = true
        )

        returnVal
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
    ),

    fn gen_custom_morph_targets inMesh inName initPos:[0,0,0] inPosOffset:[0,0,0] = (
        local returnVal = undefined
        if univMesh != undefined and regionArray.count > 0 then (
            local custMorph = _CustomMorphTarget()
            custMorph.scanMesh = inMesh
            custMorph.baseName = inName
            for i = 1 to regionMeshArray.count do (
                local custMorphCloneMesh = copy regionMeshArray[i]
                local morphMod = Morpher()
                custMorphCloneMesh.pos = initPos + [inPosOffset.x*(i-1), inPosOffset.y*(i-1), inPosOffset.z*(i-1)]
                custMorphCloneMesh.name = jal.name.replace_base regionMeshArray[i].name inName
                custMorphCloneMesh = apply_volumeSelect custMorphCloneMesh
                morphMod.Autoload_of_targets = 1
                addModifier custMorphCloneMesh morphMod
                WM3_MC_BuildFromNode morphMod 1 inMesh
                WM3_MC_SetValue morphMod 1 100.0
                custMorph.regionMeshArray[i] = custMorphCloneMesh
            )
            returnVal = custMorph
        )

        returnVal
    )
)
