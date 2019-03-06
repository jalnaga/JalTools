rollout mainRollout "Hair Tools" width:280 height:820 (
    SubRollout mainSub "" align:#center height:805

    local minWidth = 280
    local minHeight = 820
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    /*global __hairCardModRoll

    include "ui_hairGuideRollout.ms"
    include "ui_hairCardCreateRollout.ms"
    include "ui_hairCardModifyRollout.ms"


    on mainRollout open do (
        __hairCardModRoll = hairCardModifyRollout

        AddSubRollout mainSub hairGuideRollout
        AddSubRollout mainSub hairCardCreateRollout
        AddSubRollout mainSub hairCardModifyRollout
    )

    on mainRollout close do (
        hairGuideRollout.jalHairLine.reset()
        hairCardCreateRollout.jalHairCard.reset()
    )*/

    include "ui_hairLineRollout.ms"

    on mainRollout open do (
        AddSubRollout mainSub hairLineRollout
    )
)
jalHairTool = mainRollout
createDialog jalHairTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
