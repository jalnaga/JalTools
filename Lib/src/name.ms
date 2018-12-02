struct _Name (
    /*************************************************/
    /* Default name structure:
    /*    [Base] [Type] [Side] [RealName] [Index]
    /*    ex) Bip001 Dummy L SpineA 001
    /*************************************************/

    fn split_into_string_and_digit inStr = (
        t = trimRight inStr "0123456789"
        #(t, substring inStr (t.count+1) -1)
    ),

    fn get_filteringChar inStr = (
        if (matchPattern inStr pattern:"* *") then return " "
        if (matchPattern inStr pattern:"*_*") then return "_"
        return ""
    ),

    fn is_nub inStr = (
        local filChar = get_filteringChar inStr
        local patternStr = "*" + filChar + "Nub"
        local returnVal = matchPattern inStr pattern:patternStr

        returnVal
    ),

    fn get_index inStr = (
        if (is_nub inStr) then return "Nub"

        indexStr = (split_into_string_and_digit inStr)[2]
        if indexStr != "" then return indexStr
        else return ""
    ),

    fn get_index_as_digit inStr = (
        if (is_nub inStr) then return -1

        indexStr = get_index inStr
        if indexStr != "" then (
            index = execute indexStr
            return index
        )
        else return false
    ),

    fn get_string inStr = (
        local filteringChar = get_filteringChar inStr
        local nameStr = (split_into_string_and_digit inStr)[1]
        if nameStr != "" then (
            local nameArray = filterString nameStr filteringChar
            local returnName = ""
            if nameArray.count > 1 then (
                local nubShifter = 0
                if (is_nub inStr) then nubShifter = 1
                for i = 1 to (nameArray.count - 1 - nubShifter) do (
                    returnName += nameArray[i]
                    returnName += filteringChar
                )
                returnName += nameArray[nameArray.count - nubShifter]
            )
            else (
                if (is_nub inStr) then returnName = ""
                else returnName = nameArray[1]
            )

            return returnName
        )
        else return ""
    ),

    fn set_index_as_nub inStr = (
        local filChar = get_filteringChar inStr
        local nameStr = get_string inStr
        local returnName
        if nameStr != "" then returnName = nameStr + filChar + "Nub"
        else returnName = inStr
        returnName
    ),

    fn get_side_char inStr = (
        local filChar = get_filteringChar inStr
        if filChar != "" then (
            local nameStr = get_string inStr
            if nameStr != "" then (
                local patternStr = "*" + filChar + "?" + filChar + "*"
                if (matchPattern nameStr pattern:patternStr) then (
                    local nameArray = filterString nameStr filChar
                    if nameArray.count > 1 then (
                        for i = 2 to nameArray.count do (
                            if nameArray[i].count == 1 then return nameArray[i]
                        )
                    )
                )
            )
        )
        
        return false
    ),

    fn is_left inStr = (
        local sideChar = get_side_char inStr
        if (classOf sideChar) == string then (
            sideChar = toUpper sideChar
            if sideChar == "L" then return true
        )
        return false
    ),

    fn is_right inStr = (
        local sideChar = get_side_char inStr
        if (classOf sideChar) == string then (
            sideChar = toUpper sideChar
            if sideChar == "R" then return true
        )
        return false
    ),

    fn is_front inStr = (
        local sideChar = get_side_char inStr
        if (classOf sideChar) == string then (
            sideChar = toUpper sideChar
            if sideChar == "F" then return true
        )
        return false
    ),

    fn is_back inStr = (
        local sideChar = get_side_char inStr
        if (classOf sideChar) == string then (
            sideChar = toUpper sideChar
            if sideChar == "B" then return true
        )
        return false
    ),

    fn has_side inStr = (
        if (is_left inStr) then return true
        if (is_right inStr) then return true
        if (is_front inStr) then return true
        if (is_back inStr) then return true

        return false
    ),

    fn get_side inStr = (
        if (is_left inStr) then return "L"
        if (is_right inStr) then return "R"
        if (is_front inStr) then return "F"
        if (is_back inStr) then return "B"

        return ""
    ),

    fn get_base inStr = (
        local nameStr = get_string inStr
        local filChar = get_filteringChar inStr
        local nameArray = filterString nameStr filChar
        
        if nameArray.count > 1 then return nameArray[1]

        return ""
    ),

    fn get_type inStr = (
        local nameStr = get_string inStr
        local filChar = get_filteringChar inStr
        local nameArray = filterString nameStr filChar

        if nameArray.count > 2 then (
            if (has_side inStr) then (
                local sideChar = get_side inStr
                local sideIndex = findItem nameArray sideChar
                if sideIndex > 2 then return NameArray [2]
            )
            else return nameArray[2]
        )

        return ""
    ),

    fn get_nonRealName inStr = (
        local filChar = get_filteringChar inStr
        local nameStr = get_string inStr
        local base = get_base inStr
        local type = get_type inStr
        local side = get_side inStr
        
        local nonRealNameStr = ""
        if base != "" then nonRealNameStr += base + filChar
        if type != "" then nonRealNameStr += type + filChar
        if side != "" then nonRealNameStr += side + filChar

        if nonRealNameStr.count > 1 then nonRealNameStr = replace nonRealNameStr (nonRealNameStr.count - 1) 1 ""

        return nonRealNameStr
    ),

    fn get_realName inStr = (
        local returnStr = ""
        local filChar = get_filteringChar inStr
        local nameStr = get_string inStr
        
        local nonRealNameStr = get_nonRealName inStr
        
        if nonRealNameStr.count > 0 then returnStr = replace nameStr 1 (nonRealNameStr.count + 1) ""
        else returnStr = nameStr
        
        return returnStr
    ),

    fn combine inBase inType inSide inRealName inIndex inFilChar = (
        local returnStr = ""
        if inBase != "" then returnStr += inBase + inFilChar
        if inType != "" then returnStr += inType + inFilChar
        if inSide != "" then returnStr += inSide + inFilChar
        if inRealName != "" then returnStr += inRealName
        if inIndex != "" then (
            if returnStr.count > 0 then returnStr += inFilChar
            returnStr += inIndex
        )

        return returnStr
    ),

    fn add_prefix_to_realName inStr inPrefix = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local type = get_type inStr
        local side = get_side inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine base type side (inPreFix + realName) index filChar)
    ),

    fn add_sufix_to_realName inStr inSufix = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local type = get_type inStr
        local side = get_side inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine base type side (realName + inSufix) index filChar)
    ),

    fn set_index_padding_num inStr inPaddingNum:3 = (
        local indexStr = get_index inStr
        local formatStr = "0" + (inPaddingNum as String) + "d"
        local index = get_index_as_digit inStr
        
        if indexStr != "" then (
            if index > -1 then indexStr = formattedPrint index format:formatStr
            if index == -1 then indexStr = "Nub"
        )

        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local type = get_type inStr
        local side = get_side inStr
        local realName = get_realName inStr

        return (combine base type side realName indexStr filChar)
    ),

    fn get_index_padding_num inStr = (
        local index = get_index inStr
        if index != "Nub" then (
            if index.count > 0 then return index.count
        )

        return 1
    ),

    fn increase_index inStr inAmount = (
        local newName = ""
        if (is_nub inStr) == false then (
            local filChar = get_filteringChar inStr
            local base = get_base inStr
            local type = get_type inStr
            local side = get_side inStr
            local realName = get_realName inStr
            local index = get_index inStr
            local indexNum = get_index_as_digit inStr
            local indexPaddingNum = get_index_padding_num inStr

            if indexNum == false then indexNum = 0
            indexNum = indexNum + inAmount
            if indexNum == -1 then indexNum = "Nub"
            newName = combine base type side realName (indexNum as string) filChar
            newName = set_index_padding_num newName inPaddingNum:indexPaddingNum
        )
        else newName = inStr

        return newName
    ),

    fn replace_filteringChar inStr inNewFilChar = (
        local base = get_base inStr
        local type = get_type inStr
        local side = get_side inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine base type side realName index inNewFilChar)
    ),

    fn replace_base inStr inNewBase = (
        local filChar = get_filteringChar inStr
        local type = get_type inStr
        local side = get_side inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine inNewBase type side realName index filChar)
    ),

    fn replace_type inStr inNewType = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local side = get_side inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine base inNewType side realName index filChar)
    ),

    fn replace_side inStr inNewSide = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local type = get_type inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine base type inNewSide realName index filChar)
    ),

    fn replace_index inStr inNewIndex keepPadding:true = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local type = get_type inStr
        local side = get_side inStr
        local realName = get_realName inStr

        local returnName = combine base type side realName inNewIndex filChar
        if keepPadding then (
            local indexPaddingNum = get_index_padding_num inStr
            returnName = set_index_padding_num returnName inPaddingNum:indexPaddingNum
        )

        return returnName
    ),

    fn replace_realName inStr inNewRealName = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local type = get_type inStr
        local side = get_side inStr
        local index = get_index inStr

        return (combine base type side inNewRealName index filChar)
    ),

    fn remove_type inStr = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local side = get_side inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine base "" side realName index filChar)
    ),

    fn remove_side inStr = (
        local filChar = get_filteringChar inStr
        local base = get_base inStr
        local type = get_type inStr
        local realName = get_realName inStr
        local index = get_index inStr

        return (combine base type "" realName index filChar)
    ),

    fn remove_index inStr = (
        local returnName = replace_index inStr ""
        returnName
    ),

    fn remove_base inStr = (
        local returnName = replace_base inStr ""
        returnName
    ),

    fn gen_mirroring_name inStr = (
        local returnName = inStr
        if (is_left inStr) then returnName = replace_side inStr "R"
        if (is_right inStr) then returnName = replace_side inStr "L"
        if (is_front inStr) then returnName = replace_side inStr "B"
        if (is_back inStr) then returnName = replace_side inStr "F"

        if returnName == inStr then returnName = increase_index inStr 1

        return returnName
    ),

    fn sort_by_index inNameArray = (
        if inNameArray.count > 0 then (
            struct indexSorting (oriIndex, newIndex)

            local sortedNameArray = #()
            local structArray = #()

            for i = 1 to inNameArray.count do (
                local tempIndex = get_index_as_digit inNameArray[i]
                if tempIndex == false then (
                    structArray[i] indexSorting i 0
                )
                else structArray[i] = indexSorting i tempIndex
            )

            qsort structArray (fn myLevel v1 v2 = (v1.newIndex - v2.newIndex))

            for i = 1 to inNameArray.count do append sortedNameArray inNameArray[structArray[i].oriIndex]

            return sortedNameArray
        )
        return #()
    ),

    fn gen_uniqueName inStr indexPaddingNum:1 = (
        local oriName = get_string inStr
        local filChar = get_filteringChar inStr
        local resultName = uniqueName (oriName + filChar)
        local indexStr = (get_index_as_digit resultName) as String
        resultName = replace_index resultName indexStr
        resultName = set_index_padding_num resultName inPaddingNum:indexPaddingNum

        resultName
    )
)
