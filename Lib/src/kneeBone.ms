struct _KneeBone (
    name, anim, helper, bone, const, bip,

    boneSize = 2.0,

    fn create_lift_bones inThigh inCalf inFoot = (
        select inThigh
        local reverseRotHelper = (helper.create_helper())[1]
        reverseRotHelper.name = name.replace_type reverseRotHelper.name "Rot"
        reverseRotHelper.name = name.replace_realName reverseRotHelper.name "KneeReverse"
        reverseRotHelper.parent = inThigh
        local reverseRotLookAt = const.assign_lookat reverseRotHelper inFoot
        reverseRotLookAt.upnode_world = false
        reverseRotLookAt.pickUpNode = inThigh
        reverseRotLookAt.lookat_vector_length = 0.0

        local tempHelperA = point()
        local tempHelperB = point()
        tempHelperA.transform = inThigh.transform
        tempHelperB.transform = inCalf.transform
        local thighLiftBoneName = name.add_sufix_to_realName inThigh.name "Lift"
        local thighLiftBones = bone.create_bone #(tempHelperA, tempHelperB) thighLiftBoneName end:true delPoint:true parent:false size:boneSize
        local tempLookAt = const.assign_lookat thighLiftBones[1] inCalf
        tempLookAt.upnode_world  = false
        tempLookAt.pickUpNode = inThigh
        const.collapse thighLiftBones[1]
        anim.rotate_local thighLiftBones[1] 180 0 0
        thighLiftBones[1].parent = inThigh

        tempHelperA = point()
        tempHelperB = point()
        tempHelperA.transform = inFoot.transform
        tempHelperB.transform = inCalf.transform
        local calfLiftBoneName = name.add_sufix_to_realName inCalf.name "Lift"
        local calfLiftBones = bone.create_bone #(tempHelperA, tempHelperB) calfLiftBoneName end:true delPoint:true parent:false size:boneSize
        tempLookAt = const.assign_lookat calfLiftBones[1] inThigh
        tempLookAt.upnode_world = false
        tempLookAt.pickUpNode = inCalf
        const.collapse calfLiftBones[1]
        calfLiftBones[1].parent = inCalf

        local thighLiftRotConst = const.assign_rot_const thighLiftBones[1] reverseRotHelper
        thighLiftRotConst.local_world = 1
        thighLiftRotConst.appendTarget world 95
        thighLiftRotConst.setWeight 1 7
        thighLiftRotConst.setWeight 2 93

        local calfLiftRotConst = const.assign_rot_const calfLiftBones[1] reverseRotHelper
        calfLiftRotConst.local_world = 1
        calfLiftRotConst.appendTarget world 92
        calfLiftRotConst.setWeight 1 10
        calfLiftRotConst.setWeight 2 90

        #(thighLiftBones, calfLiftBones)
    ),

    /*fn create_mid_bone inHamStart inHamEnd inThighLiftBones inCalfLiftBones = (
        local hamBoneName = name.replace_realName inThighLiftBones[1].name "Knee"
        local hamBoneArray = bone.create_bone #(inHamStart, inHamEnd) hamBoneName delPoint:false size:boneSize
        
        local tempHelperA = point()
        tempHelperA.transform = hamBoneArray[2].transform
        local tempLookAt = const.assign_lookat hamBoneArray[1] tempHelperA
        tempLookAt.upnode_world = false
        tempLookAt.pickUpNode = inCalfLiftBones[1].parent
        const.collapse hamBoneArray[1]
        delete tempHelperA

        hamBoneArray[1].parent = inCalfLiftBones[1].parent
        
        select hamBoneArray[1]
        local hamPosHelperArray = helper.create_helper makeTwo:true
        hamPosHelperArray[1].parent = inCalfLiftBones[1].parent
        hamPosHelperArray[2].parent = inCalfLiftBones[1]
        local hamPosConst = const.assign_pos_const_multi hamBoneArray[1] hamPosHelperArray
        local hamLookAtConst = const.assign_lookat_multi hamBoneArray[1] #(inThighLiftBones[2], inCalfLiftBones[2])
        hamBoneArray[1].rotation.controller[2].setWeight 1 70
        hamBoneArray[1].rotation.controller[2].setWeight 2 30
        hamBoneArray[1].rotation.controller[2].upnode_world = false
        hamBoneArray[1].rotation.controller[2].pickUpNode = inCalfLiftBones[1].parent
        hamBoneArray[1].rotation.controller[2].lookat_vector_length = 0.0

        hamBoneArray
    ),*/

    fn create_mid_bone inHamStart inHamEnd inThighLiftBones inCalfLiftBones = (
        local hamBoneName = name.replace_realName inThighLiftBones[1].name "Knee"
        hamBoneName = name.remove_index hamBoneName
        local hamBoneArray = bone.create_bone #(inHamStart, inHamEnd) hamBoneName delPoint:false size:boneSize
        
        local tempHelperA = point()
        tempHelperA.transform = hamBoneArray[2].transform
        local tempLookAt = const.assign_lookat hamBoneArray[1] tempHelperA
        tempLookAt.upnode_world = false
        tempLookAt.pickUpNode = inCalfLiftBones[1].parent
        const.collapse hamBoneArray[1]
        delete tempHelperA

        hamBoneArray[1].parent = inCalfLiftBones[1].parent
        
        select hamBoneArray[1]
        local hamPosHelperArray = helper.create_helper makeTwo:true
        hamPosHelperArray[1].parent = inCalfLiftBones[1].parent
        hamPosHelperArray[2].parent = inCalfLiftBones[1]

        local hamRootHelper = helper.create_point (name.replace_type hamBoneArray[1].name "Dum")
        hamRootHelper.transform = hamBoneArray[1].transform
        hamRootHelper.parent = inCalfLiftBones[1].parent

        const.assign_pos_const_multi hamRootHelper hamPosHelperArray
        const.assign_rot_const_multi hamRootHelper #(inThighLiftBones[1].parent, inCalfLiftBones[1].parent)
        hamRootHelper.position.controller[2].setWeight 1 70
        hamRootHelper.position.controller[2].setWeight 2 30
        hamRootHelper.rotation.controller[2].setWeight 1 60
        hamRootHelper.rotation.controller[2].setWeight 2 40


        hamBoneArray[1].parent = hamRootHelper

        hamBoneArray
    ),

    fn create_bones inThigh inCalf inFoot inHamStart inHamEnd = (
        local returnArray = #()
        local liftBones = (create_lift_bones inThigh inCalf inFoot)
        local midBones = (create_mid_bone inHamStart inHamEnd liftBones[1] liftBones[2])

        for item in liftBones[1] do append returnArray item
        for item in liftBones[2] do append returnArray item
        for item in midBones do append returnArray item

        returnArray
    )
)