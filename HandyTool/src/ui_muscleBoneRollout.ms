rollout muscleBoneRollout "Muscle Bones" (
    pickButton splinePickBtn "Spline Object" autoDisplay: true width:180 height:30
    editText muscleBoneNameTxt "Name:" text:"MuscleBone"
    spinner linkNumSpn "BoneNum:" range:[1, 100, 2] type:#integer
    spinner boneSizeSpn "Size:" range:[1.0, 100, 2.0] type:#float
    checkbox squashCkb "Squash"
    button createBtn "Create Muscle Bones"
    button delBtn "Delete"

    on createBtn pressed do (
        if isValidNode splinePickBtn.object then (
            if classOf splinePickBtn.object == line or classOf splinePickBtn.object == SplineShape then (
                undo on (
                    local muscleBoneName = muscleBoneNameTxt.text
                    jal.muscleBone.init muscleBoneName splinePickBtn.object linkNumSpn.value boneSizeSpn.value squashCkb.checked

                    jal.muscleBone.create()
                )
            )
        )
    )

    on delBtn pressed do (
        undo on (
            jal.muscleBone.delAll()
        )
    )
)
