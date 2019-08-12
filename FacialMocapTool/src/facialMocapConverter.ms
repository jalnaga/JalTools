struct _FacialCtrl (
    obj = undefined,
    xController = undefined,
    yController = undefined,
    xPositiveChannel = "",
    xNegativeChaneel = "",
    yPositiveChannel = "",
    yNegativeChannel = "",

    fn init inObj inXPosCh:"" inXNegCh:"" inYPosCh:"" inYNegCh:"" = (
        obj = inObj
        xPositiveChannel = inXPosCh
        xNegativeChaneel = inXNegCh
        yPositiveChannel = inYPosCh
        yNegativeChannel = inYNegCh

        if xPositiveChannel != "" or xNegativeChaneel != "" then xController = obj.position.controller[2].x_position.controller[1]
        if yPositiveChannel != "" or yNegativeChannel != "" then yController = obj.position.controller[2].y_position.controller[1]
    ),

    fn set_value inValue = (
        local saturatedValue = amax 0.0 inValue
        saturatedValue = amin 100.0 saturatedValue
        if xPositiveChannel != "" then xController.value = saturatedValue
        if xNegativeChaneel != "" then xController.value = saturatedValue * (-1.0)
        if yPositiveChannel != "" then yController.value = saturatedValue
        if yNegativeChannel != "" then yController.value = saturatedValue * (-1.0)
    )
)
struct _FacialMocapConverter (
    sourceHead = undefined,
    morphMod = undefined,
    allChannelNameArray = #("browDownLeft", "browDownRight", "browInnerUp", "browOuterUpLeft", "browOuterUpRight", "cheekPuff", "cheekSquintLeft", "cheekSquintRight", "eyeBlinkLeft", "eyeBlinkRight", "eyeLookDownLeft", "eyeLookDownRight", "eyeLookInLeft", "eyeLookInRight", "eyeLookOutLeft", "eyeLookOutRight", "eyeLookUpLeft", "eyeLookUpRight", "eyeSquintLeft", "eyeSquintRight", "eyeWideLeft", "eyeWideRight", "jawForward", "jawOpen", "jawLeft", "jawRight", "mouthClose", "mouthDimpleLeft", "mouthDimpleRight", "mouthFrownLeft", "mouthFrownRight", "mouthFunnel", "mouthLeft", "mouthRight", "mouthLowerDownLeft", "mouthLowerDownRight", "mouthPressLeft", "mouthPressRight", "mouthPucker", "mouthRollLower", "mouthRollUpper", "mouthShrugLower", "mouthShrugUpper", "mouthSmileLeft", "mouthSmileRight", "mouthStretchLeft", "mouthStretchRight", "mouthUpperUpLeft", "mouthUpperUpRight", "noseSneerLeft", "noseSneerRight"),
    controlObjArray = #($L_BrowDown_00_Cur, $R_BrowDown_00_Cur, $C_BrowInUp_00_Cur, $L_BrowOutUp_00_Cur, $R_BrowOutUp_00_Cur, $C_CheekPuff_00_Cur, $L_CheekSquint_00_Cur, $R_CheekSquint_00_Cur, $L_EyeBlink_00_Cur, $R_EyeBlink_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_EyeSquint_00_Cur, $R_EyeSquint_00_Cur, $L_EyeWide_00_Cur, $R_EyeWide_00_Cur, $C_Jaw_00_Cur, $C_JawOpen_00_Cur, $C_Jaw_00_Cur, $C_Jaw_00_Cur, $C_MouthClose_00_Cur, $L_MouthDimple_00_Cur, $R_MouthDimple_00_Cur, $L_MouthFrown_00_Cur, $R_MouthFrown_00_Cur, $C_MouthFunnel_00_Cur, $C_Mouth_00_Cur, $C_Mouth_00_Cur, $L_MouthLower_00_Cur, $R_MouthLower_00_Cur, $L_MouthPress_00_Cur, $R_MouthPress_00_Cur, $C_MouthPucker_00_Cur, $C_MouthRollLower_00_Cur, $C_MouthRollUpper_00_Cur, $C_MouthShrugLower_00_Cur, $C_MouthShrugUpper_00_Cur, $L_MouthSmile_00_Cur, $R_MouthSmile_00_Cur, $L_MouthStretch_00_Cur, $R_MouthStretch_00_Cur, $L_MouthUpper_00_Cur, $R_MouthUpper_00_Cur, $L_NoseSneer_00_Cur, $R_NoseSneer_00_Cur),
    allRigControllerArray = #(),
    channelValueSaveArray = #(),

    fn set_sourceHead inObj = (
        if (jal.mor.get_modifier_index inObj) > 0 then (
            sourceHead = inObj
            morphMod = jal.mor.get_modifier inObj
            return true
        )
        else return false
    ),

    fn convert_morphTargetName = (
        if sourceHead != undefined then (
            local leftChar = "Left"
            local leftPattern = "*_L"
            local rightChar = "Right"
            local rightPattern = "*_R"

            jal.prog.start_progress "Converting Morphtarget Name..." useDialog:false
            local nameArray = jal.mor.get_all_channel_name sourceHead
            local nameArrayCount = nameArray.count
            for i = 1 to nameArrayCount do (
                local oriName = nameArray[i]
                local newName = oriName
                if (matchPattern oriName pattern:"*_*") == "_" then (
                    local filteredNameArray = filterString oriName "_"
                    newName = filteredNameArray[1]
                    if (MatchPattern oriName pattern:leftPattern) then newName = newName + leftChar
                    if (MatchPattern oriName pattern:rightPattern) then newName = newName + rightChar
                )
                if (WM3_MC_HasData morphMod i) then (
                    WM3_MC_SetName morphMod i newName
                )
                jal.prog.update_progress i nameArrayCount inProgressText:"Converting Morphtarget Name..."
            )
            jal.prog.end_progress()
            return true
        )
        else return false
    ),

    fn get_channelValue = (
        local returnArray = #()
        if sourceHead != undefined then (
            for item in allChannelNameArray do (
                local foundIndex = findItem allChannelNameArray item
                local channelVal = WM3_MC_GetValue morphMod foundIndex
                append returnArray channelVal
            )
        )

        return returnArray
    ),

    fn gen_xmlNode_for_frame inFrame inXDoc = (
        local channelValueArray = get_channelValue()
        if channelValueArray.count == allChannelNameArray.count then (
            local returnFrameNode = inXDoc.create_node "Frame"
            returnFrameNode.add_attribute "num" (inFrame as String)
            for i = 1 to allChannelNameArray.count do (
                local channelNode = inXDoc.create_node allChannelNameArray[i]
                channelNode.add_attribute "index" (i as String)
                channelNode.add_attribute "name" allChannelNameArray[i]
                channelNode.add_attribute "value" (channelValueArray[i] as String)

                returnFrameNode.append_child_node channelNode
            )
            return returnFrameNode
        )
        else return undefined
    ),

    fn gen_xmlNode_for_range inStart inEnd inXDoc = (
        local returnNode = inXDoc.create_node "Range"
        local oriStart = animationRange.start
        local oriEnd = animationRange.end
        animationRange.start = inStart
        animationRange.end = inEnd
        jal.prog.start_progress "Export Facial Motions..." useDialog:false
        for i = inStart to inEnd do (
            at time i (
                local frameNode = gen_xmlNode_for_frame i inXDoc
                if frameNode != undefined then (
                    returnNode.append_child_node frameNode
                )
            )
            jal.prog.update_progress i inEnd inProgressText:"Export Facial Motions to XML..."
        )
        jal.prog.end_progress()
        animationRange.start = oriStart
        animationRange.end = oriEnd
        if (returnNode.get_children()).count > 0 then (
            return returnNode
        )
        else return false
    ),

    fn gen_rigController = (
        allRigControllerArray = #()
        for i = 1 to allChannelNameArray.count do (
            local rigCtrl = _FacialCtrl()
            rigCtrl.init controlObjArray[i] inYPosCh:allChannelNameArray[i]
            append allRigControllerArray rigCtrl
        )
        allRigControllerArray[6].init controlObjArray[6] inXPosCh:"cheekPuff" inXNegCh:"" inYPosCh:"" inYNegCh:""

        allRigControllerArray[11].init controlObjArray[11] inXPosCh:"" inXNegCh:"" inYPosCh:"" inYNegCh:"eyeLookDownLeft"
        allRigControllerArray[12].init controlObjArray[12] inXPosCh:"" inXNegCh:"" inYPosCh:"" inYNegCh:"eyeLookDownRight"
        allRigControllerArray[13].init controlObjArray[13] inXPosCh:"" inXNegCh:"eyeLookInLeft" inYPosCh:"" inYNegCh:""
        allRigControllerArray[14].init controlObjArray[14] inXPosCh:"eyeLookInRight" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[15].init controlObjArray[15] inXPosCh:"eyeLookOutLeft" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[16].init controlObjArray[16] inXPosCh:"" inXNegCh:"eyeLookOutRight" inYPosCh:"" inYNegCh:""
        allRigControllerArray[17].init controlObjArray[17] inXPosCh:"" inXNegCh:"" inYPosCh:"eyeLookUpLeft" inYNegCh:""
        allRigControllerArray[18].init controlObjArray[18] inXPosCh:"" inXNegCh:"" inYPosCh:"eyeLookUpRight" inYNegCh:""

        allRigControllerArray[23].init controlObjArray[23] inXPosCh:"" inXNegCh:"" inYPosCh:"" inYNegCh:"jawForward"
        allRigControllerArray[24].init controlObjArray[24] inXPosCh:"" inXNegCh:"" inYPosCh:"" inYNegCh:"jawOpen"
        allRigControllerArray[25].init controlObjArray[25] inXPosCh:"jawLeft" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[26].init controlObjArray[26] inXPosCh:"" inXNegCh:"jawRight" inYPosCh:"" inYNegCh:""

        allRigControllerArray[28].init controlObjArray[28] inXPosCh:"mouthDimpleLeft" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[29].init controlObjArray[29] inXPosCh:"mouthDimpleRight" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[33].init controlObjArray[33] inXPosCh:"mouthLeft" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[34].init controlObjArray[34] inXPosCh:"" inXNegCh:"mouthRight" inYPosCh:"" inYNegCh:""
        allRigControllerArray[39].init controlObjArray[39] inXPosCh:"" inXNegCh:"mouthPucker" inYPosCh:"" inYNegCh:""
        allRigControllerArray[40].init controlObjArray[40] inXPosCh:"mouthRollLower" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[41].init controlObjArray[41] inXPosCh:"mouthRollUpper" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[46].init controlObjArray[46] inXPosCh:"mouthStretchLeft" inXNegCh:"" inYPosCh:"" inYNegCh:""
        allRigControllerArray[47].init controlObjArray[47] inXPosCh:"mouthStretchRight" inXNegCh:"" inYPosCh:"" inYNegCh:""
    ),

    fn get_diffrence inPosVal inNegVal = (
        local returnVal = 0.0
        returnVal = inPosVal - inNegVal

        return returnVal
    ),

    fn set_channelValue_between_pos_neg inPosIndex inNegIndex = (
        local diffVal = get_diffrence channelValueSaveArray[inPosIndex] channelValueSaveArray[inNegIndex]
        if diffVal > 0 then (
            allRigControllerArray[inPosIndex].set_value (abs diffVal)
        )
        if diffVal < 0 then (
            allRigControllerArray[inNegIndex].set_value (abs diffVal)
        )
        if diffVal == 0 then (
            allRigControllerArray[inNegIndex].set_value 0.0
        )
    ),

    fn set_channelValueSaveArray inFrameNode = (
        channelValueSaveArray = #()
        local childrenNode = inFrameNode.get_children()
        for i = 0 to (childrenNode.count - 1) do (
            local ctrlNode = inFrameNode.get_child i
            local channelIndex = (ctrlNode.get_attribute "index") as Integer
            local channelValue = (ctrlNode.get_attribute "value") as Float
            channelValueSaveArray[channelIndex] = channelValue
        )
    ),

    fn assign_frame_to_control inFrameNode = (
        set_channelValueSaveArray inFrameNode
        for i = 1 to channelValueSaveArray.count do (
            case i of (
                15:(set_channelValue_between_pos_neg 13 15)
                16:(set_channelValue_between_pos_neg 14 16)
                17:(set_channelValue_between_pos_neg 11 17)
                18:(set_channelValue_between_pos_neg 12 18)
                26:(set_channelValue_between_pos_neg 25 26)
                34:(set_channelValue_between_pos_neg 33 34)
                default:(allRigControllerArray[i].set_value channelValueSaveArray[i])
            )
        )
    )
)
