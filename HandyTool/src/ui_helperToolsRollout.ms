rollout helperToolsRollout "Helper" (
    button createParentHelperBtn "Parent" width:60 across:3
    button createHelperBtn "Helper" width:60 toolTip:"R Click: Create 2 helpers"
    button createExpHelperBtn "ExpTM" width:60
    checkbox mirrorCkb "Mirror" across:2 align:#right offset:[-5, 3]
    checkbutton createHelperOnSurfaceBtn "Create on Surface" width:120
    radioButtons helperTypeRdo labels:#("Box", "Cross", "Axis", "Center") across:2 columns:2
    spinner helperSizeSpn "Size:" offset:[0, 10]

    struct _HelperOnSurface (
        targetNode = undefined,
        helperSize = 1,
        bMirror = false,
        helperGenTool,
        toggleBtn = createHelperOnSurfaceBtn,

        fn make_helper inHit = (
            if inHit != undefined and targetNode != undefined then (
                local pointName = (jal.helper.gen_helper_name_from_obj targetNode)[1]
                local genPoint = jal.helper.create_point pointName size:helperSize boxToggle:true pointColor:(color 14 255 2) pos:[0,0,0]

                local zVector = inHit.Dir
                local yVector = [0,0,1]
                local xVector = normalize (cross yVector zVector)
                yVector = normalize (cross zVector xVector)
                genPoint.transform = matrix3 xVector yVector zVector inHit.pos
                
                if bMirror then (
                    if genPoint.position.x > 0 then genPoint.name = jal.name.replace_side genPoint.name "L"
                    if genPoint.position.x < 0 then genPoint.name = jal.name.replace_side genPoint.name "R"
                )
                genPoint.name = jal.name.gen_uniqueName genPoint.name
            )
        ),

        fn stop_tool = (
            stopTool helperGenTool
            toggleBtn.checked = false
        ),

        fn run_tool = (
            helperGenTool = tool mouseHit (
                on mousePoint clickNo do (
                    if clickNo > 1 then (
                        local r = (mapScreenToWorldRay mouse.pos)

                        local hit = intersectRay targetNode r
                        make_helper hit

                        if bMirror then (
                            hit = intersectRay targetNode (ray (r.pos*[-1,1,1]) (r.dir*[-1,1,1]))
                            make_helper hit
                        )
                    )
                )

                on mouseAbort clickNo do (
                    if clickNo > 1 then stop_tool()
                )
            )
            startTool helperGenTool
        )
    )

    fn create_average_pos_transform inTargetArray = (
        local posConstDum = Point()

        jal.const.assign_pos_const_multi posConstDum inTargetArray
        
        local returnTransform = copy posConstDum.transform
        delete posConstDum

        returnTransform
    )

    fn create_average_rot_transform inTargetArray = (
        local rotConstDum = Point()

        jal.const.assign_rot_const_multi rotConstDum inTargetArray
        
        local returnTransform = copy rotConstDum.transform
        delete rotConstDum

        returnTransform
    )

    local helperOnSurf = _HelperOnSurface()

    on createParentHelperBtn pressed do (
        undo on (
            jal.helper.create_parent_helper()
        )
    )

    on createHelperBtn pressed do (
        undo on (
            local selArray = getCurrentSelection()
            local tempTransform = matrix3 1
            local keyPressed = 0
            
            if keyboard.shiftPressed then (
                tempTransform.rotation = (create_average_rot_transform selArray).rotation
                keyPressed += 1
            )
            if keyboard.controlPressed then (
                tempTransform.pos = (create_average_pos_transform selArray).pos
                keyPressed += 1
            )
            
            if keyPressed > 0 then (
                local dumName = jal.helper.gen_helper_name_from_obj selArray[1]
                local dumShape = jal.helper.gen_helper_shape_from_obj selArray[1]
                #(helperSize, crossToggle, boxToggle)
                local averageDum = jal.helper.create_point dumName[1] size:dumShape[1] boxToggle:dumShape[3] crossToggle:dumShape[2]
                averageDum.transform = tempTransform
            )
            else jal.helper.create_helper()
        )
    )

    on createHelperBtn rightclick do (
        undo on (
            jal.helper.create_helper makeTwo:true
        )
    )

    on createExpHelperBtn pressed do (
        undo on (
            jal.helper.create_expTm()
        )
    )

    on createHelperOnSurfaceBtn changed state do (
        if state then (
            if selection.count == 1 then (
                helperOnSurf.targetNode = (getCurrentSelection() as Array)[1]
                helperOnSurf.bMirror = mirrorCkb.checked
                helperOnSurf.run_tool()
            )
        )
        else (
            if helperOnSurf.targetNode != undefined then (
                helperOnSurf.stop_tool()
                createHelperOnSurfaceBtn.checked = false
            )
        )
    )

    on helperSizeSpn changed val do (
        undo on (
            if selection.count > 0 then (
                for item in selection do jal.helper.set_size item val
            )
        )
    )

    on helperTypeRdo changed state do (
        undo on (
            if selection.count > 0 then (
                #("Box", "Cross", "Axis", "Center")
                case state of (
                    1: for item in selection do jal.helper.set_shape_to_box item
                    2: for item in selection do jal.helper.set_shape_to_cross item
                    3: for item in selection do jal.helper.set_shape_to_axis item
                    4: for item in selection do jal.helper.set_shape_to_center item
                )
            )
        )
    )
)
