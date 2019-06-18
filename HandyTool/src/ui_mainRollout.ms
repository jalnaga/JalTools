try(destroydialog jal.tools.handyTool) catch()
rollout mainRollout "Handy Tools" width:280 height:820 (
    SubRollout mainSub "" align:#center height:805

    local minWidth = 280
    local minHeight = 820
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    include "ui_helperToolsRollout.ms"
    include "ui_nameSelToolsRollout.ms"
    include "ui_boneCreateRollout.ms"
    include "ui_constraintsRollout.ms"
    include "ui_muscleBoneRollout.ms"

    on mainRollout open do
    (
        AddSubRollout mainSub nameSelToolsRollout
        AddSubRollout mainSub helperToolsRollout
        AddSubRollout mainSub boneCreateRollout
        AddSubRollout mainSub constraintsRollout
        AddSubRollout mainSub muscleBoneRollout

        constraintsRollout.open = false
        muscleBoneRollout.open = false
        nameSelToolsRollout.open = false
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

        jal.roll.update_subroll_when_resized mainSub nameSelToolsRollout
        jal.roll.update_subroll_when_resized mainSub helperToolsRollout
        jal.roll.update_subroll_when_resized mainSub boneCreateRollout
        jal.roll.update_subroll_when_resized mainSub constraintsRollout
        jal.roll.update_subroll_when_resized mainSub muscleBoneRollout
    )
)

jal.tools.handyTool = mainRollout
try(destroydialog jal.tools.handyTool) catch()
createDialog jal.tools.handyTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
