(
    local l_eyeScale = attributes lEyeScale (
        parameters params(
            oriScale type:#float
            newScale type:#float
        )
    )

    local r_eyeScale = attributes rEyeScale (
        parameters params(
            oriScale type:#float
            newScale type:#float
        )
    )

    local lCustHolerMod = EmptyModifier()
    local rCustHolerMod = EmptyModifier()
    lCustHolerMod.name = "Eye Scale"
    rCustHolerMod.name = "Eye Scale"
    addModifier $L_Eye_0_Offset lCustHolerMod
    custAttributes.add $L_Eye_0_Offset.modifiers["Eye Scale"] l_eyeScale
    addModifier $R_Eye_0_Offset rCustHolerMod
    custAttributes.add $R_Eye_0_Offset.modifiers["Eye Scale"] r_eyeScale
)
