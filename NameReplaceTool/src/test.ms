(
    local selObj = getCurrentSelection() as Array
    local helperArray = for item in selObj where (classOf item == Point) collect item
    local boneArray = for item in selObj where (classOf item == BoneGeometry) collect item
    for i = 1 to boneArray.count do (
        local boneObjName = jal.name.remove_type boneArray[i].name
        boneObjName += "_*"
        local helperObj = undefined
        for k = 1 to helperArray.count do (
            if (matchPattern helperArray[k].name pattern:boneObjName) then helperObj = helperArray[k]
        )
        jal.const.assign_pos_const boneArray[i] helperObj
    )
)

/*(
    local selObj = getCurrentSelection() as Array
    clearSelection()
    local helperArray = for item in selObj where (classOf item == Point) collect item
    local boneArray = for item in selObj where (classOf item == BoneGeometry) collect item
    local duplicatedObjArray = #()
    for i = 1 to boneArray.count-1 do (
        for k = (i+1) to boneArray.count do (
            if (matchPattern boneArray[k].name pattern:boneArray[i].name) then (
                append duplicatedObjArray boneArray[i]
                append duplicatedObjArray boneArray[k]
            )
        )
    )
    select duplicatedObjArray
)*/
