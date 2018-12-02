rollout commonToolsRollout "Handy Tools" (
    group "Linking" (
        button linkBtn "Link" across:2 width:80 toolTip:"Click: Link to Last selection\nR Click: Link to First selection"
        button unLinkBtn "Unlink" width:80 toolTip:"Click: Unlink selection\nR Click: Unlink Children"
    )
    group "Align" (
        button alignBtn "Align" width:80 across:2 toolTip:"Click: Align to last selection\nR Click: Align to last selection Center"
        button mirrorBtn "Mirror" width:80 toolTip:"Click: Mirror to X\nR Click: Mirror to Y\nwith Ctrl: Mirror to last selection\nwith Shift:Non negative Mirror"
    )
    group "Selection Filter" (
        checkbox toggleSelectionSet "Sel Set" across:2
        radioButtons selFilterRdo labels:#("All", "Bone", "Bip", "Helper", "ExpTm", "Spline") columns:2
    )

    fn mirrorBtn_pressed inLClick inRClick inShiftPressed inCtrlPressed = (
        if selection.count > 0 then (
            local pObj = undefined
            local defMirrorAxis = 0
            local nonNegativeAxis = 0
            local oriObjArray = getCurrentSelection() as Array
            local inOriObjArray = deepCopy oriObjArray
            local boneArray = #()
            local helperArray = #()
            local nonBoneArray = #()
            
            local mirroredBoneArray = #()
            local mirroredHelperArray = #()
            local mirroredNonBoneArray = #()
            local mirroredObjArray = #()

            if inLClick then (
                defMirrorAxis = 1
                nonNegativeAxis = 1
            )
            if inRClick then (
                defMirrorAxis = 2
                nonNegativeAxis = 3
            )

            if inCtrlPressed then (
                if selection.count > 1 then (
                    inOriObjArray = #()
                    pObj = oriObjArray[oriObjArray.count]
                    inOriObjArray = for i = 1 to (oriObjArray.count - 1) collect oriObjArray[i]
                )
            )

            for item in inOriObjArray do (
                local caseIndex = 0
                if classOf item == BoneGeometry then caseIndex = 1
                if superClassOf item == helper then caseIndex = 2
                case caseIndex of (
                    1: append boneArray item
                    2: append helperArray item
                    default: append nonBoneArray item
                )
            )
            if boneArray.count != 0 then mirroredBoneArray = jal.mirror.mirror_bone boneArray mAxis:defMirrorAxis
            if helperArray.count != 0 then (
                if inShiftPressed then mirroredHelperArray = jal.mirror.mirror_without_negative helperArray mAxis:nonNegativeAxis pivotObj:pObj cloneStatus:2
                else mirroredHelperArray = jal.mirror.mirror_geo helperArray mAxis:defMirrorAxis pivotObj:pObj cloneStatus:2
            )
            if nonBoneArray.count != 0 then (
                if inShiftPressed then mirroredNonBoneArray = jal.mirror.mirror_without_negative nonBoneArray mAxis:nonNegativeAxis pivotObj:pObj cloneStatus:2
                else mirroredNonBoneArray = jal.mirror.mirror_geo nonBoneArray mAxis:defMirrorAxis pivotObj:pObj cloneStatus:2
            )

            join mirroredObjArray mirroredBoneArray
            join mirroredObjArray mirroredHelperArray
            join mirroredObjArray mirroredNonBoneArray

            clearSelection()
            select mirroredObjArray
        )
    )


    on linkBtn pressed do (
        undo "Jal Link" on (
            jal.link.link_to_last_sel()
        )
    )

    on linkBtn rightclick do (
        undo "Jal Link" on (
            jal.link.link_to_first_sel()
        )
    )

    on unLinkBtn pressed do (
        undo "Jal Unlink" on (
            jal.link.unlink_selection()
        )
    )

    on unLinkBtn rightclick do (
        undo "Jal Unlink" on (
            jal.link.unlink_children()
        )
    )

    on alignBtn pressed do (
        undo "Jal Align" on (
            jal.align.align_to_last_sel()
        )
    )

    on alignBtn rightclick do (
        undo "Jal Align" on (
            jal.align.align_to_last_sel_center()
        )
    )

    on mirrorBtn pressed do (
        undo "Jal Mirror" on (
            mirrorBtn_pressed true false keyboard.shiftPressed keyboard.controlPressed
        )
    )

    on mirrorBtn rightclick do (
        undo "Jal Mirror" on (
            mirrorBtn_pressed false true keyboard.shiftPressed keyboard.controlPressed
        )
    )

    on selFilterRdo changed state do (
        undo on (
            if toggleSelectionSet.checked then (
                case state of (
                    1: jal.sel.set_selectionSet_to_all()
                    2: jal.sel.set_selectionSet_to_bone()
                    3: jal.sel.set_selectionSet_to_bone()
                    4: jal.sel.set_selectionSet_to_point()
                    5: jal.sel.set_selectionSet_to_helper()
                    6: jal.sel.set_selectionSet_to_spline()
                )
            )
            if selection.count > 0 then (
                case state of (
                    1: getCurrentSelection()
                    2: jal.sel.filter_bone()
                    3: jal.sel.filter_bip()
                    4: jal.sel.filter_helper()
                    5: jal.sel.filter_expTm()
                    6: jal.sel.filter_spline()
                )
            )
        )
    )
)
