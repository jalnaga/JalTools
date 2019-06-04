try(destroydialog jal.tools.skinWeightTool) catch()
rollout mainRollout "SkinWeight Tool" width:280 height: 545(
    SubRollout mainSub "" align:#center height: 545

    global __jalSkinWeightToolRollout = undefined

    local skinStr

    include "skinWeight.ms"
    include "ui_skinWeightRollout.ms"

    on mainRollout open do
    (
        max modify mode
        if ((classof(modPanel.GetcurrentObject())) == Skin) then (
            skinStr = _SkinWeight()
            skinStr.init()
            __jalSkinWeightToolRollout = skinWeightRollout
            AddSubRollout mainSub skinWeightRollout
        )
        else (
            try(destroydialog jal.tools.skinWeightTool) catch()
            messageBox "Please, Select Skined Object!!!"
        )
    )

    on mainRollout close do (
        __jalSkinWeightToolRollout = undefined
        gc()
    )
)
jal.tools.skinWeightTool = mainRollout
createDialog jal.tools.skinWeightTool style:#(#style_titlebar, #style_border, #style_sysmenu)
