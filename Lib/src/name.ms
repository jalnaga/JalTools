struct _Name_Idf (
    order = 0,
    char = #(""),
    desc = #("")
)

struct _Name_Idf_Manager (
    str,
    idfArray = #(),

    fn sort_by_idf_order_function inIdf1 inIdf2 = (
        local returnVal = inIdf1.order - inIdf2.order
        returnVal
    ),
    fn sort_idf = (
        qsort idfArray sort_by_idf_order_function
        for i = 1 to idfArray.count do idfArray[i].order = i
        idfArray
    ),

    fn get_idfArray = (
        idfArray
    ),

    fn find_idf inStr = (
        local returnVal = 0
        local foundIndex = 0
        for idf in idfArray do (
            foundIndex += 1
            local charFoundIndex = findItem idf.char inStr
            local descFoundIndex = findItem idf.desc inStr
            if charFoundIndex > 0 or descFoundIndex > 0 then (
                returnVal = foundIndex
                exit
            )
        )

        returnVal
    ),

    fn add_idf inIdf = (
        append idfArray inIdf
        idfArray = sort_idf()
        idfArray
    ),

    fn remove_idf inStr = (
        local foundIndex = find_idf inStr
        if foundIndex > 0 then (
            deleteItem idfArray foundIndex
            idfArray = sort_idf()
        )
        idfArray
    ),

    fn get_idf inChar = (
        local returnVal = _Name_Idf()
        local foundIndex = find_idf inChar
        if foundIndex > 0 then returnVal = idfArray[foundIndex]
        returnVal
    ),

    fn set_idf inChar inIdf = (
        local returnVal = false
        local foundIndex = find_idf inChar
        if foundIndex > 0 then (
            idfArray[foundIndex] = inIdf
            idfArray = sort_idf()
            returnVal = true
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
    str,
    __iniFile = "",

    -- Mandatory Idf: realName, index, nub
    realNameIdf = _Name_Idf order:99 char:#("") desc:#("RealName"),
    indexIdf = _Name_Idf order:100 char:#("") desc:#("Index"),
    nubIdf = _Name_Idf order:101 char:#("Nub") desc:#("Nub"),

    idfManager = _Name_Idf_Manager str:str idfArray:#(),

    __nonRealNameArray = #(),
    __nameIdfsNum = 0,
    __paddingNum = 2,

    __namePartsOrder = #(#npBase, #npType, #npSide, #npFrontBack, #npRealName, #npIndex),
    __nameParts = #("Base", "Type", "Side", "FrontBack", "RealName", "Index"),
    __nubStr = "Nub",
    __sideStrArray = #("L", "R"),
    __frontBackStrArray = #("F", "B"),

-- New way
    fn gen_nonRealNameArray = (
        __nonRealNameArray = #()
        for item in idfManager.idfArray do (
            for char in item.char do (
                if char != "" and char != nubIdf.char[1] then append __nonRealNameArray char
            )
        )

        __nonRealNameArray
    ),

    fn load_setting_from_ini = (
        __iniFile = (getFilenamePath (getThisScriptFilename())) +"\\NameTool.ini"
        idfManager.idfArray = #()
        __nameIdfsNum = execute (getINISetting __iniFile "NameIdf" "NameIdfsNum")
        __paddingNum = execute (getINISetting __iniFile "DefaultSetting" "PaddingNum")

        for i = 1 to __nameIdfsNum do (
            local idf = _Name_Idf()
            idf.order = execute (getINISetting __iniFile "NameIdf" ("NameIdf"+(i as String)+".order"))
            idf.char = filterString (getINISetting __iniFile "NameIdf" ("NameIdf"+(i as String)+".char")) ","
            idf.desc = filterString (getINISetting __iniFile "NameIdf" ("NameIdf"+(i as String)+".desc")) ","
            append idfManager.idfArray idf
        )

        idfManager.sort_idf()
        realNameIdf = idfManager.get_idf "RealName"
        indexIdf = idfManager.get_idf "Index"
        nubIdf = idfManager.get_idf "Nub"

        gen_nonRealNameArray()
    ),

    fn set_nubStr inStr = (
        nubIdf.char[1] = inStr
        idfManager.set_idf "Nub" nubIdf
    ),

    fn get_nubStr = (
        nubIdf.char[1]
    ),

    fn set_leftStr inStr = (
        local foundIdf = idfManager.get_idf "Left"
        if foundIdf.order > 0 then (
            foundIdf.char[1] = inStr
            idfManager.set_idf "Left" foundIdf
        )
    ),

    fn set_rightStr inStr = (
        local foundIdf = idfManager.get_idf "Right"
        if foundIdf.order > 0 then (
            foundIdf.char[2] = inStr
            idfManager.set_idf "Right" foundIdf
        )
    ),

    fn set_frontStr inStr = (
        local foundIdf = idfManager.get_idf "Front"
        if foundIdf.order > 0 then (
            foundIdf.char[1] = inStr
            idfManager.set_idf "Front" foundIdf
        )
    ),

    fn set_backStr inStr = (
        local foundIdf = idfManager.get_idf "Back"
        if foundIdf.order > 0 then (
            foundIdf.char[2] = inStr
            idfManager.set_idf "Back" foundIdf
        )
    ),

    fn get_leftStr = (
        local returnVal = ""
        local foundIdf = idfManager.get_idf "Left"
        if foundIdf.order > 0 then (
            returnVal = foundIdf.char[1]
        )
        returnVal
    ),

    fn get_rightStr = (
        local returnVal = ""
        local foundIdf = idfManager.get_idf "Right"
        if foundIdf.order > 0 then (
            returnVal = foundIdf.char[2]
        )
        returnVal
    ),

    fn get_frontStr = (
        local returnVal = ""
        local foundIdf = idfManager.get_idf "Front"
        if foundIdf.order > 0 then (
            returnVal = foundIdf.char[1]
        )
        returnVal
    ),

    fn get_backStr = (
        local returnVal = ""
        local foundIdf = idfManager.get_idf "Back"
        if foundIdf.order > 0 then (
            returnVal = foundIdf.char[2]
        )
        returnVal
    ),

    fn get_base_part_index = (
        local returnVal = (idfManager.get_idf "Base").order

        returnVal
    ),

    fn get_type_part_index = (
        local returnVal = (idfManager.get_idf "Type").order

        returnVal
    ),

    fn get_side_part_index = (
        local returnVal = (idfManager.get_idf "Left").order

        returnVal
    ),

    fn get_front_back_part_index = (
        local returnVal = (idfManager.get_idf "Front").order

        returnVal
    ),

    fn get_realName_part_index = (
        local returnVal = realNameIdf.order

        returnVal
    ),

    fn get_index_part_index = (
        local returnVal = indexIdf.order

        returnVal
    ),

    fn filter_name inStr = (
        local nameArray = #()
        local filChar = str.get_filteringChar inStr
        if filChar == "" then (
            nameArray = str.filter_by_upper_case inStr
            local tempArray = #()
            for item in nameArray do (
                if (str.has_digit item) then (
                    local splittedStrArray = str.split_into_string_and_digit item
                    append tempArray splittedStrArray[1]
                    append tempArray splittedStrArray[2]
                )
                else append tempArray item
            )
            nameArray = deepCopy tempArray
        )
        else nameArray = str.filter_by_filteringChar inStr

        nameArray
    ),

    fn refine_nameArray_empty inNameArray = (
        local nameArray = #()
        for item in inNameArray do (
            if item != "" then append nameArray item
        )

        return nameArray
    ),

    fn refine_nameArray inNameArray = (
        local returnNameArray = #()
        local nameArray = refine_nameArray_empty inNameArray
        local realNameAndIndexArray = #()
        local indexArray = #()
        local realNameArray = #()
        local nonRealNameArray = #()

        for item in nameArray do (
            local foundIndex = findItem __nonRealNameArray item
            if foundIndex == 0 then append realNameAndIndexArray item
            if foundIndex > 0 then append nonRealNameArray item
        )
        if realNameIdf.order < indexIdf.order then (
            for i = 1 to realNameAndIndexArray.count do (
                if not(str.is_digit realNameAndIndexArray[i]) then (
                    if realNameAndIndexArray[i] == nubIdf.char[1] and i == realNameAndIndexArray.count then append indexArray realNameAndIndexArray[i]
                    else append realNameArray realNameAndIndexArray[i]
                )
                if (str.is_digit realNameAndIndexArray[i]) then (
                    if i == realNameAndIndexArray.count then append indexArray realNameAndIndexArray[i]
                    else append realNameArray realNameAndIndexArray[i]
                )
            )
        )
        else (
            for i = 1 to realNameAndIndexArray.count do (
                if not(str.is_digit realNameAndIndexArray[i]) then (
                    if realNameAndIndexArray[i] == nubIdf.char[1] and i == 1 then append indexArray realNameAndIndexArray[i]
                    else append realNameArray realNameAndIndexArray[i]
                )
                if (str.is_digit realNameAndIndexArray[i]) then (
                    if i == 1 then append indexArray realNameAndIndexArray[i]
                    else append realNameArray realNameAndIndexArray[i]
                )
            )
        )
        append returnNameArray nonRealNameArray
        append returnNameArray realNameArray
        append returnNameArray indexArray

        returnNameArray
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

    fn convert_name_to_nameArray inStr = (
        local returnArray = for i = 1 to __nameIdfsNum collect ""
        local filChar = str.get_filteringChar inStr
        local refinedNameArray = split_into_refined_nameArray inStr

        for item in refinedNameArray[1] do (
            local foundIndex = idfManager.find_idf item
            if foundIndex > 0 then returnArray[foundIndex] = item
        )
        returnArray[realNameIdf.order] = combine_nameArray refinedNameArray[2] filChar
        for item in refinedNameArray[3] do (
            if item == nubIdf.char[1] then returnArray[nubIdf.order] = item
            else returnArray[indexIdf.order] = item
        )

        returnArray
    ),

    fn get_realName inStr = (
        local filChar = str.get_filteringChar inStr
        local nameArray = split_into_refined_nameArray inStr
        local realNameArray = nameArray[2]
        local returnStr = ""
        returnStr = combine_nameArray realNameArray filChar
        returnStr
    ),

    fn get_side inStr = (
        local returnVal = ""
        local sideIdf = idfManager.get_idf "Left"
        if sideIdf.order != 0 then (
            local tempNameArray = convert_name_to_nameArray inStr
            returnVal = tempNameArray[sideIdf.order]
        )
        returnVal
    ),

    fn get_frontBack inStr = (
        local returnVal = ""
        local frontBackIdf = idfManager.get_idf "Front"
        if frontBackIdf.order != 0 then (
            local tempNameArray = convert_name_to_nameArray inStr
            returnVal = tempNameArray[frontBackIdf.order]
        )
        returnVal
    ),

    fn get_index inStr = (
        local returnVal = ""
        local tempNameArray = convert_name_to_nameArray inStr
        if tempNameArray[indexIdf.order] != "" then returnVal = tempNameArray[indexIdf.order]
        if tempNameArray[nubIdf.order] != "" then returnVal = tempNameArray[nubIdf.order]
        returnVal
    ),

    fn is_nub inStr = (
        local returnVal = false
        if (get_index inStr) == nubIdf.char[1] then returnVal = true
        returnVal
    ),

    fn get_index_as_digit inStr = (
        indexStr = get_index inStr
        if indexStr == nubIdf.char[1] then return -1
        if indexStr != "" then (
            index = execute indexStr
            return index
        )
        else return false
    ),

    fn get_base inStr = (
        local returnVal = ""
        local baseIdf = idfManager.get_idf "Base"
        if baseIdf.order > 0 then (
            local tempNameArray = convert_name_to_nameArray inStr
            returnVal = tempNameArray[baseIdf.order]
        )
        returnVal
    ),

    fn get_type inStr = (
        local returnVal = ""
        local typeIdf = idfManager.get_idf "Type"
        if typeIdf.order > 0 then (
            local tempNameArray = convert_name_to_nameArray inStr
            returnVal = tempNameArray[typeIdf.order]
        )
        returnVal
    ),

    fn get_string inStr = (
        local returnStr = ""
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        if indexIdf.order > 0 and nubIdf.order > 0 then (
            nameArray[indexIdf.order] = ""
            nameArray[nubIdf.order] = ""
        )
        returnStr = combine_nameArray nameArray filChar
        returnStr
    ),

    fn set_index_as_nub inStr = (
        local returnName = ""
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        nameArray[indexIdf.order] = ""
        nameArray[nubIdf.order] = nubIdf.char[1]
        returnName = combine_nameArray nameArray filChar
        returnName
    ),

    fn is_left inStr = (
        local returnVal = false
        if (get_leftStr()) != "" then returnVal = true
        returnVal
    ),

    fn is_right inStr = (
        local returnVal = false
        if (get_rightStr()) != "" then returnVal = true
        returnVal
    ),

    fn is_front inStr = (
        local returnVal = false
        if (get_frontStr()) != "" then returnVal = true
        returnVal
    ),

    fn is_back inStr = (
        local returnVal = false
        if (get_backStr()) != "" then returnVal = true
        returnVal
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
        local nameArray = split_into_refined_nameArray inStr
        join nameArray[1] nameArray[3]

        returnStr = combine_nameArray nameArray[1] filChar

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

    fn add_fix inStr inIdf inFix pos:#npPosPrefix = (
        local returnStr = inStr
        if inFix != "" then (
            local filChar = str.get_filteringChar inStr
            local nameArray = convert_name_to_nameArray inStr
            local partIndex = inIdf.order
            if partIndex != 0 then (
                if pos == #npPosPrefix then nameArray[partIndex] = inFix + nameArray[partIndex]
                if pos == #npPosSufix then nameArray[partIndex] = nameArray[partIndex] + inFix
            )
            returnStr = combine_nameArray nameArray filChar
        )

        returnStr
    ),

    fn add_prefix_to_realName inStr inPrefix = (
        local returnVal = add_fix inStr realNameIdf inPreFix pos:#npPosPrefix
        returnVal
    ),

    fn add_sufix_to_realName inStr inSufix = (
        local returnVal = add_fix inStr realNameIdf inSufix pos:#npPosSufix
        returnVal
    ),

    fn convert_digit_into_padding_string inDigit inPaddingNum:__paddingNum = (
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

    fn set_index_padding_num inStr inPaddingNum:__paddingNum = (
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexIndex = get_index_part_index()
        local indexStr = get_index inStr

        if indexStr != "" and indexStr != nubIdf.char[1] then (
            if indexStr != nubIdf.char[1] then indexStr = convert_digit_into_padding_string indexStr inPaddingNum:inPaddingNum

            nameArray[indexIndex] = indexStr
        )

        return (combine_nameArray nameArray filChar)
    ),

    fn get_index_padding_num inStr = (
        local index = get_index inStr
        if index != nubIdf.char[1] then (
            if index.count > 0 then return index.count
        )

        return __paddingNum
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
                (nubIdf.char[1]): indexNum = -9999999
                default: (
                    indexNum = execute nameArray[indexIndex]
                    indexPaddingNum = nameArray[indexIndex].count
                )
            )
            local formatStr = "0" + (indexPaddingNum as String) + "d"
            indexNum = indexNum + inAmount
            if indexNum > -1 then indexStr = formattedPrint indexNum format:formatStr
            else indexStr = nubIdf.char[1]
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
        local filChar = str.get_filteringChar inStr
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
        local filChar = str.get_filteringChar inStr
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
        local filChar = str.get_filteringChar inStr
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
        local filChar = str.get_filteringChar inStr
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
        local filChar = str.get_filteringChar inStr
        local nameArray = convert_name_to_nameArray inStr
        local indexIndex = get_index_part_index()
        if indexIndex != 0 then (
            local indexStr = get_index inStr
            nameArray[indexIndex] = ""
            nameArray[nubIdf.order] = ""

            if (jal.name.is_nub inNewIndex) then indexIndex = nubIdf.order
            if (jal.str.is_digit inNewIndex) then indexIndex = indexIdf.order

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
        local filChar = str.get_filteringChar inStr
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
        return (replace_side inStr "")
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
    )
)
