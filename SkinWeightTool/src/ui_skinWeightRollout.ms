rollout skinWeightRollout "SkinWeight Tool" (
    group "Vertex" (
        button selectByBoneBtn "Select By Bone" height:25 width:120 align:#left across:2
        button selZeroWeightVertBtn "Select Zero" height:25 align:#right
        button shrinkBtn "Shrink" across:4 width:45 height:25 align:#left
        button growBtn "Grow" width:45 height:25
        button ringBtn "Ring" width:45 height:25
        button loopBtn "Loop" width:45 height:25 align:#right
        
        button zeroBtn "0" across:7 width:25 height:25 align:#left
        button p1Btn ".1" width:25 height:25
        button p25Btn ".25" width:25 height:25
        button p5Btn ".5" width:25 height:25
        button p75Btn ".75" width:25 height:25
        button p9Btn ".9" width:25 height:25
        button oneBtn "1" width:25 height:25 align:#right

        button setWeightBtn "Set Weight" across:4 height:35 width:70 align:#left
        spinner weightSpn "" range:[0.0, 1.0, 0.1] type:#float scale:0.01 width:70 offset:[18, 10]
        button addWeightBtn "+" width:30 height:35 offset:[32, 0]
        button minusWeightBtn "-" width:30 height:35 align:#right

        button copyWeightBtn "Copy" across:4 width:48 height:25 align:#left
        button pasteWeightBtn "Paste" width:48 height:25
        button blendWeightBtn "Blend" width:48 height:25
        button removeZeroBtn "rm.Zero" width:48 height:25 align:#right

        label lblSelectedVerts ""

        listBox boneListLbx "" height:8
    )

    group "Selection"(
        checkbox vertexCkb "Vertex" checked:true height:25 across:2
        checkbox  selElementCkb "SelectElement" checked: false height:25
    )

    group "Advanced" (
        checkbox alwaysDeformCkb "Always Deform" checked:true height:25 across:2
        checkbox  showNoEnvelopeCkb "Show No Envelopes" checked: true height:25
        spinner boneAffectLimitSpn "Bones Affect Limit: " fieldWidth:40 type:#integer range:[1, 10, 4] scale:1
        button removeUnusedBonesBtn "Remove Unused Bones"
    )

    timer tmUpdateDelay interval:1000

    local suspendVertSelectionChangeUpdate = false
    local workingSkinMod
    local workingVerts
    local weightBoneListArray = #()

    fn remove_unused_bones inSkinMod weightThresh:0.0001 = (
        local vertCount = skinOps.GetNumberVertices inSkinMod
        local bonesCount = skinOps.GetNumberBones inSkinMod
        local unusedBones = #{1..bonesCount}

        for v = 1 to vertCount do (
            local vertWeightCount = skinOps.GetVertexWeightCount inSkinMod v
            
            for i = 1 to vertWeightCount do (
                local weight = skinOps.GetVertexWeight inSkinMod v i
                if weight >= weightThresh then (
                    local boneID = skinOps.GetVertexWeightBoneID inSkinMod v i
                    unusedBones[boneID] = false
                )
            )
        )
        
        for i = bonesCount to 1 by -1 where unusedBones[i] do (
            skinOps.SelectBone inSkinMod i
            skinOps.RemoveBone inSkinMod
        )
    )

    fn round_number num precision:3 = (
        local multiplier = 10 ^ precision
        ( floor ( (num * multiplier) + 0.5) ) / multiplier
    )

    fn get_formatted_weight weights = (
        weights = makeUniqueArray weights

        if weights.count > 1 then (
            formattedPrint weights[1] format:("0." + 3 as string + "f")
        ) else if weights[1] == undefined then ""
        else
            formattedPrint weights[1] format:("0." + 3 as string + "f")
    )

    fn get_selected_skinVerts inSkinMod = (
        for v = 1 to skinOps.GetNumberVertices inSkinMod where skinOps.IsVertexSelected inSkinMod v == 1 collect v
    )

    fn get_vertex_weight_boneIDs inSkinMod vert = (
        local weightsCount = skinOps.GetVertexWeightCount inSkinMod vert
        for i = 1 to weightsCount collect
            skinOps.GetVertexWeightBoneID inSkinMod vert i
    )

    fn get_current_weights inSkinMod vert = (
        local numBones = skinOps.getNumberBones inSkinMod
        local vertBones = get_vertex_weight_boneIDs inSkinMod vert
        for boneID = 1 to numBones collect (
            local n = findItem vertBones boneID
            if n > 0 then 
                round_number (skinOps.GetVertexWeight inSkinMod vert n)
            else
                undefined
        )
    )

    fn select_zeroWeight_vertex inSkinMod = (
        local numVerts = skinOps.GetNumberVertices inSkinMod
        local returnArray = #()
        
        for v = 1 to numVerts do (
            local weights = get_current_weights inSkinMod v
            local weightVal = 0.0
            for item in weights do if item != undegined then weightVal += item
            if weightVal == 0.0 then append returnArray v
        )
        skinOps.SelectVertices inSkinMod returnArray
        redrawViews()

        returnArray
    )

    fn populate_weightList skinMod verts = (
        local returnArray = #()
        weightBoneListArray = #()

        if isKindOf skinMod skin and verts != undefined then (
            local vertWeights = for v in verts collect (get_current_weights skinMod v)
            local numBones = skinOps.getNumberBones skinMod
            for boneID = 1 to numBones do(
                local weights = for w in vertWeights collect w[boneID]
                local weight = (get_formatted_weight weights)
                if weight != "" then (
                    append returnArray (weight + ": " + (skinOps.GetBoneName skinMod boneID 1))
                    append weightBoneListArray boneID
                )
            )
        )
        returnArray
    )

    fn update_ui = (
        local currentMod = modPanel.getCurrentObject()
        if isKindOf currentMod skin then (
            workingSkinMod = currentMod
            local selectedVerts = get_selected_skinVerts workingSkinMod
            if selectedVerts.count > 0 then workingVerts = selectedVerts
            else workingVerts = undefined
        ) else (
            workingSkinMod = undefined
            workingVerts = undefined
        )
        lblSelectedVerts.text = if workingVerts == undefined then "No vertices selected." \
                                        else if workingVerts.count == 1 then ("Selected vertex: " + (workingVerts[1] - 1) as string) \
                                        else (workingVerts.count as string + " vertices selected.")

        boneListLbx.items = populate_weightList workingSkinMod workingVerts
    )

    fn objectParmams_changed_ch = (
        if not suspendVertSelectionChangeUpdate then (
            local preSkin = workingSkinMod
            local preVerts = workingVerts
            local currentMod = modPanel.getCurrentObject()
            if workingSkinMod != currentMod then 
                update_ui()
            else (
                local selectedVets = get_selected_skinVerts currentMod
                selectedVets = selectedVets as bitArray
                local workingVertsBA = #{}

                if workingVerts != undefined then workingVertsBA = workingVerts as bitArray
                if selectedVets.numberSet != workingVertsBA.numberSet \
                        or (selectedVets - workingVertsBA).numberSet != 0 \
                        or (workingVertsBA - selectedVets).numberSet != 0 then (
                    update_ui()
                )
            )
        )
    )
        
    fn unregist_changeHandlers = (
        deleteAllChangeHandlers id:#SkinHelperCH
    )
    
    fn regist_changeHandlers = (
        unregist_changeHandlers()
        local currentMod = modPanel.getCurrentObject()
        if isKindOf currentMod skin then (
            local objs = refs.dependentNodes currentMod
            when parameters objs changes id:#SkinHelperCH do (try(__jalSkinWeightToolRollout.objectParmams_changed_ch())catch(print "Error in ro_SkinTools.objectParmams_changed_ch"))
        )
    )
    
    fn unregisterCallbacks = (
        unregist_changeHandlers()
        callbacks.removeScripts id:#SkinHelperCB
    )
    
    fn registerCallbacks = (
        unregisterCallbacks()
        callbacks.addScript #modPanelObjPostChange "try(__jalSkinWeightToolRollout.regist_changeHandlers())catch(print \"Error registring change handler\")" id:#SkinHelperCB
    )


    on skinWeightRollout open do (
        registerCallbacks()
        update_ui()
        regist_changeHandlers()

        if workingSkinMod != undefined then (
            workingSkinMod.filter_vertices = vertexCkb.checked
            selElementCkb.checked = workingSkinMod.selectElement
            workingSkinMod.filter_vertices = on
            workingSkinMod.ShowNoEnvelopes = on
            workingSkinMod.bone_Limit = boneAffectLimitSpn.value
        )
    )

    on skinWeightRollout close do (
        unregist_changeHandlers()
        unregisterCallbacks()
    )

    on selectByBoneBtn pressed do (
        skinOps.selectVerticesByBone workingSkinMod
        update_ui()
    )
    on selZeroWeightVertBtn pressed do (
        select_zeroWeight_vertex workingSkinMod
        update_ui()
    )
    on shrinkBtn pressed do (
        skinOps.shrinkSelection workingSkinMod
        update_ui()
    )
    on growBtn pressed do (
        skinOps.growSelection workingSkinMod
        update_ui()
    )
    on ringBtn pressed do (
        skinOps.ringSelection workingSkinMod
        update_ui()
    )
    on loopBtn pressed do (
        skinOps.loopSelection workingSkinMod
        update_ui()
    )

    on zeroBtn pressed do (
        skinOps.SetWeight  workingSkinMod 0.0
        update_ui()
    )
    on p1Btn pressed do (
        skinOps.SetWeight  workingSkinMod 0.1
        update_ui()
    )
    on p25Btn pressed do (
        skinOps.SetWeight  workingSkinMod 0.25
        update_ui()
    )
    on p5Btn pressed do (
        skinOps.SetWeight  workingSkinMod 0.5
        update_ui()
    )
    on p75Btn pressed do (
        skinOps.SetWeight  workingSkinMod 0.75
        update_ui()
    )
    on p9Btn pressed do (
        skinOps.SetWeight  workingSkinMod 0.9
        update_ui()
    )
    on oneBtn pressed do (
        skinOps.SetWeight  workingSkinMod 1.0
        update_ui()
    )

    on setWeightBtn pressed do (
        skinOps.SetWeight  workingSkinMod weightSpn.value
        update_ui()
    )
    on addWeightBtn pressed do (
        skinOps.AddWeight  workingSkinMod weightSpn.value
        update_ui()
    )
    on minusWeightBtn pressed do (
        skinOps.AddWeight  workingSkinMod (-1.0 * weightSpn.value)
        update_ui()
    )

    on copyWeightBtn pressed do (
        skinOps.CopyWeights  workingSkinMod
        update_ui()
    )
    on pasteWeightBtn pressed do (
        skinOps.PasteWeights  workingSkinMod
        update_ui()
    )
    on blendWeightBtn pressed do (
        skinOps.blendSelected workingSkinMod
        update_ui()
    )
    
    on removeZeroBtn pressed do (
        skinOps.RemoveZeroWeights workingSkinMod
        update_ui()
    )

    on boneListLbx selected selIndex do (
        skinOps.SelectBone workingSkinMod weightBoneListArray[selIndex]
        update_ui()
    )

    on tmUpdateDelay tick do (
        --if workingSkinMod == undefined then (modPanel.GetcurrentObject())
    )

    on selElementCkb changed state do (
        (modPanel.GetcurrentObject()).selectElement = state
        update_ui()
    )

    on alwaysDeformCkb changed state do (
        (modPanel.GetcurrentObject()).always_deform = state
        update_ui()
    )

    on showNoEnvelopeCkb changed state do (
        (modPanel.GetcurrentObject()).ShowNoEnvelopes = state
    )

    on boneAffectLimitSpn changed val do (
        (modPanel.GetcurrentObject()).bone_Limit = boneAffectLimitSpn.value
        update_ui()
    )

    on vertexCkb changed state do (
        (modPanel.GetcurrentObject()).filter_vertices = state
        update_ui()
    )

    on removeUnusedBonesBtn pressed do (
        remove_unused_bones workingSkinMod
        update_ui()
    )
)
