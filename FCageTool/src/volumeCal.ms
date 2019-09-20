(
    local teethVolumeArray = #($R_LipLC_1_Dum,$R_LipUC_1_Dum,$R_OrisE_1_Dum,$R_LipCornerOut_1_Dum,$R_OrisD_1_Dum,$R_LipLInA_1_Dum,$R_LipLInB_1_Dum,$R_LipLInC_1_Dum,$R_LipUInA_1_Dum,$R_LipUInB_1_Dum,$R_LipUInC_1_Dum,$R_LipCornerIn_1_Dum,$L_OrisB_1_Dum,$C_Chin_1_Dum,$R_ChinA_1_Dum,$R_OrisB_1_Dum,$L_ChinA_1_Dum,$L_Risorius_1_Dum,$R_PlastimaC_1_Dum,$R_Risorius_1_Dum,$L_PlastimaC_1_Dum,$L_CheekD_1_Dum,$L_MasseterA_1_Dum,$R_CheekD_1_Dum,$R_Masseter_1_Dum,$R_MasseterB_1_Dum,$L_MasseterB_1_Dum,$L_JowlB_1_Dum,$L_JowlC_1_Dum,$R_JowlD_1_Dum,$R_JowlC_1_Dum,$R_JowlB_00_JNT,$L_JowlD_1_Dum,$L_ZygoD_1_Dum,$L_ZygoC_1_Dum,$R_ZygoE_1_Dum,$R_ZygoD_1_Dum,$R_ZygoC_1_Dum,$L_ZygoE_1_Dum,$R_PhiltrumC_1_Dum,$L_PhiltrumC_1_Dum,$R_ChinTip_1_Dum,$C_ChinTipA_1_Dum,$L_ChinTip_1_Dum,$L_OrisC_1_Dum,$L_ChinB_1_Dum,$L_OrisD_1_Dum,$C_Oris_1_Dum,$R_OrisA_1_Dum,$R_OrisC_1_Dum,$R_ChinB_1_Dum,$L_OrisA_1_Dum,$L_PhiltrumA_1_Dum,$L_LipUA_1_Dum,$L_LipUB_1_Dum,$L_LipUC_1_Dum,$C_LipU_1_Dum,$L_LipLInA_1_Dum,$L_LipLInB_1_Dum,$L_LipUInA_1_Dum,$L_LipUInB_1_Dum,$C_LipLIN_1_Dum,$C_LipUIn_1_Dum,$C_Philtrum_1_Dum,$R_LipUA_1_Dum,$R_PhiltrumA_1_Dum,$R_LipUB_1_Dum,$L_LipLA_1_Dum,$L_LipLB_1_Dum,$L_LipLC_1_Dum,$L_OrisE_1_Dum,$L_LipCornerOut_1_Dum,$L_LipLInC_1_Dum,$L_LipUInC_1_Dum,$L_LipCornerIn_1_Dum,$C_LipL_1_Dum,$R_LipLA_1_Dum,$R_LipLB_1_Dum)

    clearSelection()
    select teethVolumeArray

    local centerPos = [0.0, 0.0, 0.0]

    for item in teethVolumeArray do (
        centerPos.x += item.position.controller.value.x
        centerPos.y += item.position.controller.value.y
        centerPos.z += item.position.controller.value.z
    )
    centerPos = [centerPos.x/teethVolumeArray.count, centerPos.y/teethVolumeArray.count, centerPos.z/teethVolumeArray.count]
    local distanceArray = for item in teethVolumeArray collect (distance centerPos item.position.controller.value)

    local stepIndex = 0
    local tmepMinMaxDist = 0.0
    for i = 1 to teethVolumeArray.count do (
        if tmepMinMaxDist < distanceArray[i] then (
            tmepMinMaxDist = distanceArray[i]
            stepIndex = i
        )
    )
    local maxVal = teethVolumeArray[stepIndex].position.controller.value

    tmepMinMaxDist = distanceArray[stepIndex]
    stepIndex = 0
    for i = 1 to teethVolumeArray.count do (
        if tmepMinMaxDist > distanceArray[i] then (
            tmepMinMaxDist = distanceArray[i]
            stepIndex = i
        )
    )
    local minVal = teethVolumeArray[stepIndex].position.controller.value

    format "CalVal = Min:%  Max:%  dist:% center:%\n" minVal maxVal (distance minVal maxVal) centerPos
    format "maxVal = Min:%  Max:%  dist:% center:%\n" selection.min selection.max (distance selection.min selection.max) selection.center
)
--11.6007
--11.0527
--11.0527/11.6007
