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
