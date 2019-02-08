include "vertexcolor.ms"

    local selObjArray = getCurrentSelection()
    local jalVert = _VertexColor()
    for k = 1 to selObjArray.count do (
        format "%\% done.\n" ((k as float) / (selObjArray.count as float) * 100.0)
        format "% done.\n" selObjArray[k].name
        format "-------------------\n"
        jalVert.init selObjArray[k]
        for i = 1 to 3 do (jalVert.blur_vertcolor blurAmount:1)
    )

    for item in selObjArray do (
        local volSelMod = Vol__Select ()
        addModifier item volSelMod
        volSelMod.level = 1
        volSelMod.volume = 4
        volSelMod.map = 1
        volSelMod.texture = Vertex_Color ()
        volSelMod.method = 0
    )

    local selMorpherMod = $'Univ Face 0'.modifiers[#Morpher]
    local usedChannelArray = #()
    for i = 1 to 100 do (
        if WM3_MC_HasData selMorpherMod i then (
           append usedChannelArray i
        )
    )
    for i = 1 to usedChannelArray.count do (
        local channelOriName = WM3_MC_GetName selMorpherMod i
        local newChannelName = jal.name.remove_type channelOriName
        newChannelName = jal.name.remove_index newChannelName
        local newChannelNameBase = jal.name.get_base newChannelName
        if (matchPattern newChannelNameBase pattern:"*Face") then (
            local faceFindIndex = (findString newChannelNameBase "Face")
            local custCharName = replace newChannelNameBase faceFindIndex 4 ""
            newChannelName = jal.name.replace_base newChannelName custCharName
            WM3_MC_SetName selMorpherMod i newChannelName
        )
    )

    for i = 1 to usedChannelArray.count do (
        local newVal = random 0.0 100.0
        WM3_MC_SetValue selMorpherMod i newVal
    )
