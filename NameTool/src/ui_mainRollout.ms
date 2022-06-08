try(destroydialog jal.tools.namingTool) catch()
rollout mainRollout "Naming Tool" width:380 height:770 (
    SubRollout mainSub "" align:#center height:755

    local minWidth = 380
    local minHeight = 770
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    local iniFile = ""
    local nubStr = ""
    local namePartsOrder = #()
    local numPaddingNum = 3
    local renameObjArray = #()

    include "ui_nameListRollout.ms"
    include "ui_namingRollout.ms"
    include "ui_batchNamingRollout.ms"

    on mainRollout open do
    (
        jal.name.load_setting_from_ini()

        AddSubRollout mainSub nameListRollout
        AddSubRollout mainSub namingRollout
        AddSubRollout mainSub batchNamingRollout

        namingRollout.baseNameDrp.items = #("") + jal.name.__baseStrArray
        namingRollout.typeDrp.items = #("") + jal.name.__typeStrArray
        nameListRollout.update_UI()
        namingRollout.paddingNumSpn.value = (jal.name.get_paddingNum())
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
