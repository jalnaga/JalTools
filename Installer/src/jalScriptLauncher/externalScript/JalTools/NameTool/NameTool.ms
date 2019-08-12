(
    try(destroydialog jal.tools.namingTool) catch()
    rollout mainRollout "Naming Tool" width:300 height:690 (
        SubRollout mainSub "" align:#center height:675
    
        local minWidth = 300
        local minHeight = 690
        local subRollWidthOffset = 25
        local subRollHeightOffset = 15
    
        global __nameListRollout
        global __namingRollout
        global __batchNamingRollout
    
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
                        __namingRollout.update_UI()
                    )
                )
                else (
                    nameListLst.items = #()
                    renameObjArray = #()
                    __namingRollout.update_UI()
                )
            )
        
            on nameListRollout open do (
                callbacks.addScript #selectionSetChanged "__nameListRollout.update_UI()" id:#jalnameListRolloutUIUpdate
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
                __namingRollout.update_UI()
            )
        )

        rollout namingRollout "Naming Tool" (
            group "Name" (
                editText basePrefixTxt "Pre:" labelOnTop:true across:3 width:40 align:#left
                editText baseNameTxt "Base Name:" text:"Bip001" labelOnTop:true width:142 offset:[-32,0]
                editText baseSufixTxt "Su:" labelOnTop:true width:40 align:#right
                editText typePrefixTxt "Pre:" labelOnTop:true across:3 width:40 align:#left
                editText typeTxt "Type:" text:"" labelOnTop:true width:142 offset:[-32,0]
                editText typeSufixTxt "Su:" labelOnTop:true width:40 align:#right
                editText namePrefixTxt "Pre:" labelOnTop:true across:3 width:40 align:#left
                editText nameTxt "Name:" text:"" labelOnTop:true width:142 offset:[-32,0]
                editText nameSufixTxt "Su:" labelOnTop:true width:40 align:#right
                radiobuttons sideRdo "L/R:" align:#left labels:#("(None)", "L", "R") offsets:#([30, -16], [30, -16], [30, -16]) across:2
                radiobuttons frontBackRdo "F/B:" align:#left labels:#("(None)", "F", "B") offsets:#([30, -16], [30, -16], [30, -16])
                radiobuttons filteringCharRdo "Filtering:" align:#left labels:#("None", "(Blank)", "_") columns:3
            )
        
            group "Numbering" (
                spinner startCountSpn "Start:" align:#left range:[-1, 1000, 0] type:#integer across:2
                spinner paddingNumSpn "PaddingNum:" align:#right range:[1, 10, 3] type:#integer
                checkbox countingBySelOrderCkb "by Selection"
            )
        
            editText resultTxt "Result:" readOnly:true text:"Bip001 Temp 0" labelOnTop:true offset:[0, 10]
            button renameBtn "Rename!" height:30 offset:[0, 5] across:3 align:#left
            button nubBtn "Nub!" height:30 offset:[20, 5]
            button settingBtn "Set" align:#right offset:[0,5] height:30
        
            rollout nameToolSettingRollout "Setting" (
                group "Parts Order" (
                    dropdownlist firstDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:1 across:6 width:75
                    dropdownlist secondDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:2 width:75
                    dropdownlist thirdDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:3 width:75
                    dropdownlist fourthDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:4 width:75
                    dropdownlist fifthDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:5 width:75
                    dropdownlist sixthDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:6 width:75
                )
                group "Left/Right" (
                    editText leftStrTxt "Left:" text:"L" across:2 align:#left width:120
                    editText rightStrTxt "Right:" text:"R" align:#left width:120
                )
                group "Front/Back" (
                    editText frontStrTxt "Front:" text:"F" across:2 align:#left width:120
                    editText backStrTxt "Back:" text:"B" align:#left width:120
                )
                group "Nub" (
                    editText nubStrTxt "Nub:" text:"Nub" width:120
                )
                spinner paddingNumSpn "PaddingNum:" range:[1, 10, 3] type:#integer
                button saveBtn "Save" across:2
                button cancelBtn "Cancel"
            
                local ddlArray = #(firstDdl, secondDdl, thirdDdl, fourthDdl, fifthDdl, sixthDdl)
                local ddlSelArray = #()
                local partsArray = #("Base", "Type", "Side", "FrontBack", "RealName", "Index")
            
                fn update_ddl inChangedDdl inNewSel = (
                    local oriDdlIndex = findItem ddlSelArray inNewSel
                    local changedDdlIndex = findItem ddlArray inChangedDdl
                    local swapDdl = ddlArray[oriDdlIndex]
                    swapDdl.selection = ddlSelArray[changedDdlIndex]
                    inChangedDdl.selection = inNewSel
                    ddlSelArray = for item in ddlArray collect item.selection
                )
            
                on nameToolSettingRollout open do (
                    for i = 1 to namePartsOrder.count do (
                        local foundIndex = findItem partsArray namePartsOrder[i]
                        ddlArray[i].selection = foundIndex
                        ddlSelArray[i] = foundIndex
                    )
                    leftStrTxt.text = jal.name.get_leftStr()
                    rightStrTxt.text = jal.name.get_rightStr()
                    frontStrTxt.text = jal.name.get_frontStr()
                    backStrTxt.text = jal.name.get_backStr()
                    nubStrTxt.text = jal.name.get_nubStr()
                )
            
                on firstDdl selected newSel do update_ddl firstDdl newSel
                on secondDdl selected newSel do update_ddl secondDdl newSel
                on thirdDdl selected newSel do update_ddl thirdDdl newSel
                on fourthDdl selected newSel do update_ddl fourthDdl newSel
                on fifthDdl selected newSel do update_ddl fifthDdl newSel
                on sixthDdl selected newSel do update_ddl sixthDdl newSel
            
                on saveBtn pressed do (
                    local saveIniFile = jal.name.get_iniFile()
                    local saveNamePartsOrderArray = for item in ddlArray collect item.selected
                    local saveNamePartsOrder =  jal.name.combine_nameArray saveNamePartsOrderArray " "
                    local lrArrayStr = ""
                    local fbArrayStr = ""
                    if leftStrTxt.text != "" and rightStrTxt.text != "" then lrArrayStr = leftStrTxt.text + " " + rightStrTxt.text
                    if frontStrTxt.text != "" and backStrTxt.text != "" then fbArrayStr = frontStrTxt.text + " " + backStrTxt.text
                    setINISetting saveIniFile "DefaultSetting" "NamePartsOrder" saveNamePartsOrder
                    setINISetting saveIniFile "DefaultSetting" "PaddingNum" (paddingNumSpn.value as String)
                    setINISetting saveIniFile "DefaultSetting" "SideStrArray" lrArrayStr
                    setINISetting saveIniFile "DefaultSetting" "FrontBackStrArray" fbArrayStr
                    if nubStrTxt.text != "" then setINISetting saveIniFile "DefaultSetting" "NubStr" nubStrTxt.text
            
                    jal.name.load_setting_from_ini()
                    DestroyDialog nameToolSettingRollout
                )
                on cancelBtn pressed do (
                    DestroyDialog nameToolSettingRollout
                )
            )

        
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
                resultTxt.text = jal.name.combine inBase:(basePrefixTxt.text + baseNameTxt.text + baseSufixTxt.text) inType:(typePrefixTxt.text + typeTxt.text + typeSufixTxt.text) inSide:sideCharArray[sideRdo.state] inFrontBack:frontBackCharArray[frontBackRdo.state] inRealName:(namePrefixTxt.text + nameTxt.text + nameSufixTxt.text) inIndex:index inFilChar:filCharArray[filteringCharRdo.state]
            )
        
            fn update_UI = (
                if renameObjArray.count > 0 then (
                    sortedRenameObjsArray = #()
                    if countingBySelOrderCkb.checked then sortedRenameObjsArray = deepCopy renameObjArray
                    else sortedRenameObjsArray = jal.sel.sort_objects renameObjArray
        
                    baseNameTxt.text = jal.name.get_base sortedRenameObjsArray[1].name
                    typeTxt.text = jal.name.get_type sortedRenameObjsArray[1].name
                    nameTxt.text = jal.name.get_realName sortedRenameObjsArray[1].name
                    local filCharInRenameObjArray = jal.name.get_filteringChar sortedRenameObjsArray[1].name
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
                    paddingNumSpn.value = numPaddingNum
                    resultTxt.text = ""
                    countingBySelOrderCkb.checked = false
                )
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
        
            on typePrefixTxt changed inTxt do (
                resultTxt.text = gen_result_name()
            )
            on typeTxt changed inTxt do (
                resultTxt.text = gen_result_name()
            )
            on typeSufixTxt changed inTxt do (
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
                        local baseStr = basePrefixTxt.text + baseNameTxt.text + baseSufixTxt.text
                        local typeStr = typePrefixTxt.text + typeTxt.text + typeSufixTxt.text
                        local realStr = namePrefixTxt.text + nameTxt.text + nameSufixTxt.text
                        local indexStr = ""
                        indexStr = jal.name.convert_digit_into_padding_string (startCountSpn.value + i - 1) inPaddingNum:paddingNumSpn.value
                        if countingBySelOrderCkb.checked == false then (
                            if (jal.name.is_nub sortedRenameObjsArray[i].name) or (jal.bone.is_end_bone sortedRenameObjsArray[i]) then indexStr = jal.name.get_nubStr()
                        )
        
                        sortedRenameObjsArray[i].name = jal.name.combine inBase:baseStr inType:typeStr inSide:sideCharArray[sideRdo.state] inFrontBack:frontBackCharArray[frontBackRdo.state] inRealName:realStr inIndex:indexStr inFilChar:filCharArray[filteringCharRdo.state]
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
                        if (jal.name.is_nub sortedRenameObjsArray[i].name) or (jal.bone.is_end_bone sortedRenameObjsArray[i]) then sortedRenameObjsArray[i].name = jal.name.set_index_as_nub sortedRenameObjsArray[i].name
                    )
                    __nameListRollout.update_UI()
                    update_UI()
                )
            )
        
            on settingBtn pressed do (
                createDialog nameToolSettingRollout width:480 modal:true style:#(#style_toolwindow)
            )
        )

        rollout batchNamingRollout "Batch Naming" (
            button windowLaunchBtn "Batch Rename" widht:180 height:30
        
            local subWindow = undefined
        
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
                        local lastNamePartSplitArray = jal.name.split_into_string_and_digit lastNamePart
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
        
                    returnName = jal.name.combine_nameArray nameArray returnFilChar
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
                    __nameListRollout.update_UI()
                    DestroyDialog subWindow
                )
            )
        
            on batchNamingRollout open do (
                subWindow = batchNamingListRollout
            )
        
            on windowLaunchBtn pressed do (
                createDialog subWindow modal:true
            )
        )

    
        on mainRollout open do
        (
            iniFile = jal.name.get_iniFile()
            nubStr = getINISetting iniFile "DefaultSetting" "NubStr"
            namePartsOrder = filterString (getINISetting iniFile "DefaultSetting" "NamePartsOrder") " "
            numPaddingNum = (getINISetting iniFile "DefaultSetting" "PaddingNum") as integer
            local iniSideStrArray = filterString (getINISetting iniFile "DefaultSetting" "SideStrArray") " "
            local iniFrontBackStrArray = filterString (getINISetting iniFile "DefaultSetting" "FrontBackStrArray") " "
            jal.name.set_name_parts_order namePartsOrder
            jal.name.set_nubStr nubStr
            jal.name.set_leftStr iniSideStrArray[1]
            jal.name.set_rightStr iniSideStrArray[2]
            jal.name.set_frontStr iniFrontBackStrArray[1]
            jal.name.set_backStr iniFrontBackStrArray[2]
    
            __nameListRollout = nameListRollout
            __namingRollout = namingRollout
            __batchNamingRollout = batchNamingRollout
    
            AddSubRollout mainSub nameListRollout
            AddSubRollout mainSub namingRollout
            AddSubRollout mainSub batchNamingRollout
    
            __nameListRollout.update_UI()
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
