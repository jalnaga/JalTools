rollout modFacsRollout "Template - FACS Modifier" (
    fn pickFilter inObj = classOf inObj == Editable_Poly
    button loadSceneBtn "Load Template"
    button oriFacsBtn "Select FACS" height:30
    pickButton oriNeutralBtn "Pick Neutral FCage" height:30 autoDisplay:true filter:pickFilter
    group "Modify" (
        pickButton newNeutralBtn "Pick New Neutral FCage" height:30 autoDisplay:true filter:pickFilter
        button modFACSBtn "Mod. FACS" width:130 height:30 offset:[0, 5]
    )

    on oriFacsBtn pressed do (
        local selObjArray = getCurrentSelection() as Array
        local result = facs.set_oriTarget selObjArray "_"
        if result then oriFacsBtn.text = "Ready"
    )

    on oriNeutralBtn picked pickedObj do (
        facs.set_oriNeutralMesh pickedObj
    )

    on newNeutralBtn picked pickedObj do (
        facs.set_newNeutralMesh pickedObj
    )

    on modFACSBtn pressed do (
        facs.modify_targets_to_newNeutralMesh()
    )
)
