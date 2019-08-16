(
struct _String (
    fn split_into_string_and_digit inStr = (
        t = trimRight inStr "0123456789"
        #(t, substring inStr (t.count+1) -1)
    ),

    fn compare_string inStr1 inStr2 = (
        stricmp inStr1 inStr2
    ),

    fn sort_by_alphabet inArray = (
        local returnArray = deepCopy inArray
        qSort returnArray compare_string
        return returnArray
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

    fn split_to_array inStr = (
        local returnArray = #()
        local filChar = get_filteringChar inStr
        if filChar == "" then (
            returnArray = filter_by_upper_case inStr
            local tempArray = #()
            for item in returnArray do (
                if (has_digit item) then (
                    local splittedStrArray = split_into_string_and_digit item
                    append tempArray splittedStrArray[1]
                    append tempArray splittedStrArray[2]
                )
                else append tempArray item
            )
            returnArray = deepCopy tempArray
        )
        else returnArray = filter_by_filteringChar inStr

        return returnArray
    ),

    fn remove_empty_string_in_array inArray = (
        local returnVal = #()
        for item in inArray do if item != "" then append returnVal item

        return returnVal
    ),

    fn combine inArray filChar:" " = (
        local returnVal = ""
        local refinedArray = remove_empty_string_in_array inArray
        if refinedArray.count < 2 then (
            if refinedArray.count == 1 then returnVal = refinedArray[1]
        )
        else (
            for i = 1 to (refinedArray.count - 1) do returnVal = returnVal + refinedArray[i] + filChar
            returnVal = returnVal + refinedArray[refinedArray.count]
        )
        return returnVal
    ),

    fn find_and_replace inStr inTargetStr inNewStr = (
        local returnVal = inStr
        if (matchPattern inStr pattern:("*" + inTargetStr + "*")) then (
            local targetStartIndex = findString inStr inTargetStr
            local targetLength = inTargetStr.count
            returnVal = replace inStr targetStartIndex targetLength inNewStr
        )

        returnVal
    )
)

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
    __iniFile = "",

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
        if refinedNameArray.count == 1 then returnStr = refinedNameArray[1]

        return returnStr
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
                if pos == #npPosPrefix then nameArray[partIndex] = inFix + nameArray[partIndex]
                if pos == #npPosSufix then nameArray[partIndex] = nameArray[partIndex] + inFix
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
        local returnVal = add_fix inStr #npRealName inSufix pos:#npPosSufix
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

    fn find_and_replace inStr inTargetStr inNewStr = (
        local returnVal = inStr
        if (matchPattern inStr pattern:("*" + inTargetStr + "*")) then (
            local targetStartIndex = findString inStr inTargetStr
            local targetLength = inTargetStr.count
            returnVal = replace inStr targetStartIndex targetLength inNewStr
        )

        returnVal
    ),

    fn get_iniFile = (
        return __iniFile
    ),

    fn load_setting_from_ini = (
        __iniFile = (getFilenamePath (getThisScriptFilename())) +"\\NameTool.ini"
        local nubStr = getINISetting __iniFile "DefaultSetting" "NubStr"
        local namePartsOrder = filterString (getINISetting __iniFile "DefaultSetting" "NamePartsOrder") " "
        local numPaddingNum = (getINISetting __iniFile "DefaultSetting" "PaddingNum") as integer
        local iniSideStrArray = filterString (getINISetting __iniFile "DefaultSetting" "SideStrArray") " "
        local iniFrontBackStrArray = filterString (getINISetting __iniFile "DefaultSetting" "FrontBackStrArray") " "
        set_name_parts_order namePartsOrder
        set_nubStr nubStr
        set_leftStr iniSideStrArray[1]
        set_rightStr iniSideStrArray[2]
        set_frontStr iniFrontBackStrArray[1]
        set_backStr iniFrontBackStrArray[2]
    )
)

/*******************************/
/* Animation Library
/*******************************/
struct _Anim (
    fn rotate_local inObj rx ry rz = (
        local currentMatrix = inObj.transform

        preRotate currentMatrix (eulertoquat (eulerAngles rx ry rz))
        inObj.transform = currentMatrix
    ),

    fn move_local inObj mx my mz = (
        local currentMatrix = inObj.transform
        
        PreTranslate currentMatrix [mx, my, mz]
        inObj.transform = currentMatrix
    ),

    fn reset_transform_controller inObj = (
        if classof inObj != Biped_Object then (
            inObj.position.controller = Position_XYZ()
            inObj.rotation.controller = Euler_XYZ()
            inObj.scale.controller = Bezier_Scale()
        )
    ),

    fn freeze_transform inObj = (
        local CurObj = inObj 

        if classof CurObj.rotation.controller != Rotation_Layer do (
            -- freeze rotation      
            CurObj.rotation.controller = Euler_Xyz()
            CurObj.rotation.controller = Rotation_list()
            CurObj.rotation.controller.available.controller = Euler_xyz()
            
            CurObj.rotation.controller.setname 1 "Frozen Rotation"
            CurObj.rotation.controller.setname 2 "Zero Euler XYZ"
        
            CurObj.rotation.controller.SetActive 2
        )
        if classof CurObj.position.controller != Position_Layer do (
            -- freeze position
            CurObj.position.controller = Bezier_Position()
            CurObj.position.controller = position_list()
            CurObj.position.controller.available.controller = Position_XYZ()

            CurObj.position.controller.setname 1 "Frozen Position"
            CurObj.position.controller.setname 2 "Zero Pos XYZ"
            
            CurObj.position.controller.SetActive 2      

            -- position to zero
            CurObj.Position.controller[2].x_Position = 0
            CurObj.Position.controller[2].y_Position = 0
            CurObj.Position.controller[2].z_Position = 0
        )
    ),

    fn collape_anim_transform inObj startFrame:animationRange.start endFrame:animationRange.end = (
        disableSceneRedraw()
        progressStart ("Collapse transform " + inObj.name + "...")

        local p = point()
        for k = startFrame to endFrame do (
            at time k (
                with animate on p.transform = inObj.transform
            )
        )

        inObj.transform.controller = transform_script()
        inObj.transform.controller = prs()

        for k = startFrame to endFrame do (
            at time k (
                with animate on (
                    in coordsys (transmatrix inObj.transform.pos) inObj.rotation = inverse p.transform.rotation
                    in coordsys world inObj.position = p.transform.position
                    inObj.scale = p.scale
                )
            )
            progressUpdate (100 * k / endFrame)
        )

        if startFrame != animationRange.start then (
            deselectKeys inObj.transform.controller
            selectKeys inObj.transform.controller animationRange.start
            deleteKeys inObj.transform.controller #selection
            deselectKeys inObj.transform.controller
        )
        
        delete p
        progressEnd()
        enableSceneRedraw()
    ),

    fn match_anim_transform inObj inTarget startFrame:animationRange.start endFrame:animationRange.end = (
        if (isValidNode inObj) and (isValidNode inTarget) then (
            disableSceneRedraw()
            progressStart ("Match transform " + inObj.name + " to " + inTarget.name)

            local p = point()
            for k = startFrame to endFrame do (
                at time k (
                    with animate on p.transform = inTarget.transform
                )

                deselectKeys inObj.transform.controller
                selectKeys inObj.transform.controller k
                deleteKeys inObj.transform.controller #selection
                deselectKeys inObj.transform.controller
            )

            progressUpdate 20

            if startFrame != animationRange.start then (
                deselectKeys p.transform.controller
                selectKeys p.transform.controller animationRange.start
                deleteKeys p.transform.controller #selection
                deselectKeys p.transform.controller
            )

            progressUpdate 25

            local posKeyArray = inTarget.pos.controller.keys
            local rotKeyArray = inTarget.rotation.controller.keys
            local scaleKeyArray = inTarget.scale.controller.keys

            at time startFrame (
                with animate on inObj.transform = p.transform
            )
            at time endFrame (
                with animate on inObj.transform = p.transform
            )

            for key in posKeyArray do (
                if key.time >= startFrame and key.time <= endFrame then (
                    at time key.time (
                        with animate on inObj.transform = p.transform
                    )
                )
            )
            progressUpdate 40
            for key in rotKeyArray do (
                if key.time >= startFrame and key.time <= endFrame then (
                    at time key.time (
                        with animate on inObj.transform = p.transform
                    )
                )
            )
            progressUpdate 60
            for key in scaleKeyArray do (
                if key.time >= startFrame and key.time <= endFrame then (
                    at time key.time (
                        with animate on inObj.transform = p.transform
                    )
                )
            )
            progressUpdate 80

            delete p

            progressUpdate 100
            progressEnd()
            enableSceneRedraw()
        )
    ),

    fn create_average_pos_transform inTargetArray = (
        local posConstDum = Point()
        local targetPosConstraint = Position_Constraint()
        local targetWeight = 100.0 / (inTargetArray.count + 1)

        posConstDum.position.controller = targetPosConstraint
        for item in inTargetArray do targetPosConstraint.appendTarget item targetWeight
        
        local returnTransform = copy posConstDum.transform
        delete posConstDum
    
        returnTransform
    ),

    fn create_average_rot_transform inTargetArray = (
        local rotConstDum = Point()
        local targetOriConstraint = Orientation_Constraint()
        local targetWeight = 100.0 / (inTargetArray.count + 1)

        rotConstDum.rotation.controller = targetOriConstraint
        for item in inTargetArray do targetOriConstraint.appendTarget item targetWeight
    
        local returnTransform = copy rotConstDum.transform
        delete rotConstDum
    
        returnTransform
    )
)


struct _Helper (
    name,

    fn create_point inName size:2 boxToggle:off crossToggle:on pointColor:(color 14 255 2) pos:[0,0,0] = (
        local returnPoint

        returnPoint = point()
        returnPoint.size = size
        returnPoint.box = boxToggle
        returnPoint.cross = crossToggle
        returnPoint.wireColor = pointColor
        returnPoint.name = inName
        returnPoint.pos = pos

        returnPoint.centermarker = off
        returnPoint.axistripod = off

        return returnPoint
    ),

    fn create_empty_point inName = (
        local returnPoint = create_point inName size:0 crossToggle:off
        returnPoint.centermarker = off
        returnPoint.axistripod = off
        freeze returnPoint

        return returnPoint
    ),

    fn gen_helper_name_from_obj inObj makeTwo:false isExp:false = (
        local pointName = ""
        local targetName = ""
        local typeName = "Dum"
        local tempName = ""

        if isExp then typeName = "Exp"

        tempName = name.replace_type inObj.name typeName
        if (name.get_type inObj.name) == typeName then (
            tempName = name.increase_index tempName 1
        )
        pointName = tempName

        if makeTwo then (
            targetName = name.add_sufix_to_realName tempName "Tgt"
        )

        return #(pointName, targetName)
    ),

    fn gen_helper_shape_from_obj inObj = (
        local helperSize = 2.0
        local crossToggle = false
        local boxToggle = true

        if (classOf inObj) == BoneGeometry then helperSize = amax #(inObj.width, inObj.height)
        if ((classOf inObj) == Point) or ((classOf inObj) == ExposeTm) then (
            helperSize = inObj.size + 0.5
            if inObj.cross then (
                crossToggle = false
                boxToggle = true
            )
            if inObj.box then (
                crossToggle = true
                boxToggle = false
            )
        )

        return #(helperSize, crossToggle, boxToggle)
    ),

    fn create_helper makeTwo:false = (
        local createdHelperArray = #()
        if selection.count > 0 then (
            local selArray = getCurrentSelection()
            local helperSize = 2.0
            local crossToggle = false
            local boxToggle = true
            local pointName = ""
            local targetName = ""

            for item in selArray do (
                -- Set size of create helpers
                local helperShapeArray = gen_helper_shape_from_obj item
                helperSize = helperShapeArray[1]
                crossToggle = helperShapeArray[2]
                boxToggle = helperShapeArray[3]

                -- Set name of create helpers
                local helperNameArray = gen_helper_name_from_obj item makeTwo:makeTwo
                pointName = helperNameArray[1]
                targetName = helperNameArray[2]

                -- For mouse right click
                if makeTwo then (
                    local targetPoint = create_point targetName size:helperSize boxToggle:off crossToggle:on pointColor:(color 14 255 2) pos:[0,0,0]
                    targetPoint.transform = item.transform
                    local genPoint = create_point pointName size:helperSize boxToggle:on crossToggle:off pointColor:(color 14 255 2) pos:[0,0,0]
                    genPoint.transform = item.transform

                    append createdHelperArray targetPoint
                    append createdHelperArray genPoint
                )
                else (
                    local genPoint = create_point pointName size:helperSize boxToggle:boxToggle crossToggle:crossToggle pointColor:(color 14 255 2) pos:[0,0,0]
                        genPoint.transform = item.transform
                    append createdHelperArray genPoint
                )
            )
        )
        else (
            local genPoint = Point wirecolor:(color 14 255 2)
            append createdHelperArray genPoint
        )
        select createdHelperArray
        return createdHelperArray
    ),

    fn create_parent_helper = (
        if selection.count > 0 then (
            local selArray = getCurrentSelection()
            local helperSize = 2.0
            local crossToggle = false
            local boxToggle = true
            local pointName = ""
            local targetName = ""

            for item in selArray do (
                local helperShapeArray = gen_helper_shape_from_obj item
                helperSize = helperShapeArray[1]
                crossToggle = helperShapeArray[2]
                boxToggle = helperShapeArray[3]

                -- Set name of create helpers
                local helperNameArray = gen_helper_name_from_obj item
                pointName = helperNameArray[1]
                targetName = helperNameArray[2]

                local genPoint = create_point pointName size:helperSize boxToggle:on crossToggle:off pointColor:(color 14 255 2) pos:[0,0,0]
                genPoint.transform = item.transform
                genPoint.parent = item.parent
                item.parent = genPoint
                item.name = name.replace_type item.name "P"
            )
        )
    ),

    fn create_expTm = (
        local createdHelperArray = #()
        if selection.count > 0 then (
            local selArray = getCurrentSelection()
            local helperSize = 2.0
            local crossToggle = false
            local boxToggle = true
            local pointName = ""
            local targetName = ""

            for item in selArray do (
                -- Set size of create helpers
                local helperShapeArray = gen_helper_shape_from_obj item
                helperSize = helperShapeArray[1]
                crossToggle = helperShapeArray[2]
                boxToggle = helperShapeArray[3]

                -- Set name of create helpers
                local helperNameArray = gen_helper_name_from_obj item makeTwo:false isExp:true
                pointName = helperNameArray[1]
                targetName = helperNameArray[2]

                local genPoint = exposeTM name:pointName size:helperSize box:boxToggle cross:crossToggle wirecolor:(color 14 255 2) pos:[0,0,0]
                    genPoint.transform = item.transform
                append createdHelperArray genPoint
            )
        )
        else (
            local genPoint = exposeTM wirecolor:(color 14 255 2)
            append createdHelperArray genPoint
        )
        select createdHelperArray
        return createdHelperArray
    ),

    fn set_size inObj inNewSize = (
        if superClassOf inObj == helper then (
            inObj.size = inNewSize
            inObj
        )
    ),

    fn add_size inObj inAddSize = (
        if superClassOf inObj == helper then (
            inObj.size += inAddSize
            inObj
        )
    ),

    fn set_shape_to_center inObj = (
        if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
            inObj.centermarker = true
            inObj.box = true

            inObj.axistripod = false
            inObj.cross = false
        )
    ),

    fn set_shape_to_axis inObj = (
        if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
            inObj.axistripod = true

            inObj.centermarker = false
            inObj.box = false
            inObj.cross = false
        )
    ),

    fn set_shape_to_cross inObj = (
        if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
            inObj.cross = true

            inObj.box = false
            inObj.centermarker = false
            inObj.axistripod = false
        )
    ),

    fn set_shape_to_box inObj = (
        if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
            inObj.box = true

            inObj.centermarker = false
            inObj.axistripod = false
            inObj.cross = false
        )
    )
)

