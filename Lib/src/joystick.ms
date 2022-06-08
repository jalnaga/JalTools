struct _Joystick (
    joyName = "",
    controlBox,
    cursor,
    caption,
    minX = -100.0,
    minY = -100.0,
    maxX = 100.0,
    maxY = 100.0,

    fn reset = (
        cursor.position.controller[2].value = [0,0,0]
    ),

    fn delete_all = (
        delete caption
        delete cursor
        delete controlBox
    )
)

struct _JoystickGenerator (
    str, name, anim, const,

    joyName = "",
    controlBoxColor = color 0 198 255,
    cursColor = color 255 194 7 ,
    captionColor = color 255 85 0,
    controlBox,
    cursor,
    caption = undefined,
    minX = -100.0,
    minY = -100.0,
    maxX = 100.0,
    maxY = 100.0,

    fn gen_shapes inName inMinX inMinY inMaxX inMaxY noCaption:false = (
        joyName = inName
        minX = inMinX as Float
        minY = inMinY as Float
        maxX = inMaxX as Float
        maxY = inMaxY as Float
        
        local sizeX = maxX - minX
        local sizeY = maxY - minY

        controlBox = Rectangle length:sizeY width:sizeX cornerRadius:((sizeX/20 + sizeY/20)/2) transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
        controlBox.wirecolor = controlBoxColor
        controlBox.name = name.replace_type joyName "Ctr"
        controlBox.name = name.add_sufix_to_realName controlBox.name "Joystick"

        cursor = Circle radius:((sizeX/10 + sizeY/10)/2) transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])
        cursor.wirecolor = cursColor
        cursor.name = name.replace_type joyName "Ctr"
        cursor.name = name.add_sufix_to_realName cursor.name "Cursor"
        cursor.position = [-(maxX + minX)/2, 0, -(maxY + minY)/2]
        
        if noCaption == false then (
            local displayCaptionText = (name.get_side joyName) + (str.get_filteringChar joyName) + (name.get_realName joyName)
            caption = Text text:displayCaptionText size:((sizeX/2+sizeY/2)/4)  kerning:0 leading:0 transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,sizeY/2])
            caption.wirecolor = captionColor
            caption.name = name.replace_type joyName "Ctr"
            caption.name = name.add_sufix_to_realName caption.name "Caption"
        )
    ),

    fn apply_constraints = (
        if caption != undefined then caption.parent = controlBox
        cursor.parent = controlBox

        anim.freeze_transform cursor

        local activeNum = cursor.position.controller.getActive()
        cursor.position.controller[activeNum][1].controller = float_limit()
        cursor.position.controller[activeNum][2].controller = float_limit()
        
        local xConst = cursor.position.controller[activeNum][1].controller
        local yConst = cursor.position.controller[activeNum][2].controller
        xConst.lower_limit = minX
        xConst.upper_limit = maxX
        yConst.lower_limit = minY
        yConst.upper_limit = maxY
    ),

    fn add_customAttributes = (
        local cursorAtt = attributes joystickCursorAtt (
            parameters params rollout:joysticCursorAttRollout (
                minVal type:#float
                maxVal type:#float
                xValue type:#float
                yValue type:#float
            )

            rollout joysticCursorAttRollout "Joystick" (
                button resetBtn "Reset"

                on resetBtn pressed do $.position.controller[2].value = [0,0,0]
            )
        )

        local cursorMod = EmptyModifier()
        cursorMod.name = "Joystick Cursor"
        addModifier cursor cursorMod
        custAttributes.add cursor.modifiers["Joystick Cursor"] cursorAtt
    ),

    fn add_wireParam = (
        paramWire.connect controlBox.baseObject[#Width] cursor.pos.controller.Zero_Pos_XYZ.controller.X_Position.controller[#Limits][#Upper_Limit] "Width/2"
        paramWire.connect controlBox.baseObject[#Width] cursor.pos.controller.Zero_Pos_XYZ.controller.X_Position.controller[#Limits][#Lower_Limit] "-Width/2"
        paramWire.connect controlBox.baseObject[#Length] cursor.pos.controller.Zero_Pos_XYZ.controller.Y_Position.controller[#Limits][#Upper_Limit] "Length/2"
        paramWire.connect controlBox.baseObject[#Length] cursor.pos.controller.Zero_Pos_XYZ.controller.Y_Position.controller[#Limits][#Lower_Limit] "-Length/2"

        paramWire.connect controlBox.baseObject[#Width] cursor.modifiers[#Joystick_Cursor].joystickCursorAtt[#width] "Width"
        paramWire.connect controlBox.baseObject[#Length] cursor.modifiers[#Joystick_Cursor].joystickCursorAtt[#height] "Length"
    ),

    fn create inName inMinX inMinY inMaxX inMaxY noCaption:false = (
        gen_shapes inName inMinX inMinY inMaxX inMaxY noCaption:noCaption
        apply_constraints()
        add_customAttributes()

        local joystick = _Joystick joyName:joyName minX:inMinX minY:inMinY maxX:inManX maxY:inManY controlBox:controlBox cursor:cursor caption:caption
        
        joystick
    ),

    fn create_square inName inSize noCaption:false xMin:-100.0 yMin:-100.0 xMax:100 yMax:100 = (
        local joystick = _Joystick()
        joystick = create inName xMin yMin xMax yMax noCaption:noCaption
        setTransformLockFlags joystick.cursor #{4,5,6,7,8,9}

        in coordsys local scale joystick.controlBox [inSize/200.0, inSize/200.0, 1.0]

        joystick
    ),

    fn create_horizontal inName inSize noCaption:false min:-100.0 max:100 = (
        local joystick = _Joystick()
        joystick = create inName min -10.0 max 10 noCaption:noCaption
        setTransformLockFlags joystick.cursor #{2,3,4,5,6,7,8,9}

        in coordsys local scale joystick.controlBox [inSize/200.0, inSize/200.0, 1.0]

        joystick
    ),

    fn create_vertical inName inSize noCaption:false min:-100.0 max:100= (
        local joystick = _Joystick()
        joystick = create inName -10.0 min 10.0 max noCaption:noCaption
        setTransformLockFlags joystick.cursor #{1,3,4,5,6,7,8,9}

        in coordsys local scale joystick.controlBox [inSize / 200.0, inSize / 200.0, 1.0]

        joystick
    )
)
