struct _ChestBone (
    name, anim, helper, bone, const,

    boneArray = #(),
    heleperArray = #(),

    fn create_bones inSpine inTwist0 inFigureStart inFigureEnd inBack = (
        local pectoralName = name.replace_realName inTwist0.name "PectoralU"
        pectoralName = name.remove_index pectoralName
        local chestName = name.replace_realName inTwist0.name "PectoralD"
        chestName = name.remove_index chestName

        local tempHelperA = point()
        local tempHelperB = point()
        tempHelperA.transform = inFigureStart.transform
        tempHelperB.transform = inFigureStart.transform
        anim.move_local tempHelperB ((distance inFigureStart inFigureEnd)*0.8) 0.0 0.0

        local pectoralBoneArray = bone.create_bone #(tempHelperA, tempHelperB) pectoralName delPoint:false

        local pectoralRootHelper = helper.create_point (name.replace_type pectoralName "T")
        pectoralRootHelper.transform = pectoralBoneArray[1].transform
        pectoralRootHelper.parent = inTwist0
        
        local frontHelper = helper.create_point (name.replace_type chestName "T")
        frontHelper.transform = inBack.transform
        frontHelper.pos.y = inFigureEnd.transform.position.y
        frontHelper.parent = inSpine

        local chestBoneArray = bone.create_bone #(frontHelper, tempHelperB) chestName delPoint:false

        local chestMidHelper = helper.create_point (name.replace_type chestName "Dum")
        chestMidHelper.transform = pectoralBoneArray[2].transform
        const.assign_rot_const_multi chestMidHelper #(pectoralBoneArray[2], chestBoneArray[2])
        const.collapse chestMidHelper

        local backHelper = helper.create_point (name.replace_type chestName "Lat")
        backHelper.transform = inBack.transform
        backHelper.parent = inSpine
        const.assign_lookat_multi backHelper #(pectoralRootHelper, frontHelper)
        backHelper.rotation.controller[2].setWeight 1 40
        backHelper.rotation.controller[2].setWeight 2 60
        backHelper.rotation.controller[2].lookat_vector_length = 0.0
        backHelper.rotation.controller[2].pickUpNode = inSpine
        backHelper.rotation.controller[2].upnode_world = false

        chestMidHelper.parent = backHelper

        chestBoneArray[1].parent = frontHelper
        pectoralBoneArray[1].parent = pectoralRootHelper

        const.assign_lookat pectoralBoneArray[1] chestMidHelper
        pectoralBoneArray[1].rotation.controller[2].lookat_vector_length = 0.0
        pectoralBoneArray[1].rotation.controller[2].pickUpNode = inSpine
        pectoralBoneArray[1].rotation.controller[2].upnode_world = false

        const.assign_lookat chestBoneArray[1] chestMidHelper
        chestBoneArray[1].rotation.controller[2].lookat_vector_length = 0.0
        chestBoneArray[1].rotation.controller[2].pickUpNode = inSpine
        chestBoneArray[1].rotation.controller[2].upnode_world = false

        delete #(tempHelperA, tempHelperB)

        boneArray = #(pectoralBoneArray[1], pectoralBoneArray[2], chestBoneArray[1], chestBoneArray[2])
        heleperArray = #(backHelper, pectoralRootHelper, frontHelper, chestMidHelper)

        #(boneArray, heleperArray)
    )
)