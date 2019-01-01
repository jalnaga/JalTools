rollout hairGuideRollout "Hair Line" (
    pickButton hairMeshPickBtn "Pick Hair Mesh" autoDisplay:true
    button createLineBtn "Create Line" enabled:false
    group "" (
        button createLineFromHairBtn "Create Line from Hair" enabled:false
        Spinner hairDensitySpn "Density:" type:#integer range:[1, 1000, 10] enabled:false
        button genLineFromHairBtn "Gen Line" enabled:false
    )

    include "hairLine.ms"

    local jalHairLine = __HairLine()

    on hairMeshPickBtn picked inArg do (
        if (jalHairLine.is_valid_hairMesh inArg) then (
            jalHairLine.set_hairMesh inArg
            createLineBtn.enabled = true
            createLineFromHairBtn.enabled = true
        )
        else (
            jalHairLine.reset()
            hairMeshPickBtn.object = undefined
            hairMeshPickBtn.text = "Pick Hair Mesh"
            messageBox "The node is...\n   -Not Editable Poly\n   -No Material ID 2"
        )
    )

    on hairMeshPickBtn rightclick do (
        jalHairLine.reset()
        hairMeshPickBtn.object = undefined
        hairMeshPickBtn.text = "Pick Hair Mesh"
        createLineBtn.enabled = false
        createLineFromHairBtn.enabled = false
        hairDensitySpn.enabled = false
        genLineFromHairBtn.enabled = false
    )

    on createLineBtn pressed do (
    )

    on createLineFromHairBtn pressed do (
        hairDensitySpn.enabled = true
        genLineFromHairBtn.enabled = true
    )
)
