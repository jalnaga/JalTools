(
    local cursorAtt = attributes wrinkleAtt (
        parameters params (
            C_ForeHeadUp type:#float
            L_ForeHeadUp type:#float
            R_ForeHeadUp type:#float
            L_MouthCorner type:#float
            R_MouthCorner type:#float
            L_Palza_Stretch type:#float
            R_Palza_Stretch type:#float
            L_MouthOut_Stretch type:#float
            R_MouthOut_Stretch type:#float
            L_NeckStraint type:#float
            R_NeckStraint type:#float
            L_EyeBrowIn type:#float
            R_EyeBrowIn type:#float
            L_EyeIn type:#float
            R_EyeIn type:#float
            L_Nose type:#float
            R_Nose type:#float
            L_MouthUp type:#float
            R_MouthUp type:#float
            L_EyeCorner type:#float
            R_EyeCorner type:#float
            L_MouthOut_Smile type:#float
            R_MouthOut_Smile type:#float
            L_Palza_Smile type:#float
            R_Palza_Smile type:#float
        )
    )

    local cursorMod = EmptyModifier()
    cursorMod.name = "WrinkleMap Value"
    addModifier $ cursorMod
    custAttributes.add $.modifiers["WrinkleMap Value"] cursorAtt
)
