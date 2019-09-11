rollout facialCageInfoGenRollout "Template - Info Generator" (
    fn pickFilter inObj = classOf inObj == Editable_Poly
    button loadSceneBtn "Load Template File"
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
    local staticBoneNameArray = #("L_BrowA_0_JNT", "L_BrowB_0_JNT", "L_ForeheadA_0_JNT", "L_LidUA_0_JNT", "L_LidUB_0_JNT", "L_LidCoverB_0_JNT", "L_LidUC_0_JNT", "L_LidCoverC_0_JNT", "L_LidUD_0_JNT", "L_LidCoverD_0_JNT", "L_LidUE_0_JNT", "L_LidCoverE_0_JNT", "L_LidOut_0_JNT", "L_LidCoverOut_0_JNT", "L_LidLE_0_JNT", "L_OculiC_0_JNT", "L_LidLD_0_JNT", "L_OculiB_0_JNT", "L_LidLC_0_JNT", "L_LidCoverIn_0_JNT", "L_LidIn_0_JNT", "L_OculiA_0_JNT", "L_LidLA_0_JNT", "L_LidCoverA_0_JNT", "L_BrowD_0_JNT", "L_BrowC_0_JNT", "L_OculiF_0_JNT", "L_ForeheadB_0_JNT", "L_CheekA_0_JNT", "L_OrisA_0_JNT", "L_LipLA_0_JNT", "L_ChinA_0_JNT", "L_ChinTip_0_JNT", "L_OrisB_0_JNT", "L_LipLB_0_JNT", "L_OrisC_0_JNT", "L_LipLC_0_JNT", "L_ChinB_0_JNT", "L_ZygoE_0_JNT", "L_JowlE_0_JNT", "L_JowlD_0_JNT", "L_ZygoD_0_JNT", "L_PhiltrumA_0_JNT", "L_LipUA_0_JNT", "L_NoseL_0_JNT", "L_NostrilInC_0_JNT", "L_NostrilOutC_0_JNT", "L_LipUB_0_JNT", "L_PhiltrumC_0_JNT", "L_LipUC_0_JNT", "L_OrisE_0_JNT", "L_PhiltrumB_0_JNT", "L_NoseWrinkleB_0_JNT", "L_NoseWrinkleA_0_JNT", "L_ZygoB_0_JNT", "L_ZygoA_0_JNT", "L_NostrilOutB_0_JNT", "L_NostrilInB_0_JNT", "L_NostrilOutA_0_JNT", "L_LipCornerOut_0_JNT", "L_OrisD_0_JNT", "L_MasseterB_0_JNT", "L_NostrilInA_0_JNT", "L_OculiD_0_JNT", "L_OculiE_0_JNT", "L_JowlA_0_JNT", "L_JowlB_0_JNT", "L_JowlC_0_JNT", "L_ZygoC_0_JNT", "L_TemporalisA_0_JNT", "L_TemporalisB_0_JNT", "L_CheekB_0_JNT", "L_CheekC_0_JNT", "L_PlastimaC_0_JNT", "L_Risorius_0_JNT", "L_LidLB_0_JNT", "L_CheekD_0_JNT", "L_MasseterA_0_JNT", "L_PlastimaB_0_JNT", "L_PlastimaA_0_JNT", "C_BrowIn_0_JNT", "C_Forehead_0_JNT", "C_LipU_0_JNT", "L_LipLInA_0_JNT", "L_LipLInB_0_JNT", "L_LipLInC_0_JNT", "L_LipUInA_0_JNT", "L_LipUInB_0_JNT", "L_LipUInC_0_JNT", "L_LipCornerIn_0_JNT", "C_LipLIN_0_JNT", "C_LipUIn_0_JNT", "C_LipL_0_JNT", "C_NoseBridge_0_JNT", "C_Chin_0_JNT", "C_Philtrum_0_JNT", "C_NoseL_0_JNT", "C_NoseTip_0_JNT", "R_BrowC_0_JNT", "R_ForeheadA_0_JNT", "R_BrowB_0_JNT", "R_LidCoverB_0_JNT", "R_LidCoverA_0_JNT", "R_LidUA_0_JNT", "R_LidUB_0_JNT", "R_LidUC_0_JNT", "R_LidCoverC_0_JNT", "R_LidUD_0_JNT", "R_LidCoverD_0_JNT", "R_LidUE_0_JNT", "R_LidCoverE_0_JNT", "R_LidOut_0_JNT", "R_LidCoverOut_0_JNT", "R_LidLE_0_JNT", "R_OculiC_0_JNT", "R_LidLD_0_JNT", "R_OculiB_0_JNT", "R_LidLC_0_JNT", "R_LidCoverIn_0_JNT", "R_LidIn_0_JNT", "R_OculiA_0_JNT", "R_LidLA_0_JNT", "R_BrowA_0_JNT", "R_BrowD_0_JNT", "R_OculiF_0_JNT", "R_ForeheadB_0_JNT", "R_CheekA_0_JNT", "C_Oris_0_JNT", "R_OrisA_0_JNT", "R_LipLA_0_JNT", "R_ChinA_0_JNT", "R_OrisB_0_JNT", "R_LipLB_0_JNT", "R_OrisC_0_JNT", "R_LipLC_0_JNT", "R_ChinB_0_JNT", "R_ZygoE_0_JNT", "R_JowlE_0_JNT", "R_JowlD_0_JNT", "R_ZygoD_0_JNT", "R_LipUA_0_JNT", "R_PhiltrumA_0_JNT", "R_NoseL_0_JNT", "R_NostrilInC_0_JNT", "R_NostrilOutC_0_JNT", "R_LipUB_0_JNT", "R_PhiltrumC_0_JNT", "R_LipUC_0_JNT", "R_OrisE_0_JNT", "R_PhiltrumB_0_JNT", "R_NoseWrinkleB_0_JNT", "R_NoseWrinkleA_0_JNT", "R_ZygoB_0_JNT", "R_ZygoA_0_JNT", "R_NostrilOutB_0_JNT", "R_NostrilInB_0_JNT", "R_NostrilOutA_0_JNT", "R_LipCornerOut_0_JNT", "R_OrisD_0_JNT", "R_ChinTip_0_JNT", "R_JowlC_0_JNT", "R_LidLB_0_JNT", "R_NostrilInA_0_JNT", "R_JowlA_0_JNT", "R_OculiD_0_JNT", "R_OculiE_0_JNT", "R_JowlB_00_JNT", "R_CheekD_0_JNT", "R_ZygoC_0_JNT", "R_TemporalisA_0_JNT", "R_TemporalisB_0_JNT", "R_CheekB_0_JNT", "R_CheekC_0_JNT", "R_PlastimaC_0_JNT", "R_Risorius_0_JNT", "R_Masseter_0_JNT", "R_MasseterB_0_JNT", "R_PlastimaB_0_JNT", "C_Plastima_0_JNT", "R_PlastimaA_0_JNT", "C_ChinTipA_0_JNT", "C_ChinTipB_0_JNT", "R_LipLInA_0_JNT", "R_LipLInB_0_JNT", "R_LipLInC_0_JNT", "R_LipUInA_0_JNT", "R_LipUInB_0_JNT", "R_LipUInC_0_JNT", "R_LipCornerIn_0_JNT")
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
            saveXmlBtn.enabled = true
            boneSelBtn.caption = "Select Facial Bones"
        )
        else (
            saveXmlBtn.enabled = true
            boneSelBtn.caption = "189 bones are selected"
        )
    )

    on loadSceneBtn pressed do (
        if (checkForSave()) then (
            saveMaxFile (maxFilePath + maxFileName)
        )
        loadMaxFile facialCageMeshFullName quiet:true
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
        if univMesh != undefined and fCageMesh != undefined then (
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
                if facialBoneArray.count == staticFacialBoneNum then (
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
                else (
                    local pairBoneArray = #()
                    append pairBoneArray i
                    append pairBoneArray staticBoneNameArray[i]
                    append matchBonesArray pairBoneArray
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
            univMesh.name = univFaceMeshName
            fCageMesh.name = fCageMeshName
            saveMaxFile (maxFilePath + maxFileName)
        )
        else messageBox "Not enough components!\nPick\n- Average Mesh\n- Facial Cage Mesh\n- Facial Bones"
    )
)
