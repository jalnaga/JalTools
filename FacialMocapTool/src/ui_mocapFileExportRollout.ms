rollout mocapFileExportRollout "Mocap File Export"(
    button loadBtn "Load Mocap FBX"
    spinner startSpn "From:" across:2 type:#integer range:[0, 100000, 0]
    spinner endSpn "End:" type:#integer range:[0, 100000, 100]
    button exportFileBtn "Export Mocap File"

    on mocapFileExportRollout open do (
        startSpn.value = animationRange.start
        endSpn.value = animationRange.end
    )

    on loadBtn pressed do (
        local mocapFile = getOpenFileName caption:"Load Mocap FBX:" types:"Autodesk (*.fbx)|*.fbx"
        if mocapFile != undefined then (
            actionMan.executeAction 0 "16"
            local importClass = importerPlugin.classes
            importFile mocapFile #noPrompt using:importClass[(get_fbx_classNum import:true export:false)]
        )
    )

    on exportFileBtn pressed do (
        fmc.set_sourceHead $head
        fmc.convert_morphTargetName()

        if fmc.sourceHead != undefined then (
            local saveFileName = getSaveFileName caption:"Save Mocap XML:" types:"XML (*.xml)|*.xml"
            if saveFileName != undefined then (
                local rNode
                local frameRangeNode
                xDoc.create_file saveFileName
                rNode = xDoc.get_root_node()
                frameRangeNode = fmc.gen_xmlNode_for_range startSpn.value endSpn.value xDoc
                rNode.append_child_node frameRangeNode

                xDoc.save_pretty()
            )
        )
    )
)
