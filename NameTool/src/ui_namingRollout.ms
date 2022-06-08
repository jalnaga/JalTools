rollout namingRollout "Naming Tool" (
    group "Name" (
        editText basePrefixTxt "Pre:" labelOnTop:true across:3 width:60 align:#left
        editText baseNameTxt "Base Name:" text:"Bip001" labelOnTop:true width:170 offset:[-32,0]
        editText baseSufixTxt "Su:" labelOnTop:true width:60 align:#right
        dropdownList baseNameDrp "" items:#("") width:170 align:#center
        editText typePrefixTxt "Pre:" labelOnTop:true across:3 width:60 align:#left
        editText typeTxt "Type:" text:"" labelOnTop:true width:170 offset:[-32,0]
        editText typeSufixTxt "Su:" labelOnTop:true width:60 align:#right
        dropdownList typeDrp "" items:#("") width:170 align:#center
        editText namePrefixTxt "Pre:" labelOnTop:true across:3 width:60 align:#left
        editText nameTxt "Name:" text:"" labelOnTop:true width:170 offset:[-32,0]
        editText nameSufixTxt "Su:" labelOnTop:true width:60 align:#right
        radiobuttons sideRdo "L/R:" align:#left labels:#("(None)", "Left", "Right") offsets:#([30, -16], [30, -16], [30, -16]) across:2
        radiobuttons frontBackRdo "F/B:" align:#left labels:#("(None)", "Front", "Back") offsets:#([30, -16], [30, -16], [30, -16])
        radiobuttons filteringCharRdo "Filtering:" align:#left labels:#("None", "(Blank)", "_") columns:3
    )

    group "Numbering" (
        spinner startCountSpn "Start:" align:#left range:[-1, 1000, 0] type:#integer across:2
        spinner paddingNumSpn "PaddingNum:" align:#right range:[1, 10, 3] type:#integer
        checkbox countingBySelOrderCkb "by Selection"
    )

    editText resultTxt "Result:" readOnly:true text:"Bip001 Temp 0" labelOnTop:true offset:[0, 10]
    button renameBtn "Rename!" width:100 height:40 offset:[0, 5] across:2 align:#left
    button nubBtn "Nub!" height:40 align:#right offset:[0, 5]

    local sortedRenameObjsArray = #()
    local sideCharArray = #("", jal.name.get_leftStr(), jal.name.get_rightStr())
    local frontBackCharArray = #("", jal.name.get_frontStr(), jal.name.get_backStr())
    local filCharArray = #("", " ", "_")

    fn gen_result_name = (
        local index = ""
        if startCountSpn.value > -1 then (
            local formatStr = "0" + (paddingNumSpn.value as String) + "d"
            index = formattedPrint startCountSpn.value format:formatStr
        )
        else index = nubStr

        local tempBaseName = ""
        local tempType = ""
        if baseNameTxt.text != "" then tempBaseName = baseNameTxt.text
        if baseNameTxt.text == "" and baseNameDrp.selection > 1 then tempBaseName = baseNameDrp.items[baseNameDrp.selection]
        if typeTxt.text != "" then tempType = typeTxt.text
        if typeTxt.text == "" and typeDrp.selection > 1 then tempType = typeDrp.items[typeDrp.selection]

        resultTxt.text = jal.name.combine inBase:(basePrefixTxt.text + tempBaseName + baseSufixTxt.text) inType:(typePrefixTxt.text + tempType + typeSufixTxt.text) inSide:sideCharArray[sideRdo.state] inFrontBack:frontBackCharArray[frontBackRdo.state] inRealName:(namePrefixTxt.text + nameTxt.text + nameSufixTxt.text) inIndex:index inFilChar:filCharArray[filteringCharRdo.state]
    )

    fn update_UI = (
        if renameObjArray.count > 0 then (
            sortedRenameObjsArray = #()
            if countingBySelOrderCkb.checked then sortedRenameObjsArray = deepCopy renameObjArray
            else sortedRenameObjsArray = jal.sel.sort_objects renameObjArray

            baseNameTxt.text = jal.name.get_base sortedRenameObjsArray[1].name
            local baseNameFoundIndex = findItem baseNameDrp.items baseNameTxt.text
            if baseNameFoundIndex != 0 then baseNameDrp.selection = baseNameFoundIndex else baseNameDrp.selection = 1
            typeTxt.text = jal.name.get_type sortedRenameObjsArray[1].name
            local typeFoundIndex = findItem typeDrp.items baseNameTxt.text
            if typeFoundIndex != 0 then typeDrp.selection = typeFoundIndex else typeDrp.selection = 1
            nameTxt.text = jal.name.get_realName sortedRenameObjsArray[1].name
            local filCharInRenameObjArray = jal.str.get_filteringChar sortedRenameObjsArray[1].name
            local sideCharInRenameObjArray = jal.name.get_side sortedRenameObjsArray[1].name
            local fbCharInRenameObjArray = jal.name.get_frontBack sortedRenameObjsArray[1].name

            case sideCharInRenameObjArray of (
                "": sideRdo.state = 1
                (jal.name.get_leftStr()): sideRdo.state = 2
                (jal.name.get_rightStr()): sideRdo.state = 3
            )
            case fbCharInRenameObjArray of (
                "": frontBackRdo.state = 1
                (jal.name.get_frontStr()): frontBackRdo.state = 2
                (jal.name.get_backStr()): frontBackRdo.state = 3
            )
            case filCharInRenameObjArray of (
                "": filteringCharRdo.state = 1
                " ": filteringCharRdo.state = 2
                "_": filteringCharRdo.state = 3
            )

            local indexDigit = jal.name.get_index_as_digit sortedRenameObjsArray[1].name
            if indexDigit != false then (
                startCountSpn.value = indexDigit
                paddingNumSpn.value = jal.name.get_index_padding_num sortedRenameObjsArray[1].name
            )
            else startCountSpn.value = 0
            resultTxt.text = gen_result_name()
        )
        else (
            baseNameTxt.text = ""
            typeTxt.text = ""
            nameTxt.text = ""
            sideRdo.state = 1
            frontBackRdo.state = 1
            filteringCharRdo.state = 2
            startCountSpn.value = 0
            paddingNumSpn.value = jal.name.get_paddingNum()
            resultTxt.text = ""
            countingBySelOrderCkb.checked = false
            baseNameDrp.selection = 1
            typeDrp.selection = 1
        )
        basePrefixTxt.text = ""
        baseSufixTxt.text = ""
        typePrefixTxt.text = ""
        typeSufixTxt.text = ""
        namePrefixTxt.text = ""
        nameSufixTxt.text = ""
    )

    on namingRollout open do (
        paddingNumSpn.value = jal.name.get_paddingNum()
    )

    on basePrefixTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on baseNameTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on baseSufixTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on baseNameDrp selected inSel do (
        baseNameTxt.text = ""
        resultTxt.text = gen_result_name()
    )

    on typePrefixTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on typeTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on typeSufixTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on typeDrp selected inSel do (
        typeTxt.text = ""
        resultTxt.text = gen_result_name()
    )

    on namePrefixTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on nameTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )
    on nameSufixTxt changed inTxt do (
        resultTxt.text = gen_result_name()
    )

    on startCountSpn changed inVal do (
        resultTxt.text = gen_result_name()
    )

    on sideRdo changed stat do (
        resultTxt.text = gen_result_name()
    )
    on frontBackRdo changed stat do (
        resultTxt.text = gen_result_name()
    )

    on filteringCharRdo changed stat do (
        resultTxt.text = gen_result_name()
    )

    on paddingNumSpn changed newVal do (
        resultTxt.text = gen_result_name()
    )

    on renameBtn pressed do (
        if countingBySelOrderCkb.checked then sortedRenameObjsArray = deepCopy renameObjArray
        else sortedRenameObjsArray = jal.sel.sort_objects renameObjArray

        if sortedRenameObjsArray.count > 0 then (
            for i = 1 to sortedRenameObjsArray.count do (
                local tempBaseName = ""
                local tempType = ""
                if baseNameTxt.text != "" then tempBaseName = baseNameTxt.text
                if baseNameTxt.text == "" and baseNameDrp.selection > 1 then tempBaseName = baseNameDrp.items[baseNameDrp.selection]
                if typeTxt.text != "" then tempType = typeTxt.text
                if typeTxt.text == "" and typeDrp.selection > 1 then tempType = typeDrp.items[typeDrp.selection]

                local baseStr = basePrefixTxt.text + tempBaseName + baseSufixTxt.text
                local typeStr = typePrefixTxt.text + tempType + typeSufixTxt.text
                local realStr = namePrefixTxt.text + nameTxt.text + nameSufixTxt.text
                local indexStr = ""
                indexStr = jal.name.convert_digit_into_padding_string (startCountSpn.value + i - 1) inPaddingNum:paddingNumSpn.value
                if countingBySelOrderCkb.checked == false then (
                    if (jal.name.is_nub sortedRenameObjsArray[i].name) or (jal.bone.is_end_bone sortedRenameObjsArray[i]) then indexStr = jal.name.get_nubStr()
                )

                sortedRenameObjsArray[i].name = jal.name.combine inBase:baseStr inType:typeStr inSide:sideCharArray[sideRdo.state] inFrontBack:frontBackCharArray[frontBackRdo.state] inRealName:realStr inIndex:indexStr inFilChar:filCharArray[filteringCharRdo.state]
            )

            jal.tools.namingTool.nameListRollout.update_UI()
            update_UI()
        )
    )

    on nubBtn pressed do (
        if countingBySelOrderCkb.checked then sortedRenameObjsArray = deepCopy renameObjArray
        else sortedRenameObjsArray = jal.sel.sort_objects renameObjArray

        if sortedRenameObjsArray.count > 0 then (
            for i = 1 to sortedRenameObjsArray.count do (
                if (jal.name.is_nub sortedRenameObjsArray[i].name) or (jal.bone.is_end_bone sortedRenameObjsArray[i]) then sortedRenameObjsArray[i].name = jal.name.set_index_as_nub sortedRenameObjsArray[i].name
            )
            jal.tools.namingTool.nameListRollout.update_UI()
            update_UI()
        )
    )
)
