global _jalToolSkinWeightTool
try(destroydialog _jalToolSkinWeightTool) catch()
rollout mainRollout "SkinWeight Tool" width:280 height: 530(
    SubRollout mainSub "" align:#center height: 530

    global __jalSkinWeightToolRollout = undefined

    include "ui_skinWeightRollout.ms"

    on mainRollout open do
    (
        max modify mode
        if ((classof(modPanel.GetcurrentObject())) == Skin) then (
            __jalSkinWeightToolRollout = skinWeightRollout
            AddSubRollout mainSub skinWeightRollout
        )
        else (
            try(destroydialog _jalToolSkinWeightTool) catch()
            messageBox "Please, Select Skined Object!!!"
        )
    )

    on mainRollout close do (
        __jalSkinWeightToolRollout = undefined
        gc()
    )
)
_jalToolSkinWeightTool = mainRollout
try(destroydialog _jalToolSkinWeightTool) catch()
createDialog _jalToolSkinWeightTool style:#(#style_titlebar, #style_border, #style_sysmenu)

clearlistener()
gc()
