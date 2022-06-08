(
    try(destroydialog jal.tools.namingTool) catch()
    rollout mainRollout "Naming Tool" width:380 height:770 (
        SubRollout mainSub "" align:#center height:755
    
        local minWidth = 380
        local minHeight = 770
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        local iniFile = ""
        local nubStr = ""
        local namePartsOrder = #()
        local numPaddingNum = 3
        local renameObjArray = #()
    
        rollout nameListRollout "Name List" (
            multiListBox nameListLst "Selected Objects:" height:10
        
            fn update_UI = (
                local selArray = getCurrentSelection() as array
                if selArray.count > 0 then (
                    selArray = jal.name.sort_by_name selArray
                    local selNameArray = #()
                    for item in selArray do (
                        if (jal.name.get_index item.name) == "" then appendIfUnique selNameArray ((jal.name.get_string item.name) + "*")
                        else appendIfUnique selNameArray (jal.name.replace_index item.name "*")
                    )
                    nameListLst.items = selNameArray
        
                    if nameListLst.items.count > 0 then (
                        renameObjArray = #()
                        local selName = nameListLst.items[1]
                        renameObjArray = for item in selArray where (matchPattern item.name pattern:selName) collect item
                        jal.tools.namingTool.namingRollout.update_UI()
                    )
                )
                else (
                    nameListLst.items = #()
                    renameObjArray = #()
                    jal.tools.namingTool.namingRollout.update_UI()
                )
            )
        
            on nameListRollout open do (
                callbacks.addScript #selectionSetChanged "jal.tools.namingTool.nameListRollout.update_UI()" id:#jalnameListRolloutUIUpdate
            )
        
            on nameListRollout close do (
                callbacks.removeScripts id:#jalnameListRolloutUIUpdate
            )
        
            on nameListLst selectionEnd do (
                local selArray = getCurrentSelection() as Array
                renameObjArray = #()
                local selNameIndexArray = nameListLst.selection as array
                for index in selNameIndexArray do (
                    local selName = nameListLst.items[index]
                    local tempObjCollection = for item in selArray where (matchPattern item.name pattern:selName) collect item
                    join renameObjArray tempObjCollection
                )
                jal.tools.namingTool.namingRollout.update_UI()
            )
        )

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

        rollout batchNamingRollout "Batch Naming" (
            button windowLaunchBtn "Batch Rename" widht:200 height:40 across:2
            button nameReplacerBtn "Replace Name" widht:200 height:40
        
            local batchWindow = undefined
            local replaceWindow = undefined
        
            rollout batchNamingListRollout "List" width:565 height:740 (
                group "Name" (
                    editText basePrefixTxt "Pre:" labelOnTop:true across:4 width:40
                    editText baseNameTxt "Base Name:" text:"" width:380 labelOnTop:true offset:[-85,0]
                    editText baseSufixTxt "Su:" labelOnTop:true width:40 offset:[170,0]
                    checkbox removeBaseNameCkb "Remove" offset:[82,20]
                    editText typePrefixTxt "Pre:" labelOnTop:true across:4 width:40
                    editText typeTxt "Type:" text:"" width:380 labelOnTop:true offset:[-85,0]
                    editText typeSufixTxt "Su:" labelOnTop:true width:40 offset:[170,0]
                    checkbox removeTypeCkb "Remove" offset:[82,20]
                    editText namePrefixTxt "Pre:" labelOnTop:true across:3 width:40
                    editText nameTxt "Name:" text:"" labelOnTop:true width:380 offset:[-130,0]
                    editText nameSufixTxt "Su:" labelOnTop:true width:40 offset:[80,0]
                    radiobuttons filteringCharRdo "Filtering:" labels:#("None", "(Blank)", "_") columns:3 default:2 align:#left
                )
                group "Index" (
                    spinner addIndexSpn "Add:" type:#integer across:2 align:#left range:[-1, 999, 0]
                    editText replaceIndexTxt "Replace:" text:"" align:#right
                    checkbox lastDigitToIndexCkb "Use Last digit as Index" offset:[0, 5]
                )
                group "Side" (
                    radiobuttons sideModTypeRdo "Side Modify Mode:" align:#left labels:#("No Change", "Replace", "Swap") columns:3 default:1 across:2
                    radiobuttons sideRdo "Side:" align:#left labels:#("(None)", "L", "R") columns:3 enabled:false
                    radiobuttons fbModTypeRdo "Front/Back Modify Mode:" align:#left labels:#("No Change", "Replace", "Swap") columns:3 default:1 across:2
                    radiobuttons frontBackRdo "Front/Back:" align:#left labels:#("(None)", "F", "B") columns:3 enabled:false
                )
                listbox resultLst "" readOnly:true height:23
                button batchRenameBtn "Rename!" offset:[0, 10]
            
                local sideCharArray = #("", "L", "R")
                local frontBackCharArray = #("", "F", "B")
                local filCharArray = #("", " ", "_")
                local renameSelObjNameArray = #()
                local renameSelObjArray = #()
                local newNameArray = #()
            
                local baseIndex = jal.name.get_base_part_index()
                local typeIndex = jal.name.get_type_part_index()
                local sideIndex = jal.name.get_side_part_index()
                local forntBackIndex = jal.name.get_front_Back_part_index()
                local realNameIndex = jal.name.get_realName_part_index()
                local indexIndex = jal.name.get_index_part_index()
            
                fn gen_name inName = (
                    local returnName = ""
                    local nameArray = jal.name.convert_name_to_nameArray inName
                    local returnBaseNameTxt = ""
                    local returnTypeTxt = ""
                    local returnNameTxt = ""
                    if baseNameTxt.text == "" then returnBaseNameTxt = nameArray[baseIndex] else returnBaseNameTxt = baseNameTxt.text
                    if typeTxt.text == "" then returnTypeTxt = nameArray[typeIndex] else returnTypeTxt = typeTxt.text
                    if nameTxt.text == "" then returnNameTxt = nameArray[realNameIndex] else returnNameTxt = nameTxt.text
            
                    local returnFilChar = filCharArray[filteringCharRdo.state]
                    local returnBase = basePrefixTxt.text + returnBaseNameTxt + baseSufixTxt.text
                    local returnType = typePrefixTxt.text + returnTypeTxt + typeSufixTxt.text
                    local returnRealName = namePrefixTxt.text + returnNameTxt + nameSufixTxt.text
                    local returnSide = nameArray[sideIndex]
                    local returnFrontBack = nameArray[forntBackIndex]
                    struct renamedStruct (result, newName)
            
                    if returnBase != "" then nameArray[baseIndex] = returnBase
                    if returnType != "" then nameArray[typeIndex] = returnType
                    if returnRealName != "" then nameArray[realNameIndex] = returnRealName
                    if removeBaseNameCkb.checked then nameArray[baseIndex] = ""
                    if removeTypeCkb.checked then nameArray[typeIndex] = ""
                    case sideModTypeRdo.state of (
                        1: nameArray[sideIndex] = returnSide
                        2: nameArray[sideIndex] = sideCharArray[sideRdo.state]
                        3: (
                            case returnSide of (
                                "L": nameArray[sideIndex] = "R"
                                "R": nameArray[sideIndex] = "L"
                                default: nameArray[sideIndex] = returnSide
                            )
                        )
                    )
                    case fbModTypeRdo.state of (
                        1: nameArray[forntBackIndex] = returnFrontBack
                        2: nameArray[forntBackIndex] = frontBackCharArray[frontBackRdo.state]
                        3: (
                            case returnFrontBack of (
                                "F": nameArray[forntBackIndex] = "B"
                                "B": nameArray[forntBackIndex] = "F"
                                default: nameArray[forntBackIndex] = returnFrontBack
                            )
                        )
                    )
                    if lastDigitToIndexCkb.checked then (
                        local lastNamePart = ""
                        local lastIndex = 0
                        for i = 1 to nameArray.count do (
                            if nameArray[i] != "" then (
                                lastNamePart = nameArray[i]
                                lastIndex = i
                            )
                        )
                        local lastNamePartSplitArray = jal.str.split_into_string_and_digit lastNamePart
                        nameArray[lastIndex] = lastNamePartSplitArray[1]
                        nameArray[indexIndex] = lastNamePartSplitArray[2]
                    )
                    else (
                        local indexStr = ""
                        local indexPaddingNum = 0
                        local indexNum = -9999
            
                        indexPaddingNum = nameArray[indexIndex].count
                        if indexPaddingNum == 0 then indexPaddingNum = 1
            
                        case nameArray[indexIndex] of (
                            "": indexNum = -1
                            (jal.name.get_nubStr()): indexNum = -9999999
                            default: (
                                indexNum = execute nameArray[indexIndex]
                            )
                        )
                        indexNum = indexNum + addIndexSpn.value
                        if indexNum > -1 then (
                            nameArray[indexIndex] = jal.name.convert_digit_into_padding_string indexNum inPaddingNum:indexPaddingNum
                        )
            
                        if replaceIndexTxt.text != "" then nameArray[indexIndex] = replaceIndexTxt.text
                    )
            
                    returnName = jal.str.combine nameArray filChar:returnFilChar
                    local returnStruct = renamedStruct result:(inName + "  =>  " + returnName) newName:returnName
            
                    return returnStruct
                )
            
                on batchNamingListRollout open do (
                    renameSelObjArray = getCurrentSelection() as Array
                    renameSelObjNameArray = for item in renameSelObjArray collect item.name
                    resultLst.items = renameSelObjNameArray
                )
            
                on basePrefixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on baseNameTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on baseSufixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on typePrefixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on typeTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on typeSufixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on namePrefixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on nameTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on nameSufixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on filteringCharRdo changed state do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on addIndexSpn changed inVal do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on replaceIndexTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
            
                on sideModTypeRdo changed state do (
                    case state of (
                        2: sideRdo.enabled = true
                        default: sideRdo.enabled = false
                    )
                    resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                )
                on sideRdo changed state do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
            
                on fbModTypeRdo changed state do (
                    case state of (
                        2: frontBackRdo.enabled = true
                        default: frontBackRdo.enabled = false
                    )
                    resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                )
                on frontBackRdo changed state do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
            
                on removeBaseNameCkb changed arg do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                on removeTypeCkb changed arg do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
            
                on lastDigitToIndexCkb changed arg do (
                    if arg then (
                        addIndexSpn.value = 0
                        addIndexSpn.enabled = false
                        replaceIndexTxt.text = ""
                        replaceIndexTxt.enabled = false
                    )
                    else (
                        addIndexSpn.enabled = true
                        replaceIndexTxt.enabled = true
                    )
                    resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
                )
            
                on batchRenameBtn pressed do (
                    for i = 1 to renameSelObjArray.count do (
                        renameSelObjArray[i].name = (gen_name renameSelObjArray[i].name).newName
                    )
                    nameListRollout.update_UI()
                    DestroyDialog batchWindow
                )
            )

            rollout replaceNameRollout "Replace Name" width:565 height:760 (
                multiListBox nameListLst "Selected Objects:" height:10
            
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
            
                local renameObjArray = #()
                local filteringChar = " "
            
                fn nameList_update_ui = (
                    renameObjArray = #()
                    local selArray = getCurrentSelection() as array
                    if selArray.count > 0 then (
                        local selNameArray = for item in selArray collect item.name
                        nameListLst.items = jal.str.sort_by_alphabet selNameArray
                    )
                    else nameListLst.items = #()
                    nameListLst.selection = #{}
                )
            
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
            
                on replaceNameRollout open do (
                    nameList_update_ui()
                )
            
                on nameListLst selectionEnd do (
                    local selArray = getCurrentSelection() as Array
                    renameObjArray = #()
                    local selNameIndexArray = nameListLst.selection as array
                    for index in selNameIndexArray do (
                        local selName = nameListLst.items[index]
                        local tempObjCollection = for item in selArray where (matchPattern item.name pattern:selName) collect item
                        join renameObjArray tempObjCollection
                    )
                    update_UI()
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
                        nameList_update_ui()
                    )
                    DestroyDialog replaceWindow
                )
            )

        
            on batchNamingRollout open do (
                batchWindow = batchNamingListRollout
                replaceWindow = replaceNameRollout
            )
        
            on windowLaunchBtn pressed do (
                createDialog batchWindow modal:true
            )
        
            on nameReplacerBtn pressed do (
                createDialog replaceNameRollout modal:true
            )
        )

    
        on mainRollout open do
        (
            jal.name.load_setting_from_ini()
    
            AddSubRollout mainSub nameListRollout
            AddSubRollout mainSub namingRollout
            AddSubRollout mainSub batchNamingRollout
    
            namingRollout.baseNameDrp.items = #("") + jal.name.__baseStrArray
            namingRollout.typeDrp.items = #("") + jal.name.__typeStrArray
            nameListRollout.update_UI()
            namingRollout.paddingNumSpn.value = (jal.name.get_paddingNum())
        )
    
        on mainRollout resized newSize do
        (
            if newSize[1] > minWidth then
            mainSub.width = newSize[1] - subRollWidthOffset
            else (
                mainRollout.width = minWidth
                mainSub.width = minWidth - subRollWidthOffset
            )
            if newSize[2] > minHeight then mainSub.height = newSize[2] - subRollHeightOffset
            else (
                mainRollout.height = minHeight
                mainSub.height = minHeight - subRollHeightOffset
            )
    
            jal.roll.update_subroll_when_resized mainSub nameListRollout
            jal.roll.update_subroll_when_resized mainSub namingRollout
            jal.roll.update_subroll_when_resized mainSub batchNamingRollout
        )
    )
    
    jal.tools.namingTool = mainRollout
    createDialog jal.tools.namingTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)

    clearlistener()
    gc()
)
