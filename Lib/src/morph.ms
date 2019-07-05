struct _Morph (
    channelMaxViewNum = 100,

    fn get_modifier_index inObj = (
        local returnVal = 0
        if inObj.modifiers.count > 0 then (
            for i = 1 to inObj.modifiers.count do (
                if classOf inObj.modifiers[i] == Morpher then returnVal = i
            )
        )

        return returnVal
    ),

    fn get_modifier inObj = (
        local returnVal = undefined
        local modIndex = get_modifier_index inObj
        if modIndex > 0 then (
            returnVal = inObj.modifiers[modIndex]
        )

        return returnval
    ),

    fn get_channel_num inObj = (
        local returnVal = 0
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            local morphChannelExistance = true
            local morphChannelCounter = 0
            while morphChannelExistance do (
                for i = (morphChannelCounter + 1) to (morphChannelCounter + channelMaxViewNum) do (
                    if not(WM3_MC_HasTarget morphMod i) then (
                        returnVal = i - 1
                        morphChannelExistance = false
                        exit
                    )
                )
                morphChannelCounter = morphChannelCounter + channelMaxViewNum
            )
        )

        return returnVal
    ),

    fn get_all_channel_name inObj = (
        local returnVal = #()
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            local channelNum = get_channel_num inObj
            for i = 1 to channelNum do (
                append returnVal (WM3_MC_GetName morphMod i)
            )
        )
        return returnVal
    ),

    fn get_channel_name inObj inIndex = (
        local returnVal = ""
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            returnVal = WM3_MC_GetName morphMod inIndex
        )
        return returnVal
    ),

    fn get_channel_index inObj inName = (
        local returnVal = 0
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            local allNameArray = get_all_channel_name inObj
            returnVal = findItem allNameArray inName
        )
        return returnVal
    ),

    fn get_channel_value_by_name inObj inName = (
        local returnVal = 0
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            local channelIndex = get_channel_index inObj inName
            if channelIndex > 0 then (
                returnVal = WM3_MC_GetValue morphMod channelIndex
            )
        )
        return returnVal
    ),

    fn get_channel_value_by_index inObj inIndex = (
        local returnVal = 0
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            returnVal = WM3_MC_GetValue morphMod channelIndex
        )
        return returnVal
    ),

    fn set_cahnnel_value_by_name inObj inName inVal = (
        local returnVal = false
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            local channelIndex = get_channel_index inObj inName
            if channelIndex > 0 then (
                WM3_MC_SetValue morphMod inVal
                returnVal = true
            )
        )

        return returnVal
    ),

    fn set_channel_name_by_name inObj inTargetName inNewName = (
        local returnVal = false
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            local channelIndex = get_channel_index inObj inTargetName
            if channelIndex > 0 then (
                WM3_MC_SetName morphMod channelIndex inNewName
                returnVal = true
            )
        )
        return returnVal
    ),

    fn set_channel_name_by_index inObj inIndex inName = (
        local returnVal = false
        local morphMod = get_modifier inObj
        if morphMod != undefined then (
            if (WM3_MC_HasTarget morphMod inIndex) then (
                WM3_MC_SetName morphMod inIndex inName
                returnVal = true
            )
        )
        return returnVal
    )
)