struct _Constraint (
    name, helper,

    fn collapse inObj = (
        if classof inObj != Biped_Object then (
            inObj.position.controller = Position_XYZ()
            inObj.rotation.controller = Euler_XYZ()
            inObj.scale.controller = Bezier_Scale()
        )
    ),

    fn set_active_last inObj = (
        if classOf inObj.position.controller == position_list then (
            inObj.position.controller.setActive inObj.position.controller.count
        )
        if classOf inObj.rotation.controller == rotation_list then (
            inObj.rotation.controller.setActive inObj.rotation.controller.count
        )
    ),

    fn get_pos_list_controller inObj = (
        local returnPosListCtr = undefined

        if classOf inObj.position.controller == position_list then returnPosListCtr = inObj.position.controller

        returnPosListCtr
    ),

    fn assign_pos_list inObj = (
        local returnPosListCtr = undefined

        if classOf inObj.position.controller != position_list then (
            returnPosListCtr = position_list()
            inObj.position.controller = returnPosListCtr
            return returnPosListCtr
        )
        if classOf inObj.position.controller == position_list then returnPosListCtr = inObj.position.controller

        returnPosListCtr
    ),

    fn get_pos_const inObj = (
        local returnConst = undefined
        if classOf inObj.position.controller == position_list then (
            local lst = inObj.position.controller
            local constNum = lst.getCount()
            local activeNum = lst.getActive()
            for i = 1 to constNum do (
                if (classOf lst[i].controller == Position_Constraint) then (
                    returnConst = lst[i].controller
                    if activeNum == i then return returnConst
                )
            )
        )

        if classOf inObj.position.controller == Position_Constraint then returnConst = inObj.position.controller

        return returnConst
    ),

    fn assign_pos_const inObj inTarget keepInit:false = (
        if classOf inObj.position.controller != position_list then inObj.position.controller = position_list()
        local targetPosConstraint = get_pos_const inObj
        if targetPosConstraint == undefined then (
            targetPosConstraint = Position_Constraint()
            inObj.position.controller.Available.controller = targetPosConstraint
            inObj.position.controller.setActive inObj.position.controller.count
        )

        local targetNum = targetPosConstraint.getNumTargets()
        local targetWeight = 100.0 / (targetNum + 1)
        targetPosConstraint.appendTarget inTarget targetWeight
        if targetNum > 0 then (
            local newWeightScale = 100.0 - targetWeight
            for i = 1 to targetNum do (
                local newWeight = (targetPosConstraint.GetWeight i) * 0.01 * newWeightScale
                targetPosConstraint.SetWeight i newWeight
            )
        )
        targetPosConstraint.relative = keepInit

        targetPosConstraint
    ),

    fn assign_pos_const_multi inObj inTargetArray keepInit:false = (
        for item in inTargetArray do assign_pos_const inObj item keepInit:keepInit
    ),

    fn add_target_to_pos_const inObj inTarget inWeight = (
        local targetPosConst = assign_pos_const inObj inTarget
        local targetNum = targetPosConst.getNumTargets()
        targetPosConstraint.SetWeight targetNum inWeight
    ),

    fn assign_pos_xyz inObj = (
        if classOf inObj.position.controller != position_list then inObj.position.controller = position_list()
        local posList = assign_pos_list inObj
        posList.Available.controller = Position_XYZ()
        posList.setActive posList.count
    ),

    fn get_rot_list_controller inObj = (
        local returnRotListCtr = undefined

        if classOf inObj.rotation.controller == rotation_list then returnRotListCtr = inObj.rotation.controller

        returnRotListCtr
    ),

    fn assign_rot_list inObj = (
        local returnRotListCtr = undefined

        if classOf inObj.rotation.controller != rotation_list then (
            returnRotListCtr = rotation_list()
            inObj.rotation.controller = returnRotListCtr
            return returnRotListCtr
        )
        if classOf inObj.rotation.controller == rotation_list then returnRotListCtr = inObj.rotation.controller

        returnRotListCtr
    ),

    fn get_rot_const inObj = (
        local returnConst = undefined
        if classOf inObj.rotation.controller == rotation_list then (
            local lst = inObj.rotation.controller
            local constNum = lst.getCount()
            local activeNum = lst.getActive()
            for i = 1 to constNum do (
                if (classOf lst[i].controller == Orientation_Constraint) then (
                    returnConst = lst[i].controller
                    if activeNum == i then return returnConst
                )
            )
        )

        if classOf inObj.rotation.controller == Orientation_Constraint then returnConst = inObj.rotation.controller

        return returnConst
    ),

    fn assign_rot_const inObj inTarget keepInit:false = (
        if classOf inObj.rotation.controller != rotation_list then inObj.rotation.controller = rotation_list()
        local targetRotConstraint = get_rot_const inObj
        if targetRotConstraint == undefined then (
            targetRotConstraint = Orientation_Constraint()
            inObj.rotation.controller.Available.controller = targetRotConstraint
            inObj.rotation.controller.setActive inObj.rotation.controller.count
        )

        local targetNum = targetRotConstraint.getNumTargets()
        local targetWeight = 100.0 / (targetNum + 1)
        targetRotConstraint.appendTarget inTarget targetWeight
        if targetNum > 0 then (
            local newWeightScale = 100.0 - targetWeight
            for i = 1 to targetNum do (
                local newWeight = (targetRotConstraint.GetWeight i) * 0.01 * newWeightScale
                targetRotConstraint.SetWeight i newWeight
            )
        )
        targetRotConstraint.relative = keepInit

        targetRotConstraint
    ),

    fn assign_rot_const_multi inObj inTargetArray keepInit:false = (
        for item in inTargetArray do assign_rot_const inObj item keepInit:keepInit
    ),

    fn add_target_to_rot_const inObj inTarget inWeight = (
        local targetRotConstraint = assign_rot_const inObj inTarget
        local targetNum = targetRotConstraint.getNumTargets()
        targetRotConstraint.SetWeight targetNum inWeight
    ),

    fn assign_euler_xyz inObj = (
        if classOf inObj.rotation.controller != rotation_list then inObj.rotation.controller = rotation_list()
        local rotList = assign_rot_list inObj
        rotList.Available.controller = Euler_XYZ()
        rotList.setActive rotList.count
    ),

    fn get_lookat inObj = (
        local returnConst = undefined
        if classOf inObj.rotation.controller == rotation_list then (
            local lst = inObj.rotation.controller
            local constNum = lst.getCount()
            local activeNum = lst.getActive()
            for i = 1 to constNum do (
                if (classOf lst[i].controller == LookAt_Constraint) then (
                    returnConst = lst[i].controller
                    if activeNum == i then return returnConst
                )
            )
        )

        if classOf inObj.rotation.controller == LookAt_Constraint then returnConst = inObj.rotation.controller

        return returnConst
    ),

    fn assign_lookat inObj inTarget keepInit:false = (
        if classOf inObj.rotation.controller != rotation_list then inObj.rotation.controller = rotation_list()
        local targetRotConstraint = get_lookat inObj
        if targetRotConstraint == undefined then (
            targetRotConstraint = LookAt_Constraint()
            inObj.rotation.controller.Available.controller = targetRotConstraint
            inObj.rotation.controller.setActive inObj.rotation.controller.count
        )

        local targetNum = targetRotConstraint.getNumTargets()
        local targetWeight = 100.0 / (targetNum + 1)
        targetRotConstraint.appendTarget inTarget targetWeight
        if targetNum > 0 then (
            local newWeightScale = 100.0 - targetWeight
            for i = 1 to targetNum do (
                local newWeight = (targetRotConstraint.GetWeight i) * 0.01 * newWeightScale
                targetRotConstraint.SetWeight i newWeight
            )
        )
        targetRotConstraint.relative = keepInit
    ),

    fn assign_lookat_multi inObj inTargetArray keepInit:false = (
        for item in inTargetArray do assign_lookat inObj item keepInit:keepInit
    ),

    fn assign_lookat_flipless inObj inTarget = (
        if (inObj.parent != undefined) then
        (
            local targetRotConstraint = rotation_script()
            targetRotConstraint.AddNode "Target" inTarget
            targetRotConstraint.AddNode "Parent" inObj.parent
            targetRotConstraint.AddObject "NodePos" inObj.pos.controller
            targetRotConstraint.script = "theTargetVector=(Target.transform.position * Inverse Parent.transform)-NodePos.value\ntheAxis=Normalize (cross theTargetVector [1,0,0])\ntheAngle=acos (dot (Normalize theTargetVector) [1,0,0])\nQuat theAngle theAxis"

            if classOf inObj.rotation.controller != rotation_list then inObj.rotation.controller = rotation_list()
            inObj.rotation.controller.Available.controller = targetRotConstraint
            inObj.rotation.controller.setActive inObj.rotation.controller.count
        )
    ),

    fn assign_rot_const_scripted inObj inTarget = (
        local targetRotConstraint = rotation_script()
        if classOf inObj.rotation.controller != rotation_list then inObj.rotation.controller = rotation_list()
        inObj.rotation.controller.Available.controller = targetRotConstraint
        inObj.rotation.controller.setActive inObj.rotation.controller.count

        local rotPointName = name.replace_type inObj.name "Dum"
        local rotMeasurePointNmae = name.increase_index rotPointName 1
        local rotExpName = name.replace_type inObj.name "Exp"
        rotExpName = name.replace_index rotExpName "0"

        local rotPoint = helper.create_point rotPointName size:2 boxToggle:on crossToggle:off
        local rotMeasuerPoint = helper.create_point rotMeasurePointNmae size:3 boxToggle:on crossToggle:off
        local rotExpPoint = ExposeTm name:rotExpName size:3 boxToggle:off crossToggle:on wirecolor:(color 14 255 2)

        rotPoint.transform = inObj.transform
        rotMeasuerPoint.transform = inObj.transform
        rotExpPoint.transform = inObj.transform

        rotPoint.transform.position = inTarget.transform.position
        rotMeasuerPoint.transform.position = inTarget.transform.position
        rotExpPoint.transform.position = inTarget.transform.position

        rotPoint.parent = inTarget
        rotMeasuerPoint.parent = inTarget.parent
        rotExpPoint.parent = inTarget

        rotExpPoint.exposeNode = rotPoint
        rotExpPoint.useParent = false
        rotExpPoint.localReferenceNode = rotMeasuerPoint

        local rotScript = ""
        rotScript += "local targetRot = rot.localEuler\n"
        rotScript += "local rotX = (radToDeg targetRot.x)\n"
        rotScript += "local rotY = (radToDeg targetRot.y)\n"
        rotScript += "local rotZ = (radToDeg targetRot.z)\n"
        rotScript += "local result = eulerAngles rotX rotY rotZ\n"
        rotScript += "eulerToQuat result\n"

        targetRotConstraint.AddNode "rot" rotExpPoint
        targetRotConstraint.SetExpression rotScript
    ),

    fn assign_scripted_lookat inOri inTarget = (
        local oriObj = inOri
        local oriParentObj = inOri.parent
        local targetObjArray = inTarget

        local objName = name.get_string oriObj.name
        local indexNum = name.get_index_as_digit oriObj.name
        local fChar = name.get_filteringChar objName
        local dummyName = name.add_prefix_to_realName objName "Dummy" filteringChar:fChar

        local lookAtPoint = helper.create_point (dummyName + fChar + (indexNum as String)) size:2 boxToggle:on crossToggle:off
        local lookAtMasuerPoint = helper.create_point (dummyName + fChar + ((indexNum + 1) as String)) size:3 boxToggle:on crossToggle:off
        local lookAtExpPoint = ExposeTm name:(dummyName + "Exp" + fChar + "0") size:3 boxToggle:off crossToggle:on wirecolor:(color 14 255 2)

        lookAtPoint.transform = oriObj.transform
        lookAtMasuerPoint.transform = oriObj.transform
        lookAtExpPoint.transform = oriObj.transform

        lookAtPoint.parent = oriParentObj
        lookAtMasuerPoint.parent = oriParentObj
        lookAtExpPoint.parent = oriParentObj

        lookAtExpPoint.exposeNode = lookAtPoint
        lookAtExpPoint.useParent = false
        lookAtExpPoint.localReferenceNode = lookAtMasuerPoint

        lookAtPoint.rotation.controller = LookAt_Constraint()
        for item in targetObjArray do (
            lookAtPoint.rotation.controller.appendTarget item (1.0 / targetObjArray.count * 100.0)
        )

        local rotControll = Euler_XYZ()
        if classOf oriObj.rotation.controller != rotation_list then oriObj.rotation.controller = rotation_list()
        oriObj.rotation.controller.Available.controller = rotControll

        local rotControllerNum = oriObj.rotation.controller.count
        oriObj.rotation.controller.setname rotControllerNum "Script Rotation"

        rotControll.X_Rotation.controller = Float_Expression()
        rotControll.Y_Rotation.controller = Float_Expression()
        rotControll.Z_Rotation.controller = Float_Expression()

        rotControll.X_Rotation.controller.AddScalarTarget "rotX" lookAtExpPoint.localEulerX.controller
        rotControll.Y_Rotation.controller.AddScalarTarget "rotY" lookAtExpPoint.localEulerY.controller
        rotControll.Z_Rotation.controller.AddScalarTarget "rotZ" lookAtExpPoint.localEulerZ.controller

        rotControll.X_Rotation.controller.SetExpression "rotX"
        rotControll.Y_Rotation.controller.SetExpression "rotY"
        rotControll.Z_Rotation.controller.SetExpression "rotZ"

        rotControll.X_Rotation.controller.Update()
        rotControll.Y_Rotation.controller.Update()
        rotControll.Z_Rotation.controller.Update()
    ),

    fn assign_attachment inPlacedObj inSurfObj bAlign:false shiftAxis:[0,0,1] shiftAmount:3.0 = (
        local placedObjTm = inPlacedObj.transform
        PreTranslate placedObjTm (shiftAxis * (-shiftAmount))
        local dirStartPos = placedObjTm.pos
        dirStartPos = placedObjTm.pos

        placedObjTm = inPlacedObj.transform
        PreTranslate placedObjTm (shiftAxis * shiftAmount)
        local dirEndPos = placedObjTm.pos
        dirEndPos = placedObjTm.pos

        local dirVec = dirEndPos - dirStartPos
        local dirRay = ray dirEndPos -dirVec
        local intersectArr = (intersectRayEx inSurfObj dirRay)

        if intersectArr != undefined then (
            local posListConst = assign_pos_list inPlacedObj
            local attConst = attachment()

            posListConst.Available.controller = attConst
            attConst.node = inSurfObj
            attConst.align = bAlign

            attachKey = attachCtrl.addNewKey attConst 0
            attachKey.face = intersectArr[2] - 1
            attachKey.coord = intersectArr[3]

            return attConst
        )
        else return undefined
    ),

    fn get_pos_controllers_name_from_list inObj = (
        local returnNameArray = #()

        if classOf inObj.position.controller == position_list then (
            local posList = inObj.position.controller
            for i = 1 to posList.count do append returnNameArray posList.getName i
        )

        returnNameArray
    ),

    fn get_pos_controllers_weight_from_list inObj = (
        local returnWeightArray = #()

        if classOf inObj.position.controller == position_list then (
            local posList = inObj.position.controller
            returnWeightArray = posList.weight
        )

        returnWeightArray
    ),

    fn set_pos_controllers_name_in_list inObj inLayerNum inNewName = (
        local listCtr = get_pos_list_controller inObj
        if listCtr != undefined then listCtr.setName inLayerNum inNewName
    ),

    fn set_pos_controllers_weight_in_list inObj inLayerNum inNewWeight = (
        local listCtr = get_pos_list_controller inObj
        if listCtr != undefined then listCtr.weight[inLayerNum] = inNewWeight
    ),

    fn get_rot_controllers_name_from_list inObj = (
        local returnNameArray = #()

        if classOf inObj.rotation.controller == position_list then (
            local rotList = inObj.rotation.controller
            for i = 1 to rotList.count do append returnNameArray rotList.getName i
        )

        returnNameArray
    ),

    fn get_rot_controllers_weight_from_list inObj = (
        local returnWeightArray = #()

        if classOf inObj.rotation.controller == position_list then (
            local rotList = inObj.rotation.controller
            returnWeightArray = rotList.weight
        )

        returnWeightArray
    ),

    fn set_rot_controllers_name_in_list inObj inLayerNum inNewName = (
        local listCtr = get_rot_list_controller inObj
        if listCtr != undefined then listCtr.setName inLayerNum inNewName
    ),

    fn set_rot_controllers_weight_in_list inObj inLayerNum inNewWeight = (
        local listCtr = get_rot_list_controller inObj
        if listCtr != undefined then listCtr.weight[inLayerNum] = inNewWeight
    )
)

