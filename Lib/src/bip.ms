struct _Bip (
    rootName = "",

    com,
    head,
    neck,

    lClavicle,
    lUpperArm,
    lUpperArmTwist,
    lUpperArmTwist1,
    lUpperArmTwist2,
    lUpperArmTwist3,
    lUpperArmTwist4,
    lUpperArmTwist5,
    lUpperArmTwist6,
    lUpperArmTwist7,
    lUpperArmTwist8,
    lUpperArmTwist9,
    lForeArm,
    lForeArmTwist,
    lForeArmTwist1,
    lForeArmTwist2,
    lForeArmTwist3,
    lForeArmTwist4,
    lForeArmTwist5,
    lForeArmTwist6,
    lForeArmTwist7,
    lForeArmTwist8,
    lForeArmTwist9,
    lHand,

    rClavicle,
    rUpperArm,
    rUpperArmTwist,
    rUpperArmTwist1,
    rUpperArmTwist2,
    rUpperArmTwist3,
    rUpperArmTwist4,
    rUpperArmTwist5,
    rUpperArmTwist6,
    rUpperArmTwist7,
    rUpperArmTwist8,
    rUpperArmTwist9,
    rForeArm,
    rForeArmTwist,
    rForeArmTwist1,
    rForeArmTwist2,
    rForeArmTwist3,
    rForeArmTwist4,
    rForeArmTwist5,
    rForeArmTwist6,
    rForeArmTwist7,
    rForeArmTwist8,
    rForeArmTwist9,
    rHand,
    
    spine,
    spine1,
    spine2,
    spine3,
    spine4,
    pelvis,
    
    lThigh,
    lCalf,
    lFoot,
    lThighTwist,
    lThighTwist1,
    lThighTwist2,
    lThighTwist3,
    lThighTwist4,
    lThighTwist5,
    lThighTwist6,
    lThighTwist7,
    lThighTwist8,
    lThighTwist9,
    lCalfTwist,
    lCalfTwist1,
    lCalfTwist2,
    lCalfTwist3,
    lCalfTwist4,
    lCalfTwist5,
    lCalfTwist6,
    lCalfTwist7,
    lCalfTwist8,
    lCalfTwist9,

    rThigh,
    rCalf,
    rFoot,
    rThighTwist,
    rThighTwist1,
    rThighTwist2,
    rThighTwist3,
    rThighTwist4,
    rThighTwist5,
    rThighTwist6,
    rThighTwist7,
    rThighTwist8,
    rThighTwist9,
    rCalfTwist,
    rCalfTwist1,
    rCalfTwist2,
    rCalfTwist3,
    rCalfTwist4,
    rCalfTwist5,
    rCalfTwist6,
    rCalfTwist7,
    rCalfTwist8,
    rCalfTwist9,

    fn reset_private_variables = (
        com = undefined
        head = undefined
        neck = undefined
        lClavicle = undefined
        lUpperArm = undefined
        lUpperArmTwist = undefined
        lUpperArmTwist1 = undefined
        lUpperArmTwist2 = undefined
        lUpperArmTwist3 = undefined
        lUpperArmTwist4 = undefined
        lUpperArmTwist5 = undefined
        lUpperArmTwist6 = undefined
        lUpperArmTwist7 = undefined
        lUpperArmTwist8 = undefined
        lUpperArmTwist9 = undefined
        lForeArm = undefined
        lForeArmTwist = undefined
        lForeArmTwist1 = undefined
        lForeArmTwist2 = undefined
        lForeArmTwist3 = undefined
        lForeArmTwist4 = undefined
        lForeArmTwist5 = undefined
        lForeArmTwist6 = undefined
        lForeArmTwist7 = undefined
        lForeArmTwist8 = undefined
        lForeArmTwist9 = undefined
        lHand = undefined
        rClavicle = undefined
        rUpperArm = undefined
        rUpperArmTwist = undefined
        rUpperArmTwist1 = undefined
        rUpperArmTwist2 = undefined
        rUpperArmTwist3 = undefined
        rUpperArmTwist4 = undefined
        rUpperArmTwist5 = undefined
        rUpperArmTwist6 = undefined
        rUpperArmTwist7 = undefined
        rUpperArmTwist8 = undefined
        rUpperArmTwist9 = undefined
        rForeArm = undefined
        rForeArmTwist = undefined
        rForeArmTwist1 = undefined
        rForeArmTwist2 = undefined
        rForeArmTwist3 = undefined
        rForeArmTwist4 = undefined
        rForeArmTwist5 = undefined
        rForeArmTwist6 = undefined
        rForeArmTwist7 = undefined
        rForeArmTwist8 = undefined
        rForeArmTwist9 = undefined
        rHand = undefined
        spine = undefined
        spine1 = undefined
        spine2 = undefined
        spine3 = undefined
        spine4 = undefined
        pelvis = undefined
        lThigh = undefined
        lCalf = undefined
        lFoot = undefined
        lThighTwist = undefined
        lThighTwist1 = undefined
        lThighTwist2 = undefined
        lThighTwist3 = undefined
        lThighTwist4 = undefined
        lThighTwist5 = undefined
        lThighTwist6 = undefined
        lThighTwist7 = undefined
        lThighTwist8 = undefined
        lThighTwist9 = undefined
        lCalfTwist = undefined
        lCalfTwist1 = undefined
        lCalfTwist2 = undefined
        lCalfTwist3 = undefined
        lCalfTwist4 = undefined
        lCalfTwist5 = undefined
        lCalfTwist6 = undefined
        lCalfTwist7 = undefined
        lCalfTwist8 = undefined
        lCalfTwist9 = undefined
        rThigh = undefined
        rCalf = undefined
        rFoot = undefined
        rThighTwist = undefined
        rThighTwist1 = undefined
        rThighTwist2 = undefined
        rThighTwist3 = undefined
        rThighTwist4 = undefined
        rThighTwist5 = undefined
        rThighTwist6 = undefined
        rThighTwist7 = undefined
        rThighTwist8 = undefined
        rThighTwist9 = undefined
        rCalfTwist = undefined
        rCalfTwist1 = undefined
        rCalfTwist2 = undefined
        rCalfTwist3 = undefined
        rCalfTwist4 = undefined
        rCalfTwist5 = undefined
        rCalfTwist6 = undefined
        rCalfTwist7 = undefined
        rCalfTwist8 = undefined
        rCalfTwist9 = undefined
    ),

    fn get_bips = (
        local returnArray = for i in objects where isKindOf i Biped_Object collect i
        return returnArray
    ),

    fn get_bip_coms_name = (
        local bips = get_bips()
        local bipComsName = #()
        for obj in bips do appendIfUnique bipComsName obj.controller.rootName

        return bipComsName
    ),

    fn get_bip_nodes inBip = (
        if (classOf inBip) != Biped_Object then return false

        reset_private_variables()

        local returnNubs = #()
        local nn = biped.maxNumNodes inBip
        local nl = biped.maxNumLinks inBip
        for i = 1 to nn do (
            anode = biped.getNode inBip i
            if anode != undefined do (
                for j = 1 to nl do (
                    alink = biped.getNode inBip i link:j
                    if alink != undefined then append returnNubs alink
                )
            )
        )

        com = inBip.controller.rootNode
        rootName = com.controller.rootName
        head = biped.getNode com 11
        neck = biped.getNode com 17 link:1

        lClavicle = biped.getNode com #larm link:1
        lUpperArm = biped.getNode com #larm link:2
        lUpperArmTwist = biped.getNode com #lUparmTwist link:1
        lUpperArmTwist1 = biped.getNode com #lUparmTwist link:2
        lUpperArmTwist2 = biped.getNode com #lUparmTwist link:3
        lUpperArmTwist3 = biped.getNode com #lUparmTwist link:4
        lUpperArmTwist4 = biped.getNode com #lUparmTwist link:5
        lUpperArmTwist5 = biped.getNode com #lUparmTwist link:6
        lUpperArmTwist6 = biped.getNode com #lUparmTwist link:7
        lUpperArmTwist7 = biped.getNode com #lUparmTwist link:8
        lUpperArmTwist8 = biped.getNode com #lUparmTwist link:9
        lUpperArmTwist9 = biped.getNode com #lUparmTwist link:10
        lForeArm = biped.getNode com #larm link:3
        lForeArmTwist = biped.getNode com #lfArmTwist  link:1
        lForeArmTwist1 = biped.getNode com #lfArmTwist  link:2
        lForeArmTwist2= biped.getNode com #lfArmTwist  link:3
        lForeArmTwist3 = biped.getNode com #lfArmTwist  link:4
        lForeArmTwist4 = biped.getNode com #lfArmTwist  link:5
        lForeArmTwist5 = biped.getNode com #lfArmTwist  link:6
        lForeArmTwist6 = biped.getNode com #lfArmTwist  link:7
        lForeArmTwist7 = biped.getNode com #lfArmTwist  link:8
        lForeArmTwist8 = biped.getNode com #lfArmTwist  link:9
        lForeArmTwist9 = biped.getNode com #lfArmTwist  link:10
        lHand = biped.getNode com #larm link:4

        rClavicle = biped.getNode com #rarm link:1
        rUpperArm = biped.getNode com #rarm link:2
        rUpperArmTwist = biped.getNode com #rUparmTwist link:1
        rUpperArmTwist1 = biped.getNode com #rUparmTwist link:2
        rUpperArmTwist2 = biped.getNode com #rUparmTwist link:3
        rUpperArmTwist3 = biped.getNode com #rUparmTwist link:4
        rUpperArmTwist4 = biped.getNode com #rUparmTwist link:5
        rUpperArmTwist5 = biped.getNode com #rUparmTwist link:6
        rUpperArmTwist6 = biped.getNode com #rUparmTwist link:7
        rUpperArmTwist7 = biped.getNode com #rUparmTwist link:8
        rUpperArmTwist8 = biped.getNode com #rUparmTwist link:9
        rUpperArmTwist9 = biped.getNode com #rUparmTwist link:10
        rForeArm = biped.getNode com #rarm link:3
        rForeArmTwist = biped.getNode com #rfArmTwist  link:1
        rForeArmTwist1 = biped.getNode com #rfArmTwist  link:2
        rForeArmTwist2= biped.getNode com #rfArmTwist  link:3
        rForeArmTwist3 = biped.getNode com #rfArmTwist  link:4
        rForeArmTwist4 = biped.getNode com #rfArmTwist  link:5
        rForeArmTwist5 = biped.getNode com #rfArmTwist  link:6
        rForeArmTwist6 = biped.getNode com #rfArmTwist  link:7
        rForeArmTwist7 = biped.getNode com #rfArmTwist  link:8
        rForeArmTwist8 = biped.getNode com #rfArmTwist  link:9
        rForeArmTwist9 = biped.getNode com #rfArmTwist  link:10
        rHand = biped.getNode com #rarm link:4
        
        spine = biped.getNode com #spine link:1
        spine1 = biped.getNode com #spine link:2
        spine2 = biped.getNode com #spine link:3
        spine3 = biped.getNode com #spine link:4
        spine4 = biped.getNode com #spine link:5
        pelvis = biped.getNode com 12
        
        lThigh = biped.getNode com #lleg linke:1
        lCalf = biped.getNode com #lleg linke:2
        lFoot = biped.getNode com #lleg linke:4
        lThighTwist = biped.getNode com #lThighTwist link:1
        lThighTwist1 = biped.getNode com #lThighTwist link:2
        lThighTwist2 = biped.getNode com #lThighTwist link:3
        lThighTwist3 = biped.getNode com #lThighTwist link:4
        lThighTwist4 = biped.getNode com #lThighTwist link:5
        lThighTwist5 = biped.getNode com #lThighTwist link:6
        lThighTwist6 = biped.getNode com #lThighTwist link:7
        lThighTwist7 = biped.getNode com #lThighTwist link:8
        lThighTwist8 = biped.getNode com #lThighTwist link:9
        lThighTwist9 = biped.getNode com #lThighTwist link:10
        lCalfTwist = biped.getNode com #lCalfTwist link:1
        lCalfTwist1 = biped.getNode com #lCalfTwist link:2
        lCalfTwist2 = biped.getNode com #lCalfTwist link:3
        lCalfTwist3 = biped.getNode com #lCalfTwist link:4
        lCalfTwist4 = biped.getNode com #lCalfTwist link:5
        lCalfTwist5 = biped.getNode com #lCalfTwist link:6
        lCalfTwist6 = biped.getNode com #lCalfTwist link:7
        lCalfTwist7 = biped.getNode com #lCalfTwist link:8
        lCalfTwist8 = biped.getNode com #lCalfTwist link:9
        lCalfTwist9 = biped.getNode com #lCalfTwist link:10

        rThigh = biped.getNode com #rleg linke:1
        rCalf = biped.getNode com #rleg linke:2
        rFoot = biped.getNode com #rleg linke:4
        rThighTwist = biped.getNode com #rThighTwist link:1
        rThighTwist1 = biped.getNode com #rThighTwist link:2
        rThighTwist2 = biped.getNode com #rThighTwist link:3
        rThighTwist3 = biped.getNode com #rThighTwist link:4
        rThighTwist4 = biped.getNode com #rThighTwist link:5
        rThighTwist5 = biped.getNode com #rThighTwist link:6
        rThighTwist6 = biped.getNode com #rThighTwist link:7
        rThighTwist7 = biped.getNode com #rThighTwist link:8
        rThighTwist8 = biped.getNode com #rThighTwist link:9
        rThighTwist9 = biped.getNode com #rThighTwist link:10
        rCalfTwist = biped.getNode com #rCalfTwist link:1
        rCalfTwist1 = biped.getNode com #rCalfTwist link:2
        rCalfTwist2 = biped.getNode com #rCalfTwist link:3
        rCalfTwist3 = biped.getNode com #rCalfTwist link:4
        rCalfTwist4 = biped.getNode com #rCalfTwist link:5
        rCalfTwist5 = biped.getNode com #rCalfTwist link:6
        rCalfTwist6 = biped.getNode com #rCalfTwist link:7
        rCalfTwist7 = biped.getNode com #rCalfTwist link:8
        rCalfTwist8 = biped.getNode com #rCalfTwist link:9
        rCalfTwist9 = biped.getNode com #rCalfTwist link:10

        return returnNubs
    ),
    
    fn get_com inBip = (
        get_bip_nodes inBip
        return com
    ),

    fn get_com_name inBip = (
        get_bip_nodes inBip
        return rootName
    ),

    fn get_bip_nub_helpers inBip = (
        local returnNubs = #()
        local nn = biped.maxNumNodes inBip
        local nl = biped.maxNumLinks inBip
        for i = 1 to nn do (
            anode = biped.getNode inBip i
            if anode != undefined do (
                for j = 1 to nl do (
                    alink = biped.getNode inBip i link:j
                    if alink != undefined then (
                        if (alink.children.count == 1) and (classof alink.children[1] == Dummy) then append returnNubs alink.children[1]
                    )
                )
            )
        )

        return returnNubs
    ),

    fn get_bip_coms = (
        local bipComsName = get_bip_coms_name()
        local bipComs = for objName in bipComsName collect (getNodeByName objName)
        return bipComs
    ),

    fn get_bip_coms_num = (
        local bipComsName = get_bip_coms_name()
        return bipComsName.count
    ),

    fn get_twist_bone_number inBip = (
        local returnArray = #()
        append returnArray inBip.controller.upperarmTwistLinks
        append returnArray inBip.controller.forearmTwistLinks
        append returnArray inBip.controller.thighTwistLinks
        append returnArray inBip.controller.calfTwistLinks
        append returnArray inBip.controller.horseTwistLinks

        return returnArray
    ),

    fn add_scale_controller_to_bipNode bipObj = (
        bipObj.transform.controller.Biped_SubAnim.controller.BipScaleList.controller.Available.controller = ScaleXYZ ()
        setTransformLockFlags bipObj #{8,9}
    ),

    fn set_bipObj_scale bipObj inputScaleVal = (
        bipObj.transform.controller.Biped_SubAnim.controller.BipScaleList.ScaleXYZ.value = inputScaleVal
    ),

    fn get_bipObj_scale bipObj = (
        local returnScale = bipObj.transform.controller.Biped_SubAnim.controller.BipScaleList.ScaleXYZ.value

        return returnScale
    ),

    fn create_bip = (
        local bipObj = biped.createNew 180 -90 [0, 0, 172.627] arms:true neckLinks:1 \ 
        spineLinks:3 legLinks:3 fingers:5 fingerLinks:3 toes:1 toeLinks:1 \ 
        ankleAttach:0.2 trianglePelvis:false triangleNeck:true \ 
        forearmTwistLinks:3 upperarmTwistLinks:3 thighTwistLinks:3 calfTwistLinks:3

        get_bip_nodes bipObj
    ),

    fn turn_on_figureMode inBip = (
        inBip.controller.figureMode = true
    ),

    fn turn_off_figureMode inBip = (
        inBip.controller.figureMode = false
    )
)
