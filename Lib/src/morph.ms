struct _MorphChannel (
    index = 0,
    name = "",
    hasData = false
)
/*************************************************************/
/*Morph library can deel with ONLY ONE Morpher modifier.
/*If you want to use method, you should initialize.
/*************************************************************/
struct _Morph (
    channelMaxViewNum = 100,
    morphModIndex = 0,
    morphMod = undefined,
    channelNum = 0,
    channelArray = #(),

    fn reset = (
        channelMaxViewNum = 100
        morphModIndex = 0
        morphMod = undefined
        channelNum = 0
        channelArray = #()
    ),

    fn get_modifier_index inObj = (
        local returnVal = 0
        if inObj.modifiers.count > 0 then (
            for i = 1 to inObj.modifiers.count do (
                if classOf inObj.modifiers[i] == Morpher then (
                    returnVal = i
                    morphModIndex = i
                    morphMod = inObj.modifiers[i]
                )
            )
        )

        return returnVal
    ),

    fn get_modifier inObj = (
        local returnVal = undefined
        local modIndex = get_modifier_index inObj
        if modIndex > 0 then returnVal = morphMod

        return returnval
    ),

    fn get_channel_num = (
        local returnVal = 0
        if morphMod != undefined then (
            local morphChannelExistance = true
            local morphChannelCounter = 0
            while morphChannelExistance do (
                for i = (morphChannelCounter + 1) to (morphChannelCounter + channelMaxViewNum) do (
                    if not(WM3_MC_HasData morphMod i) then (
                        returnVal = i - 1
                        morphChannelExistance = false
                        exit
                    )
                )
                morphChannelCounter = morphChannelCounter + channelMaxViewNum
            )
            channelNum = returnVal
        )

        return returnVal
    ),

    fn gen_all_channel_info = (
        local returnVal = false
        if morphMod != undefined then (
            get_channel_num()
            if channelNum > 0 then (
                channelArray = #()
                for i = 1 to channelNum do (
                    local tempChannel = _MorphChannel()
                    tempChannel.index = i
                    tempChannel.hasData = WM3_MC_HasData morphMod i
                    tempChannel.name = WM3_MC_GetName morphMod i
                    append channelArray tempChannel
                )
                return true
            )
        )
    ),

    fn init inObj = (
        local returnVal = false
        if (get_modifier inObj) != undefined then (
            returnVal = gen_all_channel_info()
        )

        return returnVal
    ),

    fn add_target inTarget inIndex = (
        local returnVal = false
        if morphMod != undefined then (
            returnVal = WM3_MC_BuildFromNode morphMod inIndex inTarget
            gen_all_channel_info()
        )
        return returnVal
    ),

    fn add_targets inTargetArray = (
        local returnVal = false
        if morphMod != undefined then (
            for i = 1 to inTargetArray.count do (
                WM3_MC_BuildFromNode morphMod i inTargetArray[i]
            )
            gen_all_channel_info()
        )
    ),

    fn get_all_channel_name = (
        local returnVal = #()
        if channelArray.count > 0 then (
            returnval = for item in channelArray collect item.name
        )
        return returnVal
    ),

    fn get_channel_name inIndex = (
        local returnVal = ""
        if channelArray.count > 0 then (
            returnVal = channelArray[inIndex].name
        )
        return returnVal
    ),

    fn get_channel_index inName = (
        local returnVal = 0
        if channelArray.count > 0 then (
            for item in channelArray do (
                if item.name == inName then (
                    returnval = item.index
                    exit
                )
            )
        )
        return returnVal
    ),

    fn get_channel_value_by_name inName = (
        local returnVal = 0.0
        if morphMod != undefined then (
            local channelIndex = get_channel_index inName
            if channelIndex > 0 then (
                returnVal = WM3_MC_GetValue morphMod channelIndex
            )
        )
        return returnVal
    ),

    fn get_channel_value_by_index inIndex = (
        local returnVal = 0
        if morphMod != undefined then (
            returnVal = WM3_MC_GetValue morphMod channelIndex
        )
        return returnVal
    ),

    fn set_cahnnel_value_by_name inName inVal = (
        local returnVal = false
        if morphMod != undefined then (
            local channelIndex = get_channel_index inName
            if channelIndex > 0 then (
                WM3_MC_SetValue morphMod channelIndex inVal
                returnVal = true
            )
        )

        return returnVal
    ),

    fn set_channel_value_by_index inIndex inVal = (
        local returnVal = false
        if morphMod != undefined then (
            WM3_MC_SetValue morphMod inIndex inVal
            returnVal = true
        )

        return returnVal
    ),

    fn set_channel_name_by_name inTargetName inNewName = (
        local returnVal = false
        if morphMod != undefined then (
            local channelIndex = get_channel_index inTargetName
            if channelIndex > 0 then (
                WM3_MC_SetName morphMod channelIndex inNewName
                channelArray[channelIndex].name = inNewName
                returnVal = true
            )
        )
        return returnVal
    ),

    fn set_channel_name_by_index inIndex inName = (
        local returnVal = false
        if morphMod != undefined then (
            WM3_MC_SetName morphMod inIndex inName
            channelArray[inIndex].name = inNewName
            returnVal = true
        )
        return returnVal
    )
)
