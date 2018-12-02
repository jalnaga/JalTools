rollout mainRollout "Skining Tool" width:300 height:630 (
    SubRollout mainSub "main" align:#center height:615

    local minWidth = 300
    local minHeight = 630
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    local jalSkin = jal.skin
    local skinObjArray = #()
    local selSkinObj = undefined

    local objRoll = undefined
    local boneRoll = undefined

    include "ui_skinObjectsRollout.ms"
    include "ui_skinBonesRollout.ms"

    on mainRollout open do
    (
        AddSubRollout mainSub skinObjectRollout
        AddSubRollout mainSub skinBonesRollout

        objRoll = skinObjectRollout
        boneRoll = skinBonesRollout
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
        jal.roll.update_subroll_when_resized mainSub skinObjectRollout
        jal.roll.update_subroll_when_resized mainSub skinBonesRollout
    )
)
global __skiningToolRollout = mainRollout
try(destroydialog __skiningToolRollout) catch()
createDialog __skiningToolRollout style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
