rollout hairCardModifyRollout "Modify HairCard" (
    label selHairCardLb "0 HairCard selected." align:#left
    group "Shape" (
        spinner hairCardLengthSpn "Length:" type:#float range:[0.0, 1.0, 1] across:2 scale:0.001
        spinner hairCardWidthSpn "Width:" type:#float range:[0.01, 100.0, 3]
        spinner hairCardLengthsegsSpn "L.Segs:" type:#integer range:[1, 100, 20] across:2
        spinner hairCardWidthsegsSpn "W.Segs:" type:#integer range:[1, 10, 2]
        spinner hairCardRotSpn "Rot:" type:#float range:[-180.0, 180.0, 0] across:2
        spinner hairCardTwistSpn "Twist:" type:#float range:[-3600.0, 3600.0, 0]
        spinner hairCardBendSpn "Bend:" type:#float range:[-180.0, 180.0, 90] across:2
        spinner hairCardTaperSpn "Taper:" type:#float range:[-4, 4, 0]

        checkbox hairCardUniformCkb "Uniform" across:2 offset:[0, 10]
        checkbox hairCardBeforeRotCkb "Before Rot." offset:[0, 10]
        spinner hairCardXOffsetSpn "X Offset:" type:#float range:[-10, 10, 0] scale:0.001
        spinner hairCardZOffsetSpn "Z Offset:" type:#float range:[-10, 10, 0] scale:0.001

        button openScaleCurveBtn "Open Scale Curve Editor"
    )
    group "Material" (
        spinner hairCardWideNumPerMatSpn "Wide Var. Num:" type:#integer range:[1,10, 5]
        spinner hairCardNarrowNumPerMatSpn "Narrow Var. Num:" type:#integer range:[1,10, 10]
        radiobuttons hairCardTypeRdb "" columns:2 labels:#("Wide Hair", "Narrow Hair")
        spinner hairCardWideMinSpn "Wide Min:" type:#integer range:[1,10, 1] across:2
        spinner hairCardWideMaxSpn "Wide Max:" type:#integer range:[1,10, 5]
        spinner hairCardNarrowMinSpn "Narrow Min:" type:#integer range:[1,10, 1] across:2
        spinner hairCardNarrowMaxSpn "Narrow Max:" type:#integer range:[1,10, 5]
        spinner hairCardUVIndexSpn "UV Index:" type:#integer range:[1,10, 1] across:2
        button hairCardUVRandomBtn "Random"
    )

    include "hairCard.ms"
    local jalHairCard = __HairCard()
    local hairCardScaleCurve = undefined
    local bTargetArrayDone = true
    local displayHairCardShape = undefined

    fn update_ui inNewSelArray = (
        jalHairCard.hairCardArray = deepCopy inNewSelArray
        selHairCardLb.text = (jalHairCard.hairCardArray.count as String) + " HairCards Selected."
        displayHairCardShape = jalHairCard.get_hairCard_Shape jalHairCard.hairCardArray[1]

        hairCardLengthSpn.value = displayHairCardShape.length
        hairCardWidthSpn.value = displayHairCardShape.width
        hairCardLengthsegsSpn.value = displayHairCardShape.lengthsegs
        hairCardWidthsegsSpn.value = displayHairCardShape.widthsegs
        hairCardRotSpn.value = displayHairCardShape.rotation
        hairCardTwistSpn.value = displayHairCardShape.twist
        hairCardBendSpn.value = displayHairCardShape.bend
        hairCardTaperSpn.value = displayHairCardShape.taper

        hairCardScaleCurve = displayHairCardShape.scaleCurve

        hairCardUniformCkb.checked = displayHairCardShape.uniform
        hairCardBeforeRotCkb.checked = displayHairCardShape.beforeRot
        hairCardXOffsetSpn.value = displayHairCardShape.xOffset
        hairCardZOffsetSpn.value = displayHairCardShape.zOffset
    )

    fn update_selArray = (
        if bTargetArrayDone then (
            local selHairPlaneArray = for item in selection where (jalHairCard.is_hairPlane item) collect item
            if selHairPlaneArray.count > 0 then (
                update_ui selHairPlaneArray
            )
        )
    )

    fn modify_length inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.length = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_width inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.width = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_lengthsegs inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.lengthsegs = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_widthsegs inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.widthsegs = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_rot inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.rotation = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_twist inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.twist = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_bend inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.bend = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_taper inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.taper = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_scaleCurve inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.scaleCurve = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_uniform inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.uniform = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_beforeRot inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.beforeRot = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_offsetX inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.xOffset = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )
    fn modify_offsetZ inNewVal = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local oriShape = __HairCardShape()
            local newShape = __HairCardShape()
            for item in jalHairCard.hairCardArray do (
                oriShape = jalHairCard.get_hairCard_Shape item
                oriShape.zOffset = inNewVal
                newShape = jalHairCard.set_hairCard_Shape item oriShape
                jalHairCard.modifiy_hairCard newShape
            )
            bTargetArrayDone = true
        )
    )

    fn modify_uv inNewVal bRandom:false = (
        if jalHairCard.hairCardArray.count != 0 then (
            bTargetArrayDone = false
            local matIndex = hairCardTypeRdb.state
            local maxVal = jalHairCard.hairCardNumPerMatArray[matIndex]
            local matMaxVal = 0
            local matMinVal = 0
            local newVal = inNewVal
            case matIndex of (
                1: (
                    matMaxVal = hairCardWideMaxSpn.value
                    matMinVal = hairCardWideMinSpn.value
                )
                2: (
                    matMaxVal = hairCardNarrowMaxSpn.value
                    matMinVal = hairCardNarrowMinSpn.value
                )
            )
            if matMaxVal <= matMinVal then matMinVal = matMinVal - 1
            if matMaxVal > maxVal then matMaxVal = maxVal
            if newVal > matMaxVal then newVal = matMaxVal
            for item in jalHairCard.hairCardArray do (
                if bRandom then newVal = random matMinVal matMaxVal
                jalHairCard.modify_uv item matIndex newVal
            )
            bTargetArrayDone = true
        )
    )

    rollout hairCardScaleCurveEditorRollout "Scale Curve Editor" (
        CurveControl hairCardScaleCrv ""
    )

    on hairCardModifyRollout open do (
        callbacks.addScript #selectionSetChanged "__hairCardModRoll.update_selArray()" id:#jalHairCardModRolloutUpdateUI
    )
    on hairCardModifyRollout close do (
        callbacks.removeScripts id:#jalHairCardModRolloutUpdateUI
    )

    on hairCardLengthSpn changed newVal do modify_length newVal
    on hairCardWidthSpn changed newVal do modify_width newVal
    on hairCardLengthsegsSpn changed newVal do modify_lengthsegs newVal
    on hairCardWidthsegsSpn changed newVal do modify_widthsegs newVal
    on hairCardRotSpn changed newVal do modify_rot newVal
    on hairCardTwistSpn changed newVal do modify_twist newVal
    on hairCardBendSpn changed newVal do modify_bend newVal
    on hairCardTaperSpn changed newVal do modify_taper newVal

    on hairCardUniformCkb changed newVal do modify_uniform newVal
    on hairCardBeforeRotCkb changed newVal do modify_uniform newVal

    on hairCardXOffsetSpn changed newVal do modify_offsetX newVal
    on hairCardZOffsetSpn changed newVal do modify_offsetZ newVal

    on hairCardWideNumPerMatSpn changed newVal do jalHairCard.set_hairCardNumPerMat 1 newVal
    on hairCardNarrowNumPerMatSpn changed newVal do jalHairCard.set_hairCardNumPerMat 2 newVal

    on hairCardUVIndexSpn changed newVal do (
        modify_uv newVal
    )

    on hairCardUVRandomBtn pressed do (
        modify_uv 1 bRandom:true
    )
)
