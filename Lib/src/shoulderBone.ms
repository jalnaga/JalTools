struct _ShoulderBone (
    name, anim, helper, bone, const,

    boneArray = #(),
    helperArray = #(),

    fn create_bones inClavicle inUpperArm inForeArm inStart inEnd inTwist0 inTwist1 autoClavicle:undefined = (
        boneArray = #()
        helperArray = #()

        local shoulderName = name.replace_realName inClavicle.name "Shoulder"

        local clavicleLength = distance inClavicle inUpperArm
        local shoulderRotHelper = helper.create_point (name.replace_type shoulderName "Rot")
        local upperArmTargetHelper = helper.create_point (name.replace_type shoulderName "T")

        shoulderRotHelper.transform = inClavicle.transform
        upperArmTargetHelper.transform = inUpperArm.transform
        anim.move_local upperArmTargetHelper clavicleLength 0.0 0.0
        shoulderRotHelper.parent = inClavicle
        upperArmTargetHelper.parent = inUpperArm

        --const.assign_lookat_multi shoulderRotHelper #(inUpperArm, upperArmTargetHelper)
        const.assign_lookat shoulderRotHelper upperArmTargetHelper
        shoulderRotHelper.rotation.controller[2].pickUpNode = inClavicle
        shoulderRotHelper.rotation.controller[2].upnode_world = false
        shoulderRotHelper.rotation.controller[2].lookat_vector_length = 0.0

        local shoulderRotCopyHelper = helper.create_point (name.add_sufix_to_realName shoulderRotHelper.name "Transfer")
        shoulderRotCopyHelper.transform = inUpperArm.transform
        if autoClavicle != undefined then shoulderRotCopyHelper.parent = autoClavicle
        else shoulderRotHelper.parent = inClavicle
        const.assign_rot_const shoulderRotCopyHelper shoulderRotHelper

        local shoulderBones = bone.create_bone #(inStart, inEnd) shoulderName delPoint:false parent:false size:2

        local shoulderLookatTargetHelper = helper.create_point (name.add_sufix_to_realName upperArmTargetHelper.name "Tip")
        shoulderLookatTargetHelper.transform = shoulderBones[1].transform
        anim.move_local shoulderLookatTargetHelper (distance inUpperArm inForeArm) 0.0 0.0
        shoulderLookatTargetHelper.parent = inTwist1

        local shoulderLookatUpHelper = helper.create_point (name.replace_type shoulderRotHelper.name "UpN")
        shoulderLookatUpHelper.transform = inTwist1.transform
        shoulderLookatUpHelper.parent = inUpperArm
        const.assign_rot_const_multi shoulderLookatUpHelper #(inTwist0, inTwist1)
        shoulderLookatUpHelper.rotation.controller[2].setWeight 1 70.0
        shoulderLookatUpHelper.rotation.controller[2].setWeight 2 30.0

        shoulderBones[1].parent = shoulderRotCopyHelper
        const.assign_lookat shoulderBones[1] shoulderLookatTargetHelper
        shoulderBones[1].rotation.controller[2].upnode_world = false
        --shoulderBones[1].rotation.controller[2].pickUpNode = inClavicle
        shoulderBones[1].rotation.controller[2].pickUpNode = shoulderLookatUpHelper
        shoulderBones[1].rotation.controller[2].lookat_vector_length = 0.0

        boneArray = deepCopy shoulderBones
        append helperArray shoulderRotHelper
        append helperArray upperArmTargetHelper
        append helperArray shoulderRotCopyHelper
        append helperArray shoulderLookatTargetHelper
        append helperArray shoulderLookatUpHelper

        boneArray
    )
)