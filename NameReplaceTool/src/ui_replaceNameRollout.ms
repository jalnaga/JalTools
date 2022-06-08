rollout replaceNameRollout "Replace Name" (
    radiobuttons filteringCharRdo "Filtering:" labels:#("None", "(Blank)", "_") columns:3 default:2 align:#left across:2
    button renameBtn "Rename" width:100 height:35 align:#right
    group "Find and Replace" (
        editText targetTxt "Find:" labelOnTop:true across:4
        label findToArrowLbl "==>" offset:[0, 20]
        editText replaceTxt "To:" labelOnTop:true
        button clearFindBtn "Clear" align:#right offset:[0, 15]
    )

    editText strTxt1 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb1 "Remove" offset:[0, 20] align:#right
    editText strTxt2 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb2 "Remove" offset:[0, 20] align:#right
    editText strTxt3 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb3 "Remove" offset:[0, 20] align:#right
    editText strTxt4 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb4 "Remove" offset:[0, 20] align:#right
    editText strTxt5 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb5 "Remove" offset:[0, 20] align:#right
    editText strTxt6 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb6 "Remove" offset:[0, 20] align:#right
    editText strTxt7 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb7 "Remove" offset:[0, 20] align:#right
    editText strTxt8 " " text:"" labelOnTop:true align:#left across:2 width:200
    checkbox removeCkb8 "Remove" offset:[0, 20] align:#right

    listbox resultLst "Result:" readOnly:true height:10

    local editTextCtrArray = #(strTxt1, strTxt2, strTxt3, strTxt4, strTxt5, strTxt6, strTxt7, strTxt8)
    local checkboxCtrArray = #(removeCkb1, removeCkb2, removeCkb3, removeCkb4, removeCkb5, removeCkb6, removeCkb7, removeCkb8)
    local prevEditTextCtrArray = #()
    local resultNameArray = #()

    fn get_longest_name_in_renameObjArray = (
        local returnVal = ""
        local nameArray = #()
        for item in renameObjArray do (
            local tempNameArray = jal.str.split_to_array item.name
            if tempNameArray.count >= nameArray.count then (
                nameArray = deepCopy tempNameArray
                returnVal = item.name
            )
        )
        return returnVal
    )

    fn set_filCharRdo inLongestName = (
        local filChar = jal.str.get_filteringChar inLongestName
        local filCharIdex = findItem #("", " ", "_") filChar
        case filCharIdex of (
            1: (
                filteringCharRdo.state = 1
                filteringChar = ""
            )
            2: (
                filteringCharRdo.state = 2
                filteringChar = " "
            )
            3: (
                filteringCharRdo.state = 3
                filteringChar = "_"
            )
            default: (
                filteringCharRdo.state = 2
                filteringChar = " "
            )
        )
    )

    fn match_nameArray_count_to_editTextCtrArray_count inNameArray = (
        local returnVal = #()
        if inNameArray.count <= editTextCtrArray.count then (
            for i = 1 to editTextCtrArray.count do(
                if i <= inNameArray.count then append returnVal inNameArray[i]
                else append returnVal ""
            )
        )
        if inNameArray.count > editTextCtrArray.count then (
            for i = 1 to (editTextCtrArray.count-1) do append returnVal inNameArray[i]
            local overflowinNameArray = for i = editTextCtrArray.count to inNameArray.count collect inNameArray[i]
            local lastCtrlText = jal.str.combine overflowinNameArray filChar:filteringChar
            append returnVal lastCtrlText
        )
        return returnVal
    )

    fn set_editTextCtrText inNameArray = (
        local ctrlTextFillArray = #()
        for item in editTextCtrArray do item.text = ""
        ctrlTextFillArray = match_nameArray_count_to_editTextCtrArray_count inNameArray
        for i = 1 to ctrlTextFillArray.count do editTextCtrArray[i].text = ctrlTextFillArray[i]
        prevEditTextCtrArray = for item in editTextCtrArray collect item.text
    )

    fn update_ui = (
        if renameObjArray.count > 0 then (
            local displayName = get_longest_name_in_renameObjArray()
            local ctrlTextFillArray = #()
            local nameArray = jal.str.split_to_array displayName
            set_filCharRdo displayName
            set_editTextCtrText nameArray
            resultLst.items = for item in renameObjArray collect item.name
        )
        else (
            resultLst.items = #()
            set_editTextCtrText #("")
            for item in checkboxCtrArray do item.checked = false
        )
    )

    fn gen_new_name = (
        resultNameArray = #()
        if renameObjArray.count > 0 then (
            local currentEditTextCtrArray = for item in editTextCtrArray collect item.text
            local changedEditTextCtrArray = #()
            for i = 1 to prevEditTextCtrArray.count do (
                if currentEditTextCtrArray[i] == "" or currentEditTextCtrArray[i] == prevEditTextCtrArray[i] then changedEditTextCtrArray[i] = undefined
                else changedEditTextCtrArray[i] = currentEditTextCtrArray[i]
            )
            for item in renameObjArray do (
                local nameArray = jal.str.split_to_array item.name
                local refinedNameArray = match_nameArray_count_to_editTextCtrArray_count nameArray
                local newNameArray = #()
                for i = 1 to refinedNameArray.count do (
                    if changedEditTextCtrArray[i] != undefined then newNameArray[i] = changedEditTextCtrArray[i]
                    else newNameArray[i] = refinedNameArray[i]
                )
                for i = 1 to checkboxCtrArray.count do if checkboxCtrArray[i].checked then newNameArray[i] = ""
                local resultStr = jal.str.combine newNameArray filChar:filteringChar
                append resultNameArray resultStr
            )
        )
        return resultNameArray
    )

    fn update_result_ui = (
        if renameObjArray.count > 0 then (
            local uiListItemArray = #()
            for i = 1 to renameObjArray.count do (
                local resultStr = (renameObjArray[i].name + " -> " + resultNameArray[i])
                append uiListItemArray resultStr
            )
            resultLst.items = uiListItemArray
        )
    )

    on strTxt1 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb1 changed arg do (
        gen_new_name()
        update_result_ui()
    )
    on strTxt2 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb2 changed arg do (
        gen_new_name()
        update_result_ui()
    )
    on strTxt3 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb3 changed arg do (
        gen_new_name()
        update_result_ui()
    )
    on strTxt4 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb4 changed arg do (
        gen_new_name()
        update_result_ui()
    )
    on strTxt5 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb5 changed arg do (
        gen_new_name()
        update_result_ui()
    )
    on strTxt6 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb6 changed arg do (
        gen_new_name()
        update_result_ui()
    )
    on strTxt7 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb7 changed arg do (
        gen_new_name()
        update_result_ui()
    )
    on strTxt8 entered inTxt do (
        gen_new_name()
        update_result_ui()
    )
    on removeCkb8 changed arg do (
        gen_new_name()
        update_result_ui()
    )

    on filteringCharRdo changed state do (
        case state of (
            1: filteringChar = ""
            2: filteringChar = " "
            3: filteringChar = "_"
            default: filteringChar = " "
        )
        gen_new_name()
        update_result_ui()
    )

    on replaceTxt entered inTxt do (
        if targetTxt.text.count > 0 then (
            if renameObjArray.count > 0 then (
                resultNameArray = #()
                for i = 1 to renameObjArray.count do (
                    resultNameArray[i] = jal.str.find_and_replace renameObjArray[i].name targetTxt.text inTxt
                )
                update_result_ui()
            )
        )
    )

    on clearFindBtn pressed do (
        targetTxt.text = ""
        replaceTxt.text = ""
        update_ui()
    )

    on renameBtn pressed do (
        if renameObjArray.count == resultNameArray.count then (
            for i = 1 to renameObjArray.count do (
                renameObjArray[i].name = resultNameArray[i]
            )
            update_ui()
            jal.tools.nameReplaceTool.nameListRollout.update_UI()
        )
        try(destroydialog jal.tools.nameReplaceTool) catch()
    )
)
