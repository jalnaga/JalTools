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
