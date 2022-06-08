rollout advanceRollout "Advanced Parameters" (
    checkbox alwaysDeformCkb "Always Deform" checked:true height:25 across:2
    checkbox  showNoEnvelopeCkb "Show No Envelopes" checked: true height:25
    spinner boneAffectLimitSpn "Bones Affect Limit: " fieldWidth:40 type:#integer range:[1, 20, 20] scale:1
    button removeUnusedBonesBtn "Remove Unused Bones"

    on alwaysDeformCkb changed state do (
        (modPanel.GetcurrentObject()).always_deform = state
    )

    on showNoEnvelopeCkb changed state do (
        (modPanel.GetcurrentObject()).ShowNoEnvelopes = state
    )

    on boneAffectLimitSpn changed val do (
        (modPanel.GetcurrentObject()).bone_Limit = boneAffectLimitSpn.value
    )

    on removeUnusedBonesBtn pressed do (
        skinStr.remove_unused_bones()
    )
)
