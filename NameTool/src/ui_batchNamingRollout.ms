rollout batchNamingRollout "Batch Naming" (
    button windowLaunchBtn "Batch Rename" widht:180 height:30

    local subWindow = undefined

    rollout batchNamingListRollout "List" width:500 height:650 (
        group "Name" (
            editText baseNameTxt "Base Name:" text:"" across:2 width:400
            checkbox removeBaseNameCkb "Remove" align:#right
            editText typeTxt "Type:" text:"" across:2 width:400
            checkbox removeTypeCkb "Remove" align:#right
            editText prefixTxt "Pre:" labelOnTop:true across:3 width:40 align:#left
            editText nameTxt "Name:" text:"" labelOnTop:true align:#center width:380
            editText sufixTxt "Su:" labelOnTop:true width:40 align:#right
            radiobuttons filteringCharRdo "Filtering:" align:#left labels:#("(None)", "(Blank)", "_") columns:3 default:2
        )
        group "Index" (
            spinner addIndexSpn "Add:" type:#integer across:2 align:#left range:[-1, 999, 0]
            editText replaceIndexTxt "Replace:" text:"" align:#right
        )
        group "Side" (
            radiobuttons sideModTypeRdo "" align:#left labels:#("No Change", "Replace", "Swap") columns:3 default:1
            radiobuttons sideRdo "Side:" align:#left labels:#("(None)", "L", "R", "F", "B") columns:5 enabled:false
        )
        listbox resultLst "" readOnly:true height:23
        button batchRenameBtn "Rename!" offset:[0, 10]

        local sideCharArray = #("", "L", "R", "F", "B")
        local filCharArray = #("", " ", "_")
        local renameSelObjNameArray = #()
        local renameSelObjArray = #()
        local newNameArray = #()

        fn gen_name inName = (
            local returnName = ""
            local returnFilChar = filCharArray[filteringCharRdo.state]
            local returnSide = jal.name.get_side inName
            struct renamedStruct (result, newName)

            returnName = deepCopy inName
            
            if baseNameTxt.text != "" then returnName = jal.name.replace_base returnName baseNameTxt.text
            if typeTxt.text != "" then returnName = jal.name.replace_type returnName typeTxt.text
            if prefixTxt.text != "" then returnName = jal.name.add_prefix_to_realName returnName prefixTxt.text
            if nameTxt.text != "" then returnName = jal.name.replace_realName returnName nameTxt.text
            if sufixTxt.text != "" then returnName = jal.name.add_sufix_to_realName returnName sufixTxt.text
            returnName = jal.name.increase_index returnName addIndexSpn.value
            if removeBaseNameCkb.checked then returnName = jal.name.replace_base returnName ""
            if removeTypeCkb.checked then returnName = jal.name.replace_type returnName ""

            case sideModTypeRdo.state of (
                1: returnName
                2: returnName = jal.name.replace_side returnName sideCharArray[sideRdo.state]
                3: (
                    case returnSide of (
                        "L": returnName = jal.name.replace_side returnName "R"
                        "R": returnName = jal.name.replace_side returnName "L"
                        "F": returnName = jal.name.replace_side returnName "B"
                        "B": returnName = jal.name.replace_side returnName "F"
                        default: returnName
                    )
                )
            )

            if replaceIndexTxt.text != "" then returnName = jal.name.replace_index returnName replaceIndexTxt.text
            returnName = jal.name.replace_filteringChar returnName returnFilChar
            local returnStruct = renamedStruct result:(inName + "  =>  " + returnName) newName:returnName

            return returnStruct
        )

        on batchNamingListRollout open do (
            renameSelObjArray = getCurrentSelection() as Array
            renameSelObjNameArray = for item in renameSelObjArray collect item.name
            resultLst.items = renameSelObjNameArray
        )

        on baseNameTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
        on typeTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
        on prefixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
        on nameTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
        on sufixTxt entered inTxt do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
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

        on removeBaseNameCkb changed arg do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result
        on removeTypeCkb changed arg do resultLst.items = for item in renameSelObjNameArray collect (gen_name item).result

        on batchRenameBtn pressed do (
            for i = 1 to renameSelObjArray.count do (
                renameSelObjArray[i].name = (gen_name renameSelObjArray[i].name).newName
            )
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
