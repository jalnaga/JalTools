try(destroydialog jal.tools.nameReplaceTool) catch()
rollout mainRollout "Name Replace Tool" width:350 height:740 (
    SubRollout mainSub "" align:#center height:725

    local minWidth = 350
    local minHeight = 725
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    local renameObjArray = #()
    local filteringChar = " "

    global __nameRepNameListRollout
    global __nameRepNameReplaceRollout

    include "ui_nameListRollout.ms"
    include "ui_replaceNameRollout.ms"

    on mainRollout open do
    (
        __nameRepNameListRollout = nameListRollout
        __nameRepNameReplaceRollout = replaceNameRollout
        AddSubRollout mainSub nameListRollout
        AddSubRollout mainSub replaceNameRollout
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

        jal.roll.update_subroll_when_resized mainSub nameListRollout
        jal.roll.update_subroll_when_resized mainSub replaceNameRollout
    )
)
jal.tools.nameReplaceTool = mainRollout
createDialog jal.tools.nameReplaceTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
