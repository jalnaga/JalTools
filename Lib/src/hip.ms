struct _Hip (
    name, anim, helper, bone, const, bip,
    
    baseName = "",
    filteringChar = " ",

    boneSize = 2.0,

    boneArray = #(),
    rotDir = [0.0, 0.0, -1.0],

    pelvisWeight = 60.0,
    thighWeight = 40.0,

    xAxisOffset = 0.1,

    spineDummy,
    lHipDummy,
    lHipTargetDummy,
    lHipExp,
    rHipDummy,
    rHipTargetDummy,
    rHipExp,

    pelvis,
    spine,
    lThigh,
    lThighTwist,
    rThigh,
    rThighTwist,

    helperArray = #(),

    fn init inBip inLThighTwist inRThighTwist inBaseName inFilteringChar:" " inXAxisOffset:0.1 inRotDir:[0.0, 0.0, -1.0] inPelvisWeight:60.0 inThighWeight:40.0 inBoneSize:2.0 = (
        baseName = inBaseName
        filteringChar = inFilteringChar
        boneSize = inBoneSize
        xAxisOffset = inXAxisOffset
        rotDir = inRotDir

        pelvisWeight = inPelvisWeight
        thighWeight = inThighWeight

        pelvis = inBip.pelvis
        spine = inBip.spine
        lThigh = inBip.lThigh
        rThigh = inBip.rThigh
        lThighTwist = inLThighTwist
        rThighTwist = inRThighTwist

        boneArray = #()
        helperArray = #()
    ),

    fn assign_position_script inObj inExp inScale:"0.1" = (
        local posScript = position_script()
        inObj.position.controller = position_list()
        inObj.position.controller.available.controller = posScript

        posScript.AddNode "exp" inExp
        local scriptStr = ""
        scriptStr += "zRotValue = amin 0.0 exp.localEulerZ\n"
        scriptStr += "result = [0, zRotValue * " + inScale + ", 0]\n"
        scriptStr += "result"

        posScript.SetExpression scriptStr
        posScript.Update()

        const.set_active_last inObj
    ),

    fn update_position_script_scale_value inObj inVal = (
        local posScript = inObj.position.controller[2]
        local newScale = inVal as String
        local scriptStr = ""
        scriptStr += "zRotValue = amin 0.0 exp.localEulerZ\n"
        scriptStr += "result = [0, zRotValue * " + newScale + ", 0]\n"
        scriptStr += "result"
        posScript.SetExpression scriptStr
        posScript.Update()
    ),

    fn gen_helpers = (
        spineDummy = helper.create_point (name.combine baseName "Dum" "" "HipSpine" "0" filteringChar) boxToggle:on crossToggle:off axisToggle:off
        
        lHipDummy = helper.create_point (name.combine baseName "Dum" "L" "Hip" "0" filteringChar) boxToggle:on crossToggle:off axisToggle:off
        lHipTargetDummy = helper.create_point (name.combine baseName "Dum" "L" "HipTgt" "0" filteringChar) boxToggle:off crossToggle:on axisToggle:off
        lHipExp = ExposeTm name:(name.combine baseName "Exp" "L" "Hip" "0" filteringChar) size:1 boxToggle:on crossToggle:off wirecolor:(color 14 255 2)
        rHipDummy = helper.create_point (name.combine baseName "Dum" "R" "Hip" "0" filteringChar) boxToggle:on crossToggle:off axisToggle:off
        rHipTargetDummy = helper.create_point (name.combine baseName "Dum" "R" "HipTgt" "0" filteringChar) boxToggle:off crossToggle:on axisToggle:off
        rHipExp = ExposeTm name:(name.combine baseName "Exp" "R" "Hip" "0" filteringChar) size:1 boxToggle:on crossToggle:off wirecolor:(color 14 255 2)

        helperArray = #()
        append helperArray spineDummy
        append helperArray lHipDummy
        append helperArray lHipTargetDummy
        append helperArray lHipExp
        append helperArray rHipDummy
        append helperArray rHipTargetDummy
        append helperArray rHipExp
        return helperArray
    ),

    fn create = (
        gen_helpers()

        lHipDummy.transform = lThighTwist.transform
        rHipDummy.transform = rThighTwist.transform

        const.assign_pos_const spineDummy spine
        const.assign_rot_const_multi spineDummy #(lThighTwist, rThighTwist)
        const.collapse spineDummy

        lHipDummy.parent = pelvis
        lHipTargetDummy.parent = pelvis
        lHipExp.parent = pelvis
        rHipDummy.parent = pelvis
        rHipTargetDummy.parent = pelvis
        rHipExp.parent = pelvis
        spineDummy.parent = pelvis

        lHipDummy.rotation.controller = Orientation_Constraint()
        lHipDummy.rotation.controller.appendTarget spineDummy pelvisWeight
        lHipDummy.rotation.controller.appendTarget lThighTwist thighWeight
        lHipDummy.rotation.controller.relative = true
        
        rHipDummy.rotation.controller = Orientation_Constraint()
        rHipDummy.rotation.controller.appendTarget spineDummy pelvisWeight
        rHipDummy.rotation.controller.appendTarget rThighTwist thighWeight
        rHipDummy.rotation.controller.relative = true

        lHipTargetDummy.transform = lHipDummy.transform
        lHipExp.transform = lHipDummy.transform
        rHipTargetDummy.transform = rHipDummy.transform
        rHipExp.transform = rHipDummy.transform

        lHipExp.exposeNode = lHipDummy
        lHipExp.localReferenceNode = lHipTargetDummy
        lHipExp.useParent = false

        rHipExp.exposeNode = rHipDummy
        rHipExp.localReferenceNode = rHipTargetDummy
        rHipExp.useParent = false

        boneArray = #()

        local lHipBone = bone.create_simple_bone (boneSize * 2) (name.combine baseName "" "L" "Hip" "" filteringChar) size:boneSize
        lHipBone[1].transform = lThigh.transform
        anim.rotate_local lHipBone[1] (rotDir.x * 0) (rotDir.y * 0) (rotDir.z * 90)
        lHipBone[1].parent = lHipDummy
        append boneArray lHipBone[1]
        append boneArray lHipBone[2]
        
        local rHipBone = bone.create_simple_bone (boneSize * 2) (name.combine baseName "" "R" "Hip" "" filteringChar) size:boneSize
        rHipBone[1].transform = rThigh.transform
        anim.rotate_local rHipBone[1] (rotDir.x * 0) (rotDir.y * 0) (rotDir.z * 90)
        rHipBone[1].parent = rHipDummy
        append boneArray rHipBone[1]
        append boneArray rHipBone[2]

        assign_position_script lHipBone[1] lHipExp inScale:(xAxisOffset as string)
        assign_position_script rHipBone[1] rHipExp inScale:(xAxisOffset as string)
    ),

    fn delAll = (
        bone.delete_bones_safely boneArray
        bone.delete_bones_safely helperArray
    ),

    fn set_weight inPelvisWeight inThighWeight = (
        delAll()
        pelvisWeight = inPelvisWeight
        thighWeight = inThighWeight

        create()
    )
)
