(
    local wrinkleAtt = attributes wrinkleMap (
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
    local attachScale = attributes attachScale (
        parameters params (
            L_Eye_Ori type:#float default:6.56708
            R_Eye_Ori type:#float default:6.56708
            U_Teeth_Ori type:#float default:199.955
            B_Teeth_Ori type:#float default:199.955
            L_Eye_New type:#float default:6.56708
            R_Eye_New type:#float default:6.56708
            U_Teeth_New type:#float default:199.955
            B_Teeth_New type:#float default:199.955
        )
    )

    local attHolerMod = EmptyModifier()
    attHolerMod.name = "Attribute Holder"
    addModifier $C_FC_Head_0_JNT attHolerMod
    custAttributes.add $C_FC_Head_0_JNT.modifiers["Attribute Holder"] wrinkleAtt
    custAttributes.add $C_FC_Head_0_JNT.modifiers["Attribute Holder"] attachScale

    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.L_Eye_Ori = 3.77155
    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.R_Eye_Ori = 3.77155
    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.U_Teeth_Ori = 199.955
    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.B_Teeth_Ori = 199.955
    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.L_Eye_New = 3.77155
    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.R_Eye_New = 3.77155
    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.U_Teeth_New = 199.955
    $C_FC_Head_0_JNT.modifiers["Attribute Holder"].attachScale.B_Teeth_New = 199.955
)
