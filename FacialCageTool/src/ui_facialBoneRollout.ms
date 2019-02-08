rollout facialBoneRollout "Bone Generator" (
    fn filter_facialCageMesh inObj = classOf inObj == Editable_Poly and inObj.mesh.numverts < facialCageMaxVertNum
    pickbutton meshPickBtn "Pick Facial Cage Mesh" autoDisplay:true filter:filter_facialCageMesh width:160 height:40 across:2 align:#left
    button genPlacerBtn "Gen. Placer" enabled:false width:70 height:40 align:#right
    group "Bip Pick" (
        pickbutton bipHeadPickBtn "Pick Head Bone" autoDisplay:true across:2 enabled:false width:100 height:25 align:#left
        pickbutton bipNeckPickBtn "Pick Neck" autoDisplay:true enabled:false width:100 height:25 align:#right
        pickbutton bipJawStartPickBtn "Pick Jaw Start" autoDisplay:true across:2 enabled:false width:100 height:25 align:#left
        pickbutton bipJawEndPickBtn "Pick Jaw End" autoDisplay:true enabled:false width:100 height:25 align:#right
    )
    button genBoneBtn "Generate Bone!" enabled:false width:180 height:40 offset:[0, 10]

    local facialCageLayerName = "FCage"
    local facialPlacerLayerName = "FCage_Placer"
    local facialBoneLayerName = "FCage_Bone"

    fn reset_ui = (
        meshPickBtn.object = undefined
        meshPickBtn.text = "Pick Facial Cage Mesh"
        genPlacerBtn.enabled = false
        bipHeadPickBtn.object = undefined
        bipNeckPickBtn.object = undefined
        bipJawStartPickBtn.object = undefined
        bipJawEndPickBtn.object = undefined
        bipHeadPickBtn.enabled = false
        bipNeckPickBtn.enabled = false
        bipJawStartPickBtn.enabled = false
        bipJawEndPickBtn.enabled = false
    )

    fn disable_bipPick_ui = (
        bipHeadPickBtn.object = undefined
        bipNeckPickBtn.object = undefined
        bipJawStartPickBtn.object = undefined
        bipHeadPickBtn.enabled = false
        bipNeckPickBtn.enabled = false
        bipJawStartPickBtn.enabled = false
        bipJawEndPickBtn.enabled = false
    )

    fn enable_bipPick_ui = (
        bipHeadPickBtn.enabled = true
        bipNeckPickBtn.enabled = true
        bipJawStartPickBtn.enabled = true
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
        fCage.gen_placer_on_vertex()
        jal.layer.create_layer_from_array fCage.placerArray facialPlacerLayerName
        jal.layer.set_parent_layer facialPlacerLayerName facialCageLayerName
        enable_bipPick_ui()
        gc()
    )

    on genPlacerBtn rightclick do (
        jal.layer.delete_layer facialPlacerLayerName forceDelete:true
        fCage.placerArray = #()
        disable_bipPick_ui()
        gc light:true
    )

    on bipHeadPickBtn picked inObj do (
        fCage.set_bipHead inObj
    )

    on bipHeadPickBtn rightclick do (
        fCage.set_bipHead undefined
        bipHeadPickBtn.object = undefined
    )

    on bipNeckPickBtn picked inObj do (
        fCage.set_bipNeck inObj
    )

    on bipNeckPickBtn rightclick do (
        fCage.set_bipNeck undefined
        bipNeckPickBtn.object = undefined
    )

    on bipJawStartPickBtn picked inObj do (
        bipJawEndPickBtn.enabled = true
    )

    on bipJawStartPickBtn rightclick do (
        bipJawStartPickBtn.object = undefined
        bipJawEndPickBtn.object = undefined
        bipJawEndPickBtn.enabled = false
    )

    on bipJawEndPickBtn picked inObj do (
        genBoneBtn.enabled = true
    )

    on bipJawEndPickBtn rightclick do (
        bipJawEndPickBtn.object = undefined
        genBoneBtn.enabled = false
    )

    on genBoneBtn pressed do (
        if bipHeadPickBtn.object != undefined and bipNeckPickBtn.object != undefined and bipJawStartPickBtn.object != undefined and bipJawEndPickBtn.object != undefined then (
            max create mode
            fCage.gen_headBone()
            fCage.gen_jawBone bipJawStartPickBtn.object bipJawEndPickBtn.object
            fCage.gen_bone_on_placer()

            jal.anim.rotate_local fCage.jawBone[1] 90 0 0
            fCage.jawBone[1].parent = fCage.headBone[1]

            jal.prog.start_progress "Assigning anim controlls..."
            for i = 1 to fCage.boneArray.count by 2 do (
                local prevParent = fCage.boneArray[i].parent
                fCage.boneArray[i].parent = fCage.headBone[1]
                jal.const.assign_pos_const fCage.boneArray[i] prevParent
                jal.const.assign_rot_const fCage.boneArray[i] prevParent

                jal.prog.update_progress i fCage.boneArray.count
            )
            jal.prog.end_progress()

            jal.layer.create_layer_from_array fCage.boneArray facialBoneLayerName
            jal.layer.set_parent_layer facialBoneLayerName facialCageLayerName
            jal.layer.create_layer_from_array fCage.headBone facialBoneLayerName
            jal.layer.create_layer_from_array fCage.jawBone facialBoneLayerName
        )
    )
)
