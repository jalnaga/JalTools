rollout mocapFileExportRollout "Mocap File Export"(
    button loadBtn "Load Mocap FBX"
    spinner startSpn "From:" across:2 type:#integer
    spinner endSpn "End:" type:#integer
    button exportFileBtn "Export Mocap File"

    on loadBtn pressed do (
        local mocapFile = getOpenFileName caption:"Load Mocap FBX:" types:"Autodesk (*.fbx)|*.fbx"
        if mocapFile != undefined then (
            actionMan.executeAction 0 "16"
            local importClass = importerPlugin.classes
            importFile mocapFile #noPrompt using:importClass[(get_fbx_classNum import:true export:false)]
            fmc.set_sourceHead $head
            fmc.convert_morphTargetName()
        )
    )

    on exportFileBtn pressed do (
        if fmc.sourceHead != undefined then (
            local saveFileName = getSaveFileName caption:"Save Mocap XML:" types:"XML (*.xml)|*.xml"
            if saveFileName != undefined then (
                local rNode
                local frameRangeNode
                xDoc.create_file saveFileName
                rNode = xDoc.get_root_node()
                frameRangeNode = fmc.gen_xmlNode_for_range startSpn.value endSpn.value xDoc
                local temp = frameRangeNode.get_children()
                rNode.append_child_node frameRangeNode

                xDoc.save_pretty()
            )
        )
    )
)
