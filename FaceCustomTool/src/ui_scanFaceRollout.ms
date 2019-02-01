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
                local custMorphTargetInitPos = fc.univMesh.pos + [(i-1) * 40,0,0]
                local custPrefixName = jal.name.get_base fc.scanMeshArray[i].name
                local layerName = custPrefixName + "RegionMesh"
                local previousMeshArray = jal.layer.get_nodes_by_layername layerName
                local custMorph = fc.gen_custom_morph_targets fc.scanMeshArray[i] custPrefixName initPos:custMorphTargetInitPos inPosOffset:[0, 0, 20]
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
