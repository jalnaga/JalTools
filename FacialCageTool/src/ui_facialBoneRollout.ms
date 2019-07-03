rollout facialBoneRollout "Bone Generator" (
    fn filter_facialCageMesh inObj = classOf inObj.baseObject == Editable_Poly and inObj.mesh.numverts < facialCageMaxVertNum
    pickbutton meshPickBtn "Pick Facial Cage Mesh" autoDisplay:true filter:filter_facialCageMesh width:160 height:40 across:2 align:#left
    button genPlacerBtn "Gen. Placer" enabled:false width:70 height:40 align:#right
    checkBox alignNormalCkb "Align to Normal" across:2
    checkBox rotConstCkb "Rotation"
    button genBoneBtn "Generate Bone"
    button assignSkinBtn "Assign Skin"

    local facialCageLayerName = "FCage"
    local facialPlacerLayerName = "FCage_Placer"
    local facialBoneLayerName = "FCage_Bone"

    fn reset_ui = (
        meshPickBtn.object = undefined
        meshPickBtn.text = "Pick Facial Cage Mesh"
    )

    fn reset_layer = (
    )

    on meshPickBtn picked inObj do (
        if inObj != undefined then fCage.cageMesh = inObj
        genPlacerBtn.enabled = true
        jal.layer.create_layer_from_array #(fCage.cageMesh) facialCageLayerName
    )

    on meshPickBtn rightclick do (
        if meshPickBtn.object != undefined then (
            if (queryBox ("Delete " + meshPickBtn.object.name + "?")) then delete fCage.cageMesh
        )
        if (jal.layer.get_layer_number facialPlacerLayerName) != false then jal.layer.delete_layer facialPlacerLayerName forceDelete:true
        if (jal.layer.get_layer_number facialBoneLayerName) != false then jal.layer.delete_layer facialBoneLayerName forceDelete:true

        fCage.cageMesh = undefined
        fCage.reset()
        jal.layer.delete_layer facialCageLayerName forceDelete:false
        reset_ui()
    )

    on genPlacerBtn pressed do (
        max create mode
        fCage.gen_placer_on_vertex alignToVertexNormal:alignNormalCkb.checked useRotConst:rotConstCkb.checked
        jal.layer.create_layer_from_array fCage.placerArray facialPlacerLayerName
        jal.layer.set_parent_layer facialPlacerLayerName facialCageLayerName
        gc()
    )

    on genPlacerBtn rightclick do (
        jal.layer.delete_layer facialPlacerLayerName forceDelete:true
        fCage.placerArray = #()
        disable_bipPick_ui()
        gc light:true
    )

    on genBoneBtn pressed do (
        fCage.gen_bone_on_placer()
        if not(alignNormalCkb.checked) and not(rotConstCkb.checked) then (
            for i = 1 to fCage.boneArray.count by 2 do (
                jal.anim.rotate_local fCage.boneArray[i] 0 -90 0
            )
        )
        jal.layer.create_layer_from_array fCage.boneArray facialBoneLayerName
        jal.layer.set_parent_layer facialBoneLayerName facialCageLayerName
    )

    on assignSkinBtn pressed do (
        fCage.create_skinMesh()
        fCage.add_skinBone()
        fCage.set_skinWeight()
    )
)
