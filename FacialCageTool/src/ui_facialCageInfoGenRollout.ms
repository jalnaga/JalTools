rollout facialCageInfoGenRollout "Facial Cage Info Genereator" (
    fn pickFilter inObj = classOf inObj == Editable_Poly
    group "Steps" (
        label step1Lbl "1. " across:2 offset:[-10, 8]
        pickButton avgMeshPickBtn "Pick Average Face mesh" enabled:true width:130 height:30 align:#left offset:[-40, 0] filter:pickFilter autoDisplay:true
        label step2Lbl "2. " across:2 offset:[-10, 8]
        pickButton fCageMeshPickBtn "Pick Facial Cage mesh" enabled:false width:130 height:30 align:#left offset:[-40, 0] filter:pickFilter autoDisplay:true
        label step3Lbl "3. " across:2 offset:[-10, 8]
        button boneSelBtn "Select Facial Bones" enabled:false width:130 height:30 align:#left offset:[-40, 0]
    )

    button saveXmlBtn "Save FCage Info" height:25 offset:[0, 5] enabled:false

    local univMesh = undefined
    local fCageMesh = undefined
    local staticFacialBoneNum = 189
    local facialBoneArray = #()

    fn update_ui = (
        if univMesh == undefined then (
            fCageMeshPickBtn.enabled = false
            fCageMesh = undefined
            facialBoneArray = #()
        )
        else fCageMeshPickBtn.enabled = true

        if fCageMesh == undefined then (
            boneSelBtn.enabled = false
            facialBoneArray = #()
        )
        else boneSelBtn.enabled = true

        if facialBoneArray.count == 0 then (
            saveXmlBtn.enabled = false
            boneSelBtn.caption = "Select Facial Bones"
        )
        else (
            saveXmlBtn.enabled = true
            boneSelBtn.caption = "189 bones are selected"
        )
    )

    on avgMeshPickBtn picked pickedObj do (
        univMesh = pickedObj
        update_ui()
    )

    on avgMeshPickBtn rightclick do (
        univMesh = undefined
        avgMeshPickBtn.object = undefined
        update_ui()
    )

    on fCageMeshPickBtn picked pickedObj do (
        fCageMesh = pickedObj
        update_ui()
    )

    on fCageMeshPickBtn rightclick do (
        fCageMesh = undefined
        fCageMeshPickBtn.object = undefined
        update_ui()
    )

    on boneSelBtn pressed do (
        local selBoneArray = for item in selection where classOf item == BoneGeometry collect item
        if selBoneArray.count == staticFacialBoneNum then (
            facialBoneArray = deepCopy selBoneArray
        )
        else (
            if selBoneArray.count > staticFacialBoneNum then messageBox "Select facial bones only!\nSome non relative bones are selected."
            if selBoneArray.count < staticFacialBoneNum then messageBox "Select every facial bones!"
        )
        update_ui()
    )

    on boneSelBtn rightclick do (
        facialBoneArray = #()
        update_ui()
    )

    on saveXmlBtn pressed do (
        if univMesh != undefined and fCageMesh != undefined and facialBoneArray.count == staticFacialBoneNum then (
            local distThresh = 0.02905

            local lMeshVertCount = polyop.getNumVerts fCageMesh
            local hMeshVertCount = polyop.getNumVerts univMesh

            local matchVertsArray = #()
            local matchBonesArray = #()

            toolMode.coordsys #world

            for i = 1 to lMeshVertCount do (
                local lMeshVertPos = polyop.getVert fCageMesh i node:fCageMesh
                for k = 1 to hMeshVertCount do (
                    local pairVertArray = #()

                    local hMeshVertPos = polyop.getVert univMesh k node:univMesh
                    local vertDist = distance lMeshVertPos hMeshVertPos
                    if vertDist <= distThresh then (
                        append pairVertArray i
                        append pairVertArray k
                        append matchVertsArray pairVertArray
                        exit
                    )
                )
                for j = 1 to facialBoneArray.count do (
                    local pairBoneArray = #()

                    local bonePos = in coordsys world (facialBoneArray[j].transform.position)
                    local boneDist = distance lMeshVertPos bonePos
                    if boneDist <= distThresh then (
                        append pairBoneArray i
                        append pairBoneArray facialBoneArray[j].name
                        append matchBonesArray pairBoneArray
                        exit
                    )
                )
            )

            jal.xml.create_file xmlFile
            local rNode = jal.xml.get_root_node()
            local cageNode = jal.xml.create_node "CageMesh"

            cageNode.add_attribute "totalVertNum" "189"
            for i = 1 to matchVertsArray.count do (
                local matchBoneName = matchBonesArray[i][2]
                local side = ""
                if (MatchPattern matchBoneName pattern:"L_*") then side = "L"
                if (MatchPattern matchBoneName pattern:"R_*") then side = "R"
                if (MatchPattern matchBoneName pattern:"C_*") then side = "C"
                local boneName = (FilterString matchBoneName "_")[2]
                local vertInfoNode = jal.xml.create_node "VertInfo"
                vertInfoNode.add_attribute "index" (matchVertsArray[i][1] as String)
                vertInfoNode.add_attribute "highMeshVertIndex" (matchVertsArray[i][2] as String)
                vertInfoNode.add_attribute "side" side
                vertInfoNode.add_attribute "boneName" boneName

                cageNode.append_child_node vertInfoNode
            )
            rNode.append_child_node cageNode
            jal.xml.save_pretty()
        )
        else messageBox "Not enough components!\nPick\n- Average Mesh\n- Facial Cage Mesh\n- Facial Bones"
    )
)
