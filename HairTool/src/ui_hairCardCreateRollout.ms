rollout hairCardCreateRollout "Create HairCard" (
    group "Create" (
        radiobuttons hairCardTypeRdb "" columns:2 labels:#("Wide Hair", "Narrow Hair")
        button createHairCardBtn "Create HairCard"
    )
    group "Card Mdofy" (
        spinner hairCardLengthSpn "Length:" type:#float range:[0.0, 1.0, 1] across:2 enabled:false
        spinner hairCardWidthSpn "Width:" type:#float range:[0.01, 100.0, 3] enabled:false
        spinner hairCardLengthsegsSpn "L.Segs:" type:#integer range:[1, 100, 20] across:2 enabled:false
        spinner hairCardWidthsegsSpn "W.Segs:" type:#integer range:[1, 10, 2] enabled:false
        spinner hairCardRotSpn "Rot:" type:#float range:[-180.0, 180.0, 0] across:2 enabled:false
        spinner hairCardTwistSpn "Twist:" type:#float range:[-1800.0, 1800.0, 0] enabled:false
        spinner hairCardBendSpn "Bend:" type:#float range:[-180.0, 180.0, 90] across:2 enabled:false
        spinner hairCardTaperSpn "Taper:" type:#float range:[-4, 4, 0] enabled:false
    )
    button doneBtn "Done" enabled:false

    include "hairCard.ms"

    local jalHairCard = __HairCard()

    fn reset_ui = (
        createHairCardBtn.enabled = true

        hairCardLengthSpn.enabled = false
        hairCardLengthSpn.value = 1

        hairCardWidthSpn.enabled = false
        hairCardWidthSpn.value = 3

        hairCardLengthsegsSpn.enabled = false
        hairCardLengthsegsSpn.value = 20

        hairCardWidthsegsSpn.enabled = false
        hairCardWidthsegsSpn.value = 2

        hairCardRotSpn.enabled = false
        hairCardRotSpn.value = 0

        hairCardTwistSpn.enabled = false
        hairCardTwistSpn.value = 0

        hairCardBendSpn.enabled = false
        hairCardBendSpn.value = 90

        hairCardTaperSpn.enabled = false
        hairCardTaperSpn.value = 0

        doneBtn.enabled = false
    )

    fn enabled_modify_controls = (
        hairCardLengthSpn.enabled = true
        hairCardWidthSpn.enabled = true
        hairCardWidthSpn.value = jalHairCard.hairCardWidthArray[hairCardTypeRdb.state]
        hairCardLengthsegsSpn.enabled = true
        hairCardWidthsegsSpn.enabled = true
        hairCardRotSpn.enabled = true
        hairCardTwistSpn.enabled = true
        hairCardBendSpn.enabled = true
        hairCardTaperSpn.enabled = true

        doneBtn.enabled = true
    )

    fn modify_hairCard  = (
        if jalHairCard.hairCardArray.count != 0 then (
            for item in jalHairCard.hairCardArray do (
                jalHairCard.modify_plane_shape item hairCardLengthSpn.value hairCardWidthSpn.value hairCardLengthsegsSpn.value hairCardWidthsegsSpn.value hairCardRotSpn.value hairCardTwistSpn.value hairCardBendSpn.value hairCardTaperSpn.value
            )
        )
    )

    on createHairCardBtn pressed do (
        local hairLineArray = for item in selection where ((classOf item) == SplineShape) and ((numSplines item) == 1) collect item
        if hairLineArray.count > 0 then (
            jalHairCard.set_hairLineArray hairLineArray
            jalHairCard.create_hairCard type:hairCardTypeRdb.state

            createHairCardBtn.enabled = false
            enabled_modify_controls()
        )
        else (
            jalHairCard.reset()
            reset_ui()
        )
    )

    on hairCardLengthSpn changed newVal do modify_hairCard()
    on hairCardWidthSpn changed newVal do modify_hairCard()
    on hairCardLengthsegsSpn changed newVal do modify_hairCard()
    on hairCardWidthsegsSpn changed newVal do modify_hairCard()
    on hairCardRotSpn changed newVal do modify_hairCard()
    on hairCardTwistSpn changed newVal do modify_hairCard()
    on hairCardBendSpn changed newVal do modify_hairCard()
    on hairCardTaperSpn changed newVal do modify_hairCard()

    on doneBtn pressed do (
        jalHairCard.reset()
        reset_ui()
    )
)
