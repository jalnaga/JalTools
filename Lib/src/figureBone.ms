struct _FigureBone (
    name, bone, helper, anim,

    boneArray = #(),
    helperArray = #(),
    startPoint, endPoint,
    pointOriTrArray = #(), 
    figureName = "",
    size = 2.0,
    length = 4.0,
    parentBone = undefined,
    offset = [0.0, 0.0, 0.0],
    chainNum = 2,

    fn init_figure = (
        boneArray = #()
        helperArray = #()
        startPoint = undefined
        endPoint = undefined
        pointOriTrArray = #()
        figureName = ""
        size = 2.0
        length = 4.0
        parentBone = undefined
        offset = [0.0, 0.0, 0.0]
    ),

    fn create_bone inName inSize inLength inParent inOffset start:[0.0, 0.0, 0.0] end:[0.0, 0.0, 0.0] chainNum:1 = (
        init_figure()

        figureName = name.replace_base inName "Figure001"
        size = inSize
        length = inLength
        parentBone = inParent
        offset = inOffset
        boneArray = #()
        helperArray = #()
        startPoint = undefined
        endPoint = undefined

        local startPos = start
        local endPos = end

        disableSceneRedraw()

        if startPos == [0.0, 0.0, 0.0] and endPos == [0.0, 0.0, 0.0] then (
            local tempBonesArray = bone.create_simple_bone length figureName size:inSize
            tempBonesArray[1].transform = parentBone.transform
            anim.move_local tempBonesArray[1] inOffset.x inOffset.y inOffset.z

            startPos = tempBonesArray[1].pos
            endPos = tempBonesArray[2].pos

            delete tempBonesArray
        )

        local pointName = name.replace_type figureName "Dum"
        startPoint = helper.create_point (name.add_sufix_to_realName pointName "Start") pos:startPos
        endPoint = helper.create_point (name.add_sufix_to_realName pointName "End") pos:endPos
        startPointOriTr = startPoint.transform
        endPointOriTr = endPoint.transform

        append helperArray startPoint
        append pointOriTrArray startPoint.transform
        for i = 1 to (chainNum-1) do (
            local tempPoint = point()
            tempPoint.transform = startPoint.transform
            anim.move_local tempPoint (((distance startPoint endPoint) / chainNum) * i) 0 0
            local midPoint = helper.create_point (name.add_sufix_to_realName pointName ("Mid"+(i as string))) pos:tempPoint.pos
            delete tempPoint
            append helperArray midPoint
            append pointOriTrArray midPoint.transform
        )
        append helperArray endPoint
        append pointOriTrArray endPoint.transform

        redrawViews()
        enableSceneRedraw()

        boneArray = bone.create_stretch_bone helperArray figureName size:size

        return #(boneArray, helperArray, pointOriTrArray)
    ),

    fn match_figure_l_to_r inputLHelperArray inputRHelperArray = (
        for i = 1 to inputLHelperArray.count do (
            inputRHelperArray[i].pos.x = -(inputLHelperArray[i].pos.x)
            inputRHelperArray[i].pos.y = inputLHelperArray[i].pos.y
            inputRHelperArray[i].pos.z = inputLHelperArray[i].pos.z
        )
    ),

    fn match_figure_r_to_l inputLHelperArray inputRHelperArray  = (
        for i = 1 to inputLHelperArray.count do (
            inputLHelperArray[i].pos.x = -(inputRHelperArray[i].pos.x)
            inputLHelperArray[i].pos.y = inputRHelperArray[i].pos.y
            inputLHelperArray[i].pos.z = inputRHelperArray[i].pos.z
        )
    )
)