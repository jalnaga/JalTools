rollout genFacsRollout "Template - FACS Generator" (
    fn pickFilter inObj = classOf inObj == Editable_Poly
    button loadSceneBtn "Load Template"
    button oriFacsBtn "Select FACS" height:30
    pickButton oriNeutralBtn "Pick Neutral FCage" height:30 autoDisplay:true filter:pickFilter
    group "Generate" (
        pickButton hUnivBtn "Pick HUniv Mesh" height:30 autoDisplay:true filter:pickFilter
        button oriHMeshArrayBtn "Select Highpoly Meshes" height:30
        button genFacsBtn "Gen FACS" offset:[0, 5] height:30
    )

    on oriFacsBtn pressed do (
        local selObjArray = getCurrentSelection() as Array
        local result = facs.set_oriTarget selObjArray "_"
        if result then oriFacsBtn.text = "Ready"
    )

    on oriNeutralBtn picked pickedObj do (
        facs.set_oriNeutralMesh pickedObj
    )

    on hUnivBtn picked pickedObj do (
        facs.set_highUnivMesh pickedObj
    )

    on oriHMeshArrayBtn pressed do (
        local selObjArray = getCurrentSelection() as Array
        local result = facs.set_hightMeshArrah selObjArray
        if result then oriHMeshArrayBtn.text = "Ready"
    )

    on genFacsBtn pressed do (
        facs.load_vertMatchInfo vertMatchXml
        facs.gen_targets_from_highMesh()
    )
)
