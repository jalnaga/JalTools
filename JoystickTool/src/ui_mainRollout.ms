try(destroydialog jal.tools.joystickTool) catch()
rollout mainRollout "Joystick Tool" width:280 height: 160(
    SubRollout mainSub "" align:#center height:385

    local minWidth = 280
    local minHeight = 160
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    include "joystick.ms"

    local joystick = _JoystickGenerator()

    include "ui_joystickRollout.ms"

    on mainRollout open do
    (
        AddSubRollout mainSub joystickRollout
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

        jal.roll.update_subroll_when_resized mainSub joystickRollout
    )
)

jal.tools.joystickTool = mainRollout
try(destroydialog jal.tools.joystickTool) catch()
createDialog jal.tools.joystickTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
