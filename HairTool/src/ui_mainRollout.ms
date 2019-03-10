rollout mainRollout "Hair Tools" width:320 height:900 (
    SubRollout mainSub "" align:#center height:885

    local minWidth = 320
    local minHeight = 900
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

    include "hairLine.ms"
    include "hairChunk.ms"

    local jalHairLine = __HairLine()
    local jalHairChunk = __HairChunk()

    include "ui_hairLineRollout.ms"
    include "ui_hairChunkRollout.ms"

    on mainRollout open do (
        AddSubRollout mainSub hairLineRollout
        AddSubRollout mainSub hairChunkRollout
    )
)
jalHairTool = mainRollout
createDialog jalHairTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
