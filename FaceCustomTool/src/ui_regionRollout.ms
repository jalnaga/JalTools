rollout regionRollout "Region" (
    fn filter_univFaceMesh inObj = classOf inObj == Editable_Poly
    group "Generate Regions" (
        pickButton regionMeshPickBtn "Pick Region Mesh" autoDisplay:true filter:filter_univFaceMesh across:2 align:#left height:35 width:180
        button getRegionMatBtn "Gen\nMaterial" align:#right height:35 width:45
        edittext regionMatTxt "Region Material" across:2 labelOnTop:true readOnly:true align:#left width:180 height:18
        button editRegionMatBtn "Edit" align:#right height:35 width:45 enabled:false offset:[0, 3]
        listbox regionLst "Custom Region" height:14
    )
    button genRegionMeshBtn "Make Region Mesh" across:2 enabled:false align:#left height:30 width:145
    button updateRegionBtn "Update Region" enabled:false align:#right height:30

    fn update_regionList = (
        fc.gen_regionMat()
        fc.gen_regionArray_from_mat fc.regionMat

        regionMatTxt.text = fc.get_regionMat_name()

        regionLst.items = for item in fc.regionArray collect item.name
    )

    fn reset_ui = (
        regionMeshPickBtn.object = none
        regionMeshPickBtn.text = "Pick Region Mesh"
        regionMatTxt.text = ""
        editRegionMatBtn.enabled = false
        regionLst.items = #()
        genRegionMeshBtn.enabled = false
        updateRegionBtn.enabled = false
    )

    fn enable_regionMesh_ui = (
        genRegionMeshBtn.enabled = true
        editRegionMatBtn.enabled = true
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

    on regionRollout open do (
        callbacks.addScript #selectionSetChanged "update_regionList()" id:#jalnameListRolloutUIUpdate
    )

    on regionMeshPickBtn picked pickedObj do (
        fc.set_univMesh pickedObj
    )

    on regionMeshPickBtn rightclick do (
        fc.reset()
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

        regionLst.items = for item in fc.regionArray collect item.name
        if regionLst.items.count > 0 then enable_regionMesh_ui()
    )

    on genRegionMeshBtn pressed do (
        if fc.univMesh != undefined and fc.regionArray.count > 0 then (
            local cloneMeshInitPos = fc.univMesh.pos
            cloneMeshInitPos = cloneMeshInitPos + [-20,0,0]
            fc.gen_regionMeshArray initPos:cloneMeshInitPos inPosOffset:[0,0,20]
        )
    )

    on updateRegionBtn pressed do (
    )
)
