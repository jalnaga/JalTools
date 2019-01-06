struct __HairCardShape (
    object,
    length,
    width,
    lengthsegs,
    widthsegs,
    rotation,
    twist,
    bend,
    taper,
    scaleCurve,
    uniform,
    beforeRot,
    xOffset,
    zOffset
)
struct __HairCard (
    hairLineArray = #(),
    hairCardArray = #(),
    hairMatArray = #("Wide Hair", "Narrow Hair"),
    hairCardNumPerMatArray = #(5, 10),

    fn reset = (
        hairLineArray = #()
        hairCardArray = #()
        hairMatArray = #("Wide Hair", "Narrow Hair")
        hairCardNumPerMatArray = #(5, 10)

        gc()
    ),

    fn set_hairCardNumPerMatArray inMatIndex inNum = (
        hairCardNumPerMatArray[inMatIndex] = inNum
    ),

    fn set_hairLineArray inArray = (
        hairLineArray = deepCopy inArray
    ),

    fn create_plane matIndex:1 = (
        local hairPlane = Plane length:50 width:3 lengthsegs:20 widthsegs:2
        local hairPlaneUVWMod = uvwmap()
        local hairPlaneBendMod = Bend()

        SetCommandPanelTaskMode #modify
        select hairPlane

        addModifier hairPlane hairPlaneUVWMod
        hairPlaneUVWMod.name = "HairPlaneUVW"
        hairPlaneUVWMod.maptype = 0
        hairPlaneUVWMod.length = hairPlane.length
        hairPlaneUVWMod.width = hairPlane.width
        hairPlaneUVWMod.utile = 1.0/hairCardNumPerMatArray[matIndex]
        hairPlaneUVWMod.axis = 2
        hairPlane.modifiers[#HairPlaneUVW].gizmo.position = [-((random 0 (hairCardNumPerMatArray[matIndex]-1)) * hairPlane.width), 0.0, 0.0]

        addModifier hairPlane hairPlaneBendMod
        hairPlaneBendMod.name = "HairPlaneBend"
        hairPlaneBendMod.angle = 90.0
        hairPlaneBendMod.direction = 0.0
        hairPlaneBendMod.axis = 0

        clearSelection()

        hairPlane
    ),

    fn is_hairPlane inHairPlane = (
        local returnVal = false
        if inHairPlane.modifiers[#HairPlaneUVW] != undefined and inHairPlane.modifiers[#HairPathDeform] != undefined and inHairPlane.modifiers[#HairPlaneBend] != undefined then returnVal = true
        else returnVal = false

        returnVal
    ),

    fn modify_plane_shape inHairPlane inLength inWidth inLengthsegs inWidthsegs inRotation inTwist inBend inTaper = (
        if (is_hairPlane inHairPlane) then (
            SetCommandPanelTaskMode #modify
            select inHairPlane

            local uvwGizmoOriXIndex = (inHairPlane.modifiers[#HairPlaneUVW].gizmo.position.x) / inHairPlane.width
            inHairPlane.width = inWidth
            inHairPlane.lengthsegs = inLengthsegs
            inHairPlane.widthsegs = inWidthsegs

            inHairPlane.modifiers[#HairPlaneUVW].width = inWidth
            inHairPlane.modifiers[#HairPlaneUVW].gizmo.position = [(uvwGizmoOriXIndex * inHairPlane.width), 0.0, 0.0]

            inHairPlane.modifiers[#HairPlaneBend].angle = inBend
            inHairPlane.modifiers[#HairPlaneBend].direction = inTaper

            inHairPlane.modifiers[#HairPathDeform].rotation = inRotation
            inHairPlane.modifiers[#HairPathDeform].twist = inTwist
            inHairPlane.modifiers[#HairPathDeform].auto_amount = inLength
            clearSelection()
        )
    ),

    fn add_path_deform inHairPlane inHairLine = (
        local hairPathDeformMod = Path_Deform2 ()
        if inHairPlane.modifiers[#HairPlaneUVW] != undefined then (
            addModifier inHairPlane hairPathDeformMod
            hairPathDeformMod.name = "HairPathDeform"
            hairPathDeformMod.AdaptiveUpVector = on
            hairPathDeformMod.spline = inHairLine
            hairPathDeformMod.auto_stretch = on
            hairPathDeformMod.percent_along_path = 100
            hairPathDeformMod.axis = 1
            hairPathDeformMod.ScaleEnable = on
            hairPathDeformMod.uniform = off
        )
    ),

    fn create_hairCard type:1 = (
        hairCardArray = #()
        for i =1 to hairLineArray.count do (
            local hairCard = create_plane matIndex:type
            add_path_deform hairCard hairLineArray[i]

            append hairCardArray hairCard
        )

        hairCardArray
    ),

    fn get_hairCard_Shape inHairCard = (
        local returnShape = __HairCardShape()
        if inHairCard.modifiers[#HairPlaneUVW] != undefined and inHairCard.modifiers[#HairPathDeform] != undefined and inHairCard.modifiers[#HairPlaneBend] != undefined then (
            returnShape.object = inHairCard
            returnShape.length = inHairCard.modifiers[#HairPathDeform].auto_amount
            returnShape.width = inHairCard.width
            returnShape.lengthsegs = inHairCard.lengthsegs
            returnShape.widthsegs = inHairCard.widthsegs
            returnShape.rotation = inHairCard.modifiers[#HairPathDeform].rotation
            returnShape.twist = inHairCard.modifiers[#HairPathDeform].twist
            returnShape.bend = inHairCard.modifiers[#HairPlaneBend].angle
            returnShape.taper = inHairCard.modifiers[#HairPlaneBend].direction
            --returnShape.scaleCurve = inHairCard.modifiers[#HairPathDeform].scaleCurve.Curve_1
            returnShape.uniform = inHairCard.modifiers[#HairPathDeform].uniform
            returnShape.beforeRot = inHairCard.modifiers[#HairPathDeform].MoveBeforeRotation
            returnShape.xOffset = inHairCard.modifiers[#HairPathDeform].X_OFFSET
            returnShape.zOffset = inHairCard.modifiers[#HairPathDeform].Z_OFFSET
        )

        returnShape
    ),

    fn set_hairCard_Shape inHairCard inShape = (
        local returnShape = __HairCardShape()
        if inHairCard.modifiers[#HairPlaneUVW] != undefined and inHairCard.modifiers[#HairPathDeform] != undefined and inHairCard.modifiers[#HairPlaneBend] != undefined then (
            returnShape.object = inHairCard
            inHairCard.modifiers[#HairPathDeform].auto_amount = inShape.length
            inHairCard.width = inShape.width
            inHairCard.lengthsegs = inShape.lengthsegs
            inHairCard.widthsegs = inShape.widthsegs
            inHairCard.modifiers[#HairPathDeform].rotation = inShape.rotation
            inHairCard.modifiers[#HairPathDeform].twist = inShape.twist
            inHairCard.modifiers[#HairPlaneBend].angle = inShape.bend
            inHairCard.modifiers[#HairPlaneBend].direction = inShape.taper
            --inHairCard.modifiers[#HairPathDeform].scaleCurve.Curve_1 = inShape.scaleCurve
            inHairCard.modifiers[#HairPathDeform].uniform = inShape.uniform
            inHairCard.modifiers[#HairPathDeform].MoveBeforeRotation = inShape.beforeRot
            inHairCard.modifiers[#HairPathDeform].X_OFFSET = inShape.xOffset
            inHairCard.modifiers[#HairPathDeform].Z_OFFSET = inShape.zOffset
            returnShape = get_hairCard_Shape inHairCard
        )

        returnShape
    ),

    fn modifiy_hairCard inHairCardShape = (
            modify_plane_shape inHairCardShape.object inHairCardShape.length inHairCardShape.width inHairCardShape.lengthsegs inHairCardShape.widthsegs inHairCardShape.rotation inHairCardShape.twist inHairCardShape.bend inHairCardShape.taper

            --inHairCardShape.object.modifiers[#HairPathDeform].scaleCurve.Curve_1 == inHairCardShape.scaleCurve
            inHairCardShape.object.modifiers[#HairPathDeform].uniform == inHairCardShape.uniform
            inHairCardShape.object.modifiers[#HairPathDeform].MoveBeforeRotation == inHairCardShape.beforeRot
            inHairCardShape.object.modifiers[#HairPathDeform].X_OFFSET = inHairCardShape.xOffset
            inHairCardShape.object.modifiers[#HairPathDeform].Z_OFFSET = inHairCardShape.zOffset
    ),

    fn modify_uv inHairPlane inHairMatIndex inPosIndex = (
        if (is_hairPlane inHairPlane) then (
            local uPosMul = 1.0/hairCardNumPerMatArray[inHairMatIndex]
            inHairPlane.modifiers[#HairPlaneUVW].gizmo.position = [-((inPosIndex - 1) * inHairPlane.width), 0.0, 0.0]
        )
    )
)
