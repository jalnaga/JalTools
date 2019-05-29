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
