(
    local oriMesh = $Avg_MaleFace_00_Cage
    local selSetStr = "#($browDownLeft,$browDownRight,$browInnerUp,$browOuterUpLeft,$browOuterUpRight,$cheekPuff,$cheekSquintLeft,$cheekSquintRight,$eyeBlinkLeft,$eyeBlinkRight,$eyeLookDownLeft,$eyeLookDownRight,$eyeLookInLeft,$eyeLookInRight,$eyeLookOutLeft,$eyeLookOutRight,$eyeLookUpLeft,$eyeLookUpRight,$eyeSquintLeft,$eyeSquintRight,$eyeWideLeft,$eyeWideRight,$jawForward,$jawOpen,$jawLeft,$jawRight,$mouthClose,$mouthDimpleLeft,$mouthDimpleRight,$mouthFrownLeft,$mouthFrownRight,$mouthFunnel,$mouthLeft,$mouthRight,$mouthLowerDownLeft,$mouthLowerDownRight,$mouthPressLeft,$mouthPressRight,$mouthPucker,$mouthRollLower,$mouthRollUpper,$mouthShrugLower,$mouthShrugUpper,$mouthSmileLeft,$mouthSmileRight,$mouthStretchLeft,$mouthStretchRight,$mouthUpperUpLeft,$mouthUpperUpRight,$noseSneerLeft,$noseSneerRight)"
    /*local morphTargets = for item in selection collect item
    local morphMod = Morpher()
    addModifier oriMesh morphMod
    morphMod.Autoload_of_targets = 1
    for i = 1 to morphTargets.count do (
        WM3_MC_BuildFromNode morphMod i morphTargets[i]
        WM3_MC_SetValue morphMod i 0.0
    )*/
    local morphMod = oriMesh.modifiers[1]
    for i = 1 to 51 do (
        local channelName = WM3_MC_GetName morphMod i
        local newName = jal.name.get_realName channelName
        WM3_MC_SetName morphMod i newName
    )
    /*local appleCage = $average_mesh_LLL_cage001
    local averageCage = $average_mesh_LLL_cage005
    for i = 1 to morphTargets.count do (
        if (WM3_MC_IsValid morphMod (i-1)) then WM3_MC_SetValue morphMod (i-1) 0.0
        local clonedCage = copy appleCage
        ConvertTo clonedCage Editable_Poly
        clonedCage.name = "Cage_" + morphTargets[i].name + "_Apple"
        clonedCage.pos = [appleCage.position.x+(i*20), 0.0, 25.0]
        local cageMorph = Morpher()
        addModifier clonedCage cageMorph
        cageMorph.Autoload_of_targets = 1
        WM3_MC_BuildFromNode cageMorph 1 appleCage
        WM3_MC_BuildFromNode cageMorph 2 averageCage

        WM3_MC_SetValue morphMod i 100.0
        WM3_MC_SetValue cageMorph 1 100.0
        WM3_MC_SetValue cageMorph 2 100.0
        ConvertTo clonedCage Editable_Poly
    )*/
    /*for i = 2 to morphTargets.count do (
        local clonedCage = copy oriMesh
        local morphMod = clonedCage.modifiers[1]
        WM3_MC_SetValue morphMod 1 100.0
        WM3_MC_SetValue morphMod i 100.0
        convertTo clonedCage Editable_Poly
        clonedCage.name = jal.name.replace_base morphTargets[i].name "Avg"
        clonedCage.pos = [clonedCage.position.x+(i*20), 0.0, 25.0]
    )*/
)
