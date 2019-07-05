rollout mocapFileExportRollout "Mocap File Export"(
    button loadBtn "Load Mocap FBX"
    button exportFileBtn "Export Mocap File"

    fn get_fbx_classNum import:true export:false = (
        local exportClass = exporterPlugin.classes
        local importClass = importerPlugin.classes
        local returnVal = 0

        if export then (
            for i = 1 to exportClass.count do (
                if exportClass[i] == FBXEXP then (
                    returnVal = i
                )
            )
        )

        if import then (
            for i = 1 to importClass.count do (
                if importClass[i] == FBXIMP then (
                    returnVal = i
                )
            )
        )

        return returnVal
    )

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
                local xDoc = _XMLDoc()
                local rNode
                local frameRangeNode
                xDoc.create_file saveFileName
                rNode = xDoc.get_root_node()
                frameRangeNode = fmc.gen_xmlNode_for_range 0 473 xDoc
                local temp = frameRangeNode.get_children()
                format "%\n" temp.count
                rNode.append_child_node frameRangeNode

                xDoc.save_pretty()
            )
        )
    )
)
