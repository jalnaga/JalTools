struct _BreastBone (
    name, anim, helper, bone, const,

    fn create_bones inSpine inArm inFigureStart inFigureEnd pectoral:undefined = (
        local breastName = name.replace_realName inArm.name "Breast"

        local breastMainBones = bone.create_bone #(inFigureStart, inFigureEnd) breastName end:true delPoint:false size:2
        local tempLookAt = const.assign_lookat breastMainBones[1] inFigureEnd
        tempLookAt.pickUpNode = inSpine
        tempLookAt.upnode_world = false
        tempLookAt.StoUP_axisFlip = true
        const.collapse breastMainBones[1]

        local breastRootBone = bone.create_nub_bone breastName 2
        breastRootBone.transform = breastMainBones[1].transform
        local breastBones = #(breastRootBone, breastMainBones[1], breastMainBones[2])
        for i = 1 to breastBones.count do breastBones[i].name = name.replace_index breastMainBones[1].name ((i-1) as String)
        breastBones[2].parent = breastBones[1]
        breastBones[3].name = name.replace_index breastBones[3].name "Nub"

        local breastRootHelper = helper.create_point (name.replace_type breastBones[1].name "P") boxToggle:on crossToggle:off
        breastRootHelper.transform = breastBones[1].transform
        breastRootHelper.parent = inSpine
        breastBones[1].parent = breastRootHelper

        local breastSpinePosHelper = helper.create_point (name.replace_type breastBones[1].name "Dum")
        local breastPectoralPosHelper = helper.create_point (name.add_sufix_to_realName breastSpinePosHelper.name "Tgt")
        breastSpinePosHelper.transform = breastBones[1].transform
        breastPectoralPosHelper.transform = breastBones[1].transform
        breastSpinePosHelper.parent = inSpine
        if pectoral != undefined then breastPectoralPosHelper.parent = pectoral else breastPectoralPosHelper.parent = inSpine

        const.assign_pos_const_multi breastRootHelper #(breastSpinePosHelper, breastPectoralPosHelper)
        breastRootHelper.position.controller[2].setWeight 1 60
        breastRootHelper.position.controller[2].setWeight 2 40

        #(breastBones, #(breastRootHelper, breastSpinePosHelper, breastPectoralPosHelper))
    )
)