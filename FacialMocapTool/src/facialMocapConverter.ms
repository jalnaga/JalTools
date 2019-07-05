struct _FacialMocapConverter (
    sourceHead = undefined,
    allChannelNameArray = #("browDownLeft", "browDownRight", "browInnerUp", "browOuterUpLeft", "browOuterUpRight", "cheekPuff", "cheekSquintLeft", "cheekSquintRight", "eyeBlinkLeft", "eyeBlinkRight", "eyeLookDownLeft", "eyeLookDownRight", "eyeLookInLeft", "eyeLookInRight", "eyeLookOutLeft", "eyeLookOutRight", "eyeLookUpLeft", "eyeLookUpRight", "eyeSquintLeft", "eyeSquintRight", "eyeWideLeft", "eyeWideRight", "jawForward", "jawOpen", "jawLeft", "jawRight", "mouthClose", "mouthDimpleLeft", "mouthDimpleRight", "mouthFrownLeft", "mouthFrownRight", "mouthFunnel", "mouthLeft", "mouthRight", "mouthLowerDownLeft", "mouthLowerDownRight", "mouthPressLeft", "mouthPressRight", "mouthPucker", "mouthRollLower", "mouthRollUpper", "mouthShrugLower", "mouthShrugUpper", "mouthSmileLeft", "mouthSmileRight", "mouthStretchLeft", "mouthStretchRight", "mouthUpperUpLeft", "mouthUpperUpRight", "noseSneerLeft", "noseSneerRight"),

    fn set_sourceHead inObj = (
        if (jal.mor.get_modifier_index inObj) > 0 then (
            sourceHead = inObj
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
            local nameArray = jal.mor.get_all_channel_name sourceHead
            for i = 1 to nameArray.count do (
                local oriName = nameArray[i]
                local newName = oriName
                if (jal.name.get_filteringChar oriName) == "_" then (
                    newName = jal.name.get_realName oriName
                    if (MatchPattern oriName pattern:leftPattern) then newName = newName + leftChar
                    if (MatchPattern oriName pattern:rightPattern) then newName = newName + rightChar
                )
                jal.mor.set_channel_name_by_index sourceHead i newName
            )
            return true
        )
        else return false
    ),

    fn get_channelValue = (
        local returnArray = #()
        if sourceHead != undefined then (
            for item in allChannelNameArray do (
                local channelVal = jal.mor.get_channel_value_by_name sourceHead item
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
            jal.prog.update_progress i inEnd inProgressText:"Converting to XML..."
        )
        jal.prog.end_progress()
        animationRange.start = oriStart
        animationRange.end = oriEnd
        if (returnNode.get_children()).count > 0 then (
            return returnNode
        )
        else return false
    )
)
