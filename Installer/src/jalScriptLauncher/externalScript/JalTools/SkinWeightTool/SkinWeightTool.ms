(
try(destroydialog jal.tools.skinWeightTool) catch()
rollout mainRollout "SkinWeight Tool" width:280 height: 545(
    SubRollout mainSub "" align:#center height: 545

    global __jalSkinWeightToolRollout = undefined

    local skinStr

    struct __SkinVert (
        index,
        boneArray = #(),
        boneIDArray = #(),
        boneNameArray = #(),
        weightArray = #()
    )
    
    struct _SkinWeight (
        skinMod,
        allBoneNamesArray = #(),
        allBonesArray = #(),
        skinWeightsArray = #(),
    
        fn init = (
            local returnVal = false
    
            skinMod = undefined
            allBoneNamesArray = #()
            allBonesArray = #()
            skinWeightsArray = #()
    
            local currentMod = modPanel.getCurrentObject()
            if isKindOf currentMod skin then (
                skinMod = currentMod
                allBoneNamesArray = for i = 1 to skinOps.GetNumberBones skinMod collect skinOps.GetBoneName skinMod i 0
                allBonesArray = for i = 1 to allBoneNamesArray.count collect getNodeByName allBoneNamesArray[i]
    
                returnVal = true
            )
    
            returnVal
        ),
    
        fn remove_unused_bones weightThresh:0.0001 = (
            local vertCount = skinOps.GetNumberVertices skinMod
            local bonesCount = skinOps.GetNumberBones skinMod
            local unusedBones = #{1..bonesCount}
    
            for v = 1 to vertCount do (
                local vertWeightCount = skinOps.GetVertexWeightCount skinMod v
    
                for i = 1 to vertWeightCount do (
                    local weight = skinOps.GetVertexWeight skinMod v i
                    if weight >= weightThresh then (
                        local boneID = skinOps.GetVertexWeightBoneID skinMod v i
                        unusedBones[boneID] = false
                    )
                )
            )
    
            for i = bonesCount to 1 by -1 where unusedBones[i] do (
                skinOps.SelectBone skinMod i
                skinOps.RemoveBone skinMod
            )
    
            init()
        ),
    
        fn round_number num precision:3 = (
            local multiplier = 10 ^ precision
            ( floor ( (num * multiplier) + 0.5) ) / multiplier
        ),
    
        fn get_selected_skinVerts = (
            for v = 1 to skinOps.GetNumberVertices skinMod where skinOps.IsVertexSelected skinMod v == 1 collect v
        ),
    
        fn get_vert_weight inVertIndex = (
            local returnVal = __SkinVert()
            local boneArray = #()
            local boneIDArray = #()
            local boneNameArray = #()
            local weightArray = #()
            local boneNum = skinOps.getVertexWeightCount skinMod inVertIndex
    
            for i = 1 to boneNum do (
                local boneID = skinOps.getVertexWeightBoneID skinMod inVertIndex i
                local boneName = skinOps.GetBoneName skinMod boneID 0
                local boneSysID = findItem allBoneNamesArray boneName
                local boneWeight = skinOps.getVertexWeight skinMod inVertIndex i
                append boneArray allBonesArray[boneSysID]
                append boneIDArray boneID
                append boneNameArray boneName
                append weightArray (round_number boneWeight)
            )
    
            returnVal.index = inVertIndex
            returnVal.boneArray = deepCopy boneArray
            returnVal.boneIDArray = deepCopy boneIDArray
            returnVal.boneNameArray = deepCopy boneNameArray
            returnVal.weightArray = deepCopy weightArray
    
            returnVal
        ),
    
        fn select_zeroWeight_vertex = (
            local numVerts = skinOps.GetNumberVertices skinMod
            local returnArray = #()
    
            for v = 1 to numVerts do (
                local weights = (get_vert_weight v).weightArray
                local weightVal = 0.0
                for item in weights do if item != undefined then weightVal += item
                if weightVal == 0.0 then append returnArray v
            )
            skinOps.SelectVertices skinMod returnArray
            redrawViews()
    
            returnArray
        )
    )

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
    
            button setWeightBtn "Set Weight" across:4 height:25 width:70 align:#left
            spinner weightSpn "" range:[0.0, 1.0, 0.1] type:#float scale:0.001 width:70 offset:[18, 5]
            button addWeightBtn "+" width:30 height:25 offset:[32, 0]
            button minusWeightBtn "-" width:30 height:25 align:#right
            label absWeightLbl "Abs. Effect:" across:2
            spinner absWeightSpn "" range:[0.0, 1.0, 0.1] type:#float scale:0.001 width:90 align:#right
    
            button copyWeightBtn "Copy" across:4 width:48 height:25 align:#left offset:[0, 10]
            button pasteWeightBtn "Paste" width:48 height:25 offset:[0, 10]
            button blendWeightBtn "Blend" width:48 height:25 offset:[0, 10]
            button removeZeroBtn "rm.Zero" width:48 height:25 align:#right offset:[0, 10]
    
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
            spinner boneAffectLimitSpn "Bones Affect Limit: " fieldWidth:40 type:#integer range:[1, 20, 20] scale:1
            button removeUnusedBonesBtn "Remove Unused Bones"
        )
    
        timer tmUpdateDelay interval:1000
    
        local suspendVertSelectionChangeUpdate = false
        local workingSkinMod
        local workingVerts
        local weightBoneListArray = #()
        local selBoneID = 1
    
        fn populate_weightList = (
            local returnArray = #()
            weightBoneListArray = #()
            if skinStr.skinMod != undefined then (
                local selVerts = skinStr.get_selected_skinVerts()
                if selVerts != undefined and selVerts.count > 0 then (
                    local skinVert = skinStr.get_vert_weight selVerts[1]
                    for i = 1 to skinVert.weightArray.count do (
                        local weightStr = formattedPrint skinVert.weightArray[i] format:("0." + 3 as string + "f")
                        local boneNameStr = skinVert.boneNameArray[i] as String
                        append returnArray (weightStr + ": " + boneNameStr)
                        append weightBoneListArray skinVert.boneIDArray[i]
                    )
                )
            )
            returnArray
        )
    
        fn populate_absWeight inBoneID:1 = (
            local returnVal = 0.0
            if skinStr.skinMod != undefined then (
                local selVerts = skinStr.get_selected_skinVerts()
                if selVerts != undefined and selVerts.count > 0 then (
                    local skinWeight = skinStr.get_vert_weight selVerts[1]
                    returnVal = skinWeight.weightArray[inBoneID]
                )
            )
    
            returnVal
        )
    
        fn update_ui = (
            local currentMod = modPanel.getCurrentObject()
            if isKindOf currentMod skin then (
                workingSkinMod = currentMod
                local selectedVerts = skinStr.get_selected_skinVerts()
                if selectedVerts.count > 0 then workingVerts = selectedVerts
                else workingVerts = undefined
            ) else (
                workingSkinMod = undefined
                workingVerts = undefined
            )
            lblSelectedVerts.text = if workingVerts == undefined then "No vertices selected." \
                                            else if workingVerts.count == 1 then ("Vertex ID: " + (workingVerts[1] - 1) as string) \
                                            else (workingVerts.count as string + " vertices selected.")
    
            boneListLbx.items = populate_weightList()
            selBoneID = skinOps.GetSelectedBone workingSkinMod
            local boneFindingResult = findItem weightBoneListArray selBoneID
            boneListLbx.selection = boneFindingResult
    
            if boneListLbx.selection > 0 then (
                absWeightSpn.value = populate_absWeight inBoneID:boneListLbx.selection
                skinOps.SelectBone workingSkinMod weightBoneListArray[boneListLbx.selection]
            )
            else skinOps.SelectBone workingSkinMod selBoneID
        )
    
        fn objectParmams_changed_ch = (
            if not suspendVertSelectionChangeUpdate then (
                local preSkin = workingSkinMod
                local preVerts = workingVerts
                local currentMod = modPanel.getCurrentObject()
                if workingSkinMod != currentMod then
                    update_ui()
                else (
                    local selectedVerts = skinStr.get_selected_skinVerts()
                    local selectedVertsBA = selectedVerts as bitArray
                    local workingVertsBA = #{}
    
                    if workingVerts != undefined then workingVertsBA = workingVerts as bitArray
                    if selectedVertsBA.numberSet != workingVertsBA.numberSet \
                            or (selectedVertsBA - workingVertsBA).numberSet != 0 \
                            or (workingVertsBA - selectedVertsBA).numberSet != 0 then (
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
            skinStr.select_zeroWeight_vertex()
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
            skinOps.SetWeight workingSkinMod 0.0
            update_ui()
        )
        on p1Btn pressed do (
            skinOps.SetWeight workingSkinMod 0.1
            update_ui()
        )
        on p25Btn pressed do (
            skinOps.SetWeight workingSkinMod 0.25
            update_ui()
        )
        on p5Btn pressed do (
            skinOps.SetWeight workingSkinMod 0.5
            update_ui()
        )
        on p75Btn pressed do (
            skinOps.SetWeight workingSkinMod 0.75
            update_ui()
        )
        on p9Btn pressed do (
            skinOps.SetWeight workingSkinMod 0.9
            update_ui()
        )
        on oneBtn pressed do (
            skinOps.SetWeight workingSkinMod 1.0
            update_ui()
        )
    
        on setWeightBtn pressed do (
            skinOps.SetWeight workingSkinMod weightSpn.value
            update_ui()
        )
        on addWeightBtn pressed do (
            skinOps.AddWeight workingSkinMod weightSpn.value
            update_ui()
        )
        on minusWeightBtn pressed do (
            skinOps.AddWeight workingSkinMod (-1.0 * weightSpn.value)
            update_ui()
        )
    
        on absWeightSpn changed inVal do (
            undo off (
                skinOps.SetWeight workingSkinMod inVal
            )
        )
        on absWeightSpn buttonup do (
            undo on (
                skinOps.SetWeight workingSkinMod absWeightSpn.value
                update_ui()
            )
        )
    
        on copyWeightBtn pressed do (
            skinOps.CopyWeights workingSkinMod
            update_ui()
        )
        on pasteWeightBtn pressed do (
            skinOps.PasteWeights workingSkinMod
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
            skinStr.remove_unused_bones()
            update_ui()
        )
    )


    on mainRollout open do
    (
        max modify mode
        if ((classof(modPanel.GetcurrentObject())) == Skin) then (
            skinStr = _SkinWeight()
            skinStr.init()
            __jalSkinWeightToolRollout = skinWeightRollout
            AddSubRollout mainSub skinWeightRollout
        )
        else (
            try(destroydialog jal.tools.skinWeightTool) catch()
            messageBox "Please, Select Skined Object!!!"
        )
    )

    on mainRollout close do (
        __jalSkinWeightToolRollout = undefined
        gc()
    )
)
jal.tools.skinWeightTool = mainRollout
createDialog jal.tools.skinWeightTool style:#(#style_titlebar, #style_border, #style_sysmenu)

clearlistener()
gc()
)
