rollout skinBoneRollout "Skin Bone Tool" (
    button genBaseSkelBtn "Create Base Skeleton" width:120
    group "Base Sekeleton <-> Biped" (
        button linkBipBtn "Link" across:2 width:80
        button unLinkBipBtn "UnLink" width:80
    )
    button genSkinBoneBtn "Create Skin Bones" width:120

    on genBaseSkelBtn pressed do (
        local selObjs = getCurrentSelection() as array
        if selObjs.count > 0 then (
            if jal.bip.get_bip_coms_num() == 1 then (
                jal.bone.create_skin_bone_from_bip selObjs
            )
            else (
                messageBox "There are too many Bips! It should be one!"
            )
        )
        else (
            messageBox "Select Bip objects!"
        )
    )

    on linkBipBtn pressed do (
        if jal.bip.get_bip_coms_num() == 1 then jal.bip.link_base_skeleton()
        else messageBox "There are too many Bips! It should be one!"
    )

    on unLinkBipBtn pressed do (
        if jal.bip.get_bip_coms_num() == 1 then jal.bip.unlink_base_skeleton()
        else messageBox "There are too many Bips! It should be one!"
    )

    on genSkinBoneBtn pressed do (
        local selObjs = getCurrentSelection() as array
        if selObjs.count > 0 then (
            local targetBones = for item in selObjs where classof item == BoneGeometry collect item
            jal.bone.create_skin_bone targetBones
        )
    )
)
