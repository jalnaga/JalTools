struct _SartoriusBone (
    name, anim, helper, bone, const,

    fn create_bones inPelvis inThigh inCalf inThighTwist inUpNode = (
        local tempAHelper = helper.create_point "TempA"
        local tempBHelper = helper.create_point "TempB"
        local thighLength = distance inThigh inCalf
        local thighStartOffset = thighLength*0.4
        local thighEndOffset = thighLength*0.2
        local sartoriusName = name.replace_realName inThigh.name "Sartorius"

        tempAHelper.transform = inThigh.transform
        tempBHelper.transform = inThigh.transform
        anim.move_local tempAHelper thighStartOffset 0.0 0.0
        anim.move_local tempBHelper -thighEndOffset 0.0 0.0
        local sartoriusBones = bone.create_bone #(tempAHelper, tempBHelper) sartoriusName end:true delPoint:false
        sartoriusBones[1].parent = inThighTwist
        local satTargetHelper = helper.create_point (name.replace_type sartoriusName "T")
        satTargetHelper.transform = sartoriusBones[2].transform
        satTargetHelper.parent = inPelvis
        local satLookAt = const.assign_lookat sartoriusBones[1] satTargetHelper
        satLookAt.lookat_vector_length = 0.0
        satLookAt.upnode_world = false
        satLookAt.pickUpNode = inUpNode

        delete #(tempAHelper, tempBHelper)

        #(sartoriusBones, #(satTargetHelper))
    )
)