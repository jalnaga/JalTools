try(destroydialog jal.tools.hairTool) catch()
rollout mainRollout "Hair Tools" width:320 height:900 (
    SubRollout mainSub "" align:#center height:885

    local minWidth = 320
    local minHeight = 900
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    global __hairChunkRollout

    include "hairLine.ms"
    include "hairChunk.ms"

    local jalHairLine = __HairLine()
    local jalHairChunk = __HairChunk()

    include "ui_hairLineRollout.ms"
    include "ui_hairChunkRollout.ms"

    on mainRollout open do (
        __hairChunkRollout = hairChunkRollout

        AddSubRollout mainSub hairLineRollout
        AddSubRollout mainSub hairChunkRollout

        callbacks.addScript #selectionSetChanged " __hairChunkRollout.set_UI_to_chunk_shape()" id:#jalHairChunkRolloutUIUpdate
        __hairChunkRollout.set_UI_to_chunk_shape()
    )

    on mainRollout close do (
        callbacks.removeScripts id:#jalHairChunkRolloutUIUpdate
    )
)
jal.tools.hairTool = mainRollout
createDialog jal.tools.hairTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
