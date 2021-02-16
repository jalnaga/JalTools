struct _String (
    fn split_into_string_and_digit inStr = (
        t = trimRight inStr "0123456789"
        #(t, substring inStr (t.count+1) -1)
    ),

    fn sort_By_Alphabet_function inStr1 inStr2 = (
        stricmp inStr1 inStr2
    ),

    fn sort_By_Name_function inObj1 inObj2 = (
        stricmp inObj1.name inObj2.name
    ),

    fn sort_by_alphabet inArray = (
        local returnArray = deepCopy inArray
        qSort returnArray sort_By_Alphabet_function
        return returnArray
    ),

    fn sort_by_name inArray = (
        local returnArray = deepCopy inArray
        qSort returnArray sort_By_Name_function
        returnArray
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
    ),

    fn gen_uniqueName inStr = (
        local patternStr = replace_index inStr "*"
        local returnArray = for item in objects where (matchPattern item.name pattern:patternStr) collect item
        local returnVal = replace_index inStr ((returnArray.count+1) as String)

        returnVal
    )
)
