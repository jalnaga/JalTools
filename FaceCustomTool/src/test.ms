rollout qwerRollout "Face Custom Tool" (
    button booBtn "Boo!"

    on booBtn pressed do (
        local testMeshArray = jal.layer.get_nodes_by_layername "RegionMesh"
        for i = 1 to testMeshArray.count do (
            clearSelection()
            max create mode
            clearSelection()
            max modify mode
            select testMeshArray[i]
            modPanel.setCurrentObject testMeshArray[i]
            subobjectlevel = 1
        )
    )
)

createDialog qwerRollout
