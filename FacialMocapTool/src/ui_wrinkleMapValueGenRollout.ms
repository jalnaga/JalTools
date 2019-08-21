rollout wrinkleMapValueGenRollout "Wrinkle Map Value Generator" (
    spinner startFrameSpn "Start:" across:2 type:#integer range:[0, 100000, 0]
    spinner endFrameSpn "End:" type:#integer range:[0, 100000, 100]
    button genValueBtn "Assign Wrinkle Map Value"

    on wrinkleMapValueGenRollout open do (
        startFrameSpn.value = animationRange.start
        endFrameSpn.value = animationRange.end
    )

    on genValueBtn pressed do (
        fwm.set_headBone $C_FC_Head_0_JNT
        fwm.delete_value()
        fwm.assign_frame_to_att startFrameSpn.value endFrameSpn.value
    )
)
