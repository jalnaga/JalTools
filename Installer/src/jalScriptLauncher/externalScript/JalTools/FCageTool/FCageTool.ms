(
    try(destroydialog jal.tools.facialCageTool) catch()
    rollout mainRollout "Facial Cage Tool" width:300 height:400 (
        SubRollout mainSub "" align:#center height:385
    
        local minWidth = 300
        local minHeight = 400
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        local facialCageMeshFullName = ""
        local facialRigFullName = ""
        local fCageMeshName = "FCage_000"
        local univFaceMeshName = "UnivHead_000"
    
        local vertMatchXml = ""
    
        struct _Facs (
            targetNum = 51,
            targetNameArray = #("browDownLeft", "browDownRight", "browInnerUp", "browOuterUpLeft", "browOuterUpRight", "cheekPuff", "cheekSquintLeft", "cheekSquintRight","eyeBlinkLeft", "eyeBlinkRight", "eyeLookDownLeft", "eyeLookDownRight", "eyeLookInLeft", "eyeLookInRight", "eyeLookOutLeft", "eyeLookOutRight", "eyeLookUpLeft", "eyeLookUpRight", "eyeSquintLeft", "eyeSquintRight", "eyeWideLeft", "eyeWideRight", "jawForward", "jawOpen", "jawLeft", "jawRight", "mouthClose", "mouthDimpleLeft", "mouthDimpleRight", "mouthFrownLeft", "mouthFrownRight", "mouthFunnel", "mouthLeft", "mouthRight", "mouthLowerDownLeft", "mouthLowerDownRight", "mouthPressLeft", "mouthPressRight", "mouthPucker", "mouthRollLower", "mouthRollUpper", "mouthShrugLower", "mouthShrugUpper", "mouthSmileLeft", "mouthSmileRight", "mouthStretchLeft", "mouthStretchRight", "mouthUpperUpLeft", "mouthUpperUpRight", "noseSneerLeft", "noseSneerRight"),
            oriTargetArray = #(),
            oriNeutralMesh = undefined,
            newNeutralMesh = undefined,
            highUnivMesh = undefined,
            highMeshArray = #(),
            matchInfo = #(),
            newTargetArray = #(),
        
            fn set_oriNeutralMesh inMesh = (
                local returnVal = false
                if classOf inMesh == Editable_Poly then (
                    oriNeutralMesh = inMesh
                    returnVal = true
                )
                returnVal
            ),
        
            fn set_newNeutralMesh inMesh = (
                local returnVal = false
                if classOf inMesh == Editable_Poly then (
                    newNeutralMesh = inMesh
                    returnVal = true
                )
                returnVal
            ),
        
            fn set_highUnivMesh inMesh = (
                local returnVal = false
                if classOf inMesh == Editable_Poly then (
                    highUnivMesh = inMesh
                    returnVal = true
                )
                returnVal
            ),
        
            fn sort_targetArray inArray inFilterStr = (
                local returnVal = false
                if inArray.count == targetNum then (
                    oriTargetArray = #()
                    local tempArray = for item in inArray collect item.name
                    for i = 1 to tempArray.count do (
                        for j = 1 to targetNameArray.count do (
                            local pattern = "*" + inFilterStr + targetNameArray[j] + inFilterStr + "*"
                            if (MatchPattern tempArray[i] pattern:pattern) then (
                                oriTargetArray[j] = inArray[i]
                                exit
                            )
                        )
                    )
                    returnVal = true
                )
                returnVal
            ),
        
            fn set_oriTarget inArray inFilterStr = (
                local returnVal = false
                local tempArray = for item in inArray where (classOf item) == Editable_Poly collect item
                if tempArray.count == targetNum then (
                    sort_targetArray tempArray inFilterStr
                    returnVal = true
                )
                returnVal
            ),
        
            fn set_hightMeshArrah inArray = (
                local returnVal = false
                local tempArray = for item in inArray where (classOf item) == Editable_Poly collect item
                if tempArray.count == targetNum then (
                    highMeshArray = deepCopy tempArray
                    returnVal = true
                )
                returnVal
            ),
        
            fn modify_targets_to_newNeutralMesh = (
                local returnVal = #()
                if oriNeutralMesh == undefined or newNeutralMesh == undefined or oriTargetArray.count != targetNum then return returnVal
                else (
                    for i = 1 to oriTargetArray.count do (
                        local newFacsMorphMod = Morpher()
                        local newFacs = snapshot oriNeutralMesh
                        local oriFacs = snapshot oriTargetArray[i]
                        addModifier newFacs newFacsMorphMod
                        jal.mor.init newFacs
                        jal.mor.add_targets #(oriFacs, newNeutralMesh)
                        jal.mor.set_channel_value_by_index 1 100.0
                        jal.mor.set_channel_value_by_index 2 100.0
                        newFacs = convertToPoly newFacs
        
                        local oriFacsMorphMod = Morpher()
                        addModifier oriTargetArray[i] oriFacsMorphMod
                        jal.mor.init oriTargetArray[i]
                        jal.mor.add_target newFacs 1
                        jal.mor.set_channel_value_by_index 1 100.0
                        newTargetArray[i] = convertToPoly oriTargetArray[i]
        
                        delete newFacs
                        delete oriFacs
                    )
                    if newTargetArray.count == targetNum then returnval = newTargetArray
                    return returnVal
                )
            ),
        
            fn load_vertMatchInfo inXmlFile = (
                local returnVal = false
                matchInfo = #()
                jal.xml.load_file inXmlFile
                local rNode = jal.xml.get_root_node()
                local cageMeshNode = rNode.get_child 0
                local vertNum = (cageMeshNode.get_attribute "totalVertNum") as Integer
                for i = 0 to (vertNum-1) do (
                    local vertNode = cageMeshNode.get_child i
                    local lVert = (vertNode.get_attribute "index") as Integer
                    local hVert = (vertNode.get_attribute "highMeshVertIndex") as Integer
                    local tempArray = #(lVert, hVert)
                    append matchInfo tempArray
                )
                returnVal = true
                return returnVal
            ),
        
            fn match_vert_pos inLMesh inHMesh inMatchInfo = (
                toolMode.coordsys #world
                for item in inMatchInfo do (
                    local targetPos = polyop.getVert inHMesh item[2] node:inHMesh
                    polyop.setVert inLMesh item[1] targetPos node:inLMesh
                )
            ),
        
            fn gen_targets_from_highMesh = (
                local returnval = false
                if highMeshArray.count == targetNum and oriTargetArray.count == targetNum and oriNeutralMesh != undefined and highUnivMesh != undefined and matchInfo.count != 0 then (
                    newTargetArray = #()
                    local tempUnivMesh = snapshot highUnivMesh
                    tempUnivMesh = convertToPoly tempUnivMesh
        
                    for i = 1 to oriTargetArray.count do (
                        local tempFCage = snapshot oriNeutralMesh
                        tempFCage = convertToPoly tempFCage
                        local univMorphMod = Morpher()
                        addModifier tempUnivMesh univMorphMod
                        jal.mor.init tempUnivMesh
                        jal.mor.add_target highMeshArray[i] 1
                        jal.mor.set_channel_value_by_index 1 100.0
                        convertToPoly tempUnivMesh
                        match_vert_pos tempFCage tempUnivMesh matchInfo
        
                        local fCageMorphMod = Morpher()
                        addModifier oriTargetArray[i] fCageMorphMod
                        jal.mor.init oriTargetArray[i]
                        jal.mor.add_target tempFCage 1
                        jal.mor.set_Channel_value_by_index 1 100.0
                        newTargetArray[i] = convertToPoly oriTargetArray[i]
        
                        delete tempFCage
                    )
                    delete tempUnivMesh
                    returnVal = true
                )
                returnVal
            )
        )

        local facs = _Facs()
    
        rollout vertMatchRollout "Template - Vertex Match Info Generator" (
            fn pickFilter inObj = classOf inObj == Editable_Poly
            group "Steps" (
                label step1Lbl "1. " across:2 offset:[-10, 8]
                pickButton avgMeshPickBtn "Pick Average Face mesh" enabled:true width:130 height:30 align:#left offset:[-40, 0] filter:pickFilter autoDisplay:true
                label step2Lbl "2. " across:2 offset:[-10, 8]
                pickButton fCageMeshPickBtn "Pick Facial Cage mesh" enabled:false width:130 height:30 align:#left offset:[-40, 0] filter:pickFilter autoDisplay:true
                checkbox useBoneCkb "Use Bones" across:2 offset:[0, 8]
                button boneSelBtn "Select Facial Bones" enabled:false width:130 height:30 align:#left offset:[-40, 0]
            )
        
            button saveXmlBtn "Save VertMatch Info" height:25 offset:[0, 5] enabled:false
        
            local staticFacialBoneNum = 189
            local staticBoneNameArray = #("L_BrowA_0_JNT", "L_BrowB_0_JNT", "L_ForeheadA_0_JNT", "L_LidUA_0_JNT", "L_LidUB_0_JNT", "L_LidCoverB_0_JNT", "L_LidUC_0_JNT", "L_LidCoverC_0_JNT", "L_LidUD_0_JNT", "L_LidCoverD_0_JNT", "L_LidUE_0_JNT", "L_LidCoverE_0_JNT", "L_LidOut_0_JNT", "L_LidCoverOut_0_JNT", "L_LidLE_0_JNT", "L_OculiC_0_JNT", "L_LidLD_0_JNT", "L_OculiB_0_JNT", "L_LidLC_0_JNT", "L_LidCoverIn_0_JNT", "L_LidIn_0_JNT", "L_OculiA_0_JNT", "L_LidLA_0_JNT", "L_LidCoverA_0_JNT", "L_BrowD_0_JNT", "L_BrowC_0_JNT", "L_OculiF_0_JNT", "L_ForeheadB_0_JNT", "L_CheekA_0_JNT", "L_OrisA_0_JNT", "L_LipLA_0_JNT", "L_ChinA_0_JNT", "L_ChinTip_0_JNT", "L_OrisB_0_JNT", "L_LipLB_0_JNT", "L_OrisC_0_JNT", "L_LipLC_0_JNT", "L_ChinB_0_JNT", "L_ZygoE_0_JNT", "L_JowlE_0_JNT", "L_JowlD_0_JNT", "L_ZygoD_0_JNT", "L_PhiltrumA_0_JNT", "L_LipUA_0_JNT", "L_NoseL_0_JNT", "L_NostrilInC_0_JNT", "L_NostrilOutC_0_JNT", "L_LipUB_0_JNT", "L_PhiltrumC_0_JNT", "L_LipUC_0_JNT", "L_OrisE_0_JNT", "L_PhiltrumB_0_JNT", "L_NoseWrinkleB_0_JNT", "L_NoseWrinkleA_0_JNT", "L_ZygoB_0_JNT", "L_ZygoA_0_JNT", "L_NostrilOutB_0_JNT", "L_NostrilInB_0_JNT", "L_NostrilOutA_0_JNT", "L_LipCornerOut_0_JNT", "L_OrisD_0_JNT", "L_MasseterB_0_JNT", "L_NostrilInA_0_JNT", "L_OculiD_0_JNT", "L_OculiE_0_JNT", "L_JowlA_0_JNT", "L_JowlB_0_JNT", "L_JowlC_0_JNT", "L_ZygoC_0_JNT", "L_TemporalisA_0_JNT", "L_TemporalisB_0_JNT", "L_CheekB_0_JNT", "L_CheekC_0_JNT", "L_PlastimaC_0_JNT", "L_Risorius_0_JNT", "L_LidLB_0_JNT", "L_CheekD_0_JNT", "L_MasseterA_0_JNT", "L_PlastimaB_0_JNT", "L_PlastimaA_0_JNT", "C_BrowIn_0_JNT", "C_Forehead_0_JNT", "C_LipU_0_JNT", "L_LipLInA_0_JNT", "L_LipLInB_0_JNT", "L_LipLInC_0_JNT", "L_LipUInA_0_JNT", "L_LipUInB_0_JNT", "L_LipUInC_0_JNT", "L_LipCornerIn_0_JNT", "C_LipLIN_0_JNT", "C_LipUIn_0_JNT", "C_LipL_0_JNT", "C_NoseBridge_0_JNT", "C_Chin_0_JNT", "C_Philtrum_0_JNT", "C_NoseL_0_JNT", "C_NoseTip_0_JNT", "R_BrowC_0_JNT", "R_ForeheadA_0_JNT", "R_BrowB_0_JNT", "R_LidCoverB_0_JNT", "R_LidCoverA_0_JNT", "R_LidUA_0_JNT", "R_LidUB_0_JNT", "R_LidUC_0_JNT", "R_LidCoverC_0_JNT", "R_LidUD_0_JNT", "R_LidCoverD_0_JNT", "R_LidUE_0_JNT", "R_LidCoverE_0_JNT", "R_LidOut_0_JNT", "R_LidCoverOut_0_JNT", "R_LidLE_0_JNT", "R_OculiC_0_JNT", "R_LidLD_0_JNT", "R_OculiB_0_JNT", "R_LidLC_0_JNT", "R_LidCoverIn_0_JNT", "R_LidIn_0_JNT", "R_OculiA_0_JNT", "R_LidLA_0_JNT", "R_BrowA_0_JNT", "R_BrowD_0_JNT", "R_OculiF_0_JNT", "R_ForeheadB_0_JNT", "R_CheekA_0_JNT", "C_Oris_0_JNT", "R_OrisA_0_JNT", "R_LipLA_0_JNT", "R_ChinA_0_JNT", "R_OrisB_0_JNT", "R_LipLB_0_JNT", "R_OrisC_0_JNT", "R_LipLC_0_JNT", "R_ChinB_0_JNT", "R_ZygoE_0_JNT", "R_JowlE_0_JNT", "R_JowlD_0_JNT", "R_ZygoD_0_JNT", "R_LipUA_0_JNT", "R_PhiltrumA_0_JNT", "R_NoseL_0_JNT", "R_NostrilInC_0_JNT", "R_NostrilOutC_0_JNT", "R_LipUB_0_JNT", "R_PhiltrumC_0_JNT", "R_LipUC_0_JNT", "R_OrisE_0_JNT", "R_PhiltrumB_0_JNT", "R_NoseWrinkleB_0_JNT", "R_NoseWrinkleA_0_JNT", "R_ZygoB_0_JNT", "R_ZygoA_0_JNT", "R_NostrilOutB_0_JNT", "R_NostrilInB_0_JNT", "R_NostrilOutA_0_JNT", "R_LipCornerOut_0_JNT", "R_OrisD_0_JNT", "R_ChinTip_0_JNT", "R_JowlC_0_JNT", "R_LidLB_0_JNT", "R_NostrilInA_0_JNT", "R_JowlA_0_JNT", "R_OculiD_0_JNT", "R_OculiE_0_JNT", "R_JowlB_00_JNT", "R_CheekD_0_JNT", "R_ZygoC_0_JNT", "R_TemporalisA_0_JNT", "R_TemporalisB_0_JNT", "R_CheekB_0_JNT", "R_CheekC_0_JNT", "R_PlastimaC_0_JNT", "R_Risorius_0_JNT", "R_Masseter_0_JNT", "R_MasseterB_0_JNT", "R_PlastimaB_0_JNT", "C_Plastima_0_JNT", "R_PlastimaA_0_JNT", "C_ChinTipA_0_JNT", "C_ChinTipB_0_JNT", "R_LipLInA_0_JNT", "R_LipLInB_0_JNT", "R_LipLInC_0_JNT", "R_LipUInA_0_JNT", "R_LipUInB_0_JNT", "R_LipUInC_0_JNT", "R_LipCornerIn_0_JNT")
        
            local univMesh = undefined
            local fCageMesh = undefined
            local facialBoneArray = #()
        
            fn update_ui = (
                if univMesh == undefined then (
                    fCageMeshPickBtn.enabled = false
                    fCageMesh = undefined
                    facialBoneArray = #()
                )
                else fCageMeshPickBtn.enabled = true
        
                if fCageMesh == undefined then (
                    facialBoneArray = #()
                )
                else saveXmlBtn.enabled = true
        
                if useBoneCkb.checked then boneSelBtn.enabled = true
                else boneSelBtn.enabled = false
        
                if facialBoneArray.count == 0 then boneSelBtn.caption = "Select Facial Bones"
                else boneSelBtn.caption = "189 bones are selected"
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
        
            on useBoneCkb changed stat do update_ui()
        
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
                    local distThresh = 0.002905
        
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
        
                    if matchVertsArray.count == staticFacialBoneNum then (
                        jal.xml.create_file vertMatchXml
                        local rNode = jal.xml.get_root_node()
                        local cageNode = jal.xml.create_node "CageMesh"
        
                        cageNode.add_attribute "totalVertNum" (matchVertsArray.count as String)
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
                    else (
                        local vertSel = for i = 1 to matchVertsArray.count collect matchVertsArray[i][1]
                        vertSel = vertSel as BitArray
                        polyop.setVertSelection fCageMesh (-(vertSel))
                        local unMatchedVertNumStr = (staticFacialBoneNum - matchVertsArray.count) as String
                        local msgStr = unMatchedVertNumStr + " vertices are not matched!"
                        messageBox msgStr
                    )
                )
                else messageBox "Not enough components!\nPick\n- Average Mesh\n- Facial Cage Mesh\n- Facial Bones"
            )
        )

        rollout cageGenRollout "Template - Cage Generator" (
            fn pickFilter inObj = classOf inObj == Editable_Poly
            pickButton scanMeshPickBtn "Pick Scanned mesh" enabled:true width:130 height:30 filter:pickFilter autoDisplay:true
            pickButton oriNeutralBtn "Pick Original FCage" height:30 autoDisplay:true filter:pickFilter enabled:false
        
            button genCageBtn "Generate Cage" height:25 offset:[0, 5] enabled:false
        
            local univMesh = undefined
            local oriFCageMesh = undefined
        
            fn load_vertMatchInfo = (
                local returnArray = #()
                jal.xml.load_file vertMatchXml
                local rNode = jal.xml.get_root_node()
                local cageMeshNode = rNode.get_child 0
                local vertNum = (cageMeshNode.get_attribute "totalVertNum") as Integer
                for i = 0 to (vertNum-1) do (
                    local vertNode = cageMeshNode.get_child i
                    local lVert = (vertNode.get_attribute "index") as Integer
                    local hVert = (vertNode.get_attribute "highMeshVertIndex") as Integer
                    local tempArray = #(lVert, hVert)
                    append returnArray tempArray
                )
                return returnArray
            )
        
            fn match_vert_pos inLMesh inHMesh inMatchInfo = (
                toolMode.coordsys #world
                for item in inMatchInfo do (
                    local targetPos = polyop.getVert inHMesh item[2] node:inHMesh
                    polyop.setVert inLMesh item[1] targetPos node:inLMesh
                )
            )
        
            fn gen_facialCage = (
                local returnVal = undefined
                local vertMatchInfo = load_vertMatchInfo()
                local tempHMesh = snapshot univMesh
                local tempCageMesh = snapshot oriFCageMesh
                convertToPoly tempHMesh
                convertToPoly tempCageMesh
                match_vert_pos tempCageMesh tempHMesh vertMatchInfo
                tempCageMesh.name = tempHMesh.name + "_Cage"
                delete tempHMesh
                returnVal = tempCageMesh
                return returnVal
            )
        
            fn update_ui = (
                if univMesh == undefined then (
                    oriNeutralBtn.enabled = false
                    genCageBtn.enabled = false
                )
                else oriNeutralBtn.enabled = true
        
                if oriFCageMesh == undefined then (
                    genCageBtn.enabled = false
                )
                else genCageBtn.enabled = true
            )
        
            on scanMeshPickBtn picked pickedObj do (
                univMesh = pickedObj
                update_ui()
            )
        
            on scanMeshPickBtn rightclick do (
                univMesh = undefined
                scanMeshPickBtn.object = undefined
                update_ui()
            )
        
            on oriNeutralBtn picked pickedObj do (
                oriFCageMesh = pickedObj
                update_ui()
            )
        
            on oriNeutralBtn rightclick do (
                oriFCageMesh = undefined
                oriNeutralBtn.object = undefined
                update_ui()
            )
        
            on genCageBtn pressed do (
                gen_facialCage()
            )
        )

        rollout genFacsRollout "Template - FACS Generator" (
            fn pickFilter inObj = classOf inObj == Editable_Poly
            button loadSceneBtn "Load Template"
            button oriFacsBtn "Select FACS" height:30
            pickButton oriNeutralBtn "Pick Neutral FCage" height:30 autoDisplay:true filter:pickFilter
            group "Generate" (
                pickButton hUnivBtn "Pick HUniv Mesh" height:30 autoDisplay:true filter:pickFilter
                button oriHMeshArrayBtn "Select Highpoly Meshes" height:30
                button genFacsBtn "Gen FACS" offset:[0, 5] height:30
            )
        
            on oriFacsBtn pressed do (
                local selObjArray = getCurrentSelection() as Array
                local result = facs.set_oriTarget selObjArray "_"
                if result then oriFacsBtn.text = "Ready"
            )
        
            on oriNeutralBtn picked pickedObj do (
                facs.set_oriNeutralMesh pickedObj
            )
        
            on hUnivBtn picked pickedObj do (
                facs.set_highUnivMesh pickedObj
            )
        
            on oriHMeshArrayBtn pressed do (
                local selObjArray = getCurrentSelection() as Array
                local result = facs.set_hightMeshArrah selObjArray
                if result then oriHMeshArrayBtn.text = "Ready"
            )
        
            on genFacsBtn pressed do (
                facs.load_vertMatchInfo vertMatchXml
                facs.gen_targets_from_highMesh()
            )
        )

        rollout modFacsRollout "Template - FACS Modifier" (
            fn pickFilter inObj = classOf inObj == Editable_Poly
            button loadSceneBtn "Load Template"
            button oriFacsBtn "Select FACS" height:30
            pickButton oriNeutralBtn "Pick Neutral FCage" height:30 autoDisplay:true filter:pickFilter
            group "Modify" (
                pickButton newNeutralBtn "Pick New Neutral FCage" height:30 autoDisplay:true filter:pickFilter
                button modFACSBtn "Mod. FACS" width:130 height:30 offset:[0, 5]
            )
        
            on oriFacsBtn pressed do (
                local selObjArray = getCurrentSelection() as Array
                local result = facs.set_oriTarget selObjArray "_"
                if result then oriFacsBtn.text = "Ready"
            )
        
            on oriNeutralBtn picked pickedObj do (
                facs.set_oriNeutralMesh pickedObj
            )
        
            on newNeutralBtn picked pickedObj do (
                facs.set_newNeutralMesh pickedObj
            )
        
            on modFACSBtn pressed do (
                facs.modify_targets_to_newNeutralMesh()
            )
        )

        rollout offsetRollout "Template - Generate Pose Asset" (
            button genValueBtn "Assign Offset Value"
        
            fn get_volume_center inSelArray = (
                local volumeElementsNum = inSelArray.count
                local centerPos = [0.0, 0.0, 0.0]
                for item in inSelArray do (
                    centerPos.x += item.position.controller.value.x
                    centerPos.y += item.position.controller.value.y
                    centerPos.z += item.position.controller.value.z
                )
                centerPos = [centerPos.x/volumeElementsNum, centerPos.y/volumeElementsNum, centerPos.z/volumeElementsNum]
        
                return centerPos
            )
        
            fn get_volume_scale inSelArray = (
                local returnVal = 0.0
                local volumeElementsNum = inSelArray.count
                local centerPos = (get_volume_center inSelArray)
                local distanceArray = for item in inSelArray collect (distance centerPos item.position.controller.value)
                local accVolume = 0.0
                for item in distanceArray do accVolume += item
        
                local stepIndex = 0
                local tmepMinMaxDist = amin distanceArray
                for i = 1 to volumeElementsNum do (
                    if tmepMinMaxDist < distanceArray[i] then (
                        tmepMinMaxDist = distanceArray[i]
                        stepIndex = i
                    )
                )
                local maxVal = inSelArray[stepIndex].position.controller.value
        
                tmepMinMaxDist = amax distanceArray
                stepIndex = 0
                for i = 1 to volumeElementsNum do (
                    if tmepMinMaxDist > distanceArray[i] then (
                        tmepMinMaxDist = distanceArray[i]
                        stepIndex = i
                    )
                )
                local minVal = inSelArray[stepIndex].position.controller.value
                returnVal = distance minVal maxVal
                returnVal = accVolume
        
                return returnVal
            )
        
            local lEyeVolumeArray = #($L_LidUD_1_Dum, $L_LidUC_1_Dum, $L_LidUB_1_Dum, $L_LidLB_1_Dum, $L_LidLC_1_Dum, $L_LidLD_1_Dum)
            local rEyeVolumeArray = #($R_LidUD_1_Dum, $R_LidUC_1_Dum, $R_LidUB_1_Dum, $R_LidLB_1_Dum, $R_LidLC_1_Dum, $R_LidLD_1_Dum)
        
            local teethVolumeArray = #($L_LipUA_1_Dum, $L_LipUB_1_Dum, $L_LipUC_1_Dum, $L_LipCornerOut_1_Dum, $C_LipU_1_Dum, $L_LipLInA_1_Dum, $L_LipLInB_1_Dum, $L_LipLInC_1_Dum, $L_LipUInA_1_Dum, $L_LipUInB_1_Dum, $L_LipUInC_1_Dum, $L_LipCornerIn_1_Dum, $C_LipLIN_1_Dum, $C_LipUIn_1_Dum, $R_LipUA_1_Dum, $R_LipUB_1_Dum, $R_LipUC_1_Dum, $R_LipCornerOut_1_Dum, $R_LipLInA_1_Dum, $R_LipLInB_1_Dum, $R_LipLInC_1_Dum, $R_LipUInA_1_Dum, $R_LipUInB_1_Dum, $R_LipUInC_1_Dum, $R_LipCornerIn_1_Dum, $C_Philtrum_1_Dum, $R_PhiltrumA_1_Dum, $L_PhiltrumA_1_Dum, $C_NoseL_1_Dum, $L_NoseL_1_Dum, $R_NoseL_1_Dum, $R_LipLC_1_Dum, $R_OrisE_1_Dum, $R_OrisD_1_Dum, $L_OrisB_1_Dum, $C_Chin_1_Dum, $R_ChinA_1_Dum, $R_OrisB_1_Dum, $L_ChinA_1_Dum, $L_Risorius_1_Dum, $R_PlastimaC_1_Dum, $R_Risorius_1_Dum, $L_PlastimaC_1_Dum, $L_ZygoD_1_Dum, $R_ZygoE_1_Dum, $R_ZygoD_1_Dum, $L_ZygoE_1_Dum, $R_ChinTip_1_Dum, $C_ChinTipA_1_Dum, $L_ChinTip_1_Dum, $L_OrisC_1_Dum, $L_ChinB_1_Dum, $L_OrisD_1_Dum, $C_Oris_1_Dum, $R_OrisA_1_Dum, $R_OrisC_1_Dum, $R_ChinB_1_Dum, $L_OrisA_1_Dum, $L_LipLA_1_Dum, $L_LipLB_1_Dum, $L_LipLC_1_Dum, $L_OrisE_1_Dum, $C_LipL_1_Dum, $R_LipLA_1_Dum, $R_LipLB_1_Dum)
        
            local teethLowerVolumeArray = #($R_LipLC_1_Dum, $R_OrisE_1_Dum, $R_LipCornerOut_1_Dum, $R_OrisD_1_Dum, $R_LipLInA_1_Dum, $R_LipLInB_1_Dum, $R_LipLInC_1_Dum, $R_LipUInA_1_Dum, $R_LipUInB_1_Dum, $R_LipUInC_1_Dum, $R_LipCornerIn_1_Dum, $L_OrisB_1_Dum, $C_Chin_1_Dum, $R_ChinA_1_Dum, $R_OrisB_1_Dum, $L_ChinA_1_Dum, $L_Risorius_1_Dum, $R_PlastimaC_1_Dum, $R_Risorius_1_Dum, $L_PlastimaC_1_Dum, $L_ZygoD_1_Dum, $R_ZygoE_1_Dum, $R_ZygoD_1_Dum, $L_ZygoE_1_Dum, $R_ChinTip_1_Dum, $C_ChinTipA_1_Dum, $L_ChinTip_1_Dum, $L_OrisC_1_Dum, $L_ChinB_1_Dum, $L_OrisD_1_Dum, $C_Oris_1_Dum, $R_OrisA_1_Dum, $R_OrisC_1_Dum, $R_ChinB_1_Dum, $L_OrisA_1_Dum, $L_LipLInA_1_Dum, $L_LipLInB_1_Dum, $L_LipUInA_1_Dum, $L_LipUInB_1_Dum, $C_LipLIN_1_Dum, $C_LipUIn_1_Dum, $L_LipLA_1_Dum, $L_LipLB_1_Dum, $L_LipLC_1_Dum, $L_OrisE_1_Dum, $L_LipCornerOut_1_Dum, $L_LipLInC_1_Dum, $L_LipUInC_1_Dum, $L_LipCornerIn_1_Dum, $C_LipL_1_Dum, $R_LipLA_1_Dum, $R_LipLB_1_Dum, $R_LipUC_1_Dum, $L_LipUC_1_Dum, $R_LipUB_1_Dum, $L_LipUB_1_Dum, $R_LipUA_1_Dum, $L_LipUA_1_Dum, $C_LipU_1_Dum)
        
            local teethUpperVolumeArray = #($L_LipUA_1_Dum, $L_LipUB_1_Dum, $L_PhiltrumC_1_Dum, $L_LipUC_1_Dum, $L_LipCornerOut_1_Dum, $C_LipU_1_Dum, $L_LipLInA_1_Dum, $L_LipLInB_1_Dum, $L_LipLInC_1_Dum, $L_LipUInA_1_Dum, $L_LipUInB_1_Dum, $L_LipUInC_1_Dum, $L_LipCornerIn_1_Dum, $C_LipLIN_1_Dum, $C_LipUIn_1_Dum, $R_LipUA_1_Dum, $R_LipUB_1_Dum, $R_PhiltrumC_1_Dum, $R_LipUC_1_Dum, $R_LipCornerOut_1_Dum, $R_LipLInA_1_Dum, $R_LipLInB_1_Dum, $R_LipLInC_1_Dum, $R_LipUInA_1_Dum, $R_LipUInB_1_Dum, $R_LipUInC_1_Dum, $R_LipCornerIn_1_Dum, $C_Philtrum_1_Dum, $R_PhiltrumA_1_Dum, $L_PhiltrumA_1_Dum, $C_NoseL_1_Dum, $R_PhiltrumB_1_Dum, $L_PhiltrumB_1_Dum, $R_NoseWrinkleB_1_Dum, $L_NoseWrinkleB_1_Dum, $L_NoseL_1_Dum, $R_NoseL_1_Dum)
        
            local customFaceNum = 4
        
            on genValueBtn pressed do (
                local selObjArray = (getCurrentSelection()) as Array
                if selObjArray.count == 1 then (
                    local headBone = undefined
                    local scaleAtt = undefined
                    local modArray = for item in selObjArray[1].modifiers collect item
                    if modArray.count > 0 then (
                        for item in modArray do (
                            if item.name == "Attribute Holder" then (
                                headBone = selObjArray[1]
                                scaleAtt = headBone.modifiers["Attribute Holder"].attachScale
                                exit
                            )
                        )
                    )
                    if headBone != undefined then (
                        with animate on (
                            for i = 0 to customFaceNum do (
                                at time i(
                                    local lEyeScale = get_volume_scale lEyeVolumeArray
                                    local lEyeScaleChanged = 1.0 + (((lEyeScale/scaleAtt.L_Eye_Ori) - 1.0) * 0.8)
                                    local lEyeEndSCale = scaleAtt.L_Eye_Ori * lEyeScaleChanged
        
                                    local rEyeScale = get_volume_scale rEyeVolumeArray
                                    local rEyeScaleChanged = 1.0 + (((rEyeScale/scaleAtt.R_Eye_Ori) - 1.0) * 0.8)
                                    local rEyeEndSCale = scaleAtt.R_Eye_Ori * rEyeScaleChanged
        
                                    --local uTeethScale = get_volume_scale teethVolumeArray
                                    --local bTeethScale = get_volume_scale teethVolumeArray
                                    --local uTeethScaleChanged = uTeethScale/scaleAtt.U_Teeth_Ori
                                    --local bTeethScaleChanged = bTeethScale/scaleAtt.B_Teeth_Ori
                                    --local teethEndScale = amin uTeethScaleChanged bTeethScaleChanged
        
                                    scaleAtt.L_Eye_New = lEyeEndSCale
                                    scaleAtt.R_Eye_New = rEyeEndSCale
                                    scaleAtt.U_Teeth_New = get_volume_scale teethVolumeArray
                                    scaleAtt.B_Teeth_New = get_volume_scale teethVolumeArray
                                )
                            )
                        )
                    )
                )
            )
        )

    
        on mainRollout open do
        (
            local tool_path = getINISetting ((GetDir #userMacros) + "\\jalScriptLauncher\\ini\\scriptPath.ini") "ExternalScript" "ScriptPath"
            tool_path = tool_path + "\\JalTools\\FCageTool"
            facialCageMeshFullName = tool_path + "\\maxScene\\FCage.max"
            facialRigFullName = tool_path + "\\maxScene\\FCageRig.max"
            vertMatchXml = tool_path + "\\data\\fCageInfo.xml"
    
            AddSubRollout mainSub vertMatchRollout
            AddSubRollout mainSub cageGenRollout
            AddSubRollout mainSub genFacsRollout
            AddSubRollout mainSub modFacsRollout
            AddSubRollout mainSub offsetRollout
        )
    
        on mainRollout resized newSize do
        (
            if newSize[1] > minWidth then
            mainSub.width = newSize[1] - subRollWidthOffset
            else (
                mainRollout.width = minWidth
                mainSub.width = minWidth - subRollWidthOffset
            )
            if newSize[2] > minHeight then mainSub.height = newSize[2] - subRollHeightOffset
            else (
                mainRollout.height = minHeight
                mainSub.height = minHeight - subRollHeightOffset
            )
    
            jal.roll.update_subroll_when_resized mainSub vertMatchRollout
            jal.roll.update_subroll_when_resized mainSub cageGenRollout
            jal.roll.update_subroll_when_resized mainSub genFacsRollout
            jal.roll.update_subroll_when_resized mainSub modFacsRollout
            jal.roll.update_subroll_when_resized mainSub offsetRollout
        )
    )
    jal.tools.facialCageTool = mainRollout
    createDialog jal.tools.facialCageTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)

    clearlistener()
    gc()
)
