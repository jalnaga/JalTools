try(destroydialog jal.tools.skinWeightTool) catch()
rollout mainRollout "SkinWeight Tool" width:280 height: 620(
    SubRollout mainSub "" align:#center height: 605

    global __jalSkinWeightToolRollout = undefined

    local smoothSkin
    local skinStr

    include "skinWeight.ms"
    include "smoothSkin.ms"
    include "ui_skinWeightRollout.ms"
    include "ui_advanceRollout.ms"

    on mainRollout open do
    (
        max modify mode
        if ((classof(modPanel.GetcurrentObject())) == Skin) then (
            smoothSkin = _smootSkin()
            skinStr = _SkinWeight()
            skinStr.init()
            __jalSkinWeightToolRollout = skinWeightRollout
            AddSubRollout mainSub skinWeightRollout
            AddSubRollout mainSub advanceRollout

            advanceRollout.open = false
        )
        else (
            try(destroydialog jal.tools.skinWeightTool) catch()
            messageBox "Please, Select Skined Object!!!"
        )
    )

    on mainRollout close do (
        __jalSkinWeightToolRollout = undefined
        try(destroydialog smoothSkinRollout) catch()
        gc()
    )
)
jal.tools.skinWeightTool = mainRollout
createDialog jal.tools.skinWeightTool style:#(#style_titlebar, #style_border, #style_sysmenu)
