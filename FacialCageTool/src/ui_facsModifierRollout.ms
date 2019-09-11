rollout facsModifierRollout "Template - FACS Modifier" (
    fn pickFilter inObj = classOf inObj == Editable_Poly
    button loadSceneBtn "Load Template"
    group "FACS" (
        button oriFacsBtn "Get FACS" width:130 height:30
        pickButton oriNeutralBtn "Get Neutral" width:130 height:30 autoDisplay:true filter:pickFilter
        pickButton newNeutralBtn "Get New FCage" width:130 height:30 autoDisplay:true filter:pickFilter
    )
    button genNewFACSBtn "Gen New FACS" width:130 height:30 offset:[0, 5]

    on loadSceneBtn pressed do (
        if (checkForSave()) then (
            saveMaxFile (maxFilePath + maxFileName)
        )
        loadMaxFile facialRigFullName quiet:true
    )

    on oriFacsBtn pressed do (
        local selObjArray = getCurrentSelection() as Array
        local result = facs.set_oriTarget selObjArray
        if result then oriFacsBtn.text = "Ready"
    )

    on oriNeutralBtn picked pickedObj do (
        facs.set_oriNeutralMesh pickedObj
    )

    on newNeutralBtn picked pickedObj do (
        facs.set_newNeutralMesh pickedObj
    )

    on genNewFACSBtn pressed do (
        facs.gen_newTargetArray()
    )
)
