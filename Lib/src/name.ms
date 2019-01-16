struct _Name (
    /*************************************************/
    /* Default name structure:
    /*    [Base] [Type] [Side] [RealName] [Index]
    /*    ex) Bip001 Dummy L SpineA 001
    /*************************************************/
    __namePartsOrder = #(#npBase, #npType, #npSide, #npFrontBack, #npRealName, #npIndex),
    __nameParts = #("Base", "Type", "Side", "FrontBack", "RealName", "Index"),
    __nubStr = "Nub",
    __sideStrArray = #("L", "R"),
    __frontBackStrArray = #("F", "B"),

    fn set_nubStr inStr = (
        __nubStr = inStr
    ),

    fn get_nubStr = (
        return __nubStr
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
        local returnVal = findItem __namePartsOrder #npBase

        returnVal
    ),

    fn get_type_part_index = (
        local returnVal = findItem __namePartsOrder #npType

        returnVal
    ),

    fn get_side_part_index = (
        local returnVal = findItem __namePartsOrder #npSide

        returnVal
    ),

    fn get_front_back_part_index = (
        local returnVal = findItem __namePartsOrder #npFrontBack

        returnVal
    ),

    fn get_realName_part_index = (
        local returnVal = findItem __namePartsOrder #npRealName

        returnVal
    ),

    fn get_index_part_index = (
        local returnVal = findItem __namePartsOrder #npIndex

        returnVal
    ),

    fn set_name_parts_order inOrder = (
        __nameParts = inOrder
        __namePartsOrder[(findItem __nameParts "Base")] = #npBase
        __namePartsOrder[(findItem __nameParts "Type")] = #npType
        __namePartsOrder[(findItem __nameParts "Side")] = #npSide
        __namePartsOrder[(findItem __nameParts "FrontBack")] = #npFrontBack
        __namePartsOrder[(findItem __nameParts "RealName")] = #npRealName
        __namePartsOrder[(findItem __nameParts "Index")] = #npIndex
    ),

    fn split_nameParts_to_refined_nameArray = (
        local realNameIndex = get_realName_part_index()
        local beforeRealNameArray = for i = 1 to (realNameIndex - 1) collect __namePartsOrder[i]
        local afterRealNameArray = for i = (realNameIndex + 1) to __namePartsOrder.count collect __namePartsOrder[i]
        local returnArray = #(beforeRealNameArray, #(#npRealName), afterRealNameArray)

        returnArray
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

    fn filter_by_filteringChar inStr = (
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

    fn filter_by_upper_case inStr = (
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
        returnVal
    ),

    fn is_frontBack_char inChar = (
        local returnVal = false
        if (findItem __frontBackStrArray inChar) != 0 then returnVal = true
        returnVal
    ),

    fn filter_name inStr = (
        local nameArray = #()
        local filChar = get_filteringChar inStr
        if filChar == "" then (
            nameArray = filter_by_upper_case inStr
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
        else nameArray = filter_by_filteringChar inStr

        nameArray
    ),

    fn refine_nameArray_empty inNameArray = (
        local nameArray = #()
        for item in inNameArray do (
            if item != "" then append nameArray item
        )

        return nameArray
    ),

    fn refine_nameArray_longer_than_nameParts inNameArray = (
        local nameArray = deepCopy inNameArray
        local beforeRealNameArray = #()
        local tempAfterRealNameArray = #()
        local afterRealNameArray = #()
        local returnArray = #()

        for i = 1 to (get_realName_part_index() - 1) do (
            local k = 1
            while nameArray.count > 0 do (
                case __namePartsOrder[i] of (
                    #npBase:(
                        if nameArray[k] != "" then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npType:(
                        if nameArray[k] != "" then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npSide:(
                        if (is_side_char nameArray[k]) then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npFrontBack:(
                        if (is_frontBack_char nameArray[k]) then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npIndex:(
                        if (is_digit nameArray[k]) or (nameArray[k] == __nubStr) then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    default: (
                        k += 1
                        exit
                    )
                )
            )
        )

        for i = __namePartsOrder.count to (get_realName_part_index() + 1) by -1 do (
            local k = nameArray.count
            while nameArray.count > 1 do (
                case __namePartsOrder[i] of (
                    #npBase:(
                        if nameArray[k] != "" then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npType:(
                        if nameArray[k] != "" then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npSide:(
                        if (is_side_char nameArray[k]) then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npFrontBack:(
                        if (is_frontBack_char nameArray[k]) then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npIndex:(
                        if (is_digit nameArray[k]) or (nameArray[k] == __nubStr) then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    default: (
                        k -= 1
                        exit
                    )
                )
            )
        )
        afterRealNameArray = for i = tempAfterRealNameArray.count to 1 by -1 collect tempAfterRealNameArray[i]

        returnArray = #(beforeRealNameArray, nameArray, afterRealNameArray)
        returnArray
    ),

    fn refine_nameArray_shorter_than_nameParts inNameArray = (
        local nameArray = deepCopy inNameArray
        local beforeRealNameArray = #()
        local tempAfterRealNameArray = #()
        local afterRealNameArray = #()
        local returnArray = #()

        for i = __namePartsOrder.count to (get_realName_part_index()) by -1 do (
            local k = nameArray.count
            while nameArray.count > 0 do (
                case __namePartsOrder[i] of (
                    #npBase:(
                        if nameArray[k] != "" then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npType:(
                        if nameArray[k] != "" then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npSide:(
                        if (is_side_char nameArray[k]) then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npFrontBack:(
                        if (is_frontBack_char nameArray[k]) then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    #npIndex:(
                        if (is_digit nameArray[k]) or (nameArray[k] == __nubStr) then (
                            append tempAfterRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k -= 1
                            exit
                        )
                    )
                    default: (
                        k -= 1
                        exit
                    )
                )
            )
        )
        afterRealNameArray = for i = tempAfterRealNameArray.count to 1 by -1 collect tempAfterRealNameArray[i]

        for i = 1 to (get_realName_part_index() - 1) do (
            local k = 1
            while nameArray.count > 1 do (
                case __namePartsOrder[i] of (
                    #npBase:(
                        if nameArray[k] != "" then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npType:(
                        if nameArray[k] != "" then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npSide:(
                        if (is_side_char nameArray[k]) then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npFrontBack:(
                        if (is_frontBack_char nameArray[k]) then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    #npIndex:(
                        if (is_digit nameArray[k]) or (nameArray[k] == __nubStr) then (
                            append beforeRealNameArray nameArray[k]
                            nameArray = deleteItem nameArray k
                            exit
                        )
                        else (
                            k += 1
                            exit
                        )
                    )
                    default: (
                        k += 1
                        exit
                    )
                )
            )
        )

        returnArray = #(beforeRealNameArray, nameArray, afterRealNameArray)
        returnArray
    ),

    fn refine_nameArray inNameArray = (
        local returnArray = #(#(), #(), #())
        if (get_realName_part_index()) > 1 then (
            if inNameArray.count < __nameParts.count then returnArray = refine_nameArray_shorter_than_nameParts inNameArray
            else returnArray = refine_nameArray_longer_than_nameParts inNameArray
        )
        else returnArray = #(#(), inNameArray, #())
        returnArray
    ),

    fn split_into_refined_nameArray inStr = (
        local splittedNameArray = filter_name inStr
        local nameArray = refine_nameArray splittedNameArray
        nameArray
    ),

    fn combine_nameArray inNameArray inFilChar = (
        local returnStr = ""
        local copiedNameArray = deepCopy inNameArray
        local refinedNameArray = refine_nameArray_empty copiedNameArray
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

    fn get_char_type inChar = (
        local returnVal = undefined
        if (is_digit inChar) then returnVal = #npIndex
        if (is_side_char inChar) then returnVal = #npSide
        if (is_frontBack_char inChar) then returnVal = #npFrontBack
        returnVal
    ),

    fn match_nameArray_as_namePartsOrder inNameArray inNamePartsOrder = (
        local returnArray = for item in inNamePartsOrder collect ""
        local nameArray = deepCopy inNameArray
        local lastType = inNamePartsOrder[inNamePartsOrder.count]
        local lastChar = nameArray[nameArray.count]
        local lastCharType = get_char_type lastChar
        local lastCharPos = 0
        local basePos = findItem inNamePartsOrder #npBase
        local typePos = findItem inNamePartsOrder #npType

        if nameArray.count == inNamePartsOrder.count then returnArray = for item in nameArray collect item
        else (
            if lastCharType != undefined then (
                lastCharPos = findItem inNamePartsOrder lastCharType
                if lastCharPos < nameArray.count then lastCharPos = inNamePartsOrder.count
            )
            if lastCharPos == 0 then (
                if basePos < typePos then lastCharPos = typePos
                if basePos > typePos then lastCharPos = basePos
            )

            for i = lastCharPos to 1 by -1 do (
                while nameArray.count > 0 do (
                    local charType = get_char_type nameArray[nameArray.count]
                    if charType == inNamePartsOrder[i] then (
                        returnArray[i] = nameArray[nameArray.count]
                        nameArray = deleteItem nameArray nameArray.count
                    )
                    else (
                        if inNamePartsOrder[i] == #npBase or inNamePartsOrder[i] == #npType then (
                            returnArray[i] = nameArray[nameArray.count]
                            nameArray = deleteItem nameArray nameArray.count
                        )
                    )
                    i -= 1
                )
            )
        )

        if basePos != 0 and typePos != 0 then (
            if returnArray[basePos] == "" and returnArray[typePos] != "" then (
                returnArray[basePos] = returnArray[typePos]
                returnArray[typePos] = ""
            )
        )

        returnArray
    ),

    fn get_realName inStr = (
        local filChar = get_filteringChar inStr
        local nameArray = split_into_refined_nameArray inStr
        local realNameArray = nameArray[2]
        local returnStr = ""
        returnStr = combine_nameArray realNameArray filChar

        returnStr
    ),

    fn convert_name_to_nameArray inStr = (
        local returnArray = for item in __namePartsOrder collect ""
        local filChar = get_filteringChar inStr
        local refinedNameArray = split_into_refined_nameArray inStr
        local refinedNamePartsArray = split_nameParts_to_refined_nameArray()
        local beforeRealNameArray = for item in refinedNamePartsArray[1] collect ""
        local realNameArray = #((combine_nameArray refinedNameArray[2] filChar))
        local afterRealNameArray = for item in refinedNamePartsArray[3] collect ""

        if refinedNameArray[1].count > 0 then beforeRealNameArray = match_nameArray_as_namePartsOrder refinedNameArray[1] refinedNamePartsArray[1]
        if refinedNameArray[3].count > 0 then afterRealNameArray = match_nameArray_as_namePartsOrder refinedNameArray[3] refinedNamePartsArray[3]
        returnArray = join beforeRealNameArray realNameArray
        returnArray = join returnArray afterRealNameArray

        returnArray
    ),

    fn get_side inStr = (
        local tempNameArray = convert_name_to_nameArray inStr
        local sideStr = tempNameArray[(get_side_part_index())]

        sideStr
    ),

    fn get_frontBack inStr = (
        local tempNameArray = convert_name_to_nameArray inStr
        local frontBackStr = tempNameArray[(get_front_back_part_index())]

        frontBackStr
    ),

    fn get_index inStr = (
        local tempNameArray = convert_name_to_nameArray inStr
        local indexStr = tempNameArray[(get_index_part_index())]

        indexStr
    ),

    fn is_nub inStr = (
        local returnVal = false
        if (get_index inStr) == __nubStr then returnVal = true
        returnVal
    ),

    fn get_index_as_digit inStr = (
        indexStr = get_index inStr
        if indexStr == __nubStr then return -1
        if indexStr != "" then (
            index = execute indexStr
            return index
        )
        else return false
    ),

    fn get_base inStr = (
        local tempNameArray = convert_name_to_nameArray inStr
        local baseStr = tempNameArray[(get_base_part_index())]

        baseStr
    ),

    fn get_type inStr = (
        local tempNameArray = convert_name_to_nameArray inStr
        local typeStr = tempNameArray[(get_type_part_index())]

        typeStr
    ),

    fn get_string inStr = (
        local returnStr = ""
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexOrder = get_index_part_index()
        local returnNameArray = deleteItem nameArray indexOrder

        returnStr = combine_nameArray returnNameArray filChar
        returnStr
    ),

    fn set_index_as_nub inStr = (
        local returnName = ""
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexOrder = get_index_part_index()
        nameArray[indexOrder] = __nubStr
        returnName = combine_nameArray nameArray filChar
        returnName
    ),

    fn is_left inStr = (
        local sideChar = get_side inStr
        if sideChar != "" and sideChar == get_leftStr() then return true
        return false
    ),

    fn is_right inStr = (
        local sideChar = get_side inStr
        if sideChar != "" and sideChar == get_rightStr() then return true
        return false
    ),

    fn is_front inStr = (
        local frontBackChar = get_frontBack inStr
        if frontBackChar != "" and frontBackChar == get_frontStr() then return true
        return false
    ),

    fn is_back inStr = (
        local frontBackChar = get_frontBack inStr
        if frontBackChar != "" and frontBackChar == get_backStr() then return true
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

        return false
    ),

    fn get_nonRealName inStr = (
        local returnStr = ""
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local realNameIndex = get_realName_part_index()
        nameArray[realNameIndex] = ""
        returnStr = combine_nameArray nameArray filChar

        returnStr
    ),

    fn combine inBase:"" inType:"" inSide:"" inFrontBack:"" inRealName:"" inIndex:"" inFilChar:" " = (
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
        local frontBack = inFrontBack
        local realName = inRealName
        local index = inIndex

        local partsIndexArray = #(baseIndex, typeIndex, sideIndex, frontBackIndex, realNameIndex, indexIndex)
        local partsArray = #(base, type, side, frontBack, realName, index)
        local combinedNameArray = for item in __namePartsOrder collect ""
        for i = 1 to partsIndexArray.count do (
            if partsIndexArray[i] != 0 then combinedNameArray[partsIndexArray[i]] = partsArray[i]
        )

        returnStr = combine_nameArray combinedNameArray inFilChar

        returnStr
    ),

    fn add_fix inStr inPart inFix pos:#npPosPrefix = (
        local returnStr = inStr
        if inFix != "" then (
            local filChar = get_filteringChar inStr
            local nameArray = convert_name_to_nameArray inStr
            local partIndex = 0
            case inPart of (
                #npBase: partIndex = get_base_part_index()
                #npType: partIndex = get_type_part_index()
                #npSide: partIndex = get_side_part_index()
                #npFrontBack: partIndex = get_front_back_part_index()
                #npRealName: partIndex = get_realName_part_index()
                #npIndex: partIndex = get_index_part_index()
            )
            if partIndex != 0 then (
                if pos == #npPosPrefix then nameArray[partIndex] = inFix + filChar + nameArray[partIndex]
                if pos == #npPosSufix then nameArray[partIndex] = nameArray[partIndex] + filChar + inFix
            )
            returnStr = combine_nameArray nameArray filChar
        )

        returnStr
    ),

    fn add_prefix_to_realName inStr inPrefix = (
        local returnVal = add_fix inStr #npRealName inPreFix pos:#npPosPrefix
        returnVal
    ),

    fn add_sufix_to_realName inStr inSufix = (
        local returnVal = add_fix inStr #npRealName inPreFix pos:#npPosSufix
        returnVal
    ),

    fn convert_digit_into_padding_string inDigit inPaddingNum:3 = (
        local formatStr = "0" + (inPaddingNum as String) + "d"
        local digitNum = 0
        local returnVal = ""
        if (classOf inDigit) == integer then digitNum = inDigit
        if (classOf inDigit) == String then (
            if (is_digit inDigit) then digitNum = execute inDigit
        )
        returnVal = formattedPrint digitNum format:formatStr

        returnVal
    ),

    fn set_index_padding_num inStr inPaddingNum:3 = (
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexIndex = get_index_part_index()
        local indexStr = get_index inStr
        local index = -999

        if indexStr != "" then (
            if indexStr != __nubStr then indexStr = convert_digit_into_padding_string indexStr inPaddingNum:inPaddingNum

            nameArray[indexIndex] = indexStr
        )

        return (combine_nameArray nameArray filChar)
    ),

    fn get_index_padding_num inStr = (
        local index = get_index inStr
        if index != __nubStr then (
            if index.count > 0 then return index.count
        )

        return 1
    ),

    fn increase_index inStr inAmount = (
        local newName = inStr
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexIndex = get_index_part_index()

        if indexIndex != 0 then (
            local indexStr = ""
            local indexPaddingNum = 3
            local indexNum = -9999

            case nameArray[indexIndex] of (
                "": indexNum = -1
                __nubStr: indexNum = -9999999
                default: (
                    indexNum = execute nameArray[indexIndex]
                    indexPaddingNum = nameArray[indexIndex].count
                )
            )
            local formatStr = "0" + (indexPaddingNum as String) + "d"
            indexNum = indexNum + inAmount
            if indexNum > -1 then indexStr = formattedPrint indexNum format:formatStr
            else indexStr = __nubStr
            nameArray[indexIndex] = indexStr

            newName = combine_nameArray nameArray filChar
        )

        newName
    ),

    fn replace_filteringChar inStr inNewFilChar = (
        local nameArray = convert_name_to_nameArray inStr

        return (combine_nameArray nameArray inNewFilChar)
    ),

    fn replace_base inStr inNewBase = (
        local returnVal = inStr
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local baseIndex = get_base_part_index()
        if baseIndex != 0 then (
            nameArray[baseIndex] = inNewBase
            returnVal = combine_nameArray nameArray filChar
        )

        returnVal
    ),

    fn replace_type inStr inNewType = (
        local returnVal = inStr
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local typeIndex = get_type_part_index()
        if typeIndex != 0 then (
            nameArray[typeIndex] = inNewType
            returnVal = combine_nameArray nameArray filChar
        )

        returnVal
    ),

    fn replace_side inStr inNewSide = (
        local returnVal = inStr
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local sideIndex = get_side_part_index()
        if sideIndex != 0 then (
            nameArray[sideIndex] = inNewSide
            returnVal = combine_nameArray nameArray filChar
        )

        returnVal
    ),

    fn replace_frontBack inStr inNewFrontBack = (
        local returnVal = inStr
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local frontBackIndex = get_front_back_part_index()
        if frontBackIndex != 0 then (
            nameArray[frontBackIndex] = inNewFrontBack
            returnVal = combine_nameArray nameArray filChar
        )

        returnVal
    ),

    fn replace_index inStr inNewIndex keepPadding:true = (
        local returnVal = inStr
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexIndex = get_index_part_index()
        if indexIndex != 0 then (
            nameArray[indexIndex] = inNewIndex
            returnVal = combine_nameArray nameArray filChar

            if keepPadding then (
                local indexPaddingNum = get_index_padding_num inStr
                returnVal = set_index_padding_num returnVal inPaddingNum:indexPaddingNum
            )
        )

        returnVal
    ),

    fn replace_realName inStr inNewRealName = (
        local returnVal = inStr
        local filChar = get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local realNameIndex = get_realName_part_index()
        if realNameIndex != 0 then (
            nameArray[realNameIndex] = inNewRealName
            returnVal = combine_nameArray nameArray filChar
        )

        returnVal
    ),

    fn remove_type inStr = (
        return (replace_type inStr "")
    ),

    fn remove_side inStr = (
        return (rplace_side inStr "")
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
        local sortedNameArray = #()
        if inNameArray.count > 0 then (
            struct indexSorting (oriIndex, newIndex)

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

        sortedNameArray
    ),

    fn gen_uniqueName inStr = (
        local patternStr = replace_index inStr "*"
        local returnArray = for item in objects where (matchPattern item.name pattern:patternStr) collect item
        local returnVal = replace_index inStr ((returnArray.count+1) as String)

        returnVal
    ),

    fn replace inStr inTargetStr inNewStr = (
        local returnVal = inStr
        if (matchPattern inStr pattern:("*" + inTargetStr + "*")) then (
            local targetStartIndex = findString inStr inTargetStr
            local targetLength = inTargetStr.count
            returnVal = replace inStr targetStartIndex targetLength inNewStr
        )

        returnVal
    )
)
