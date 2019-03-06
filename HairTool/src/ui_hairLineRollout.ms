rollout hairLineRollout "Guide Line" (
    pickButton hairMeshPickBtn "Pick Hair Mesh" autoDisplay:true across:2
    button splineDetachBtn "Detach Spline" autoDisplay:true
    button createLineBtn "Create Line" enabled:false
    group "Generate from Hair Modifier" (
        button createGuideLineFromHairModBtn "Create Line from Hair" enabled:false
        button genLineFromHairBtn "Gen Line" enabled:false
    )

    include "hairLine.ms"

    local jalHairLine = __HairLine()

    fn reset_ui = (
        hairMeshPickBtn.object = undefined
        hairMeshPickBtn.text = "Pick Hair Mesh"
        createLineBtn.enabled = false
        createGuideLineFromHairModBtn.enabled = false
        genLineFromHairBtn.enabled = false
    )

    on hairMeshPickBtn picked inArg do (
        if (jalHairLine.is_valid_hairMesh inArg) then (
            jalHairLine.set_hairMesh inArg
            createLineBtn.enabled = true
            createGuideLineFromHairModBtn.enabled = true
        )
        else (
            jalHairLine.reset()
            reset_ui()
            messageBox "Please Select...\n   -Editable Poly which has\n   -Material ID 2"
        )
    )

    on hairMeshPickBtn rightclick do (
        jalHairLine.reset()
        reset_ui()
    )

    on splineDetachBtn pressed do (
        local selSpline = for item in selection where (classOf item == SplineShape) collect item
        for item in selSpline do (
            jalHairLine.detach_spline_to_hairLine item
        )
    )

    on createLineBtn pressed do (
        jalHairLine.create_hairLine hairMeshPickBtn.object
        reset_ui()
    )
)
