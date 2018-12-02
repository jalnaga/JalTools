rollout joystickRollout "Joystcik Tool" (
    editText nameTxt "Name: "
    radiobuttons typeRdo "Type: " labels:#("Square", "Horizontal", "Vertical")
    spinner xMinSpn "xMin:" range:[-100.0, 0.0, -100.0] across:2
    spinner yMinSpn "yMin:" range:[-100.0, 0.0, -100.0]
    spinner xMaxSpn "xMax:" range:[0.0, 100.0, 100.0] across:2
    spinner yMaxSpn "yMax:" range:[0.0, 100.0, 100.0]
    button createBtn "Create!" width:120 height:30

    local joyName = ""

    on nameTxt changed inTxt do (
        joyName = inTxt
    )

    on typeRdo changed stat do (
        case typeRdo.state of (
            1: (
                xMinSpn.enabled = true
                yMinSpn.enabled = true
                xMaxSpn.enabled = true
                yMaxSpn.enabled = true
            )
            2: (
                xMinSpn.enabled = true
                yMinSpn.enabled = false
                xMaxSpn.enabled = true
                yMaxSpn.enabled = false
            )
            3: (
                xMinSpn.enabled = false
                yMinSpn.enabled = true
                xMaxSpn.enabled = false
                yMaxSpn.enabled = true
            )
        )
    )

    on createBtn pressed do (
        local bCaption = false
        
        if joyName == "" then bCaption = true
        case typeRdo.state of (
            1: jal.joystick.create_square joyName 5 noCaption:bCaption xMin:xMinSpn.value yMin:yMinSpn.value xMax:xMaxSpn.value yMax:yMaxSpn.value
            2: jal.joystick.create_horizontal joyName 5 noCaption:bCaption min:xMinSpn.value max:xMaxSpn.value
            3: jal.joystick.create_vertical joyName 5 noCaption:bCaption min:yMinSpn.value max:yMaxSpn.value
        )
    )
)