/*******************************/
/* Bone Creation Library
/* dependency:
/*     name.ms
/*     anim.ms
/*     helper.ms
/*     constraint.ms
/*******************************/
struct _Bone (
    name, anim, helper, const,

    fn remove_ik inBone = (
        if (not IsProperty inBone "pos") or (not IsProperty inBone "rotation") then HDIKSys.RemoveChain inBone
    ),

    fn get_bone_assemblyHead inBone = (
        tempBone = inBone
        while (tempBone != undefined) do (
            if tempBone.assemblyHead then return tempBone
            if not tempBone.assemblyMember then exit
            tempBone = tempBone.parent
        )
        undefined
    ),

    fn put_child_into_bone_assembly inBone = (
        if (inBone.parent != undefined) and (inBone.parent.assemblyMember) then (
            inBone.assemblyMember = true
            inBone.assemblyMemberOpen = true
        )
    ),

    fn sort_bones_as_hierarchy inBoneArray = (
        struct BoneLevel (index, level)
        local bones     = #()

        -- fill the array of bone structures. intialize the hierarchy level with 0
        for i = 1 to inBoneArray.count do
        (
            bones[i] = BoneLevel i 0
        )

        -- calculate the hierarchy level for each bone in bones array. the hierarchy level
        -- is the number of ancestors between the current bone and the root node
        for i = 1 to bones.count do
        (
            local node = inBoneArray[bones[i].index]
            local n    = 0
            do
            (
                n    = n + 1
                node = node.parent
            ) while (node != undefined)
            bones[i].level = n
        )

        -- sort the bones array by the hierarchy level
        qsort bones (fn myLevel v1 v2 = (v1.level - v2.level))

        -- prepare the storage for the new bones and their parents
        local returnBonesArray = #()
        for i = 1 to inBoneArray.count do append returnBonesArray inBoneArray[bones[i].index]

        return returnBonesArray
    ),

    fn correct_negative_stretch bone ask = (
        local axisIndex, ooscale
        case bone.boneAxis of
        (
            #X: axisIndex = 1
            #Y: axisIndex = 2
            #Z: axisIndex = 3
        )

        ooscale = bone.objectOffsetScale
        if (ooscale[axisIndex] < 0) and ((not ask) or (queryBox "마이너스 방향본 수정할깝쇼? 이게 맞냐?" title:bone.Name)) do
        (
            ooscale[axisIndex] = -ooscale[axisIndex]
            axisIndex = axisIndex+2
            if axisIndex > 3 do axisIndex = axisIndex-3
            ooscale[axisIndex] = -ooscale[axisIndex]
            bone.objectOffsetScale = ooscale
        )
    ),

    fn reset_scale_of_selected_bones ask = (
        local bones = #()
        bones = sort_bones_as_hierarchy selection

        -- reset scale for all bones in the bones array
        --print "***resetting***"
        for i = 1 to bones.count do
        (
            --print "----"
            --print bones[i]
            --print selection[bones[i].index]
            ResetScale bones[i]
            if ask do correct_negative_stretch bones[i] false
        )
    ),

    fn is_nub_bone inputBone = (
        if (classOf inputBone) == BoneGeometry then (
            if inputBone.parent == undefined and inputBone.children.count == 0 then return true
            else return false
        )
        return false
    ),

    fn is_end_bone inputBone = (
        if (classOf inputBone) == BoneGeometry then (
            if inputBone.parent != undefined and inputBone.children.count == 0 then return true
            else return false
        )
        return false
    ),

    fn create_nub_bone inName inSize = (
        local nubBone = undefined
        with redraw off (
            nubBone = BoneSys.createBone [0,0,0] [1,0,0] [0,0,1]

            nubBone.width = inSize
            nubBone.height = inSize
            nubBone.taper = 90
            nubBone.length = inSize
            nubBone.frontfin = off
            nubBone.backfin = off
            nubBone.sidefins = off
            nubBone.name = name.set_index_as_nub inName
        )
        redrawViews()

        return nubBone
    ),

    fn create_nub_bone_on_obj inObj inSize:1 = (
        local boneName = name.get_string inObj.name
        local newBone = create_nub_bone boneName inSize
        newBone.transform = inObj.transform

        return newBone
    ),

    fn create_end_bone inBone = (
        local parentBone  = inBone
        local parentTrans = parentBone.transform
        local parentPos = parentTrans.translation
        local boneName = name.get_string parentBone.name
        local newbone = create_nub_bone boneName parentBone.width

        newBone.transform = parentTrans
        in coordSys Local move newBone [parentBone.length, 0, 0]

        newBone.parent = parentBone
        put_child_into_bone_assembly newBone

        newBone.width = parentBone.width
        newBone.height = parentBone.height
        newBone.frontfin = off
        newBone.backfin = off
        newBone.sidefins = off
        newBone.taper = 90
        newBone.length = (parentBone.width + parentBone.height) / 2
        newBone.wirecolor = parentBone.wirecolor

        return newBone
    ),

    fn create_bone inPointArray inName end:true delPoint:false parent:false size:2 normals:#() = (
        local filteringChar = name.get_filteringChar inName
        local tempBone = undefined
        local newBone = undefined

        local returnBoneArray = #()

        if inPointArray.count != 1 then (
            for i = 1 to (inPointArray.count - 1) do (
                local boneNum = i - 1

                if normals.count == inPointArray.count then (
                    local xDir = normalize(inPointArray[i+1].transform.position - inPointArray[i].transform.position)
                    local zDir = normalize(cross xDir normals[i])
                    newBone = BoneSys.createBone inPointArray[i].transform.position inPointArray[i+1].transform.position zDir
                )
                else (
                    newBone = BoneSys.createBone inPointArray[i].transform.position inPointArray[i+1].transform.position [0,-1,0]
                )

                newBone.boneFreezeLength=true
                newBone.name = inName + filteringChar + (boneNum as String)
                newBone.height = size
                newBone.width = size
                newBone.frontfin = off
                newBone.backfin = off
                newBone.sidefins = off

                append returnBoneArray newBone

                if tempBone != undefined then (
                    local tempTm = copy (newBone.transform * Inverse tempBone.transform)
                    local localRot = (tempTm.rotation as EulerAngles).x

                    anim.rotate_local newBone -localRot 0 0
                )

                newBone.parent = tempBone
                tempBone = newBone
            )

            if delPoint then (
                for i = 1 to inPointArray.count do (
                    if ((classOf inPointArray[i] == Dummy) or (classOf inPointArray[i] == ExposeTm) or (classOf inPointArray[i] == Point)) then delete inPointArray[i]
                )
            )

            if parent then (
                local parentNubPoint = helper.create_point (inName + filteringChar + "PNub") size:size boxToggle:on crossToggle:on
                parentNubPoint.transform = returnBoneArray[1].transform
                returnBoneArray[1].parent = parentNubPoint
            )

            select newBone

            if end then (
                local endBone = create_end_bone newBone
                append returnBoneArray endBone

                clearSelection()

                return returnBoneArray
            )
            else return returnBoneArray
        )
        else return false
    ),

    fn create_simple_bone inLength inName end:true size:1 = (
        local startPoint = helper.create_point "tempStart"
        local endPoint = helper.create_point "tempEnd" pos:[inLength, 0, 0]
        local returnBoneArray = create_bone #(startPoint, endPoint) inName end:end delPoint:true size:size

        return returnBoneArray
    ),

    fn create_stretch_bone inPointArray inName size:2 = (
        local tempBone = #()
        local returnArray = #()
        tempBone = create_bone inPointArray inName size:size

        for i = 1 to (tempBone.count - 1) do
        (
            tempBone[i].position.controller = Position_Constraint()
            tempBone[i].position.controller.AppendTarget inPointArray[i] 100

            tempBone[i].rotation.controller =  LookAt_Constraint()
            tempBone[i].rotation.controller.appendTarget inPointArray[i+1] 100
            tempBone[i].rotation.controller.lookat_vector_length = 0
        )

        tempBone[tempBone.count].position.controller = Position_Constraint()
        tempBone[tempBone.count].position.controller.AppendTarget inPointArray[inPointArray.count] 100

        return tempBone
    ),

    fn create_simple_stretch_bone inStart inEnd inName squash:false size:1 = (
        local returnArray = #()
        returnArray = create_stretch_bone #(inStart, inEnd) inName size:size
        if squash then returnArray[1].boneScaleType = #squash

        return returnArray
    ),

    fn get_bone_shape inBone = (
        local returnArray = #()
        if (classOf inBone) == BoneGeometry then (
            returnArray[1] = inBone.width
            returnArray[2] = inBone.height
            returnArray[3] = inBone.taper
            returnArray[4] = inBone.length
            returnArray[5] = inBone.sidefins
            returnArray[6] = inBone.sidefinssize
            returnArray[7] = inBone.sidefinsstarttaper
            returnArray[8] = inBone.sidefinsendtaper
            returnArray[9] = inBone.frontfin
            returnArray[10] = inBone.frontfinsize
            returnArray[11] = inBone.frontfinstarttaper
            returnArray[12] = inBone.frontfinendtaper
            returnArray[13] = inBone.backfin
            returnArray[14] = inBone.backfinsize
            returnArray[15] = inBone.backfinstarttaper
            returnArray[16] = inBone.backfinendtaper
        )

        return returnArray
    ),

    fn pasete_bone_shape targetBone shapeArray = (
        if (classOf targetBone) == BoneGeometry then (
            targetBone.width = shapeArray[1]
            targetBone.height = shapeArray[2]
            targetBone.taper = shapeArray[3]
            --targetBone.length = shapeArray[4]
            targetBone.sidefins = shapeArray[5]
            targetBone.sidefinssize = shapeArray[6]
            targetBone.sidefinsstarttaper = shapeArray[7]
            targetBone.sidefinsendtaper = shapeArray[8]
            targetBone.frontfin = shapeArray[9]
            targetBone.frontfinsize = shapeArray[10]
            targetBone.frontfinstarttaper = shapeArray[11]
            targetBone.frontfinendtaper = shapeArray[12]
            targetBone.backfin = shapeArray[13]
            targetBone.backfinsize = shapeArray[14]
            targetBone.backfinstarttaper = shapeArray[15]
            targetBone.backfinendtaper = shapeArray[16]

            if (is_end_bone targetBone) then (
                targetBone.taper = 90
                targetBone.length = (targetBone.width + targetBone.height) / 2
                targetBone.frontfin = off
                targetBone.backfin = off
                targetBone.sidefins = off
            )

            return true
        )
        return false
    ),

    fn set_fin_on inBone side:true front:true back:false inSize:2.0 inTaper:0.0 = (
        if (classOf inBone) == BoneGeometry then (
            if not (is_end_bone inBone) then (
                inBone.frontfin = front
                inBone.frontfinsize = inSize
                inBone.frontfinstarttaper = inTaper
                inBone.frontfinendtaper = inTaper

                inBone.sidefins = side
                inBone.sidefinssize = inSize
                inBone.sidefinsstarttaper = inTaper
                inBone.sidefinsendtaper = inTaper

                inBone.backfin = back
                inBone.backfinsize = inSize
                inBone.backfinstarttaper = inTaper
                inBone.backfinendtaper = inTaper
            )
        )
    ),

    fn set_fin_off inBone = (
        if (classOf inBone) == BoneGeometry then (
            inBone.frontfin = false
            inBone.sidefins = false
            inBone.backfin = false
        )
    ),

    fn set_bone_size inBone inSize = (
        if (classOf inBone == BoneGeometry) then (
            inBone.width = inSize
            inBone.height = inSize

            if (is_end_bone inBone) or (is_nub_bone inBone) then (
                inBone.taper = 90
                inBone.length = inSize
            )
        )
    ),

    fn set_bone_taper inBone inTaper = (
        if (classOf inBone == BoneGeometry) then (
            if not (is_end_bone inBone) then inBone.taper = inTaper
        )
    ),

    fn delete_bones_safely inBoneArray = (
        if inBoneArray.count > 0 then (
            for targetBone in inBoneArray do (
                const.collapse targetBone
                targetBone.parent = undefined
                delete targetBone
            )
            inBoneArray = deepCopy #()
        )
    ),

    fn select_first_children inObj = (
        selectmore inObj

        if inObj.children[1] == undefined then return false
        else (
            for i = 1 to inObj.children.count do (
                select_first_children inObj.children[i]
            )
            return true
        )
    ),

    fn select_every_children inObj includeSelf:false = (
        local children = #()
        if includeSelf then (
            children = (execute ("$'" + inObj.name + "'/*/.../*")) as array
            insertItem inObj children 1
        )
        else children = (execute ("$'" + inObj.name + "'/*/.../*")) as array

        children
    ),

    fn get_bone_end_position inBone = (
        if (classOf inBone == BoneGeometry) then [inBone.length, 0, 0] * inBone.objectTransform
        else (inBone.transform).translation
    ),

    fn create_skin_bone inBoneArray skipNub:true skinBoneBaseName:"b" = (
        local bones = #()
        local skinBoneFilteringChar = "_"
        local skinBonePushAmount = -0.02
        local returnBones = #()

        for i = 1 to inBoneArray.count do (
            local snapShotObj = snapshot inBoneArray[i]
            addModifier snapShotObj (Push())
            snapShotObj.modifiers[#Push].Push_Value = skinBonePushAmount
            collapseStack snapShotObj

            local skinBone = BoneSys.createBone inBoneArray[i].transform.translation (inBoneArray[i].transform.translation+6) inBoneArray[i].dir
            skinBone.transform = inBoneArray[i].transform

            skinBone.width = 2
            skinBone.height = 2
            skinBone.taper = 90
            skinBone.length = 2
            skinBone.frontfin = off
            skinBone.backfin = off
            skinBone.sidefins = off
            skinBone.wireColor = color 255 88 199

            skinBone.name = name.replace_base inBoneArray[i].name skinBoneBaseName
            skinBone.name = name.replace_filteringChar skinBone.name skinBoneFilteringChar

            addModifier skinBone (Edit_Poly())
            max modify mode
            modPanel.setCurrentObject skinBone.modifiers[#Edit_Poly]
            skinBone.modifiers[#Edit_Poly].Attach snapShotObj editPolyNode:skinBone

            const.assign_pos_const skinBone inBoneArray[i]
            const.assign_rot_const skinBone inBoneArray[i]

            skinBone.boneEnable = true
            skinBone.renderable = false
            skinBone.boneScaleType=#none

            append bones skinBone
        )

        for i = 1 to inBoneArray.count do (
            local oriParentObj = inBoneArray[i].parent
            if oriParentObj != undefined then (
                local skinBoneParentObjName = name.replace_base oriParentObj.name skinBoneBaseName
                skinBoneParentObjName = name.replace_filteringChar skinBoneParentObjName skinBoneFilteringChar
                bones[i].parent = getNodeByName skinBoneParentObjName
            )
            else bones[i].parent = undefined
        )

        if skipNub then (
            for item in bones do (
                if not (matchPattern item.name pattern:"*Nub") then append returnBones item
                else delete item
            )
        )
        else returnBones = deepCopy bones

        bones = #()

        return returnBones
    ),

    fn set_bone_on inBone = (
        if (classOf inBone == BoneGeometry) then (
            inBone.boneEnable = true
        )
    ),

    fn set_bone_off inBone = (
        if (classOf inBone == BoneGeometry) then (
            inBone.boneEnable = false
        )
    ),

    fn set_bone_on_selection = (
        local selArray = getCurrentSelection() as array
        for item in selArray do item.boneEnable = true
    ),

    fn set_bone_off_selection = (
        local selArray = getCurrentSelection() as array
        for item in selArray do item.boneEnable = false
    )
)





struct _Bip (
    rootName = "",

    com,
    head,
    neck,

    lClavicle,
    lUpperArm,
    lUpperArmTwist,
    lUpperArmTwist1,
    lUpperArmTwist2,
    lUpperArmTwist3,
    lUpperArmTwist4,
    lUpperArmTwist5,
    lUpperArmTwist6,
    lUpperArmTwist7,
    lUpperArmTwist8,
    lUpperArmTwist9,
    lForeArm,
    lForeArmTwist,
    lForeArmTwist1,
    lForeArmTwist2,
    lForeArmTwist3,
    lForeArmTwist4,
    lForeArmTwist5,
    lForeArmTwist6,
    lForeArmTwist7,
    lForeArmTwist8,
    lForeArmTwist9,
    lHand,

    rClavicle,
    rUpperArm,
    rUpperArmTwist,
    rUpperArmTwist1,
    rUpperArmTwist2,
    rUpperArmTwist3,
    rUpperArmTwist4,
    rUpperArmTwist5,
    rUpperArmTwist6,
    rUpperArmTwist7,
    rUpperArmTwist8,
    rUpperArmTwist9,
    rForeArm,
    rForeArmTwist,
    rForeArmTwist1,
    rForeArmTwist2,
    rForeArmTwist3,
    rForeArmTwist4,
    rForeArmTwist5,
    rForeArmTwist6,
    rForeArmTwist7,
    rForeArmTwist8,
    rForeArmTwist9,
    rHand,

    spine,
    spine1,
    spine2,
    spine3,
    spine4,
    pelvis,

    lThigh,
    lCalf,
    lFoot,
    lThighTwist,
    lThighTwist1,
    lThighTwist2,
    lThighTwist3,
    lThighTwist4,
    lThighTwist5,
    lThighTwist6,
    lThighTwist7,
    lThighTwist8,
    lThighTwist9,
    lCalfTwist,
    lCalfTwist1,
    lCalfTwist2,
    lCalfTwist3,
    lCalfTwist4,
    lCalfTwist5,
    lCalfTwist6,
    lCalfTwist7,
    lCalfTwist8,
    lCalfTwist9,

    rThigh,
    rCalf,
    rFoot,
    rThighTwist,
    rThighTwist1,
    rThighTwist2,
    rThighTwist3,
    rThighTwist4,
    rThighTwist5,
    rThighTwist6,
    rThighTwist7,
    rThighTwist8,
    rThighTwist9,
    rCalfTwist,
    rCalfTwist1,
    rCalfTwist2,
    rCalfTwist3,
    rCalfTwist4,
    rCalfTwist5,
    rCalfTwist6,
    rCalfTwist7,
    rCalfTwist8,
    rCalfTwist9,

    fn reset_private_variables = (
        com = undefined
        head = undefined
        neck = undefined
        lClavicle = undefined
        lUpperArm = undefined
        lUpperArmTwist = undefined
        lUpperArmTwist1 = undefined
        lUpperArmTwist2 = undefined
        lUpperArmTwist3 = undefined
        lUpperArmTwist4 = undefined
        lUpperArmTwist5 = undefined
        lUpperArmTwist6 = undefined
        lUpperArmTwist7 = undefined
        lUpperArmTwist8 = undefined
        lUpperArmTwist9 = undefined
        lForeArm = undefined
        lForeArmTwist = undefined
        lForeArmTwist1 = undefined
        lForeArmTwist2 = undefined
        lForeArmTwist3 = undefined
        lForeArmTwist4 = undefined
        lForeArmTwist5 = undefined
        lForeArmTwist6 = undefined
        lForeArmTwist7 = undefined
        lForeArmTwist8 = undefined
        lForeArmTwist9 = undefined
        lHand = undefined
        rClavicle = undefined
        rUpperArm = undefined
        rUpperArmTwist = undefined
        rUpperArmTwist1 = undefined
        rUpperArmTwist2 = undefined
        rUpperArmTwist3 = undefined
        rUpperArmTwist4 = undefined
        rUpperArmTwist5 = undefined
        rUpperArmTwist6 = undefined
        rUpperArmTwist7 = undefined
        rUpperArmTwist8 = undefined
        rUpperArmTwist9 = undefined
        rForeArm = undefined
        rForeArmTwist = undefined
        rForeArmTwist1 = undefined
        rForeArmTwist2 = undefined
        rForeArmTwist3 = undefined
        rForeArmTwist4 = undefined
        rForeArmTwist5 = undefined
        rForeArmTwist6 = undefined
        rForeArmTwist7 = undefined
        rForeArmTwist8 = undefined
        rForeArmTwist9 = undefined
        rHand = undefined
        spine = undefined
        spine1 = undefined
        spine2 = undefined
        spine3 = undefined
        spine4 = undefined
        pelvis = undefined
        lThigh = undefined
        lCalf = undefined
        lFoot = undefined
        lThighTwist = undefined
        lThighTwist1 = undefined
        lThighTwist2 = undefined
        lThighTwist3 = undefined
        lThighTwist4 = undefined
        lThighTwist5 = undefined
        lThighTwist6 = undefined
        lThighTwist7 = undefined
        lThighTwist8 = undefined
        lThighTwist9 = undefined
        lCalfTwist = undefined
        lCalfTwist1 = undefined
        lCalfTwist2 = undefined
        lCalfTwist3 = undefined
        lCalfTwist4 = undefined
        lCalfTwist5 = undefined
        lCalfTwist6 = undefined
        lCalfTwist7 = undefined
        lCalfTwist8 = undefined
        lCalfTwist9 = undefined
        rThigh = undefined
        rCalf = undefined
        rFoot = undefined
        rThighTwist = undefined
        rThighTwist1 = undefined
        rThighTwist2 = undefined
        rThighTwist3 = undefined
        rThighTwist4 = undefined
        rThighTwist5 = undefined
        rThighTwist6 = undefined
        rThighTwist7 = undefined
        rThighTwist8 = undefined
        rThighTwist9 = undefined
        rCalfTwist = undefined
        rCalfTwist1 = undefined
        rCalfTwist2 = undefined
        rCalfTwist3 = undefined
        rCalfTwist4 = undefined
        rCalfTwist5 = undefined
        rCalfTwist6 = undefined
        rCalfTwist7 = undefined
        rCalfTwist8 = undefined
        rCalfTwist9 = undefined
    ),

    fn get_bips = (
        local returnArray = for i in objects where isKindOf i Biped_Object collect i
        return returnArray
    ),

    fn get_bip_coms_name = (
        local bips = get_bips()
        local bipComsName = #()
        for obj in bips do appendIfUnique bipComsName obj.controller.rootName

        return bipComsName
    ),

    fn get_bip_nodes inBip = (
        if (classOf inBip) != Biped_Object then return false

        reset_private_variables()

        local returnNubs = #()
        local nn = biped.maxNumNodes inBip
        local nl = biped.maxNumLinks inBip
        for i = 1 to nn do (
            anode = biped.getNode inBip i
            if anode != undefined do (
                for j = 1 to nl do (
                    alink = biped.getNode inBip i link:j
                    if alink != undefined then append returnNubs alink
                )
            )
        )

        com = inBip.controller.rootNode
        rootName = com.controller.rootName
        head = biped.getNode com 11
        neck = biped.getNode com 17 link:1

        lClavicle = biped.getNode com #larm link:1
        lUpperArm = biped.getNode com #larm link:2
        lUpperArmTwist = biped.getNode com #lUparmTwist link:1
        lUpperArmTwist1 = biped.getNode com #lUparmTwist link:2
        lUpperArmTwist2 = biped.getNode com #lUparmTwist link:3
        lUpperArmTwist3 = biped.getNode com #lUparmTwist link:4
        lUpperArmTwist4 = biped.getNode com #lUparmTwist link:5
        lUpperArmTwist5 = biped.getNode com #lUparmTwist link:6
        lUpperArmTwist6 = biped.getNode com #lUparmTwist link:7
        lUpperArmTwist7 = biped.getNode com #lUparmTwist link:8
        lUpperArmTwist8 = biped.getNode com #lUparmTwist link:9
        lUpperArmTwist9 = biped.getNode com #lUparmTwist link:10
        lForeArm = biped.getNode com #larm link:3
        lForeArmTwist = biped.getNode com #lfArmTwist  link:1
        lForeArmTwist1 = biped.getNode com #lfArmTwist  link:2
        lForeArmTwist2= biped.getNode com #lfArmTwist  link:3
        lForeArmTwist3 = biped.getNode com #lfArmTwist  link:4
        lForeArmTwist4 = biped.getNode com #lfArmTwist  link:5
        lForeArmTwist5 = biped.getNode com #lfArmTwist  link:6
        lForeArmTwist6 = biped.getNode com #lfArmTwist  link:7
        lForeArmTwist7 = biped.getNode com #lfArmTwist  link:8
        lForeArmTwist8 = biped.getNode com #lfArmTwist  link:9
        lForeArmTwist9 = biped.getNode com #lfArmTwist  link:10
        lHand = biped.getNode com #larm link:4

        rClavicle = biped.getNode com #rarm link:1
        rUpperArm = biped.getNode com #rarm link:2
        rUpperArmTwist = biped.getNode com #rUparmTwist link:1
        rUpperArmTwist1 = biped.getNode com #rUparmTwist link:2
        rUpperArmTwist2 = biped.getNode com #rUparmTwist link:3
        rUpperArmTwist3 = biped.getNode com #rUparmTwist link:4
        rUpperArmTwist4 = biped.getNode com #rUparmTwist link:5
        rUpperArmTwist5 = biped.getNode com #rUparmTwist link:6
        rUpperArmTwist6 = biped.getNode com #rUparmTwist link:7
        rUpperArmTwist7 = biped.getNode com #rUparmTwist link:8
        rUpperArmTwist8 = biped.getNode com #rUparmTwist link:9
        rUpperArmTwist9 = biped.getNode com #rUparmTwist link:10
        rForeArm = biped.getNode com #rarm link:3
        rForeArmTwist = biped.getNode com #rfArmTwist  link:1
        rForeArmTwist1 = biped.getNode com #rfArmTwist  link:2
        rForeArmTwist2= biped.getNode com #rfArmTwist  link:3
        rForeArmTwist3 = biped.getNode com #rfArmTwist  link:4
        rForeArmTwist4 = biped.getNode com #rfArmTwist  link:5
        rForeArmTwist5 = biped.getNode com #rfArmTwist  link:6
        rForeArmTwist6 = biped.getNode com #rfArmTwist  link:7
        rForeArmTwist7 = biped.getNode com #rfArmTwist  link:8
        rForeArmTwist8 = biped.getNode com #rfArmTwist  link:9
        rForeArmTwist9 = biped.getNode com #rfArmTwist  link:10
        rHand = biped.getNode com #rarm link:4

        spine = biped.getNode com #spine link:1
        spine1 = biped.getNode com #spine link:2
        spine2 = biped.getNode com #spine link:3
        spine3 = biped.getNode com #spine link:4
        spine4 = biped.getNode com #spine link:5
        pelvis = biped.getNode com 12

        lThigh = biped.getNode com #lleg linke:1
        lCalf = biped.getNode com #lleg linke:2
        lFoot = biped.getNode com #lleg linke:4
        lThighTwist = biped.getNode com #lThighTwist link:1
        lThighTwist1 = biped.getNode com #lThighTwist link:2
        lThighTwist2 = biped.getNode com #lThighTwist link:3
        lThighTwist3 = biped.getNode com #lThighTwist link:4
        lThighTwist4 = biped.getNode com #lThighTwist link:5
        lThighTwist5 = biped.getNode com #lThighTwist link:6
        lThighTwist6 = biped.getNode com #lThighTwist link:7
        lThighTwist7 = biped.getNode com #lThighTwist link:8
        lThighTwist8 = biped.getNode com #lThighTwist link:9
        lThighTwist9 = biped.getNode com #lThighTwist link:10
        lCalfTwist = biped.getNode com #lCalfTwist link:1
        lCalfTwist1 = biped.getNode com #lCalfTwist link:2
        lCalfTwist2 = biped.getNode com #lCalfTwist link:3
        lCalfTwist3 = biped.getNode com #lCalfTwist link:4
        lCalfTwist4 = biped.getNode com #lCalfTwist link:5
        lCalfTwist5 = biped.getNode com #lCalfTwist link:6
        lCalfTwist6 = biped.getNode com #lCalfTwist link:7
        lCalfTwist7 = biped.getNode com #lCalfTwist link:8
        lCalfTwist8 = biped.getNode com #lCalfTwist link:9
        lCalfTwist9 = biped.getNode com #lCalfTwist link:10

        rThigh = biped.getNode com #rleg linke:1
        rCalf = biped.getNode com #rleg linke:2
        rFoot = biped.getNode com #rleg linke:4
        rThighTwist = biped.getNode com #rThighTwist link:1
        rThighTwist1 = biped.getNode com #rThighTwist link:2
        rThighTwist2 = biped.getNode com #rThighTwist link:3
        rThighTwist3 = biped.getNode com #rThighTwist link:4
        rThighTwist4 = biped.getNode com #rThighTwist link:5
        rThighTwist5 = biped.getNode com #rThighTwist link:6
        rThighTwist6 = biped.getNode com #rThighTwist link:7
        rThighTwist7 = biped.getNode com #rThighTwist link:8
        rThighTwist8 = biped.getNode com #rThighTwist link:9
        rThighTwist9 = biped.getNode com #rThighTwist link:10
        rCalfTwist = biped.getNode com #rCalfTwist link:1
        rCalfTwist1 = biped.getNode com #rCalfTwist link:2
        rCalfTwist2 = biped.getNode com #rCalfTwist link:3
        rCalfTwist3 = biped.getNode com #rCalfTwist link:4
        rCalfTwist4 = biped.getNode com #rCalfTwist link:5
        rCalfTwist5 = biped.getNode com #rCalfTwist link:6
        rCalfTwist6 = biped.getNode com #rCalfTwist link:7
        rCalfTwist7 = biped.getNode com #rCalfTwist link:8
        rCalfTwist8 = biped.getNode com #rCalfTwist link:9
        rCalfTwist9 = biped.getNode com #rCalfTwist link:10

        return returnNubs
    ),

    fn get_com inBip = (
        get_bip_nodes inBip
        return com
    ),

    fn get_com_name inBip = (
        get_bip_nodes inBip
        return rootName
    ),

    fn get_bip_nub_helpers inBip = (
        local returnNubs = #()
        local nn = biped.maxNumNodes inBip
        local nl = biped.maxNumLinks inBip
        for i = 1 to nn do (
            anode = biped.getNode inBip i
            if anode != undefined do (
                for j = 1 to nl do (
                    alink = biped.getNode inBip i link:j
                    if alink != undefined then (
                        if (alink.children.count == 1) and (classof alink.children[1] == Dummy) then append returnNubs alink.children[1]
                    )
                )
            )
        )

        return returnNubs
    ),

    fn get_bip_coms = (
        local bipComsName = get_bip_coms_name()
        local bipComs = for objName in bipComsName collect (getNodeByName objName)
        return bipComs
    ),

    fn get_bip_coms_num = (
        local bipComsName = get_bip_coms_name()
        return bipComsName.count
    ),

    fn get_twist_bone_number inBip = (
        local returnArray = #()
        append returnArray inBip.controller.upperarmTwistLinks
        append returnArray inBip.controller.forearmTwistLinks
        append returnArray inBip.controller.thighTwistLinks
        append returnArray inBip.controller.calfTwistLinks
        append returnArray inBip.controller.horseTwistLinks

        return returnArray
    ),

    fn add_scale_controller_to_bipNode bipObj = (
        bipObj.transform.controller.Biped_SubAnim.controller.BipScaleList.controller.Available.controller = ScaleXYZ ()
        setTransformLockFlags bipObj #{8,9}
    ),

    fn set_bipObj_scale bipObj inputScaleVal = (
        bipObj.transform.controller.Biped_SubAnim.controller.BipScaleList.ScaleXYZ.value = inputScaleVal
    ),

    fn get_bipObj_scale bipObj = (
        local returnScale = bipObj.transform.controller.Biped_SubAnim.controller.BipScaleList.ScaleXYZ.value

        return returnScale
    ),

    fn create_bip = (
        local bipObj = biped.createNew 180 -90 [0, 0, 172.627] arms:true neckLinks:1 \
        spineLinks:3 legLinks:3 fingers:5 fingerLinks:3 toes:1 toeLinks:1 \
        ankleAttach:0.2 trianglePelvis:false triangleNeck:true \
        forearmTwistLinks:3 upperarmTwistLinks:3 thighTwistLinks:3 calfTwistLinks:3

        get_bip_nodes bipObj
    ),

    fn turn_on_figureMode inBip = (
        inBip.controller.figureMode = true
    ),

    fn turn_off_figureMode inBip = (
        inBip.controller.figureMode = false
    )
)


struct _Mirror (
    name, bone,

    fn mirror_matrix mAxis:"x" mFlip:"x" tm:(matrix3 1) pivotTm:(matrix3 1) = (
       fn fetch_reflection a = (
          case a of (
          "x": [-1,1,1]  -- reflect in YZ plane
          "y": [1,-1,1]  --     in ZX plane
          "z": [1,1,-1]  --     in XY plane
          default: [1,1,1]
          )
       )

       aReflection = scalematrix (fetch_reflection mAxis)
       fReflection = scalematrix (fetch_reflection mFlip)

       --calculate the mirroredTM
       --fReflection * (tm * (inverse pivotTm)) * aReflection * pivotTm
       fReflection * tm * aReflection * pivotTm
    ),

    fn apply_mirror inObj axis:1 flip:2 pivotObj:undefined cloneStatus:2 negative:false = (
        local axisArray = #("x", "y", "z", "none")
        local copyObj = copy inObj
        local objTm = inObj.transform
        local pivotTm = (matrix3 1)
        local mirrorAxisIndex = axis
        local flipAxisIndex = flip
        local copyObjName = name.gen_mirroring_name inObj.name

        if pivotObj != undefined then pivotTm = pivotObj.transform
        if negative == true then flipAxisIndex = 4
        
        copyObj.name = copyObjName
        copyObj.parent = undefined
        copyObj.wirecolor = inObj.wirecolor
        
        case cloneStatus of (
            1: (
                delete copyObj
                copyObj = undefined
                inObj.transform = mirror_matrix mAxis:axisArray[mirrorAxisIndex] mFlip:axisArray[flipAxisIndex] tm:objTm pivotTm:pivotTm
                copyObj = inObj
            )
            2: (
                copyObj.transform = mirror_matrix mAxis:axisArray[mirrorAxisIndex] mFlip:axisArray[flipAxisIndex] tm:objTm pivotTm:pivotTm
            )
            3: (
                delete copyObj
                copyObj = undefined
                copyObj = (snapShot inObj)
                copyObj.transform = mirror_matrix mAxis:axisArray[mirrorAxisIndex] mFlip:axisArray[flipAxisIndex] tm:objTm pivotTm:pivotTm
            )
        )

        return copyObj
    ),

    fn mirror_object inObjArray mAxis:1 pivotObj:undefined cloneStatus:2 = (
        local returnArray = for i = 1 to inObjArray.count collect (apply_mirror inObjArray[i] axis:mAxis pivotObj:pivotObj cloneStatus:cloneStatus negative:true)

        returnArray
    ),

    fn mirror_without_negative inMirrorObjArray mAxis:1 pivotObj:undefined cloneStatus:2 = (
        --mirrorAxis labels:#("XY", "XZ", "YX", "YZ", "ZX", "ZY")
        local axisIndex = 1
        local flipIndex = 1

        case mAxis of (
            1: (
                axisIndex = 1
                flipIndex = 2
            )
            2: (
                axisIndex = 1
                flipIndex = 3
            )
            3: (
                axisIndex = 2
                flipIndex = 1
            )
            4: (
                axisIndex = 2
                flipIndex = 3
            )
            5: (
                axisIndex = 3
                flipIndex = 1
            )
            6: (
                axisIndex = 3
                flipIndex = 2
            )
            default: (
                axisIndex = 1
                flipIndex = 1
            )
        )
        local returnArray = for i = 1 to inMirrorObjArray.count collect (apply_mirror inMirrorObjArray[i] axis:axisIndex flip:flipIndex pivotObj:pivotObj cloneStatus:cloneStatus negative:false)

        returnArray
    ),

    fn mirror_bone inBoneArray mAxis:1 flipZ:false offset:0.0 = (
        local bones = bone.sort_bones_as_hierarchy inBoneArray
        local axisFactor = [1,1,1]
        case mAxis of (
            1: axisFactor = [-1,1,1]
            2: axisFactor = [1,-1,1]
            3: axisFactor = [1,1,-1]
        )
        -- prepare the storage for the new bones and their parents
        local parents = #()
        local created = #()
        local root    = bones[1].transform.translation
        created.count = 0
        
        -- loop through the sorted selection so that the hierarchy is browsed from top to bottom
        for i = 1 to bones.count do (
            local original = bones[i]
            if (classof original != BoneGeometry) do -- not a real bone
            (
                append parents undefined --no parent will be assigned. undefined is added only to keep the numbering
                continue
            )

            -- take the start point, end point and the Z axis from the original bone                
            local boneStart  = original.pos
            local boneEnd    = bone.get_bone_end_position original
            local boneZ      = original.dir
            
            -- apply mirroring to the start and end points
            for k = 1 to 3 do (
                if ( axisFactor[k] < 0 ) do
                (
                  boneStart [k] = 2.0*root[k] - boneStart[k] + offset
                  boneEnd   [k] = 2.0*root[k] - boneEnd  [k] + offset
                  boneZ     [k] = -boneZ[k]
                )
            )

            -- flip the bone's Z axis if the flipZ argument says so
            if ( flipZ ) do boneZ = -boneZ

            -- create the reflection of the original bone               
            local reflection              = bonesys.createbone boneStart boneEnd boneZ
            
            -- copy all applicable parameters from the original bone to the reflection
            reflection.backfin            = original.backfin
            reflection.backfinendtaper    = original.backfinendtaper
            reflection.backfinsize        = original.backfinsize 
            reflection.backfinstarttaper  = original.backfinstarttaper
            reflection.frontfin           = original.frontfin
            reflection.frontfinendtaper   = original.frontfinendtaper
            reflection.frontfinsize       = original.frontfinsize
            reflection.frontfinstarttaper = original.frontfinstarttaper
            reflection.height             = original.height
            if (name.has_side original.name) then reflection.name = name.gen_mirroring_name original.name
            else reflection.name = name.add_sufix_to_realName original.name "Mirrored"
            reflection.sidefins           = original.sidefins 
            reflection.sidefinsendtaper   = original.sidefinsendtaper
            reflection.sidefinssize       = original.sidefinssize
            reflection.sidefinsstarttaper = original.sidefinsstarttaper
            reflection.taper              = original.taper
            reflection.width              = original.width
            reflection.wirecolor          = original.wirecolor

            append created reflection
            append parents reflection
        )

        for i = created.count to 2 by -1 do (
            local pIndex = findItem bones bones[i].parent
            if pIndex != 0 then created[i].parent = parents[pIndex]
        )
        created[1].parent = bones[1].parent
        for i = 1 to created.count do (
            if created[i].parent == undefined then created[i].position = bones[i].position * axisFactor
        )

        return created
    ),

    fn mirror_geo inMirrorObjArray mAxis:1 pivotObj:undefined cloneStatus:2 = (
        local mirroredArray = mirror_object inMirrorObjArray mAxis:mAxis pivotObj:pivotObj cloneStatus:cloneStatus
        local resetXformArray = #()
        local nonResetXformArray = #()
        local returnArray = #()

        for item in mirroredArray do (
            local caseIndex = 0
            if classOf item == Editable_Poly then caseIndex += 1
            if classOf item == Editable_mesh then caseIndex += 1
            if item.modifiers.count > 0 then caseIndex += 1

            case caseIndex of (
                1: append resetXformArray item
                default: append nonResetXformArray item
            )
        )

        for item in resetXformArray do (
            ResetXForm item
            local tempNormalMod = normalModifier()
            tempNormalMod.flip = true
            addModifier item tempNormalMod
            collapseStack item
        )
        
        join returnArray resetXformArray
        join returnArray nonResetXformArray

        returnArray
    )
)

struct _Layer (
    fn reset_layer = (
        local defaultLayer = layerManager.getLayer 0
        local layerNameArray = #()
        defaultLayer.current  = true

        if LayerManager.count > 1 then (
            for i = 1 to layerManager.count-1 do (
                ilayer = layerManager.getLayer i
                layerName = ilayer.name
                append layerNameArray layerName

                layer = ILayerManager.getLayerObject i
                layerNodes = refs.dependents layer

                for item in layerNodes do (
                    if (isValidNode item) then defaultLayer.addNode item
                )
            )
            for item in layerNameArray do LayerManager.deleteLayerByName item
        )
    ),

    fn get_nodes_from_layer inLayerNum = (
        if inLayerNum != false then (
            layer = layermanager.getLayer inLayerNum
            layer.nodes &theNodes
            return theNodes
        )
        else (
            local emptyArray = #()
            return emptyArray
        )
    ),

    fn get_layer_number inLayerName = (
        for i = 0 to (LayerManager.count - 1) do (
            ilayer = layerManager.getLayer i
            if ilayer.name == inLayerName then return i
        )

        return false
    ),

    fn get_nodes_by_layername inLayerName = (
        get_nodes_from_layer (get_layer_number inLayerName)
    ),

    fn del_empty_layer showLog:false = (
        DeletedLayerCount = 0
        local deflayer = layermanager.getlayer 0
        deflayer.current = true
        for i = Layermanager.count-1 to 1 by-1 do (
            layer = layermanager.getLayer i
            local thislayername = layer.name
            layer.nodes &theNodes
            if thenodes.count== 0 then (
                LayerManager.deleteLayerbyname thislayername
                DeletedLayerCount +=1
            )
        )

        if showLog then (
            if not DeletedLayerCount == 0 then Messagebox ("Number of layers removed - " + DeletedLayerCount as string) title:"Layer Manager"
        )
    ),

    fn create_layer_from_array inArray inLayerName = (
        local newLayer = undefined
        local layerIndex = get_layer_number inLayerName
        if layerIndex == false then (
            newLayer = LayerManager.newLayer()
            newLayer.setName inLayerName
        )
        else newLayer = layerManager.getLayer layerIndex
        for item in inArray do newLayer.addNode item

        return newLayer
    ),

    fn delete_layer inLayerName forceDelete:false = (
        local returnVal = false
        local deflayer = layermanager.getlayer 0
        deflayer.current = true
        local nodeArray = get_nodes_by_layername inLayerName
        if nodeArray.count > 0 then (
            if forceDelete then (
                delete nodeArray
                nodeArray = #()
            )
            else for item in nodeArray do deflayer.addNode item
        )
        returnVal = LayerManager.deleteLayerbyname inLayerName

        returnVal
    ),

    fn set_parent_layer inLayerName inParentName = (
        local returnVal = false
        local targetLayer = layermanager.getlayer (get_layer_number inLayerName)
        local parentLayer = layermanager.getlayer (get_layer_number inParentName)
        if targetLayer != undefined and parentLayer != undefined then (
            targetLayer.setParent parentLayer
            returnVal = true
        )

        returnVal
    )
)

struct _Align (
    fn align_to_last_sel_center = (
        if selection.count > 1 then (
            for i = 1 to (selection.count - 1) do (
                selection[i].transform = selection[selection.count].transform
                selection[i].pos = selection[selection.count].center
            )
        )
    ),

    fn align_to_last_sel = (
        if selection.count > 1 then (
            for i = 1 to (selection.count - 1) do (
                selection[i].transform = selection[selection.count].transform
            )
        )
    ),

    fn align_to_last_sel_pos = (
        if selection.count > 1 then (
            for i = 1 to (selection.count - 1) do (
                local posDumPoint = Point()
                local posConst = Position_Constraint()
                local rotConst = Orientation_Constraint()
                posDumPoint.position.controller = posConst
                posDumPoint.rotation.controller = rotConst
                posConst.appendTarget selection[selection.count] 100.0
                rotConst.appendTarget selection[i] 100.0

                selection[i].transform = posDumPoint.transform
                delete posDumPoint
            )
        )
    ),

    fn align_to_last_sel_rot = (
        if selection.count > 1 then (
            for i = 1 to (selection.count - 1) do (
                local rotDumPoint = Point()
                local posConst = Position_Constraint()
                local rotConst = Orientation_Constraint()
                rotDumPoint.position.controller = posConst
                rotDumPoint.rotation.controller = rotConst
                posConst.appendTarget selection[i] 100.0
                rotConst.appendTarget selection[selection.count] 100.0

                selection[i].transform = rotDumPoint.transform
                delete rotDumPoint
            )
        )
    )
)

struct _Select (
    name, bone,

    fn set_selectionSet_to_all = (
        SetSelectFilter 1
    ),

    fn set_selectionSet_to_bone = (
        SetSelectFilter 8
    ),

    fn reset_selectionSet = (
        SetSelectFilter 1
    ),

    fn set_selectionSet_to_helper = (
        SetSelectFilter 6
    ),

    fn set_selectionSet_to_point = (
        SetSelectFilter 10
    ),

    fn set_selectionSet_to_spline = (
        SetSelectFilter 3
    ),

    fn set_selectionSet_to_mesh = (
        SetSelectFilter 2
    ),

    fn filter_bip = (
        local selArray = getCurrentSelection()
        if selArray.count > 0 then (
            local filteredSel = for item in selArray where ((classOf item) == Biped_Object) collect item
            clearSelection()
            select filteredSel
        )
    ),

    fn filter_bone = (
        local selArray = getCurrentSelection()
        if selArray.count > 0 then (
            local filteredSel = for item in selArray where ((classOf item) == BoneGeometry) collect item
            clearSelection()
            select filteredSel
        )
    ),

    fn filter_helper = (
        local selArray = getCurrentSelection()
        if selArray.count > 0 then (
            local filteredSel = for item in selArray where (((classOf item) == Point) or ((classOf item) == IK_Chain_Object)) collect item
            clearSelection()
            select filteredSel
        )
    ),

    fn filter_expTm = (
        local selArray = getCurrentSelection()
        if selArray.count > 0 then (
            local filteredSel = for item in selArray where ((classOf item) == ExposeTm) collect item
            clearSelection()
            select filteredSel
        )
    ),

    fn filter_spline = (
        local selArray = getCurrentSelection()
        if selArray.count > 0 then (
            local filteredSel = for item in selArray where ((superClassOf item) == shape) collect item
            clearSelection()
            select filteredSel
        )
    ),

    fn select_children inObj includeSelf:false = (
        local children = #()
        if includeSelf then (
            children = (execute ("$'" + inObj.name + "'/*/.../*")) as array
            insertItem inObj children 1
        ) 
        else children = (execute ("$'" + inObj.name + "'/*/.../*")) as array

        children
    ),

    fn distinguish_hierachy_objects inArray = (
        local returnArray = #()
        local seperatedNodesArray = #()
        local hierachyNodesArray = #()

        for item in inArray do (
            if item.parent == undefined and item.children.count == 0 then append seperatedNodesArray item
            else append hierachyNodesArray item
        )

        returnArray[1] = seperatedNodesArray
        returnArray[2] = hierachyNodesArray

        return returnArray
    ),

    fn get_nonLinked_objects inArray = (
        return (distinguish_hierachy_objects inArray)[1]
    ),

    fn get_linked_objects inArray = (
        return (distinguish_hierachy_objects inArray)[2]
    ),

    fn sort_by_hierachy inArray = (
        return bone.sort_bones_as_hierarchy inArray
    ),

    fn sort_by_index inArray = (
        if inArray.count > 0 then (
            struct indexSorting (oriIndex, newIndex)

            local sortedArray = #()
            local structArray = #()

            for i = 1 to inArray.count do (
                local tempIndex = name.get_index_as_digit inArray[i].name
                if tempIndex == false then (
                    structArray[i] = indexSorting i 0
                )
                else structArray[i] = indexSorting i tempIndex
            )

            qsort structArray (fn myLevel v1 v2 = (v1.newIndex - v2.newIndex))

            for i = 1 to inArray.count do append sortedArray inArray[structArray[i].oriIndex]

            return sortedArray
        )
        return #()
    ),

    fn sort_objects inArray = (
        local returnArray = #()
        local aloneObjArray = get_nonLinked_objects inArray
        local hierachyObjArray = get_linked_objects inArray

        local sortedAloneObjArray = #()
        local sortedHierachObjArray = #()
        local isAloneImporter = false

        local firstIndexOfAloneObj = 10000
        local firstIndexOfHierachyObj = 10000

        sortedAloneObjArray = sort_by_index aloneObjArray
        sortedHierachObjArray = sort_by_hierachy hierachyObjArray
        
        if sortedAloneObjArray.count > 0 then (
            local indexDigit = name.get_index_as_digit sortedAloneObjArray[1].name
            if indexDigit == false then firstIndexOfAloneObj = 0
            else firstIndexOfAloneObj = indexDigit
        )
        if sortedHierachObjArray.count > 0 then (
            local indexDigit = name.get_index_as_digit sortedHierachObjArray[1].name
            if indexDigit == false then firstIndexOfHierachyObj = 0
            else firstIndexOfHierachyObj = indexDigit
        )
        
        if firstIndexOfAloneObj < firstIndexOfHierachyObj then isAloneImporter = true
        if isAloneImporter then (
            for item in sortedAloneObjArray do append returnArray item
            for item in sortedHierachObjArray do append returnArray item
        )
        else (
            for item in sortedHierachObjArray do append returnArray item
            for item in sortedAloneObjArray do append returnArray item
        )

        return returnArray
    )
)

struct _Link (
    fn link_to_last_sel = (
        if selection.count > 1 then (
            for i = 1 to (selection.count - 1) do (
                selection[i].parent = selection[selection.count]
            )
        )
    ),

    fn link_to_first_sel = (
        if selection.count > 1 then (
            for i = 2 to selection.count do (
                selection[i].parent = selection[1]
            )
        )
    ),

    fn unlink_selection = (
        if selection.count > 0 then (
            for item in selection do (
                item.parent = undefined
            )
        )
    ),

    fn unlink_children = (
        if selection.count == 1 then (
            for item in selection[1].children do (
                item.parent = undefined
            )
        )
    )
)


/**************************************/
/* Skin Library
/**************************************/

struct _SkinVert (
    index,
    boneArray = #(),
    boneIDArray = #(),
    boneNameArray = #(),
    weightArray = #()
)

struct _Skin (
    name,

    prog,

    skinMod,
    modIndex = 0,
    allBoneNamesArray = #(),
    allBonesArray = #(),
    skinWeightsArray = #(),

    fn find_skin inputObj = (
        local returnVal = 0
        if inputObj.modifiers.count == 0 then return returnVal
        for i = 1 to inputObj.modifiers.count do (
            if (classof inputObj.modifiers[i]) == Skin then (
                skinMod = inputObj.modifiers[i]
                modIndex = i
                returnVal = i
            )
        )

        returnVal
    ),

    fn select_skinObj inputObj = (
        local returnVal = false
        if (find_skin inputObj) == 0 then return returnVal

        max modify mode
        select inputObj
        modPanel.setCurrentObject inputObj.modifiers[modIndex]
        subobjectLevel = 1
        returnVal = true
        returnVal
    ),

    fn remove_unused_bones inputObj weightThresh:0.0001 = (
        local returnVal = false
        if not(select_skinObj inputObj) then return returnVal

        local vertCount = skinOps.GetNumberVertices skinMod
        local bonesCount = skinOps.GetNumberBones skinMod
        local unusedBones = #{1..bonesCount}

        for v = 1 to vertCount do (
            local vertWeightCount = skinOps.GetVertexWeightCount skinMod v

            for i = 1 to vertWeightCount do (
                local weight = skinOps.GetVertexWeight skinMod v i
                if weight >= weightThresh then (
                    local boneID = skinOps.GetVertexWeightBoneID skinMod v i
                    unusedBones[boneID] = false
                )
            )
        )

        for i = bonesCount to 1 by -1 where unusedBones[i] do (
            skinOps.SelectBone skinMod i
            skinOps.RemoveBone skinMod
        )

        returnVal = true
        returnVal
    ),

    fn get_all_bones inputObj = (
        local returnVal = #()
        if not(select_skinObj inputObj) then return returnVal

        allBoneNamesArray = #()
        allBonesArray = #()

        allBoneNamesArray = for i = 1 to skinOps.GetNumberBones skinMod collect skinOps.GetBoneName skinMod i 0
        allBonesArray = for i = 1 to allBoneNamesArray.count collect getNodeByName allBoneNamesArray[i]

        returnVal = deepCopy allBonesArray
        returnVal
    ),

    fn get_bone_index inputObj targetBone = (
        local returnVal = 0
        if allBonesArray.count > 0 then (
            local boneID = findItem allBonesArray targetBone
            returnVal = boneID
        )

        returnVal
    ),

    fn round_number num precision:3 = (
        local multiplier = 10 ^ precision
        ( floor ( (num * multiplier) + 0.5) ) / multiplier
    ),

    fn get_selected_skinVerts inputObj = (
        local returnVal = #()
        if not(select_skinObj inputObj) then return returnVal
        returnVal = for v = 1 to skinOps.GetNumberVertices skinMod where skinOps.IsVertexSelected skinMod v == 1 collect v

        returnVal
    ),

    fn get_vert_weight inputObj inVertIndex = (
        local returnVal = _SkinVert()
        if skinMod == undefined then return returnVal
        if allBonesArray.count == 0 then (
            get_all_bones inputObj
            if allBonesArray.count == 0 then return returnVal
        )

        local boneArray = #()
        local boneIDArray = #()
        local boneNameArray = #()
        local weightArray = #()
        local boneNum = skinOps.getVertexWeightCount skinMod inVertIndex

        for i = 1 to boneNum do (
            local boneID = skinOps.getVertexWeightBoneID skinMod inVertIndex i
            local boneName = skinOps.GetBoneName skinMod boneID 0
            local boneSysID = findItem allBoneNamesArray boneName
            local boneWeight = skinOps.getVertexWeight skinMod inVertIndex i
            append boneArray allBonesArray[boneSysID]
            append boneIDArray boneID
            append boneNameArray boneName
            append weightArray (round_number boneWeight)
        )

        returnVal.index = inVertIndex
        returnVal.boneArray = deepCopy boneArray
        returnVal.boneIDArray = deepCopy boneIDArray
        returnVal.boneNameArray = deepCopy boneNameArray
        returnVal.weightArray = deepCopy weightArray

        returnVal
    ),

    fn get_skin_weights inputObj = (
        if (get_all_bones inputObj) then (
            skinWeightsArray = #()

            local numVerts = skinOps.GetNumberVertices skinMod
            for v = 1 to numVerts do (
                local boneArray = #()
                local boneIDArray = #()
                local boneNameArray = #()
                local weightArray = #()
                local boneNum = skinOps.getVertexWeightCount skinMod v

                for i = 1 to boneNum do (
                    local boneID = skinOps.getVertexWeightBoneID skinMod v i
                    local boneName = skinOps.GetBoneName skinMod boneID 0
                    local boneSysID = findItem allBoneNamesArray boneName
                    local boneWeight = skinOps.getVertexWeight skinMod v i
                    append boneArray allBonesArray[boneSysID]
                    append boneIDArray boneID
                    append boneNameArray boneName
                    append weightArray boneWeight
                )
                append skinWeightsArray (_SkinVert index:v boneArray:boneArray boneIDArray:boneIDArray boneNameArray:boneNameArray weightArray:weightArray)
            )
        )
    ),

    fn get_skin_weights inputObj = (
        local returnVal = #()
        if allBonesArray.count > 0 then (
            skinWeightsArray = #()
            local numVerts = skinOps.GetNumberVertices skinMod
            for i = 1 to numVerts do (
                append skinWeightsArray (get_vert_weight inputObj i)
            )
            returnVal = deepCopy skinWeightsArray
        )
        returnVal
    ),

    fn select_zeroWeight_vertex inputObj = (
        local returnArray = #()
        if not(select_skinObj inputObj) then return returnArray

        local numVerts = skinOps.GetNumberVertices skinMod
        for v = 1 to numVerts do (
            local weights = (get_vert_weight inputObj v).weightArray
            local weightVal = 0.0
            for item in weights do if item != undefined then weightVal += item
            if weightVal == 0.0 then append returnArray v
        )
        skinOps.SelectVertices skinMod returnArray
        redrawViews()

        returnArray
    ),

    fn replace_bone inputObj oriBone newBone removeOldBone:true = (
        if (find_skin inputObj) == 0 then return false
        skinOps.addbone skinMod newBone 1
        get_all_bones inputObj
        if allBonesArray.count < 2 then return false

        get_skin_weights inputObj
        local prevSkinWeightsArray = deepCopy skinWeightsArray
        local oriBoneIndex = get_bone_index inputObj oriBone
        if oriBoneIndex == 0 then return false
        local newBoneIndex = get_bone_index inputObj newBone
        local vertNum = skinOps.GetNumberVertices skinMod

        for v = 1 to vertNum do (
            local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
            if finedBoneID != 0 then (
                prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
            )
        )
        if removeOldBone == true then skinOps.removebone skinMod oriBoneIndex

        return true
    ),

    fn copy_weight_between_bones_in_skin inputObj oriBone newBone removeOldBone:false = (
        if (find_skin inputObj) == 0 then return false

        get_skin_weights inputObj
        local prevSkinWeightsArray = deepCopy skinWeightsArray
        local oriBoneIndex = get_bone_index inputObj oriBone
        if oriBoneIndex == 0 then return false
        local newBoneIndex = get_bone_index inputObj newBone
        local vertNum = skinOps.GetNumberVertices skinMod

        for v = 1 to vertNum do (
            local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
            if finedBoneID != 0 then (
                prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
            )
        )
        if removeOldBone == true then skinOps.removebone skinMod oriBoneIndex

        return true
    ),

    fn replace_multi_bones inputObj oriBoneArray newBoneArray = (
        if oriBoneArray.count == newBoneArray.count then (
            if (find_skin inputObj) == 0 then return false

            for item in newBoneArray do (
                skinOps.addbone skinMod item 1
            )

            get_skin_weights inputObj
            local delBones = #{1..allBonesArray.count}
            local prevSkinWeightsArray = deepCopy skinWeightsArray

            local vertNum = skinOps.GetNumberVertices skinMod
            for i= 1 to oriBoneArray.count do (
                local oriBoneIndex = get_bone_index inputObj oriBoneArray[i]
                local newBoneIndex = get_bone_index inputObj newBoneArray[i]
                if oriBoneIndex != 0 then (
                    delBones[oriBoneIndex] = false
                    for v = 1 to vertNum do (
                        local finedBoneID = findItem prevSkinWeightsArray[v].boneIDArray oriBoneIndex
                        if finedBoneID != 0 then (
                            prevSkinWeightsArray[v].boneIDArray[finedBoneID] = newBoneIndex
                            skinOps.ReplaceVertexWeights skinMod v prevSkinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray
                        )
                    )
                )
            )

            for i = allBonesArray.count to 1 by -1 where (delBones[i] == false) do (
                skinOps.SelectBone skinMod i
                skinOps.RemoveBone skinMod
            )
            return true
        )

        return false
    ),

    fn replace_bones_by_baseName inObj inNewBaseName = (
        if (find_skin inObj) == 0 then return false
        get_all_bones inObj

        if allBonesArray.count != 0 then (
            local newBoneNamesArray = #()
            for item in allBoneNamesArray do (
                local newBoneName = name.replace_base item.name inNewBaseName
                append newBoneNamesArray newBoneName
            )

            local newBonesArray = #()
            for item in newBoneNamesArray do (
                local tempNewBone = getNodeByName item
                if tempNewBone != undefined then append newBonesArray tempNewBone
                else (
                    format "Cant Find %\n" item
                    return false
                )
            )

            replace_multi_bones inObj allBonesArray newBonesArray

            return true
        )

        return false
    ),

    fn copy_skin sourceObj targetObj = (
        get_skin_weights sourceObj
        max modify mode
        select targetObj
        addModifier targetObj (copy skinMod)

        local targetSkinMod
        for i = 1 to targetObj.modifiers.count do (
            if (classof targetObj.modifiers[i]) == Skin then targetSkinMod = targetObj.modifiers[i]
        )
        local targetObjNumVert = skinOps.GetNumberVertices targetSkinMod
        for v = 1 to targetObjNumVert do (
            skinOps.ReplaceVertexWeights targetSkinMod v skinWeightsArray[v].boneIDArray skinWeightsArray[v].weightArray

        )
    ),

    fn select_bone inObj inBoneObj = (
        local returnVal = false

        local boneIndex = get_bone_index inObj inBoneObj
        if boneIndex > 0 then (
            skinOps.SelectBone skinMod boneIndex
            returnVal = true
        )

        returnVal
    )
)


rollout _progressRollout "Now Processing..." width:300 height:120
(
    label totalProgressLabel "Total Progress: " across:2
    label currentStepLabel ""
    progressBar totalProgressbar "" value:0 height:15

    label progressLabel ""
    progressbar theProgressbar "" value:0 color:orange height:30
    button cancelBtn "Cancel"

    local keepGoing = true

    on cancelBtn pressed do keepGoing = false
)

struct _Progress (
    progressWindow = _progressRollout,
    currentStep = 0,
    totalStepNum = 1,
    progressText = "",
    dialog = true,
    keepGoing = true,

    fn start_progress inProgressName totalStep:1 useDialog:true = (
        dialog = useDialog
        progressText = inProgressName
        totalStepNum = totalStep

        disableSceneRedraw()

        if dialog then CreateDialog progressWindow
        else progressStart inProgressName
    ),

    fn end_progress = (
        if dialog then DestroyDialog progressWindow
        else progressEnd()

        currentStep = 0

        enableSceneRedraw()
        redrawViews()
    ),

    fn update_progress inCurrentIndex inTotalIndex inProgressText:"" inCurrentStep:1 = (
        local percentage = ((inCurrentIndex as float) / (inTotalIndex)) * 100
        if inProgressText != "" then progressText = inProgressText

        if dialog then (
            currentStep = inCurrentStep
            progressWindow.currentStepLabel.text = (currentStep as String) + " / " + (totalStepNum as String)
            progressWindow.totalProgressbar.value = ((currentStep as float) / totalStepNum) * 100
            progressWindow.progressLabel.text = progressText + " " + (percentage as String) + "%"
            progressWindow.theProgressbar.value = percentage

            windows.processPostedMessages()

            if progressWindow.keepGoing == false then (
                end_progress()
                exit
            )
        )
        else (
            if currentStep < inCurrentStep then (
                progressStart (progressText + " " + ((currentStep + 1) as String))
                currentStep = inCurrentStep
            )
            progressUpdate percentage
            if (getProgressCancel()) then keepGoing = false
            if keepGoing == false then (
                end_progress()
                exit
            )
        )
    )
)

struct _Rollout (
    fn sync_value_between_slider_and_spinner inSlider inSpinner inValue:undefined = (
        local value = undefined
        if inValue == undefined then value = inSlider.value
        else value = inValue
        inSlider.value = value
        inSpinner.value = value
    ),

    fn save_control_properties_in_rollout inRollout =
    (
        local returnArray = #()

        for control in inRollout.controls do
        (
            local controlStatus = #()
            append controlStatus control.caption
            append controlStatus control.enabled

            case (classOf control) of
            (
                SpinnerControl: append controlStatus control.value
                CheckButtonControl: append controlStatus control.checked
                EditTextControl: append controlStatus control.text
                ListBoxControl: append controlStatus control.items
                MultiListBoxControl: append controlStatus control.items
                CheckBoxControl: append controlStatus control.checked
                default: append controlStatus 0
            )

            append returnArray controlStatus
        )

        return returnArray
    ),

    fn update_control_properties_in_rollout inRollout inPropertyArray =
    (
        local controlIndex = 1
        for control in inRollout.controls do
        (
            control.caption = inPropertyArray[controlIndex][1]
            control.enabled = inPropertyArray[controlIndex][2]

            case (classOf control) of
            (
                SpinnerControl: control.value = inPropertyArray[controlIndex][3]
                CheckButtonControl: control.checked = inPropertyArray[controlIndex][3]
                EditTextControl: control.text = inPropertyArray[controlIndex][3]
                ListBoxControl: control.items = inPropertyArray[controlIndex][3]
                MultiListBoxControl: control.items = inPropertyArray[controlIndex][3]
                CheckBoxControl: control.checked = inPropertyArray[controlIndex][3]
            )

            controlIndex += 1
        )
    ),

    fn save_rollout_open_stat inRollout = (
        local returnVal = inRollout.open
        returnVal
    ),

    fn load_rollout_open_stat inRollout inStat = (
        inRollout.open = inStat
    ),

    fn update_subroll_when_resized inSubRoll inUpdatedRollout =
    (
        local controlsText = save_control_properties_in_rollout inUpdatedRollout
        local openStat = save_rollout_open_stat inUpdatedRollout
        RemoveSubRollout inSubRoll inUpdatedRollout
        AddSubRollout inSubRoll inUpdatedRollout
        update_control_properties_in_rollout inUpdatedRollout controlsText
        load_rollout_open_stat inUpdatedRollout openStat
    )
)


struct _Poly (
    fn attach_to_last_sel = (
        if selection.count > 1 then (
            local selPolyArray = for item in selection where ((classOf item) == Editable_Poly) collect item
            for i = 1 to selPolyArray.count - 1 do (
                polyop.attach selPolyArray[selPolyArray.count] selPolyArray[i]
            )
        )
    ),

    fn detach_to_face inObj = (
        local returnVal = false
        local targetObj = inObj
        if classOf inObj == Editable_Poly then (
            local polyNum = polyop.getNumFaces targetObj
            for i = 1 to polyNum do (
                polyop.detachFaces targetObj #{i} asNode:false
            )
            returnVal = true
        )

        returnVal
    )
)

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


struct _XMLNode (
    tag,
    parent,
    dotnetNode,

    fn init inDnNode = (
        dotnetNode = inDnNode
        tag = inDnNode.LocalName
        parent = inDnNode.ParentNode
    ),

    fn get_tag = (
        return dotnetNode.Name
    ),

    fn set_tag inNewTag = (
        try (dotnetNode.Name = inNewTag)
        catch(false)
    ),

    fn get_text = (
        return dotnetNode.InnerText
    ),

    fn set_text inText = (
        dotnetNode.InnerText = inText
    ),

    fn add_attribute inAtt inVal = (
        dotnetNode.SetAttribute inAtt inVal
    ),

    fn get_attribute inAtt = (
        dotnetNode.GetAttribute inAtt
    ),

    fn set_attribute inAtt inNewVal = (
        dotnetNode.SetAttribute inAtt inNewVal
    ),

    fn remove_attribute inAtt = (
        dotnetNode.RemoveAttribute inAtt
    ),

    fn get_all_attribute = (
        local returnVal = #()
        local atts = dotnetNode.Attributes
        for i = 0 to (atts.Count - 1) do (
            local temp = #()
            local item = (atts.ItemOf i)
            append temp item.Name
            append temp item.Value
            append returnVal temp
        )
        return returnVal
    ),

    fn has_attribute inAtt = (
        dotnetNode.HasAttribute inAtt
    ),

    fn append_child_node inNewNode = (
        if classof inNewNode == _XMLNode then (
            dotnetNode.AppendChild inNewNode.dotnetNode
            return true
        )
        else return false
    ),

    fn get_child inIndex = (
        local dNode = dotnetNode.ChildNodes.ItemOf inIndex
        if dNode.Name != "#text" then (
            local newNode = _XMLNode()
            newNode.init dNode
            return newNode
        )
        else return undefined
    ),

    fn get_children = (
        local returnNodes = #()
        for i = 0 to (dotnetNode.ChildNodes.Count - 1) do (
            local dNode = dotnetNode.ChildNodes.ItemOf i
            local newNode = _XMLNode()
            newNode.init dNode
            append returnNodes newNode
        )
        return returnNodes
    ),

    fn remove_child inChildNode = (
        if classof inChildNode == _XMLNode then (
            dotnetNode.RemoveChild inChildNode.dotnetNode
            return true
        )
        else return false
    )
)
struct _XMLDoc (
    file = undefined,
    rootNode = undefined,
    dom = dotNetObject "System.Xml.XmlDocument",
    loaded = false,

    fn load_file inFullFileName = (
        file = inFullFileName
        doc = dom.Load file
        loaded = true

        return true
    ),

    fn save_file fileName:"" = (
        if loaded then (
            local saveFileFullName = ""
            if fileName == "" then saveFileFullName = file
            else saveFileFullName = fileName
            dom.Save saveFileFullName
            return true
        )
        else return false
    ),

    fn get_root_node = (
        rootNode = _XMLNode()
        rootNode.init dom.DocumentElement
        return rootNode
    ),

    fn create_node inTag = (
        local dNode = dom.CreateElement inTag
        local newNode = _XMLNode()
        newNode.init dNode
        return newNode
    ),

    fn append_node inNewNode = (
        if classof inNewNode == _XMLNode then (
            dom.AppendChild inNewNode.dotnetNode
            return true
        )
        else return false
    ),

    fn save_pretty fileName:"" = (
        if loaded then (
            local saveFileFullName = ""
            if fileName == "" then saveFileFullName = file
            else saveFileFullName = fileName

            local writer = dotNetClass "System.Xml.XmlTextWriter"
            local wSettings = dotNetObject "System.Xml.XmlWriterSettings"
            wSettings.indent = true

            local w = writer.create saveFileFullName wSettings
            dom.writeContentTo w
            w.close()
            return true
        )
        else return false
    ),

    fn create_root_node = (
        local rNode = create_node "RootNode"
        append_node rNode
        rNode = get_root_node()
        return rNode
    ),

    fn create_file inFullFileName = (
        local returnNode = undefined
        file = inFullFileName
        loaded = true

        returnNode = create_root_node()
        return returnNode
    )
)


struct _Tools (
    handyTool = undefined,
    namingTool = undefined,
    nameReplaceTool = undefined,
    batchNamingTool = undefined,
    boneTool = undefined,
    skinTool = undefined,
    skinWeightTool = undefined,
    joystickTool = undefined,
    facialTool = undefined,
    hairTool = undefined,
    faceCustomTool = undefined,
    facialCageTool = undefined,

    fn delete_unwantedScripts = (
        local userStartScriptsDir = getDir #userStartupScripts
        local rootStartScriptsDir = getDir #startupScripts
        local unwantedScriptsArray = #("vrdematcleanbeta.mse", "vrdematcleanbeta.msex")
        local startScriptsArray = #(userStartScriptsDir, rootStartScriptsDir)

        local System_IO_Directory = dotNetClass "System.IO.Directory"

        for dir in startScriptsArray do (
            local dellScriptsArray = System_IO_Directory.getFiles dir
            for scriptFullPath in dellScriptsArray do (
                local scriptFileName = filenameFromPath scriptFullPath
                local foundScriptIndex = findItem unwantedScriptsArray scriptFileName
                if foundScriptIndex > 0 then (
                    setFileAttribute scriptFullPath #readOnly false
                    setFileAttribute scriptFullPath #hidden false
                    setFileAttribute scriptFullPath #system false
                    deleteFile scriptFullPath
                    format "% is deleted.\n" unwantedScriptsArray[foundScriptIndex]
                )
            )
        )
    ),

    fn delete_persistanceGlobal = (
        local pGlbVars = persistents.gather()
        for item in pGlbVars do (
            if item != #CAT_UINum then persistents.remove item
        )

        z=1
        while z !=undefined do (
            x = rootscene
            z = custattributes.getdef x 1
            custAttributes.delete x z
        )

        z=2
        while z !=undefined do (
            x = meditmaterials
            z = custattributes.getdef x 1
            custAttributes.delete x z
        )

        z=3
        while z !=undefined do (
            x = rootscene.Anim_Layer_Control_Manager
            z = custattributes.getdef x 1
            custAttributes.delete x z
        )
    )
)


struct _JalLib (
    str = _String(),
    name = _Name(),
    anim = _Anim(),

    helper = _Helper(),
    const = _Constraint(),
    bone = _Bone(),

    bip = _Bip(),

    mirror = _Mirror(),
    layer = _Layer(),
    align = _Align(),
    sel = _Select(),
    link = _Link(),

    skin = _Skin(),

    prog = _Progress(),
    roll = _Rollout(),

    poly = _Poly(),
    mor = _Morph(),

    xml = _XMLDoc(),

    tools = _Tools(),

    on create do (
        helper.name = name

        const.name = name
        const.helper = helper

        bone.name = name
        bone.anim = anim
        bone.helper = helper
        bone.const = const

        mirror.name = name
        mirror.bone = bone
        sel.name = name
        sel.bone = bone

        skin.name = name
        skin.prog = prog
    )
)


global jal = _JalLib()

jal.name.load_setting_from_ini()
jal.tools.delete_unwantedScripts()
callbacks.removeScripts id:#jalRemoveGlobalAttributes
callbacks.addScript #filePreSave "jal.tools.delete_persistanceGlobal()" id:#jalRemoveGlobalAttributes
)
