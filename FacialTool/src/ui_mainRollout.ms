try(destroydialog jal.tools.facialCageTool) catch()
rollout mainRollout "Facial Cage Tool" width:300 height:690 (
    SubRollout mainSub "" align:#center height:675

    local minWidth = 300
    local minHeight = 690
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    on mainRollout open do
    (
        --AddSubRollout mainSub regionRollout
    )

    on mainRollout resized newSize do
    (
        if newSize[1] > minWidth then
        mainSub.width = newSize[1] - subRollWidthOffset
        else (
            mainRollout.width = minWidth
            mainSub.width = minWidth - subRollWidthOffset
        )
        if newSize[2] > minHeight then mainSub.height = newSize[2] - subRollHeightOffset
        else (
            mainRollout.height = minHeight
            mainSub.height = minHeight - subRollHeightOffset
        )

        --jal.roll.update_subroll_when_resized mainSub regionRollout
    )
)
jal.tools.facialCageTool = mainRollout
createDialog jal.tools.facialCageTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_maximizebox)
