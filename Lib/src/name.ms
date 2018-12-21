struct _Name (
    /*************************************************/
    /* Default name structure:
    /*    [Base] [Type] [Side] [RealName] [Index]
    /*    ex) Bip001 Dummy L SpineA 001
    /*************************************************/
    struct __NP (type, oriIndex, newIndex),
    __nameParts = #((__NP type:#Base oriIndex:1 newIndex:1), (__NP type:#Type oriIndex:2 newIndex:2), (__NP type:#Side oriIndex:3 newIndex:3), (__NP type:#FrontBack oriIndex:4 newIndex:4), (__NP type:#RealName oriIndex:5 newIndex:5), (__NP type:#Index oriIndex:6 newIndex:6)),
    __namePartsOrder = #("Base", "Type", "Side", "FrontBack", "RealName", "Index"),
    --__namePartsOrder = #("Base", "Type","RealName", "Index", "Side", "FrontBack"),
    __nubStr = "Nub",
    __sideStrArray = #("L", "R"),
    __frontBackStrArray = #("F", "B"),

    fn set_nubStr inStr = (
        __nubStr = inStr
    ),

    fn set_leftStr inStr = (
        __sideStrArray[1] = inStr
    ),

    fn set_rightStr inStr = (
        __sideStrArray[2] = inStr
    ),

    fn set_frontStr inStr = (
        __frontBackStrArray[1] = inStr
    ),

    fn set_backStr inStr = (
        __frontBackStrArray[2] = inStr
    ),

    fn get_leftStr = (
        __sideStrArray[1]
    ),

    fn get_rightStr = (
        __sideStrArray[2]
    ),

    fn get_frontStr = (
        __frontBackStrArray[1]
    ),

    fn get_backStr = (
        __frontBackStrArray[2]
    ),

    fn get_base_part_index = (
        local returnVal = findItem __namePartsOrder "Base"

        returnVal
    ),

    fn get_type_part_index = (
        local returnVal = findItem __namePartsOrder "Type"

        returnVal
    ),

    fn get_side_part_index = (
        local returnVal = findItem __namePartsOrder "Side"

        returnVal
    ),

    fn get_front_back_part_index = (
        local returnVal = findItem __namePartsOrder "FrontBack"

        returnVal
    ),

    fn get_realName_part_index = (
        local returnVal = findItem __namePartsOrder "RealName"

        returnVal
    ),

    fn get_index_part_index = (
        local returnVal = findItem __namePartsOrder "Index"

        returnVal
    ),

    fn set_name_parts_order inOrder = (
        __namePartsOrder = inOrder
        __nameParts[1].newIndex = get_base_part_index()
        __nameParts[2].newIndex = get_type_part_index()
        __nameParts[3].newIndex = get_side_part_index()
        __nameParts[4].newIndex = get_front_back_part_index()
        __nameParts[5].newIndex = get_realName_part_index()
        __nameParts[6].newIndex = get_index_part_index()
    ),

    fn split_into_string_and_digit inStr = (
        t = trimRight inStr "0123456789"
        #(t, substring inStr (t.count+1) -1)
    ),

    fn is_upper_case inChar = (
        if inChar == toLower inChar then return false else return true
    ),

    fn is_lower_case inChar = (
        if inChar == toLower inChar then return true else return false
    ),

    fn get_filteringChar inStr = (
        if (matchPattern inStr pattern:"* *") then return " "
        if (matchPattern inStr pattern:"*_*") then return "_"
        return ""
    ),

    fn split_by_filteringChar inStr = (
        local filChar = get_filteringChar inStr
        local returnArray = #()
        local splittedPart = ""
        splittedPart += inStr[1]
        for i = 2 to inStr.count do (
            if (inStr[i] == filChar) then (
                append returnArray splittedPart
                i = i + 1
                splittedPart = ""
            )
            else splittedPart += inStr[i]
        )
        if splittedPart != "" then append returnArray splittedPart

        returnArray
    ),

    fn split_by_upper_case inStr = (
        local returnArray = #()
        local splittedPart = ""
        splittedPart += inStr[1]
        for i = 2 to inStr.count do (
            if (is_upper_case inStr[i]) then (
                append returnArray splittedPart
                splittedPart = inStr[i]
            )
            else splittedPart += inStr[i]
        )
        if splittedPart != "" then append returnArray splittedPart

        returnArray
    ),

    fn has_digit inStr = (
        local digitStr = (split_into_string_and_digit inStr)[2]
        if digitStr != "" then return true
        else return false
    ),

    fn is_digit inStr = (
        local returnVal = false
        if (has_digit inStr) then (
            local splittedStrArray = split_into_string_and_digit inStr
            if splittedStrArray[1] =="" and splittedStrArray[2] != "" then returnVal = true
            else returnVal = false
        )

        returnVal
    ),

    fn is_side_char inChar = (
        local returnVal = false
        if (findItem __sideStrArray inChar) != 0 then returnVal = true
        else returnVal = false
        returnVal
    ),

    fn is_front_back_char inChar = (
        local returnVal = false
        if (findItem __frontBackStrArray inChar) != 0 then returnVal = true
        else returnVal = false
        returnVal
    ),

    fn split_name inStr = (
        local nameArray = #()
        local filChar = get_filteringChar inStr
        if filChar == "" then (
            nameArray = split_by_upper_case inStr
            local tempArray = #()
            for item in nameArray do (
                if (has_digit item) then (
                    local splittedStrArray = split_into_string_and_digit item
                    append tempArray splittedStrArray[1]
                    append tempArray splittedStrArray[2]
                )
                else append tempArray item
            )
            nameArray = deepCopy tempArray
        )
        else nameArray = split_by_filteringChar inStr

        nameArray
    ),

    fn refine_empty_in_nameArray inNameArray = (
        local nameArray = #()
        for item in inNameArray do (
            if item != "" then append nameArray item
        )

        return nameArray
    ),

    fn refine_index_in_nameArray inNameArray = (
        local nameArray = #()
        if inNameArray.count > 0 then (
            local lastDigitIndex = 0
            for i = 1 to inNameArray.count do if (is_digit inNameArray[i]) then lastDigitIndex += 1
            --struct __digitInNameArray (indexAtNameArray = 0, digitStr = "")
            --local foundDigitArray = #()
            --for i = 1 to inNameArray.count do (
            --    if (is_digit inNameArray[i]) then (
            --        local tempDigitInNameArray = __digitInNameArray()
            --        tempDigitInNameArray.indexAtNameArray = i
            --        tempDigitInNameArray.digitStr = inNameArray[i]
            --        append foundDigitArray tempDigitInNameArray
            --    )
            --)

            --if foundDigitArray.count > 1 then (
            --    local indexIndex = get_index_part_index()
            --    for i = 1 to foundDigitArray.count do (
            --    )
            --)
            --else (
            --    -- skip refine index
            --)


            if lastDigitIndex > 2 then (
                for i = 1 to (lastDigitIndex - 1) do (
                    if i + 1 < lastDigitIndex then (
                        if not(is_digit inNameArray[i]) then (
                            if (is_digit inNameArray[i+1]) then (
                                local tempStr = inNameArray[i] + inNameArray[i+1]
                                append nameArray tempStr
                                i += 2
                            )
                            else append nameArray inNameArray[i]
                        )
                    )
                    else append nameArray inNameArray[i]
                )

                for i = lastDigitIndex to inNameArray.count do (
                    append nameArray inNameArray[i]
                )
            )
            else nameArray = deepCopy inNameArray
        )

        nameArray
    ),

    fn refine_nameArray inNameArray = (
        local emptyRefinedNameArray = refine_empty_in_nameArray inNameArray
        local returnNameArray = refine_index_in_nameArray emptyRefinedNameArray

        returnNameArray
    ),

    fn split_into_refined_nameArray inStr = (
        local splittedNameArray = split_name inStr
        local nameArray = refine_nameArray splittedNameArray
        nameArray
    ),

    fn match_nameArray_with_parts_order inNameArray inFilChar = (
        for i = 1 to inNameArray.count do (
            for k = 1 to __nameParts.count do (
                if __nameParts[k].type == #index
            )
        )
    ),

    fn is_nub inStr = (
        local returnVal = false
        local nameArray = split_into_refined_nameArray inStr
        local result = findItem nameArray __nubStr
        if result == 0 then returnVal = false else returnVal = true

        returnVal
    ),

    fn get_index inStr = (
        if (is_nub inStr) then return __nubStr

        local indexStr = ""
        local nameArray = split_into_refined_nameArray inStr
        for i = 1 to nameArray.count do if (is_digit nameArray[i]) then indexStr = nameArray[i]

        indexStr
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

    fn combine_nameArray inNameArray inFilChar = (
        local returnStr = ""
        local copiedNameArray = deepCopy inNameArray
        local refinedNameArray = refine_nameArray copiedNameArray
        if refinedNameArray.count > 1 then (
            for i = 1 to refinedNameArray.count - 1 do (
                returnStr += refinedNameArray[i]
                returnStr += inFilChar
            )

            returnStr += refinedNameArray[refinedNameArray.count]
        )
        else returnStr = refinedNameArray[1]

        returnStr
    ),

    fn get_string inStr = (
        local returnStr = ""
        local filChar = get_filteringChar inStr
        local nameArray = split_into_refined_nameArray inStr
        local indexRemovedNameArray = deepCopy nameArray
        local indexStr = get_index inStr
        local indexOrder = 0
        local returnNameArray = #()

        if indexStr != "" then indexOrder = findItem indexRemovedNameArray indexStr
        if indexOrder > 0 then (
            returnNameArray = deleteItem indexRemovedNameArray indexOrder
        )
        returnStr = combine_nameArray returnNameArray filChar
        returnStr
    ),

    fn set_index_as_nub inStr = (
        local returnName = ""
        local filChar = get_filteringChar inStr
        local nameArray = split_into_refined_nameArray inStr
        local indexStr = get_index inStr
        if indexStr != "" then (
            local indexOrder = findItem nameArray indexStr
            if indexOrder != 0 then nameArray[indexOrder] = __nubStr
        )
        else insertItem __nubStr nameArray (get_index_part_index())
        returnName = combine_nameArray nameArray filChar
        returnName
    ),

    fn get_side_char inStr = (
        local returnChar = ""
        local nameArray = split_into_refined_nameArray inStr
        local index = get_index inStr
        local indexPos = findItem nameArray index

        local indexBeforeNameArray = #()
        local indexAfterNameArray = #()

        local indexBeforeSideCharArray = #()
        local indexAfterSideCharArray = #()

        if indexPos > 0 then (
            for i = 1 to (indexPos - 1) do append indexBeforeNameArray nameArray[i]
            for i = (indexPos + 1) to nameArray.count do append indexAfterNameArray nameArray[i]
            for item in indexBeforeNameArray do (
                local foundSideIndex = findItem __sideStrArray (toUpper item)
                if foundSideIndex > 0 then append indexBeforeSideCharArray item
            )
            for item in indexAfterNameArray do (
                local foundSideIndex = findItem __sideStrArray (toUpper item)
                if foundSideIndex > 0 then append indexAfterSideCharArray item
            )
        )
        else (
            for i = 1 to nameArray.count do append indexBeforeNameArray nameArray[i]
            for item in indexBeforeNameArray do (
                local foundSideIndex = findItem __sideStrArray (toUpper item)
                if foundSideIndex > 0 then append indexBeforeSideCharArray item
            )
            indexAfterSideCharArray = deepCopy indexBeforeSideCharArray
        )

        if indexBeforeSideCharArray.count > 0 or indexAfterSideCharArray.count > 0 then (
            if (get_side_part_index()) < (get_index_part_index()) then (
                if indexBeforeSideCharArray.count > 0 then returnChar = indexBeforeSideCharArray[1]
            )
            else (
                if indexAfterSideCharArray.count > 0 then returnChar = indexAfterSideCharArray[1]
            )
        )

        returnChar
    ),

    fn get_front_back_char inStr = (
        local returnChar = ""
        local nameArray = split_into_refined_nameArray inStr
        local index = get_index inStr
        local indexPos = findItem nameArray index

        local indexBeforeNameArray = #()
        local indexAfterNameArray = #()

        local indexBeforeFrontBackCharArray = #()
        local indexAfterFrontBackCharArray = #()

        if indexPos > 0 then (
            for i = 1 to (indexPos - 1) do append indexBeforeNameArray nameArray[i]
            for i = (indexPos + 1) to nameArray.count do append indexAfterNameArray nameArray[i]
            for item in indexBeforeNameArray do (
                local foundFrontBackIndex = findItem __frontBackStrArray (toUpper item)
                if foundFrontBackIndex > 0 then append indexBeforeFrontBackCharArray item
            )
            for item in indexAfterNameArray do (
                local foundFrontBackIndex = findItem __frontBackStrArray (toUpper item)
                if foundFrontBackIndex > 0 then append indexAfterFrontBackCharArray item
            )
        )
        else (
            for i = 1 to nameArray.count do append indexBeforeNameArray nameArray[i]
            for item in indexBeforeNameArray do (
                local foundFrontBackIndex = findItem __frontBackStrArray (toUpper item)
                if foundFrontBackIndex > 0 then append indexBeforeFrontBackCharArray item
            )
            indexAfterFrontBackCharArray = deepCopy indexBeforeFrontBackCharArray
        )

        if indexBeforeFrontBackCharArray.count > 0 or indexAfterFrontBackCharArray.count > 0 then (
            if (get_front_back_part_index()) < (get_index_part_index()) then (
                if indexBeforeFrontBackCharArray.count > 0 then returnChar = indexBeforeFrontBackCharArray[1]
            )
            else (
                if indexAfterFrontBackCharArray.count > 0 then returnChar = indexAfterFrontBackCharArray[1]
            )
        )

        returnChar
    ),

    fn is_left inStr = (
        local sideChar = toUpper (get_side_char inStr)
        if sideChar != "" and sideChar == get_leftStr() then return true
        return false
    ),

    fn is_right inStr = (
        local sideChar = toUpper (get_side_char inStr)
        if sideChar != "" and sideChar == get_rightStr() then return true
        return false
    ),

    fn is_front inStr = (
        local sideChar = toUpper (get_front_back_char inStr)
        if sideChar != "" and sideChar == get_frontStr() then return true
        return false
    ),

    fn is_back inStr = (
        local sideChar = toUpper (get_front_back_char inStr)
        if sideChar != "" and sideChar == get_backStr() then return true
        return false
    ),

    fn has_side inStr = (
        if (is_left inStr) then return true
        if (is_right inStr) then return true

        return false
    ),

    fn has_front_back inStr = (
        if (is_front inStr) then return true
        if (is_back inStr) then return true
    ),

    fn get_side inStr = (
        toUpper (get_side_char inStr)
    ),

    fn get_front_back inStr = (
        toUpper (get_front_back_char inStr)
    ),

    fn get_base inStr = (
        local nameArray = split_into_refined_nameArray inStr
        local basePartIndex = get_base_part_index()
        if basePartIndex != 0 and nameArray.count >= basePartIndex then return nameArray[basePartIndex]

        return ""
    ),

    fn get_type inStr = (
        local nameArray = split_into_refined_nameArray inStr
        local typePartIndex = get_type_part_index()
        if typePartIndex != 0 and nameArray.count >= typePartIndex then return nameArray[typePartIndex]

        return ""

        --if nameArray.count > 0 then (
        --    if (has_side inStr) then (
        --        local sideChar = get_side inStr
        --        local sideIndex = findItem nameArray sideChar
        --        if sideIndex > 2 then return NameArray [2]
        --    )
        --    else return nameArray[2]
        --)

        --return ""
    ),

    fn get_nonRealName inStr = (
        local filChar = get_filteringChar inStr
        local baseIndex = get_base_part_index()
        local typeIndex = get_type_part_index()
        local sideIndex = get_side_part_index()
        local frontBackIndex = get_front_back_part_index()

        local base = get_base inStr
        local type = get_type inStr
        local side = get_side_char inStr
        local frontBack = get_front_back_char inStr

        local partsIndexArray = #(baseIndex, typeIndex, sideIndex, frontBackIndex)
        local partsArray = #(base, type, side, frontBack)
        local nonRealNameArray = #()
        for i = 1 to __namePartsOrder.count do append nonRealNameArray ""
        for i = 1 to partsIndexArray.count do (
            if partsIndexArray[i] != 0 then nonRealNameArray[partsIndexArray[i]] = partsArray[i]
        )

        local returnStr = ""
        returnStr = combine_nameArray nonRealNameArray filChar

        returnStr
    ),

    fn get_realName inStr = (
        local filChar = get_filteringChar inStr
        local nameArray = split_into_refined_nameArray (get_string inStr)
        local nonRealNameArray = split_into_refined_nameArray (get_nonRealName inStr)
        local realNameArray = #()

        for i = 1 to nameArray.count do (
            if (findItem nonRealNameArray nameArray[i]) == 0 then append realNameArray nameArray[i]
        )

        local returnStr = ""
        returnStr = combine_nameArray realNameArray filChar

        returnStr
    ),

    fn combine inBase inType inSide inRealName inIndex inFilChar = (
        local returnStr = ""
        local baseIndex = get_base_part_index()
        local typeIndex = get_type_part_index()
        local sideIndex = get_side_part_index()
        local frontBackIndex = get_front_back_part_index()
        local realNameIndex = get_realName_part_index()
        local indexIndex = get_index_part_index()

        local base = inBase
        local type = inType
        local side = inSide
        local frontBack = ""
        local realName = inRealName
        local index = inIndex

        local partsIndexArray = #(baseIndex, typeIndex, sideIndex, frontBackIndex, realNameIndex, indexIndex)
        local partsArray = #(base, type, side, frontBack, realName, index)
        local combinedNameArray = #()

        for i = 1 to __namePartsOrder.count do append combinedNameArray ""
        for i = 1 to partsIndexArray.count do (
            if partsIndexArray[i] != 0 then combinedNameArray[partsIndexArray[i]] = partsArray[i]
        )

        returnStr = combine_nameArray combinedNameArray inFilChar

        returnStr
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
            if index == -1 then indexStr = __nubStr
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
        if index != __nubStr then (
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
            if indexNum == -1 then indexNum = __nubStr
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

    fn gen_uniqueName inStr indexPaddingNum:3 = (
        local oriName = get_string inStr
        local filChar = get_filteringChar inStr
        local resultName = uniqueName (oriName + filChar)
        local indexStr = (get_index_as_digit resultName) as String
        resultName = replace_index resultName indexStr
        resultName = set_index_padding_num resultName inPaddingNum:indexPaddingNum

        resultName
    )
)
