rollout namingRollout "Naming Tool" (
    group "Name" (
        editText baseNameTxt "Base Name:" text:"Bip001"
        editText typeTxt "Type:" text:""
        editText nameTxt "Name:" text:""
        radiobuttons sideRdo "Side:" align:#left labels:#("(None)", "L", "R", "F", "B") offsets:#([30, -16], [30, -16], [30, -16], [30, -16], [30, -16]) across:2
        radiobuttons filteringCharRdo "Filtering:" align:#left labels:#("(None)", "(Blank)", "_") offsets:#([45, -16], [45, -16], [45, -16])
    )

    group "Numbering" (
        spinner startCountSpn "Start:" align:#left range:[-1, 1000, 0] type:#integer
        checkbox countingBySelOrderCkb "by Selection"
    )

    editText resultTxt "Result:" readOnly:true text:"Bip001 Temp 0" labelOnTop:true offset:[0, 10]
    button renameBtn "Rename!" width:120 height:30 offset:[0, 5] across:2
    button nubBtn "Nub!" width:40 height:30 offset:[0, 5] align:#right

    local sortedRenameObjsArray = #()
    local sideCharArray = #("", "L", "R", "F", "B")
    local filCharArray = #("", " ", "_")

    fn gen_result_name = (
        local index = ""
        if startCountSpn.value > -1 then index = startCountSpn.value as string
        else index = "Nub"
        resultTxt.text = jal.name.combine baseNameTxt.text typeTxt.text sideCharArray[sideRdo.state] nameTxt.text index filCharArray[filteringCharRdo.state]
    )

    fn update_UI = (
        if renameObjArray.count > 0 then (
            sortedRenameObjsArray = #()
            if countingBySelOrderCkb.checked then sortedRenameObjsArray = deepCopy renameObjArray
            else sortedRenameObjsArray = jal.sel.sort_objects renameObjArray

            baseNameTxt.text = jal.name.get_base sortedRenameObjsArray[1].name
            typeTxt.text = jal.name.get_type sortedRenameObjsArray[1].name
            nameTxt.text = jal.name.get_realName sortedRenameObjsArray[1].name
            if (jal.name.get_side sortedRenameObjsArray[1].name) == "" then sideRdo.state = 1
            if (jal.name.get_side sortedRenameObjsArray[1].name) == "L" then sideRdo.state = 2
            if (jal.name.get_side sortedRenameObjsArray[1].name) == "R" then sideRdo.state = 3
            if (jal.name.get_side sortedRenameObjsArray[1].name) == "F" then sideRdo.state = 4
            if (jal.name.get_side sortedRenameObjsArray[1].name) == "B" then sideRdo.state = 5
            if (jal.name.get_filteringChar sortedRenameObjsArray[1].name) == "" then filteringCharRdo.state = 1
            if (jal.name.get_filteringChar sortedRenameObjsArray[1].name) == " " then filteringCharRdo.state = 2
            if (jal.name.get_filteringChar sortedRenameObjsArray[1].name) == "_" then filteringCharRdo.state = 3

            local indexDigit = jal.name.get_index_as_digit sortedRenameObjsArray[1].name
            if indexDigit != false then startCountSpn.value = indexDigit
            else startCountSpn.value = 0
            resultTxt.text = gen_result_name()
        )
        else (
            baseNameTxt.text = ""
            typeTxt.text = ""
            nameTxt.text = ""
            sideRdo.state = 1
            filteringCharRdo.state = 2
            startCountSpn.value = 0
            resultTxt.text = ""
            countingBySelOrderCkb.checked = false
        )
    )

    on baseNameTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )

    on typeTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )

    on nameTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )

    on startCountSpn changed inVal do (
        resultTxt.text = gen_result_name()
    )

    on sideRdo changed stat do (
        resultTxt.text = gen_result_name()
    )

    on filteringCharRdo changed stat do (
        resultTxt.text = gen_result_name()
    )

    on renameBtn pressed do (
        if countingBySelOrderCkb.checked then sortedRenameObjsArray = deepCopy renameObjArray
        else sortedRenameObjsArray = jal.sel.sort_objects renameObjArray

        if sortedRenameObjsArray.count > 0 then (
            for i = 1 to sortedRenameObjsArray.count do (
                sortedRenameObjsArray[i].name = jal.name.combine baseNameTxt.text typeTxt.text sideCharArray[sideRdo.state] nameTxt.text ((startCountSpn.value + i - 1) as String) filCharArray[filteringCharRdo.state]
                
                if countingBySelOrderCkb.checked == false then (
                    if (jal.name.is_nub sortedRenameObjsArray[i].name) or (jal.bone.is_nub_bone sortedRenameObjsArray[i]) then sortedRenameObjsArray[i].name = jal.name.set_index_as_nub sortedRenameObjsArray[i].name
                )
            )

            __nameListRollout.update_UI()
            update_UI()
        )
    )

    on nubBtn pressed do (
        if countingBySelOrderCkb.checked then sortedRenameObjsArray = deepCopy renameObjArray
        else sortedRenameObjsArray = jal.sel.sort_objects renameObjArray

        if sortedRenameObjsArray.count > 0 then (
            for i = 1 to sortedRenameObjsArray.count do (
                if (jal.name.is_nub sortedRenameObjsArray[i].name) or (jal.bone.is_nub_bone sortedRenameObjsArray[i]) then sortedRenameObjsArray[i].name = jal.name.set_index_as_nub sortedRenameObjsArray[i].name
            )
            __nameListRollout.update_UI()
            update_UI()
        )
    )
)
