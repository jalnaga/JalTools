rollout nameToolSettingRollout "Setting" (
    group "Parts Order" (
        dropdownlist firstDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:1 across:6
        dropdownlist secondDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:2
        dropdownlist thirdDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:3
        dropdownlist fourthDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:4
        dropdownlist fifthDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:5
        dropdownlist sixthDdl "" items:#("Base", "Type", "Side", "FrontBack", "RealName", "Index") selection:6
        spinner paddingNumSpn "PaddingNum:" range:[1, 10, 3] type:#integer
    )

    button saveBtn "Save" across:2
    button cancelBtn "Cancel"

    local ddlArray = #(firstDdl, secondDdl, thirdDdl, fourthDdl, fifthDdl, sixthDdl)
    local partsArray = #("Base", "Type", "Side", "FrontBack", "RealName", "Index")

    on nameToolSettingRollout open do (
        for i = 1 to namePartsOrder.count do (
            ddlArray[i].selection = findItem partsArray namePartsOrder[i]
        )
    )

    on saveBtn pressed do (
        local saveIniFile = (getFilenamePath (getThisScriptFilename())) +"\\NameTool.ini"
        local saveNamePartsOrderArray = for item in ddlArray collect item.selected
        local saveNamePartsOrder =  jal.name.combine_nameArray saveNamePartsOrderArray " "
        setINISetting saveIniFile "DefaultSetting" "NamePartsOrder" saveNamePartsOrder
        setINISetting saveIniFile "DefaultSetting" "PaddingNum" (paddingNumSpn.value as String)
        DestroyDialog nameToolSettingRollout
    )
    on cancelBtn pressed do (
        DestroyDialog nameToolSettingRollout
    )
)
