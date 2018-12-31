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

    fn get_realName inStr = (
        local filChar = get_filteringChar inStr
        local nameArray = split_into_refined_nameArray inStr
        local realNameArray = nameArray[2]
        local returnStr = ""
        returnStr = combine_nameArray realNameArray filChar

        returnStr
    ),

    fn get_pos_from_refined_nameArray inType = (
        local returnVal = 2
        case inType of (
            #npBase:(
                if (get_base_part_index()) < (get_realName_part_index()) then returnVal = 1
                else returnVal = 3
            )
            #npType:(
                if (get_type_part_index()) < (get_realName_part_index()) then returnVal = 1
                else returnVal = 3
            )
            #npSide:(
                if (get_side_part_index()) < (get_realName_part_index()) then returnVal = 1
                else returnVal = 3
            )
            #npFrontBack:(
                if (get_front_back_part_index()) < (get_realName_part_index()) then returnVal = 1
                else returnVal = 3
            )
            #npIndex:(
                if (get_index_part_index()) < (get_realName_part_index()) then returnVal = 1
                else returnVal = 3
            )
            default: returnVal = 2
        )

        returnVal
    ),

    fn get_index_side_frontBack_part_char inNameArray inNamePartsOrder inType = (
        local returnStr = ""
        local nameArray = deepCopy inNameArray
        local baseIndex = findItem inNamePartsOrder #npBase
        local typeIndex = findItem inNamePartsOrder #npType
        local indexIndex = findItem inNamePartsOrder #npIndex
        local sideIndex = findItem inNamePartsOrder #npSide
        local frontBackIndex = findItem inNamePartsOrder #npFrontBack
        local targetIndex = 0
        case inType of (
            #npIndex: targetIndex = indexIndex
            #npSide: targetIndex = sideIndex
            #npFrontBack: targetIndex = frontBackIndex
        )
        format "nameArray:%  targetIndex:% inNamePartsOrder:%\n" nameArray targetIndex inNamePartsOrder

        if targetIndex != 0 then (
            local targetArray = #()
            case inType of (
                #npIndex: targetArray = for i = 1 to nameArray.count where ((is_digit nameArray[i]) or (nameArray[i] == __nubStr)) collect nameArray[i]
                #npSide: targetArray = for i = 1 to nameArray.count where (is_side_char nameArray[i]) collect nameArray[i]
                #npFrontBack: targetArray = targetArray = for i = 1 to nameArray.count where (is_frontBack_char nameArray[i]) collect nameArray[i]
            )
            format "targetArray:%\n" targetArray
            if targetArray.count > 0 then (
                if targetIndex < (baseIndex + typeIndex) then (
                    if baseIndex != 0 and typeIndex != 0 then (
                        if targetArray.count == 1 then (
                            returnStr = targetArray[1]
                        )
                        if targetArray.count == 2 then (
                            local firstPartIndex = amin #(baseIndex, typeIndex)
                            if (abs (targetIndex - firstPartIndex)) == 1 then returnStr = targetArray[1]
                            else returnStr = targetArray[2]
                        )
                        if targetArray.count == 3 then (
                            returnStr = targetArray[2]
                        )
                    )
                    else returnStr = targetArray[1]
                )
                if targetIndex >= (baseIndex + typeIndex) then (
                    if targetArray.count == 1 then (
                        local targetPosInNameArray = findItem nameArray targetArray[1]
                        local baseGap = abs (baseIndex - targetPosInNameArray)
                        if baseIndex == 0 then baseGap = 999
                        local typeGap = abs (typeIndex - targetPosInNameArray)
                        if typeIndex == 0 then typeGap = 999
                        local targetGap = abs (targetIndex - targetPosInNameArray)
                        format "baseGap:% typeGap:% targetGap:%\n" baseGap typeGap targetGap
                        if targetGap < baseGap or targetGap < typeGap then returnStr = targetArray[1]
                        else returnStr = ""
                    )
                    if targetArray.count > 1 then returnStr = targetArray[targetArray.count]
                )
            )
        )

        returnStr
    ),

    fn get_base_type_part_char inNameArray inNamePartsArray inType = (
        local returnStr = ""
        local baseIndex = findItem inNamePartsArray #npBase
        local typeIndex = findItem inNamePartsArray #npType
        local indexIndex = findItem inNameArray #npIndex
        local sideIndex = findItem inNameArray #npSide
        local frontBackIndex = findItem inNameArray #npFrontBack
        local tempNameArray = deepCopy inNameArray

        if (findItem inNamePartsArray inType) != 0 then (
            for i = 1 to inNamePartsArray.count do (
                local tempResult = get_index_side_frontBack_part_char inNameArray inNamePartsArray inNamePartsArray[i]
                if tempResult != "" then tempNameArray = deleteItem tempNameArray (findItem tempNameArray tempResult)
            )
            format "tempNameArray:%\n" tempNameArray
            if tempNameArray.count > 0 then (
                if inType == #npBase then (
                    if tempNameArray.count == 2 then (
                        if baseIndex < typeIndex then returnStr = tempNameArray[1]
                        else returnStr = tempNameArray[2]
                    )

                    if tempNameArray.count == 1 then (
                        if typeIndex == 0 or baseIndex == 1 then returnStr = tempNameArray[1]
                        else (
                            if baseIndex < typeIndex then returnStr = tempNameArray[1]
                            else (
                                if baseIndex < (indexIndex + sideIndex + frontBackIndex) then returnStr = tempNameArray[1]
                                else returnStr = ""
                            )
                        )
                    )
                )
                if inType == #npType then (
                    if tempNameArray.count == 2 then (
                        if typeIndex < baseIndex then returnStr = tempNameArray[1]
                        else returnStr = tempNameArray[2]
                    )

                    if tempNameArray.count == 1 then (
                        if baseIndex == 0 or typeIndex == 1 then returnStr = tempNameArray[1]
                        else (
                            if typeIndex < baseIndex then returnStr = ""
                            if typeIndex < (indexIndex + sideIndex + frontBackIndex) then returnStr = ""
                            else returnStr = tempNameArray[1]
                        )
                    )
                )
            )
        )

        returnStr
    ),

    fn match_refined_nameArray_with_namePartsOrder inStr = (
        local namePartsOrder = split_nameParts_to_refined_nameArray()
        local nameArray = split_into_refined_nameArray inStr
        local beforeRealNameArray = nameArray[1]
        local afterRealNameArray = nameArray[3]
        local returnArray = #(#(), nameArray[2], #())

        returnArray[1] = for item in namePartsOrder[1] collect ""
        returnArray[3] = for item in namePartsOrder[3] collect ""

        for i = 1 to namePartsOrder[1].count do (
            case namePartsOrder[1][i] of (
                #npBase:(
                    returnArray[1][i] = get_base_type_part_char beforeRealNameArray namePartsOrder[1] namePartsOrder[1][i]
                )
                #npType:(
                    returnArray[1][i] = get_base_type_part_char beforeRealNameArray namePartsOrder[1] namePartsOrder[1][i]
                )
                #npIndex:(
                    returnArray[1][i] = get_index_side_frontBack_part_char beforeRealNameArray namePartsOrder[1] namePartsOrder[1][i]
                )
                #npSide:(
                    returnArray[1][i] = get_index_side_frontBack_part_char beforeRealNameArray namePartsOrder[1] namePartsOrder[1][i]
                )
                #npFrontBack:(
                    returnArray[1][i] = get_index_side_frontBack_part_char beforeRealNameArray namePartsOrder[1] namePartsOrder[1][i]
                )
            )
        )
        for i = 1 to namePartsOrder[3].count do (
            case namePartsOrder[3][i] of (
                #npBase:(
                    returnArray[3][i] = get_base_type_part_char afterRealNameArray namePartsOrder[3] namePartsOrder[3][i]
                )
                #npType:(
                    returnArray[3][i] = get_base_type_part_char afterRealNameArray namePartsOrder[3] namePartsOrder[3][i]
                )
                #npIndex:(
                    returnArray[3][i] = get_index_side_frontBack_part_char afterRealNameArray namePartsOrder[3] namePartsOrder[3][i]
                )
                #npSide:(
                    returnArray[3][i] = get_index_side_frontBack_part_char afterRealNameArray namePartsOrder[3] namePartsOrder[3][i]
                )
                #npFrontBack:(
                    returnArray[3][i] = get_index_side_frontBack_part_char afterRealNameArray namePartsOrder[3] namePartsOrder[3][i]
                )
            )
        )

        returnArray
    ),

    fn get_side inStr = (
        local sidePos = get_pos_from_refined_nameArray #npSide
        local nameArray = (split_into_refined_nameArray inStr)[sidePos]
        local namePartsOrderArray = (split_nameParts_to_refined_nameArray())[sidePos]
        local sideStr = get_index_side_frontBack_part_char nameArray namePartsOrderArray #npSide

        sideStr
    ),

    fn get_frontBack inStr = (
        local frontBackPos = get_pos_from_refined_nameArray #npFrontBack
        local nameArray = (split_into_refined_nameArray inStr)[frontBackPos]
        local namePartsOrderArray = (split_nameParts_to_refined_nameArray())[frontBackPos]
        local frontBackStr = get_index_side_frontBack_part_char nameArray namePartsOrderArray #npFrontBack

        frontBackStr
    ),

    fn get_index inStr = (
        local indexPos = get_pos_from_refined_nameArray #npIndex
        local nameArray = (split_into_refined_nameArray inStr)[indexPos]
        local namePartsOrderArray = (split_nameParts_to_refined_nameArray())[indexPos]
        local indexStr = get_index_side_frontBack_part_char nameArray namePartsOrderArray #npIndex

        indexStr
    ),

    fn is_nub inStr = (
        local returnVal = false
        if (get_index inStr) == __nubStr then returnVal = true
        returnVal
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

    fn get_base inStr = (
        local basePos = get_pos_from_refined_nameArray #npBase
        local nameArray = (split_into_refined_nameArray inStr)[basePos]
        local namePartsOrderArray = (split_nameParts_to_refined_nameArray())[basePos]
        local baseStr = get_base_type_part_char nameArray namePartsOrderArray #npBase

        baseStr
    ),

    fn get_type inStr = (
        local typePos = get_pos_from_refined_nameArray #npType
        local nameArray = (split_into_refined_nameArray inStr)[typePos]
        local namePartsOrderArray = (split_nameParts_to_refined_nameArray())[typePos]
        local typeStr = get_base_type_part_char nameArray namePartsOrderArray #npType

        typeStr
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
