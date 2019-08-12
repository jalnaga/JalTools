(
    try(destroydialog jal.tools.faceCustomTool) catch()
    rollout mainRollout "Face Custom Tool" width:300 height:690 (
        SubRollout mainSub "" align:#center height:675
    
        local minWidth = 300
        local minHeight = 690
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        local genMeshOffsetVal = 35
    
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

        local fc = _FaceCustom()
    
        rollout regionRollout "Region" (
            fn filter_univFaceMesh inObj = classOf inObj == Editable_Poly
            group "Generate Regions" (
                pickButton regionMeshPickBtn "Pick Region Mesh" autoDisplay:true filter:filter_univFaceMesh across:2 align:#left height:35 width:180
                button getRegionMatBtn "Gen\nMaterial" align:#right height:35 width:45
                edittext regionMatTxt "Region Material" labelOnTop:true readOnly:true width:235 height:18
            )
            group "Edit Regions" (
                dotNetControl regionNameLv "system.windows.forms.listView" height:150
                button addRegionBtn "Add" across:3 width:55 enabled:false align:#left
                button deleteRegionBtn "Delete" width:55 enabled:false align:#left
                button clearSelectionBtn "Clr." width:25 align:#right enabled:false
            )
            button genRegionMeshBtn "Make Region Mesh" across:2 enabled:false align:#left height:30 width:145
            button bakeRegionBtn "Bake Soft Sel." enabled:false align:#right height:30
        
            local normalfont, boldfont
            local lvColumnNameArray = #("ID", "Name")
            local lvColumnWidthArray = #(40, 170)
            local lvRegionArray = #()
            local editRegionIndex = 0
            local editRegionNameStr = ""
        
            fn init_regionNameLv = (
                regionNameLv.view = (dotNetClass "system.windows.forms.view").details
                regionNameLv.FullRowSelect = true
                regionNameLv.GridLines = true
                regionNameLv.MultiSelect = true
                regionNameLv.CheckBoxes = false
                regionNameLv.hideSelection = false
                regionNameLv.IsAccessible = true
                regionNameLv.LabelEdit = true
        
                for i = 1 to lvColumnNameArray.count do (
                    regionNameLv.columns.add lvColumnNameArray[i] lvColumnWidthArray[i]
                )
            )
        
            fn populate_list = (
                local rows = #()
                for i = 1 to fc.regionArray.count do (
                    local li = dotNetObject "System.Windows.Forms.ListViewItem" (fc.regionArray[i].matID as string)
                    li.UseItemStyleForSubItems=true
                    li.subitems.add fc.regionArray[i].name
                    append rows li
                )
        
                regionNameLv.items.clear()
                regionNameLv.items.addRange rows
                regionNameLv.Update()
            )
        
            fn reset_ui = (
                regionMeshPickBtn.object = none
                regionMeshPickBtn.text = "Pick Region Mesh"
                regionMatTxt.text = ""
                genRegionMeshBtn.enabled = false
                bakeRegionBtn.enabled = false
                regionNameLv.items.clear()
                addRegionBtn.enabled = false
                deleteRegionBtn.enabled = false
                clearSelectionBtn.enabled = false
                fc.reset()
            )
        
            fn enabled_regionEdit_ui = (
                addRegionBtn.enabled = true
                deleteRegionBtn.enabled = true
                clearSelectionBtn.enabled = true
            )
        
            fn disabled_regionEdit_ui = (
                addRegionBtn.enabled = false
                deleteRegionBtn.enabled = false
            )
        
            fn enable_regionMesh_ui = (
                genRegionMeshBtn.enabled = true
                if fc.regionMeshArray.count > 0 then (
                    bakeRegionBtn.enabled = true
                    genRegionMeshBtn.enabled = false
                )
            )
        
            fn update_regionInfo = (
                local sel = regionLst.selection as array
                if sel.count > 0 then (
                    local newRegionName = ""
                    for i = 1 to sel.count do (
                        local targetRegionName = fc.get_regionName_by_matID sel[i]
                        local regionColor = fc.regionArray[sel[i]].diffuseColor
                        local regionMesh = fc.regionMesh[sel[i]]
                        local vertList = #{}
        
                        if sel.count == 1 then newRegionName = regionNameTxt.text else newRegionName = targetRegionName
                        fc.set_region targetRegionName newRegionName regionColor edgeDistCkb.checked edgeDistSpn.value falloffSpn.value
        
                        if (isValidNode regionMesh) then (
                            vertList = (fc.get_softSel_info_from_mesh regionMesh).vertList
                        )
                        else (
                            regionMesh = copy fc.univMesh
                            fc.set_regionMesh newRegionName regionMesh
                        )
                        fc.set_regionMesh_name newRegionName
                        fc.set_softSel_info_to_mesh regionMesh vertList inFalloff:falloffSpn.value inUseEdgeDist:edgeDistCkb.checked inEdgeDist:edgeDistSpn.value
                    )
                )
            )
        
            rollout editRegionNameRollout "Region Name" (
                edittext editRegionNameTxt ""
                button cancelBtn "Cancel" across:2
                button okBtn "OK"
        
                on editRegionNameRollout open do (
                    editRegionNameTxt.text = editRegionNameStr
                )
        
                on cancelBtn pressed do (
                    destroydialog editRegionNameRollout
                )
        
                on okBtn pressed do (
                    fc.set_regionName_in_regionMat editRegionNameStr editRegionNameTxt.text
                    destroydialog editRegionNameRollout
                )
        
                on editRegionNameRollout close do (
                    editRegionIndex = 0
                    editRegionNameStr = ""
        
                    populate_list()
                )
            )
        
            rollout addRegionRollout "Add Region" width:230 (
                dropdownlist matIDDrp "ID:" items:#() across:3 align:#left offset:[0, 0] width:50
                editText addRegionNameTxt "Region:" labelOnTop:true width:100 offset:[-10, 2]
                colorpicker addRegionColor "" align:#right offset:[0, 18]
                button cancelBtn "Cancel" across:2 offset:[0, 5]
                button okBtn "OK" offset:[0, 5]
        
                on addRegionRollout open do (
                    local maxMatID = fc.get_max_matID()
                    local validMatIDArray = #()
                    if maxMatID > 0 then (
                        for i = 1 to maxMatID do (
                            local matIDIndex = fc.get_index_from_regionArray_by_matID i
                            if matIDIndex == 0 then append validMatIDArray (i as String)
                        )
                        append validMatIDArray ((maxMatID + 1) as String)
                        matIDDrp.items = validMatIDArray
                        addRegionColor.color = color (random 0 255) (random 0 255) (random 0 255)
                    )
                )
        
                on cancelBtn pressed do (
                    destroydialog addRegionRollout
                )
        
                on okBtn pressed do (
                    local selMatID = execute (matIDDrp.items[matIDDrp.selection])
                    if addRegionNameTxt.text == "" then (
                        messageBox "Put New Region Name!"
                    )
                    else (
                        if (fc.add_region addRegionNameTxt.text selMatID inColor:addRegionColor.color) == false then (
                            messageBox "New Region Name already exists!"
                        )
                        else destroydialog addRegionRollout
                    )
                )
        
                on addRegionRollout close do (
                    populate_list()
                )
            )
        
            on regionRollout open do (
                init_regionNameLv()
            )
        
            on regionMeshPickBtn picked pickedObj do (
                fc.set_univMesh pickedObj
                if fc.univMesh != undefined and fc.regionArray.count > 0 then enable_regionMesh_ui()
            )
        
            on regionMeshPickBtn rightclick do (
                reset_ui()
            )
        
            on getRegionMatBtn pressed do (
                fc.gen_regionMat()
                if fc.univMesh != undefined then (
                    local meshRegionMat = fc.get_regionMat_from_mesh fc.univMesh
                    fc.set_regionMat meshRegionMat
                )
                fc.gen_regionArray_from_mat fc.regionMat
                fc.apply_regionMat_to_mesh fc.univMesh
        
                regionMatTxt.text = fc.get_regionMat_name()
        
                local lvRegionArray = for item in fc.regionArray collect item
                if lvRegionArray.count > 0 then (
                    populate_list()
                    enabled_regionEdit_ui()
                    if fc.univMesh != undefined then enable_regionMesh_ui()
                )
            )
        
            on getRegionMatBtn rightclick do (
                reset_ui()
            )
        
            on regionNameLv MouseDoubleClick arg do (
                if addRegionBtn.enabled and deleteRegionBtn.enabled then (
                    local theItem = regionNameLv.GetItemAt arg.x arg.y
                    local theSubItem = (theItem.GetSubItemAt arg.x arg.y)
                    editRegionNameStr = theSubItem.text
                    editRegionIndex = theItem.index
        
                    createDialog editRegionNameRollout modal:true
                )
            )
        
            on addRegionBtn pressed do (
                createDialog addRegionRollout modal:true
            )
        
            on deleteRegionBtn pressed do (
                for i = 1 to regionNameLv.SelectedItems.count do (
                    local targetRegionName = regionNameLv.SelectedItems.item[i-1].SubItems.item[1].text
                    fc.delete_region targetRegionName
                )
                populate_list()
            )
        
            on clearSelectionBtn pressed do (
                regionNameLv.SelectedItems.Clear()
            )
        
            on genRegionMeshBtn pressed do (
                if fc.univMesh != undefined and fc.regionArray.count > 0 then (
                    local percentage = 0.0
                    local replaceArray = (for i = 1 to fc.regionArray.count collect true)
                    local meshInLayerArray = jal.layer.get_nodes_by_layername "RegionMesh"
                    local delRegionMeshArray = #()
                    local cloneMeshInitPos = fc.univMesh.pos
                    cloneMeshInitPos = cloneMeshInitPos + [0,0,genMeshOffsetVal]
        
                    for i = 1 to fc.regionArray.count do (
                        for k = 1 to meshInLayerArray.count do (
                            if (jal.name.get_base meshInLayerArray[k].name) == "Univ" and (jal.name.get_type meshInLayerArray[k].name) == "Reg" and (jal.name.get_index_as_digit meshInLayerArray[k].name) == 0 then (
                                local meshRegionName = jal.name.get_realName meshInLayerArray[k].name
                                if meshRegionName == fc.regionArray[i].name then (
                                    if (queryBox ("Replace existing \" " + fc.regionArray[i].name + " \" Mesh?")) then (
                                        replaceArray[i] = true
                                        append delRegionMeshArray meshInLayerArray[k]
                                    )
                                    else (
                                        replaceArray[i] = false
                                        fc.regionMeshArray[i] = meshInLayerArray[k]
                                    )
                                )
                            )
                        )
                    )
                    for item in delRegionMeshArray do delete item
                    delRegionMeshArray = #()
        
                    disableSceneRedraw()
                    progressStart "Generating Custom Mesh..."
                    for i = 1 to fc.regionArray.count do (
                        if replaceArray[i] then (
                            local cloneMesh = fc.gen_regionMesh fc.regionArray[i].name initPos:cloneMeshInitPos inPosOffset:[0,0, (i-1) * genMeshOffsetVal]
                            fc.apply_regionMat_to_mesh cloneMesh
                            fc.regionMeshArray[i] = cloneMesh
                        )
                        percentage = (i as float) / (fc.scanMeshArray.count as float) * 100.0
                        progressUpdate percentage
                    )
                    progressEnd()
                    enableSceneRedraw()
                    redrawViews()
        
                    if fc.regionMeshArray.count > 0 then (
                        jal.layer.create_layer_from_array fc.regionMeshArray "RegionMesh"
                        disabled_regionEdit_ui()
                        enable_regionMesh_ui()
                    )
                )
            )
        
            on bakeRegionBtn pressed do (
                clearSelection()
                max create mode
                clearSelection()
                disableSceneRedraw()
                progressStart "Baking Region info..."
                local percentage = 1.0
                if regionNameLv.SelectedItems.count == 0 then (
                    for i = 1 to fc.regionArray.count do (
                        clearSelection()
                        select fc.regionMeshArray[i]
                        max modify mode
                        modPanel.setCurrentObject $.baseObject ui:true
                        subobjectlevel = 1
        
                        fc.bake_region_to_mesh fc.regionMeshArray[i] fc.regionArray[i].name
        
                        percentage = (i as float) / (fc.regionArray.count as float) * 100.0
                        progressUpdate percentage
                    )
                )
                else (
                    for i = 1 to regionNameLv.SelectedItems.count do (
                        local targetRegionName = regionNameLv.SelectedItems.item[i-1].SubItems.item[1].text
                        local targetIndex = fc.get_index_from_regionArray_by_name targetRegionName
        
                        clearSelection()
                        select fc.regionMeshArray[targetIndex]
                        max modify mode
                        modPanel.setCurrentObject $.baseObject ui:true
                        subobjectlevel = 1
        
                        fc.bake_region_to_mesh fc.regionMeshArray[targetIndex] targetRegionName
        
                        percentage = (i as float) / (regionNameLv.SelectedItems.count as float) * 100.0
                        progressUpdate percentage
                    )
                )
                progressEnd()
                enableSceneRedraw()
                redrawViews()
                populate_list()
            )
        )

        rollout scanFaceRollout "Scan Faces" (
            label selScanFaceLbl "0 Mesh Selected" across:2 align:#left enabled:false
            button getScanFaceBtn "Get Scan Face" align:#right
            multiListBox scanMeshLst "Scan Face" height:10 enabled:false
            button genCustomMorphTargetBtn "Generate Customizing Morph targets" height:35 enabled:false
        
            fn enable_scanFaces_ui = (
                selScanFaceLbl.enabled = true
                scanMeshLst.enabled = true
                genCustomMorphTargetBtn.enabled = true
            )
        
            on getScanFaceBtn pressed do (
                local validScanMeshArray = #()
                local scanMeshArray = getCurrentSelection() as array
                if fc.univMesh != undefined then (
                    for i = 1 to scanMeshArray.count do (
                        if (polyOp.GetNumVerts scanMeshArray[i]) == (polyOp.GetNumVerts fc.univMesh) then (
                            appendIfUnique validScanMeshArray scanMeshArray[i]
                        )
                    )
                    scanMeshLst.items = for item in validScanMeshArray collect item.name
                    fc.set_scanMeshArray validScanMeshArray
                    selScanFaceLbl.text = (validScanMeshArray.count as string) + " Mesh Selected"
        
                    enable_scanFaces_ui()
                )
                else (
                    messagebox "There is No Universal Mesh!"
                )
            )
        
            on genCustomMorphTargetBtn pressed do (
                if fc.univMesh != undefined and fc.regionMeshArray.count == fc.regionArray.count and fc.scanMeshArray.count > 0 then (
                    clearSelection()
                    disableSceneRedraw()
                    progressStart "Generating Custom Mesh..."
                    fc.customMorphTargetArray = #()
                    local percentage = 0.0
                    for i = 1 to fc.scanMeshArray.count do (
                        local custMorphTargetInitPos = fc.scanMeshArray[i].pos + [0,0,genMeshOffsetVal]
                        local custPrefixName = jal.name.get_base fc.scanMeshArray[i].name
                        local layerName = custPrefixName + "RegionMesh"
                        local previousMeshArray = jal.layer.get_nodes_by_layername layerName
                        local custMorph = fc.gen_custom_morph_targets fc.scanMeshArray[i] custPrefixName initPos:custMorphTargetInitPos inPosOffset:[0, 0, genMeshOffsetVal]
                        if custMorph != undefined then (
                            for item in previousMeshArray do delete item
                            previousMeshArray = #()
                            append fc.customMorphTargetArray custMorph
                            jal.layer.create_layer_from_array custMorph.regionMeshArray layerName
                        )
                        percentage = (i as float) / (fc.scanMeshArray.count as float) * 100.0
                        progressUpdate percentage
                    )
                    progressEnd()
                    enableSceneRedraw()
                    redrawViews()
                )
            )
        )

    
        on mainRollout open do
        (
            AddSubRollout mainSub regionRollout
            AddSubRollout mainSub scanFaceRollout
        )
    
        on mainRollout resized newSize do
        (
            if newSize[1] > minWidth then
            mainSub.width = newSize[1] - subRollWidthOffset
            else (
                mainRollout.width = minWidth
                mainSub.width = minWidth - subRollWidthOffset
            )
            if newSize[2] > minHeight then mainSub.height = newSize[2] - subRollHeightOffset
            else (
                mainRollout.height = minHeight
                mainSub.height = minHeight - subRollHeightOffset
            )
    
            jal.roll.update_subroll_when_resized mainSub regionRollout
            jal.roll.update_subroll_when_resized mainSub scanFaceRollout
        )
    )
    jal.tools.faceCustomTool = mainRollout
    createDialog jal.tools.faceCustomTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_maximizebox)

    clearlistener()
    gc()
)
