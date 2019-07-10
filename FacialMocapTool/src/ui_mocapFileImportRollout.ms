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
        for item in fmc.allRigControllerArray do (
            if item.xController != undefined then deleteKeys item.xController #allKeys
            if item.yController != undefined then deleteKeys item.yController #allKeys
        )

        local rNode = xDoc.get_root_node()
        local rangeNode = rNode.get_child 0
        local frameNum = (rangeNode.get_children()).count
        jal.prog.start_progress "Assign Keys..." totalStep:1 useDialog:false
        with animate on (
            for i = 0 to (frameNum - 1) do (
                at time i (
                    local frameNode = rangeNode.get_child i
                    fmc.assign_frame_to_control frameNode
                )
                jal.prog.update_progress (i+1) frameNum inProgressText:"Assign Keys..."
            )
        )
        jal.prog.end_progress()
    )
)
