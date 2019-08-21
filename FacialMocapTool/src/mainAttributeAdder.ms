(
local mainRectAtt = attributes facialMainAtt (
    rollout facialMainAttRollout "Facial Animation" (
        button resetBtn "Reset"

        local controlObjArray = #($L_BrowDown_00_Cur, $R_BrowDown_00_Cur, $C_BrowInUp_00_Cur, $L_BrowOutUp_00_Cur, $R_BrowOutUp_00_Cur, $C_CheekPuff_00_Cur, $L_CheekSquint_00_Cur, $R_CheekSquint_00_Cur, $L_EyeBlink_00_Cur, $R_EyeBlink_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_Eye_00_Cur, $R_Eye_00_Cur, $L_EyeSquint_00_Cur, $R_EyeSquint_00_Cur, $L_EyeWide_00_Cur, $R_EyeWide_00_Cur, $C_Jaw_00_Cur, $C_JawOpen_00_Cur, $C_Jaw_00_Cur, $C_Jaw_00_Cur, $C_MouthClose_00_Cur, $L_MouthDimple_00_Cur, $R_MouthDimple_00_Cur, $L_MouthFrown_00_Cur, $R_MouthFrown_00_Cur, $C_MouthFunnel_00_Cur, $C_Mouth_00_Cur, $C_Mouth_00_Cur, $L_MouthLower_00_Cur, $R_MouthLower_00_Cur, $L_MouthPress_00_Cur, $R_MouthPress_00_Cur, $C_MouthPucker_00_Cur, $C_MouthRollLower_00_Cur, $C_MouthRollUpper_00_Cur, $C_MouthShrugLower_00_Cur, $C_MouthShrugUpper_00_Cur, $L_MouthSmile_00_Cur, $R_MouthSmile_00_Cur, $L_MouthStretch_00_Cur, $R_MouthStretch_00_Cur, $L_MouthUpper_00_Cur, $R_MouthUpper_00_Cur, $L_NoseSneer_00_Cur, $R_NoseSneer_00_Cur)

        on resetBtn pressed do (
            for item in controlObjArray do (
                deleteKeys item.position.controller[2] #allKeys
                item.position.controller[2].value = [0,0,0]
            )
        )
    )
)
local mainCtrRect = $C_FacialRig_Rect
local mainCtrMod = EmptyModifier()
mainCtrMod.name = "Facial Control"
addModifier mainCtrRect mainCtrMod
custAttributes.add mainCtrRect.modifiers["Facial Control"] mainRectAtt
)
