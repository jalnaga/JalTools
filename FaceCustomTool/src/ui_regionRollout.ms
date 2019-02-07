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
