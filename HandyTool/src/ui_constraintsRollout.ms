rollout constraintsRollout "Constraints" (
    group "Position" (
        button posConstBtn "Pos Const"
    )
    group "Rotation" (
        button rotConstBtn "Rotation Const" width:80 across:2
        button rotScriptConstBtn "Rot Script" width:80
    )
    group "LookAt" (
        button lookAtBtn "LookAt" across:3
        button fliplessLookAtBtn "Flipless"
        button scriptedLookAtBtn "Script"
    )

    on posConstBtn pressed do (
        undo on (
            if selection.count >1 then (
                local selArray = getCurrentSelection()
                local oriObj = selArray[1]
                local targetObjArray = #()

                for i = 2 to selArray.count do (
                    append targetObjArray selArray[i]
                )

                jal.const.assign_pos_const_multi oriObj targetObjArray
            )
        )
    )

    on rotConstBtn pressed do (
        undo on (
            if selection.count >1 then (
                local selArray = getCurrentSelection()
                local oriObj = selArray[1]
                local targetObjArray = #()

                for i = 2 to selArray.count do (
                    append targetObjArray selArray[i]
                )

                jal.const.assign_rot_const_multi oriObj targetObjArray
            )
        )
    )

    on rotScriptConstBtn pressed do (
        undo on (
            if selection.count == 2 then (
                local selArray = getCurrentSelection()
                local oriObj = selArray[1]
                local targetObj = selArray[2]

                jal.const.assign_rot_const_scripted oriObj targetObj
            )
        )
    )

    on lookAtBtn pressed do (
        undo on (
            if selection.count >1 then (
                local selArray = getCurrentSelection()
                local oriObj = selArray[1]
                local targetObjArray = #()

                for i = 2 to selArray.count do (
                    append targetObjArray selArray[i]
                )

                jal.const.assign_lookat_multi oriObj targetObjArray
            )
        )
    )

    on fliplessLookAtBtn pressed do (
        undo on (
            if selection.count == 2 then (
                local selArray = getCurrentSelection()
                local oriObj = selArray[1]
                local targetObj = selArray[2]

                jal.const.assign_lookat_flipless oriObj targetObj
            )
        )
    )

    on scriptedLookAtBtn pressed do (
        undo on (
            if selection.count > 1 then (
                local selArray = getCurrentSelection()
                local oriObj = selArray[1]
                local targetObjArray = #()

                for i = 2 to selArray.count do (
                    append targetObjArray selArray[i]
                )

                jal.const.assign_scripted_lookat oriObj targetObjArray
            )
        )
    )
)
