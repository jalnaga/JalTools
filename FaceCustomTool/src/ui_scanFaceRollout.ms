rollout scanFaceRollout "Scan Faces" (
    label selScanFaceLbl "0 Mesh Selected" across:2 align:#left enabled:false
    button getScanFaceBtn "Get Scan Face" align:#right enabled:false
    multiListBox scanMeshLst "Scan Face" height:10 enabled:false
    button genCustomMorphTargetBtn "Generate Customizing Morph targets" height:35 enabled:false

    fn enable_scanFaces_ui = (
        selScanFaceLbl.enabled = true
        getScanFaceBtn.enabled = true
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
        )
        else (
            messagebox "There is No Universal Mesh!"
        )
    )

    on genCustomMorphTargetBtn pressed do (
        local testPrefixName = jal.name.get_base regionLst.items[1]
        --testPrefixName = jal.name.replace testPrefixName "Face" ""
        fc.clone_univMesh_to_customTarget testPrefixName inFalloff:2.0 inPosOffset:[5,0,0]
    )
)
