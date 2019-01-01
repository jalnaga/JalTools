rollout mainRollout "Hair Tools" width:280 height:820 (
    SubRollout mainSub "" align:#center height:805

    local minWidth = 280
    local minHeight = 820
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    include "ui_hairGuideRollout.ms"

    on mainRollout open do (
        AddSubRollout mainSub hairGuideRollout
    )
)
jalHairTool = mainRollout
createDialog jalHairTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
