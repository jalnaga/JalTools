rollout hairGuideRollout "Hair Line" (
    pickButton hairMeshPickBtn "Pick Hair Mesh" autoDisplay:true across:2
    button splineDetachBtn "Detach Spline" autoDisplay:true
    button createLineBtn "Create Line" enabled:false
    group "" (
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

    on splineDetachBtn pressed do (
        local selSpline = for item in selection where (classOf item == SplineShape) collect item
        for item in selSpline do (
            jalHairLine.detach_spline_to_hairLine item
        )
    )

    on hairMeshPickBtn rightclick do (
        jalHairLine.reset()
        reset_ui()
    )

    on createLineBtn pressed do (
        jalHairLine.create_hairLine hairMeshPickBtn.object
        reset_ui()
    )

    on createGuideLineFromHairModBtn pressed do (
        jalHairLine.create_guideline_from_hairMod hairMeshPickBtn.object
        genLineFromHairBtn.enabled = true
    )

    on genLineFromHairBtn pressed do (
        jalHairLine.create_hairline_from_hairMode()
        jalHairLine.reset()
        reset_ui()
    )
)
