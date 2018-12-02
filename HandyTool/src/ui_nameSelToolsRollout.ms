rollout nameSelToolsRollout "Name Select" (
    button renameToolOpenBtn "Tool" align:#left across:2 offset:[0, -2]
    editText findNameTxt "" align:#left offset:[-40, 0]
    checkbutton fuzzToggleBtn "Fz." checked:true align:#right offset:[0, -27]
    multiListBox nameListLst "Selected Objects:" height:4

    local findedObjNameArray = #()
    local namePattern = "*"

    fn gen_namePattern inTxt = (
        local returnNamePattern = "*"
        for i = 1 to inTxt.count do (
            returnNamePattern += inTxt[i]
            returnNamePattern += "*"
        )

        returnNamePattern
    )

    fn refill_nameList_with_nodes = (
        findedObjNameArray = for item in objects collect item.name
        nameListLst.items = findedObjNameArray
        findNameTxt.text = ""
    )

    on nameSelToolsRollout open do (
        refill_nameList_with_nodes()
        nameListLst.selection = 0
    )

    on nameSelToolsRollout rolledUp stat do (
        if stat == false then refill_nameList_with_nodes()
    )

    on fuzzToggleBtn changed state do (
        nameListLst.selection = 0
    )

    on findNameTxt changed inTxt do (
        local enteredNamePattern = gen_namePattern inTxt

        if enteredNamePattern.count > namePattern.count then (
            namePattern = enteredNamePattern
            nameListLst.items = for item in nameListLst.items where (MatchPattern item pattern:namePattern) collect item
        )
        else (
            namePattern = enteredNamePattern
            nameListLst.items = for item in objects where (MatchPattern item.name pattern:namePattern) collect item.name
        )

        nameListLst.selection = 0
        if fuzzToggleBtn.checked then (
            local selArray = for item in nameListLst.items where (getNodeByName item) != undefined collect (getNodeByName item)
            select selArray
        )
    )

    on nameListLst selectionEnd do (
        local selNameIndexArray = nameListLst.selection as Array
        local selArray = #()
        for index in selNameIndexArray do (
            local tempNode = getNodeByName nameListLst.items[index]
            if tempNode != undefined then append selArray tempNode
        )
        select selArray
    )
)
