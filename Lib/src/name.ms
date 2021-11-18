struct _Name (
    /*************************************************/
    /* Default name structure:
    /*    [Base] [Type] [Side] [RealName] [Index]
    /*    ex) Bip001 Dummy L SpineA 001
    /*************************************************/
    str,
    __namePartsOrder = #(#npBase, #npType, #npSide, #npFrontBack, #npRealName, #npIndex),
    __nameParts = #("Base", "Type", "Side", "FrontBack", "RealName", "Index"),
    __nubStr = "Nub",
    __sideStrArray = #("L", "R"),
    __frontBackStrArray = #("F", "B"),
    __typeStrArray = #("P", "Dum", "Exp", "IK", "T"),
    __baseStrArray = #("b", "Bip001"),
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

    fn set_typeStr inStrArray = (
        __typeStrArray = for item in inStrArray collect item
    ),

    fn set_baseStr inStrArray = (
        __baseStrArray = for item in inStrArray collect item
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
        local returnVal = findItem __nameParts "Base"

        returnVal
    ),

    fn get_type_part_index = (
        local returnVal = findItem __nameParts "Type"

        returnVal
    ),

    fn get_side_part_index = (
        local returnVal = findItem __nameParts "Side"

        returnVal
    ),

    fn get_front_back_part_index = (
        local returnVal = findItem __nameParts "FrontBack"

        returnVal
    ),

    fn get_realName_part_index = (
        local returnVal = findItem __nameParts "RealName"

        returnVal
    ),

    fn get_index_part_index = (
        local returnVal = findItem __nameParts "Index"

        returnVal
    ),

    fn set_name_parts_order inStrArray = (
        __nameParts = for item in inStrArray collect item
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

    fn is_type_char inChar = (
        local returnVal = false
        if (findItem __typeStrArray inChar) != 0 then returnVal = true
        returnVal
    ),

    fn is_base_char inChar = (
        local returnVal = false
        if (findItem __baseStrArray inChar) != 0 then returnVal = true
        returnVal
    ),

    fn is_index_char inChar = (
        local returnVal = false
        if (str.is_digit inChar) or (__nubStr == inChar) then returnVal = true
        returnVal
    ),

    fn get_char_type inChar = (
        local returnVal = undefined
        if (is_index_char inChar) then returnVal = "Index"
        if (is_side_char inChar) then returnVal = "Side"
        if (is_frontBack_char inChar) then returnVal = "FrontBack"
        if (is_type_char inChar) then returnVal = "Type"
        if (is_base_char inChar) then returnVal = "Base"
        returnVal
    ),

    fn get_base inStr = (
        local filChar = str.get_filteringChar inStr
        local nameArray = str.split_to_array inStr
        local returnStr = ""

        local baseIndex = get_base_part_index()
        local realNameIndex = get_realName_part_index()

        local foundResult = 0
        for item in __baseStrArray do foundResult += (findItem nameArray item)

        if foundResult > 0 then (
            if baseIndex < realNameIndex then (
                for i = 1 to baseIndex do (
                    if (is_base_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )
            if baseIndex > realNameIndex then (
                for i = nameArray.count to (nameArray.count - baseIndex) by -1 do (
                    if (is_base_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )
        )

        returnStr
    ),

    fn get_type inStr = (
        local filChar = str.get_filteringChar inStr
        local nameArray = str.split_to_array inStr
        local returnStr = ""

        local typeIndex = get_type_part_index()
        local realNameIndex = get_realName_part_index()

        local foundResult = 0
        for item in __typeStrArray do foundResult += (findItem nameArray item)

        if foundResult > 0 then (
            if typeIndex < realNameIndex then (
                for i = 1 to typeIndex do (
                    if (is_type_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )

            if typeIndex > realNameIndex then (
                for i = nameArray.count to (nameArray.count - typeIndex) by -1 do (
                    if (is_type_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )
        )

        returnStr
    ),

    fn get_side inStr = (
        local filChar = str.get_filteringChar inStr
        local nameArray = str.split_to_array inStr
        local returnStr = ""

        local sideIndex = get_side_part_index()
        local realNameIndex = get_realName_part_index()

        local foundResult = 0
        for item in __sideStrArray do foundResult += (findItem nameArray item)

        if foundResult > 0 then (
            if sideIndex < realNameIndex then (
                for i = 1 to sideIndex do (
                    if (is_side_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )

            if sideIndex > realNameIndex then (
                for i = nameArray.count to (nameArray.count - sideIndex) by -1 do (
                    if (is_side_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )
        )

        returnStr
    ),

    fn get_frontBack inStr = (
        local filChar = str.get_filteringChar inStr
        local nameArray = str.split_to_array inStr
        local returnStr = ""

        local frontBackIndex = get_front_back_part_index()
        local realNameIndex = get_realName_part_index()

        local foundResult = 0
        for item in __frontBackStrArray do foundResult += (findItem nameArray item)

        if foundResult > 0 then (
            if frontBackIndex < realNameIndex then (
                for i = 1 to frontBackIndex do (
                    if (is_frontBack_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )

            if frontBackIndex > realNameIndex then (
                for i = nameArray.count to (nameArray.count - frontBackIndex) by -1 do (
                    if (is_frontBack_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )
        )

        returnStr
    ),

    fn get_index inStr = (
        local filChar = str.get_filteringChar inStr
        local nameArray = str.split_to_array inStr
        local returnStr = ""

        local indexIndex = get_index_part_index()
        local realNameIndex = get_realName_part_index()

        local foundResult = 0
        for item in nameArray do if (is_index_char item) then foundResult += 1

        if foundResult > 0 then (
            if indexIndex < realNameIndex then (
                for i = 1 to indexIndex do (
                    if (is_index_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )

            if indexIndex > realNameIndex then (
                for i = nameArray.count to (nameArray.count - indexIndex) by -1 do (
                    if (is_index_char nameArray[i]) then (
                        returnStr = nameArray[i]
                        exit
                    )
                )
            )
        )

        returnStr
    ),

    fn get_realName inStr = (
        local filChar = str.get_filteringChar inStr
        local nameArray = str.split_to_array inStr
        local realNameArray = #()
        local returnStr = ""

        local baseStr = get_base inStr
        local typeStr = get_type inStr
        local sideStr = get_side inStr
        local frontBackStr = get_frontBack inStr
        local indexStr = get_index inStr

        local nonRealNameArray = #(baseStr, typeStr, sideStr, frontBackStr, indexStr)
        for i = 1 to nonRealNameArray.count do (
            if nonRealNameArray[i] != "" then (
                local foundIndex = findItem nameArray nonRealNameArray[i]
                nameArray = deleteItem nameArray foundIndex
            )
        )

        returnStr = str.combine nameArray filChar:filChar

        returnStr
    ),

    fn convert_name_to_nameArray inStr = (
        local returnArray = for item in __namePartsOrder collect ""
        local filChar = str.get_filteringChar inStr

        local baseIndex = get_base_part_index()
        local typeIndex = get_type_part_index()
        local sideIndex = get_side_part_index()
        local frontBackIndex = get_front_back_part_index()
        local indexIndex = get_index_part_index()
        local realNameIndex = get_realName_part_index()

        local baseStr = get_base inStr
        local typeStr = get_type inStr
        local sideStr = get_side inStr
        local frontBackStr = get_frontBack inStr
        local indexStr = get_index inStr
        local realNameStr = get_realName inStr

        returnArray[baseIndex] = baseStr
        returnArray[typeIndex] = typeStr
        returnArray[sideIndex] = sideStr
        returnArray[frontBackIndex] = frontBackStr
        returnArray[realNameIndex] = realNameStr
        returnArray[indexIndex] = indexStr

        returnArray
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

    fn get_string inStr = (
        local returnStr = ""
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexOrder = get_index_part_index()
        local returnNameArray = deleteItem nameArray indexOrder

        returnStr = str.combine returnNameArray filChar:filChar
        returnStr
    ),

    fn set_index_as_nub inStr = (
        local returnName = ""
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexOrder = get_index_part_index()
        nameArray[indexOrder] = __nubStr
        returnName = str.combine nameArray filChar:filChar
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
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local realNameIndex = get_realName_part_index()
        nameArray[realNameIndex] = ""
        returnStr = str.combine nameArray filChar:filChar

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

        returnStr = str.combine combinedNameArray filChar:inFilChar

        returnStr
    ),

    fn add_fix inStr inPart inFix pos:#npPosPrefix = (
        local returnStr = inStr
        if inFix != "" then (
            local filChar = str.get_filteringChar inStr
            local nameArray = convert_name_to_nameArray inStr
            local partIndex = 0
            case inPart of (
                "Base": partIndex = get_base_part_index()
                "Type": partIndex = get_type_part_index()
                "Side": partIndex = get_side_part_index()
                "FrontBack": partIndex = get_front_back_part_index()
                "RealName": partIndex = get_realName_part_index()
                "index": partIndex = get_index_part_index()
            )
            if partIndex != 0 then (
                if pos == #npPosPrefix then nameArray[partIndex] = inFix + nameArray[partIndex]
                if pos == #npPosSufix then nameArray[partIndex] = nameArray[partIndex] + inFix
            )
            returnStr = str.combine nameArray filChar:filChar
        )

        returnStr
    ),

    fn add_prefix_to_realName inStr inPrefix = (
        local returnVal = add_fix inStr "RealName" inPreFix pos:#npPosPrefix
        returnVal
    ),

    fn add_sufix_to_realName inStr inSufix = (
        local returnVal = add_fix inStr "RealName" inSufix pos:#npPosSufix
        returnVal
    ),

    fn convert_digit_into_padding_string inDigit inPaddingNum:3 = (
        local formatStr = "0" + (inPaddingNum as String) + "d"
        local digitNum = 0
        local returnVal = ""
        if (classOf inDigit) == integer then digitNum = inDigit
        if (classOf inDigit) == String then (
            if (str.is_digit inDigit) then digitNum = execute inDigit
        )
        returnVal = formattedPrint digitNum format:formatStr

        returnVal
    ),

    fn set_index_padding_num inStr inPaddingNum:3 = (
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexIndex = get_index_part_index()
        local indexStr = get_index inStr

        if indexStr != "" then (
            if indexStr != __nubStr then indexStr = convert_digit_into_padding_string indexStr inPaddingNum:inPaddingNum

            nameArray[indexIndex] = indexStr
        )

        return (str.combine nameArray filChar:filChar)
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
        local filChar = str.get_filteringChar inStr
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

            newName = str.combine nameArray filChar:filChar
        )

        newName
    ),

    fn replace_filteringChar inStr inNewFilChar = (
        local nameArray = convert_name_to_nameArray inStr

        return (str.combine nameArray filChar:inNewFilChar)
    ),

    fn replace_base inStr inNewBase = (
        local returnVal = inStr
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local baseIndex = get_base_part_index()
        if baseIndex != 0 then (
            nameArray[baseIndex] = inNewBase
            returnVal = str.combine nameArray filChar:filChar
        )

        returnVal
    ),

    fn replace_type inStr inNewType = (
        local returnVal = inStr
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local typeIndex = get_type_part_index()
        if typeIndex != 0 then (
            nameArray[typeIndex] = inNewType
            returnVal = str.combine nameArray filChar:filChar
        )

        returnVal
    ),

    fn replace_side inStr inNewSide = (
        local returnVal = inStr
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local sideIndex = get_side_part_index()
        if sideIndex != 0 then (
            nameArray[sideIndex] = inNewSide
            returnVal = str.combine nameArray filChar:filChar
        )

        returnVal
    ),

    fn replace_frontBack inStr inNewFrontBack = (
        local returnVal = inStr
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local frontBackIndex = get_front_back_part_index()
        if frontBackIndex != 0 then (
            nameArray[frontBackIndex] = inNewFrontBack
            returnVal = str.combine nameArray filChar:filChar
        )

        returnVal
    ),

    fn replace_index inStr inNewIndex keepPadding:true = (
        local returnVal = inStr
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexIndex = get_index_part_index()
        if indexIndex != 0 then (
            nameArray[indexIndex] = inNewIndex
            returnVal = str.combine nameArray filChar:filChar

            if keepPadding then (
                local indexPaddingNum = get_index_padding_num inStr
                returnVal = set_index_padding_num returnVal inPaddingNum:indexPaddingNum
            )
        )

        returnVal
    ),

    fn replace_realName inStr inNewRealName = (
        local returnVal = inStr
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local realNameIndex = get_realName_part_index()
        if realNameIndex != 0 then (
            nameArray[realNameIndex] = inNewRealName
            returnVal = str.combine nameArray filChar:filChar
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
        if (is_left inStr) then returnName = replace_side inStr (get_rightStr())
        if (is_right inStr) then returnName = replace_side inStr (get_leftStr())
        if (is_front inStr) then returnName = replace_side inStr (get_backStr())
        if (is_back inStr) then returnName = replace_side inStr (get_frontStr())

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

    fn compare_name inObjA inObjB = (
        stricmp inObjA.name inObjB.name
    ),

    fn sort_by_name inArray = (
        local returnArray = deepCopy inArray
        qSort returnArray compare_name
        return returnArray
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
        local typeStrArray = filterString (getINISetting __iniFile "DefaultSetting" "Type") " "
        local baseStrArray = filterString (getINISetting __iniFile "DefaultSetting" "Base") " "
        set_name_parts_order namePartsOrder
        set_nubStr nubStr
        set_leftStr iniSideStrArray[1]
        set_rightStr iniSideStrArray[2]
        set_frontStr iniFrontBackStrArray[1]
        set_backStr iniFrontBackStrArray[2]
        set_typeStr typeStrArray
        set_baseStr baseStrArray
    )
)
