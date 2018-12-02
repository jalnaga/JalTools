/*******************************/
/* Animation Library
/*******************************/
struct _Anim (
    fn rotate_local inObj rx ry rz = (
        local currentMatrix = inObj.transform

        preRotate currentMatrix (eulertoquat (eulerAngles rx ry rz))
        inObj.transform = currentMatrix
    ),

    fn move_local inObj mx my mz = (
        local currentMatrix = inObj.transform
        
        PreTranslate currentMatrix [mx, my, mz]
        inObj.transform = currentMatrix
    ),

    fn reset_transform_controller inObj = (
        if classof inObj != Biped_Object then (
            inObj.position.controller = Position_XYZ()
            inObj.rotation.controller = Euler_XYZ()
            inObj.scale.controller = Bezier_Scale()
        )
    ),

    fn freeze_transform inObj = (
        local CurObj = inObj 

        if classof CurObj.rotation.controller != Rotation_Layer do (
            -- freeze rotation      
            CurObj.rotation.controller = Euler_Xyz()
            CurObj.rotation.controller = Rotation_list()
            CurObj.rotation.controller.available.controller = Euler_xyz()
            
            CurObj.rotation.controller.setname 1 "Frozen Rotation"
            CurObj.rotation.controller.setname 2 "Zero Euler XYZ"
        
            CurObj.rotation.controller.SetActive 2
        )
        if classof CurObj.position.controller != Position_Layer do (
            -- freeze position
            CurObj.position.controller = Bezier_Position()
            CurObj.position.controller = position_list()
            CurObj.position.controller.available.controller = Position_XYZ()

            CurObj.position.controller.setname 1 "Frozen Position"
            CurObj.position.controller.setname 2 "Zero Pos XYZ"
            
            CurObj.position.controller.SetActive 2      

            -- position to zero
            CurObj.Position.controller[2].x_Position = 0
            CurObj.Position.controller[2].y_Position = 0
            CurObj.Position.controller[2].z_Position = 0
        )
    ),

    fn collape_anim_transform inObj startFrame:animationRange.start endFrame:animationRange.end = (
        disableSceneRedraw()
        progressStart ("Collapse transform " + inObj.name + "...")

        local p = point()
        for k = startFrame to endFrame do (
            at time k (
                with animate on p.transform = inObj.transform
            )
        )

        inObj.transform.controller = transform_script()
        inObj.transform.controller = prs()

        for k = startFrame to endFrame do (
            at time k (
                with animate on (
                    in coordsys (transmatrix inObj.transform.pos) inObj.rotation = inverse p.transform.rotation
                    in coordsys world inObj.position = p.transform.position
                    inObj.scale = p.scale
                )
            )
            progressUpdate (100 * k / endFrame)
        )

        if startFrame != animationRange.start then (
            deselectKeys inObj.transform.controller
            selectKeys inObj.transform.controller animationRange.start
            deleteKeys inObj.transform.controller #selection
            deselectKeys inObj.transform.controller
        )
        
        delete p
        progressEnd()
        enableSceneRedraw()
    ),

    fn match_anim_transform inObj inTarget startFrame:animationRange.start endFrame:animationRange.end = (
        if (isValidNode inObj) and (isValidNode inTarget) then (
            disableSceneRedraw()
            progressStart ("Match transform " + inObj.name + " to " + inTarget.name)

            local p = point()
            for k = startFrame to endFrame do (
                at time k (
                    with animate on p.transform = inTarget.transform
                )

                deselectKeys inObj.transform.controller
                selectKeys inObj.transform.controller k
                deleteKeys inObj.transform.controller #selection
                deselectKeys inObj.transform.controller
            )

            progressUpdate 20

            if startFrame != animationRange.start then (
                deselectKeys p.transform.controller
                selectKeys p.transform.controller animationRange.start
                deleteKeys p.transform.controller #selection
                deselectKeys p.transform.controller
            )

            progressUpdate 25

            local posKeyArray = inTarget.pos.controller.keys
            local rotKeyArray = inTarget.rotation.controller.keys
            local scaleKeyArray = inTarget.scale.controller.keys

            at time startFrame (
                with animate on inObj.transform = p.transform
            )
            at time endFrame (
                with animate on inObj.transform = p.transform
            )

            for key in posKeyArray do (
                if key.time >= startFrame and key.time <= endFrame then (
                    at time key.time (
                        with animate on inObj.transform = p.transform
                    )
                )
            )
            progressUpdate 40
            for key in rotKeyArray do (
                if key.time >= startFrame and key.time <= endFrame then (
                    at time key.time (
                        with animate on inObj.transform = p.transform
                    )
                )
            )
            progressUpdate 60
            for key in scaleKeyArray do (
                if key.time >= startFrame and key.time <= endFrame then (
                    at time key.time (
                        with animate on inObj.transform = p.transform
                    )
                )
            )
            progressUpdate 80

            delete p

            progressUpdate 100
            progressEnd()
            enableSceneRedraw()
        )
    ),

    fn create_average_pos_transform inTargetArray = (
        local posConstDum = Point()
        local targetPosConstraint = Position_Constraint()
        local targetWeight = 100.0 / (inTargetArray.count + 1)

        posConstDum.position.controller = targetPosConstraint
        for item in inTargetArray do targetPosConstraint.appendTarget item targetWeight
        
        local returnTransform = copy posConstDum.transform
        delete posConstDum
    
        returnTransform
    ),

    fn create_average_rot_transform inTargetArray = (
        local rotConstDum = Point()
        local targetOriConstraint = Orientation_Constraint()
        local targetWeight = 100.0 / (inTargetArray.count + 1)

        rotConstDum.rotation.controller = targetOriConstraint
        for item in inTargetArray do targetOriConstraint.appendTarget item targetWeight
    
        local returnTransform = copy rotConstDum.transform
        delete rotConstDum
    
        returnTransform
    )
)
