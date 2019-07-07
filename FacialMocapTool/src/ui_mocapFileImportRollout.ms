rollout mocapFileImportRollout "Mocap File Load" (
    button loadBtn "Load Mocap XML"
    button assignMocapBtn "Assign Key"

    on loadBtn pressed do (
        local openFileName = getOpenFileName caption:"Load Mocap XML:" types:"XML (*.xml)|*.xml"
        if openFileName != undefined then (
            xDoc.load_file openFileName
            fmc.gen_rigController()
        )
    )

    on assignMocapBtn pressed do (
        local rNode = xDoc.get_root_node()
        local rangeNode = rNode.get_child 0
        local frameNode = rangeNode.get_child 0
        fmc.assign_frame_to_control frameNode
    )
)
