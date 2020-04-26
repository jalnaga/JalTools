struct _FacialWrinkleMapGenerator (
    headBone = undefined,

    controlObjArray = #($L_BrowDown_00_Cur, $R_BrowDown_00_Cur, $C_BrowInUp_00_Cur, $L_BrowOutUp_00_Cur, $R_BrowOutUp_00_Cur, $C_CheekPuff_00_Cur, $L_CheekSquint_00_Cur, $R_CheekSquint_00_Cur, $L_EyeBlink_00_Cur, $R_EyeBlink_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_EyeSquint_00_Cur, $R_EyeSquint_00_Cur, $L_EyeWide_00_Cur, $R_EyeWide_00_Cur, $C_Jaw_00_Cur, $C_JawOpen_00_Cur, $C_Jaw_00_Cur, $C_Jaw_00_Cur, $C_MouthClose_00_Cur, $L_MouthDimple_00_Cur, $R_MouthDimple_00_Cur, $L_MouthFrown_00_Cur, $R_MouthFrown_00_Cur, $C_MouthFunnel_00_Cur, $C_Mouth_00_Cur, $C_Mouth_00_Cur, $L_MouthLower_00_Cur, $R_MouthLower_00_Cur, $L_MouthPress_00_Cur, $R_MouthPress_00_Cur, $C_MouthPucker_00_Cur, $C_MouthRollLower_00_Cur, $C_MouthRollUpper_00_Cur, $C_MouthShrugLower_00_Cur, $C_MouthShrugUpper_00_Cur, $L_MouthSmile_00_Cur, $R_MouthSmile_00_Cur, $L_MouthStretch_00_Cur, $R_MouthStretch_00_Cur, $L_MouthUpper_00_Cur, $R_MouthUpper_00_Cur, $L_NoseSneer_00_Cur, $R_NoseSneer_00_Cur),

    browInCtr = $C_BrowInUp_00_Cur.position.controller[2].y_position.controller[1],
    lBrowOutUpCtr = $L_BrowOutUp_00_Cur.position.controller[2].y_position.controller[1],
    rBrowOutUpCtr = $R_BrowOutUp_00_Cur.position.controller[2].y_position.controller[1],
    lMouthFrownCtr = $L_MouthFrown_00_Cur.position.controller[2].y_position.controller[1],
    rMouthFrownCtr = $R_MouthFrown_00_Cur.position.controller[2].y_position.controller[1],
    lMouthDimpleCtr = $L_MouthDimple_00_Cur.position.controller[2].x_position.controller[1],
    rMouthDimpleCtr = $R_MouthDimple_00_Cur.position.controller[2].x_position.controller[1],
    lMouthStretchCtr = $L_MouthStretch_00_Cur.position.controller[2].x_position.controller[1],
    rMouthStretchCtr = $R_MouthStretch_00_Cur.position.controller[2].x_position.controller[1],
    lBrowDownCtr = $L_BrowDown_00_Cur.position.controller[2].y_position.controller[1],
    rBrowDownCtr = $R_BrowDown_00_Cur.position.controller[2].y_position.controller[1],
    lNoseSneerCtr = $L_NoseSneer_00_Cur.position.controller[2].y_position.controller[1],
    rNoseSneerCtr = $R_NoseSneer_00_Cur.position.controller[2].y_position.controller[1],
    lEyeSquintCtr = $L_EyeSquint_00_Cur.position.controller[2].y_position.controller[1],
    rEyeSquintCtr = $R_EyeSquint_00_Cur.position.controller[2].y_position.controller[1],
    lMouthUpperCtr =$L_MouthUpper_00_Cur.position.controller[2].y_position.controller[1],
    rMouthUpperCtr =$R_MouthUpper_00_Cur.position.controller[2].y_position.controller[1],
    lCheekSquintCtr = $L_CheekSquint_00_Cur.position.controller[2].y_position.controller[1],
    rCheekSquintCtr = $R_CheekSquint_00_Cur.position.controller[2].y_position.controller[1],
    lMouthSmileCtr = $L_MouthSmile_00_Cur.position.controller[2].y_position.controller[1],
    rMouthSmileCtr = $R_MouthSmile_00_Cur.position.controller[2].y_position.controller[1],
    mouthCtr = $C_Mouth_00_Cur.position.controller[2].x_position.controller[1],

    wrinkleAtt = undefined,

    fn set_headBone inObj = (
        local returnval = false
        local modArray = for item in inObj.modifiers collect item
        if modArray.count > 0 then (
            for item in modArray do (
                if item.name == "Attribute Holder" then (
                    headBone = inObj
                    wrinkleAtt = headBone.modifiers["Attribute Holder"].wrinkleMap
                    returnval = true
                )
            )
        )
        returnVal
    ),

    /*C_ForeHeadUp - C_BrowInUp_00_Cur 100% stretch
    L/R_ForeHeadUp - L/R_BrowOutUp_00_Cur 100% stretch
    L/R_MouthCorner - L/R_MouthFrown_00_Cur 100% stretch
    L/R_Palza_Stretch - max L/R_MouthStretch_00_Cur 100% stretch L/R_MouthDimple_00_Cur 100% stretch
    L/R_MouthOut_Stretch - L/R_MouthStretch_00_Cur 100% stretch -> rescale 0.0 ~ 1.0 -> 0.5 ~ 1.0
    L/R_NeckStraint - L/R_MouthStretch_00_Cur 100% stretch
    L/R_EyeBrowIn - L/R_BrowDown_00_Cur 60% L/R_NoseSneer_00_Cur 40% frown
    L/R_EyeInner - L/R_EyeSquint_00_Cur 100% frown
    L/R_Nose -  L/R_NoseSneer_00_Cur 100% frown
    L/R_MouthUp - L/R_MouthUpper_00_Cur 100% frown
    L/R_EyeCorner - L/R_CheekSquint_00_Cur 100% smile
    L/R_MouthOut_Smile -   L/R_MouthSmile_00_Cur 100% C_Mouth_00_Cur 60% smile
    L/R_Palza_Smile - L/R_MouthSmile_00_Cur 100% C_Mouth_00_Cur 60% smile*/
    fn attVal_cal inAVal inBVal inAScale inBScale = (
        local staticMaxVal = 100.0
        local staticMinVal = 0.0
        local returnVal = 0.0

        local scaledVal = ((abs inAVal)*inAScale) + ((abs inBVal)*inBScale)
        if scaledVal < inAVal or scaledVal < inBVal then scaledVal = amax inAVal inBVal
        returnVal = amin staticMaxVal scaledVal

        return returnVal
    ),

    fn remap_range inVal inPrevMin inPrevMax inNewMin inNewMax = (
        local returnVal = inNewMin + (inVal - inPrevMin) * (inNewMax - inNewMin) / (inPrevMax - inPrevMin)

        return returnVal
    ),

    fn gen_value = (
        local lMouthValue = 0.0
        local rMouthValue = 0.0
        if mouthCtr.value > 0 then lMouthValue = mouthCtr.value
        if mouthCtr.value < 0 then rMouthValue = abs mouthCtr.value
        wrinkleAtt.C_ForeHeadUp = abs browInCtr.value
        wrinkleAtt.L_ForeHEadUp = abs lBrowOutUpCtr.value
        wrinkleAtt.R_ForeHEadUp = abs rBrowOutUpCtr.value
        wrinkleAtt.L_MouthCorner = abs lMouthFrownCtr.value
        wrinkleAtt.R_MouthCorner = abs rMouthFrownCtr.value
        wrinkleAtt.L_Palza_Stretch = attVal_cal lMouthStretchCtr.value lMouthDimpleCtr.value 0.6 0.4
        wrinkleAtt.R_Palza_Stretch = attVal_cal rMouthStretchCtr.value rMouthDimpleCtr.value 0.6 0.4
        wrinkleAtt.L_MouthOut_Stretch = abs lMouthStretchCtr.value
        wrinkleAtt.R_MouthOut_Stretch = abs rMouthStretchCtr.value
        wrinkleAtt.L_NeckStraint = amax 0.0 (remap_range (abs lMouthStretchCtr.value) 0.0 100.0 -60.0 100.0)
        wrinkleAtt.R_NeckStraint = amax 0.0 (remap_range (abs rMouthStretchCtr.value) 0.0 100.0 -60.0 100.0)
        wrinkleAtt.L_EyeBrowIn = attVal_cal lBrowDownCtr.value lNoseSneerCtr.value 0.6 0.4
        wrinkleAtt.R_EyeBrowIn = attVal_cal rBrowDownCtr.value rNoseSneerCtr.value 0.6 0.4
        wrinkleAtt.L_EyeIn = abs lEyeSquintCtr.value
        wrinkleAtt.R_EyeIn = abs rEyeSquintCtr.value
        wrinkleAtt.L_Nose = abs lNoseSneerCtr.value
        wrinkleAtt.R_Nose = abs rNoseSneerCtr.value
        wrinkleAtt.L_MouthUp = abs lMouthUpperCtr.value
        wrinkleAtt.R_MouthUp = abs lMouthUpperCtr.value
        wrinkleAtt.L_EyeCorner = abs lCheekSquintCtr.value
        wrinkleAtt.R_EyeCorner = abs rCheekSquintCtr.value
        wrinkleAtt.L_MouthOut_Smile = attVal_cal lMouthSmileCtr.value lMouthValue 1.0 0.6
        wrinkleAtt.R_MouthOut_Smile = attVal_cal rMouthSmileCtr.value rMouthValue 1.0 0.6
        wrinkleAtt.L_Palza_Smile = attVal_cal lMouthSmileCtr.value lMouthValue 1.0 0.6
        wrinkleAtt.R_Palza_Smile = attVal_cal rMouthSmileCtr.value rMouthValue 1.0 0.6

        wrinkleAtt.C_ForeHeadUp *= 0.01
        wrinkleAtt.L_ForeHEadUp *= 0.01
        wrinkleAtt.R_ForeHEadUp *= 0.01
        wrinkleAtt.L_MouthCorner *= 0.01
        wrinkleAtt.R_MouthCorner *= 0.01
        wrinkleAtt.L_Palza_Stretch *= 0.01
        wrinkleAtt.R_Palza_Stretch *= 0.01
        wrinkleAtt.L_MouthOut_Stretch *= 0.01
        wrinkleAtt.R_MouthOut_Stretch *= 0.01
        wrinkleAtt.L_NeckStraint *= 0.01
        wrinkleAtt.R_NeckStraint *= 0.01
        wrinkleAtt.L_EyeBrowIn *= 0.01
        wrinkleAtt.R_EyeBrowIn *= 0.01
        wrinkleAtt.L_EyeIn *= 0.01
        wrinkleAtt.R_EyeIn *= 0.01
        wrinkleAtt.L_Nose *= 0.01
        wrinkleAtt.R_Nose *= 0.01
        wrinkleAtt.L_MouthUp *= 0.01
        wrinkleAtt.R_MouthUp *= 0.01
        wrinkleAtt.L_EyeCorner *= 0.01
        wrinkleAtt.R_EyeCorner *= 0.01
        wrinkleAtt.L_MouthOut_Smile *= 0.01
        wrinkleAtt.R_MouthOut_Smile *= 0.01
        wrinkleAtt.L_Palza_Smile *= 0.01
        wrinkleAtt.R_Palza_Smile *= 0.01
    ),

    fn assign_frame_to_att inStart inEnd = (
        with animate on (
            for i = inStart to inEnd do (
                at time i gen_value()
            )
        )
    ),

    fn delete_value = (
        deleteKeys wrinkleAtt #allKeys
    )
)
