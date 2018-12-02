try(destroydialog jal.tools.namingTool) catch()
rollout mainRollout "Naming Tool" width:300 height:570 (
    SubRollout mainSub "" align:#center height:555

    local minWidth = 300
    local minHeight = 540
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    global __nameListRollout
    global __namingRollout
    global __batchNamingRollout

    local renameObjArray = #()

    include "ui_nameListRollout.ms"
    include "ui_namingRollout.ms"
    include "ui_batchNamingRollout.ms"

    on mainRollout open do
    (
        __nameListRollout = nameListRollout
        __namingRollout = namingRollout
        __batchNamingRollout = batchNamingRollout

        AddSubRollout mainSub nameListRollout
        AddSubRollout mainSub namingRollout
        AddSubRollout mainSub batchNamingRollout

        __nameListRollout.update_UI()
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
        jal.roll.update_subroll_when_resized mainSub namingRollout
        jal.roll.update_subroll_when_resized mainSub batchNamingRollout
    )
)

jal.tools.namingTool = mainRollout
createDialog jal.tools.namingTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
