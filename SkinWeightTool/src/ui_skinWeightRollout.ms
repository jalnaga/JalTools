rollout skinWeightRollout "SkinWeight Tool" (
    group "Vertex" (
        button selectByBoneBtn "Select By Bone" height:25 width:120 align:#left across:2
        button selZeroWeightVertBtn "Select Zero" height:25 align:#right
        button shrinkBtn "Shrink" across:4 width:45 height:25 align:#left
        button growBtn "Grow" width:45 height:25
        button ringBtn "Ring" width:45 height:25
        button loopBtn "Loop" width:45 height:25 align:#right

        button setWeightBtn "Set Weight" across:4 height:25 width:70 align:#left
        spinner weightSpn "" range:[0.0, 1.0, 0.1] type:#float scale:0.001 width:70 offset:[18, 5]
        button addWeightBtn "+" width:30 height:25 offset:[32, 0]
        button minusWeightBtn "-" width:30 height:25 align:#right

        button setScaleBtn "Set Scale" across:4 height:25 width:70 align:#left
        spinner scaleSpn "" range:[0.0, 1.0, 0.1] type:#float scale:0.001 width:70 offset:[18, 5]
        button addScaleBtn "+" width:30 height:25 offset:[32, 0]
        button minusScaleBtn "-" width:30 height:25 align:#right

        label absWeightLbl "Abs. Effect:" across:2
        spinner absWeightSpn "" range:[0.0, 1.0, 0.1] type:#float scale:0.001 width:90 align:#right

        button copyWeightBtn "Copy" across:4 width:48 height:25 align:#left offset:[0, 10]
        button pasteWeightBtn "Paste" width:48 height:25 offset:[0, 10]
        button blendWeightBtn "Blend" width:48 height:25 offset:[0, 10]
        button removeZeroBtn "rm.Zero" width:48 height:25 align:#right offset:[0, 10]

        label lblSelectedVerts ""

        listBox boneListLbx "" height:8
    )

    group "Smooth" (
        button btnGo "Smooth" width:120 height:30 align:#left across:2
        button btnUndo "Undo" width:80 height:30 align:#right
        radiobuttons rbVertGroup "" labels:#("Edges    ", "Attach    ", "All    ", "Rigid    ") columns:2 across:2 align:#left
        spinner spn_iter "Iter: " range:[1,50,1] align:#right type:#integer
        spinner spnDist "Radius" range:[0,1000,5.0] width:70 align:#right offset:[0, -15]
        checkbox chkKeepMax "Keep 100%" checked:false

        progressBar pb_bar "" height:7 value:0 color:[0,0,0]
    )

    group "Selection"(
        checkbox vertexCkb "Vertex" checked:true height:25
        checkbox  selElementCkb "SelectElement" checked:false height:25 across:2 offset:[0, -5]
        checkbox  backfaceCullCkb "Bacface Cull" checked:false height:25 offset:[0, -5]
    )

    timer tmUpdateDelay interval:1000

    local suspendVertSelectionChangeUpdate = false
    local workingSkinMod
    local workingVerts
    local weightBoneListArray = #()
    local selBoneID = 1

    local odcSkin = jal.skin
    local SmoothSkinMaxUndo = 10
    local UndoWeights = #()
    local SmoothSkinData = #(#(), #(), #(), #(), #(), #(), #())

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
            backfaceCullCkb.checked = workingSkinMod.backfacecull
            workingSkinMod.filter_vertices = on
            workingSkinMod.ShowNoEnvelopes = on
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

    on setScaleBtn pressed do (
        skinOps.scaleWeight workingSkinMod (1.0+scaleSpn.value)
        update_ui()
    )
    on addScaleBtn pressed do (
        skinOps.scaleWeight workingSkinMod (1.0+scaleSpn.value)
        update_ui()
    )
    on minusScaleBtn pressed do (
        skinOps.scaleWeight workingSkinMod (1.0-scaleSpn.value)
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

    on btnGo pressed do
    (
        if $selection.count == 1 then
        (
            p=0; pb_bar.value = 0
            for iter = 1 to spn_iter.value do
            (
                p+=1
                if classOf (modPanel.getCurrentObject()) == Skin then
                (
                    obj = $; skinMod = modPanel.getCurrentObject()
                    FinalBoneArray = #(); FinalWeightArray = #(); o = 1

                    UseOldData = (obj == SmoothSkinData[1][1]) and (obj.verts.count == SmoothSkinData[1][2])
                    if not UseOldData do SmoothSkinData = #(#(), #(), #(), #(), #(), #(), #())
                    SmoothSkinData[1][1] = obj; SmoothSkinData[1][2] = obj.verts.count

                    tmpObj = copy Obj
                    tmpObj.modifiers[skinMod.name].enabled = false

                    fn DoNormalizeWeight Weight = (
                        WeightLength = 0; NormalizeWeight = #()
                        for w = 1 to Weight.count do WeightLength += Weight[w]
                        if WeightLength != 0 then for w = 1 to Weight.count do NormalizeWeight[w] = Weight[w] * (1 / WeightLength)
                            else NormalizeWeight[1] = 1.0
                        return NormalizeWeight
                    )

                    skinMod.clearZeroLimit = 0.00
                    skinOps.RemoveZeroWeights skinMod

                    posarray = for a in tmpObj.verts collect a.pos

                    if (SmoothSkinData[8] != spnDist.value) do (SmoothSkinData[6] = #(); SmoothSkinData[7] = #())

                    for v = 1 to obj.verts.count where (skinOps.IsVertexSelected skinMod v == 1) and (not chkKeepMax.checked or (skinOps.GetVertexWeightCount skinmod v != 1)) do
                    (
                        --          print v
                        VertBros = #{}; VertBrosRatio = #()
                        Weightarray = #(); BoneArray = #(); FinalWeight = #()
                        WeightArray.count = skinOps.GetNumberBones skinMod

                        if rbVertGroup.state == 1 and (SmoothSkinData[2][v] == undefined) do (
                            if (classof tmpObj == Editable_Poly) or (classof tmpObj == PolyMeshObject) then (
                                CurEdges = polyop.GetEdgesUsingVert tmpObj v
                                for CE in CurEdges do VertBros += (polyop.getEdgeVerts tmpObj CE) as bitArray
                            )else (
                                CurEdges = meshop.GetEdgesUsingvert tmpObj v
                                for i in CurEdges do CurEdges[i] = (getEdgeVis tmpObj (1+(i-1)/3)(1+mod (i-1) 3))
                                for CE in CurEdges do VertBros += (meshop.getVertsUsingEdge tmpObj CE) as bitArray
                            )

                            VertBros = VertBros as array
                            SmoothSkinData[2][v] = #()
                            SmoothSkinData[3][v] = #()

                            if VertBros.count > 0 do (
                                for vb in VertBros do (
                                    CurDist = distance posarray[v] posarray[vb]
                                    if CurDist == 0 then append VertBrosRatio 0 else append VertBrosRatio (1 / CurDist)
                                )

                                VertBrosRatio = DoNormalizeWeight VertBrosRatio
                                VertBrosRatio[finditem VertBros v] = 1
                                SmoothSkinData[2][v] = VertBros
                                SmoothSkinData[3][v] = VertBrosRatio
                            )
                        )

                        if rbVertGroup.state == 2 do (
                            SmoothSkinData[4][v] = for vb = 1 to posarray.count where (skinOps.IsVertexSelected skinMod vb == 0) and (distance posarray[v] posarray[vb]) < spnDist.value collect vb
                            SmoothSkinData[5][v] = for vb in SmoothSkinData[4][v] collect
                                (CurDist = distance posarray[v] posarray[vb]; if CurDist == 0 then 0 else (1 / CurDist))
                            SmoothSkinData[5][v] = DoNormalizeWeight SmoothSkinData[5][v]
                            for i = 1 to SmoothSkinData[5][v].count do SmoothSkinData[5][v][i] *= 2
                        )

                        if rbVertGroup.state == 3 and (SmoothSkinData[6][v] == undefined) do (
                            SmoothSkinData[6][v] = for vb = 1 to posarray.count where (distance posarray[v] posarray[vb]) < spnDist.value collect vb
                            SmoothSkinData[7][v] = for vb in SmoothSkinData[6][v] collect
                                (CurDist = distance posarray[v] posarray[vb]; if CurDist == 0 then 0 else (1 / CurDist))
                            SmoothSkinData[7][v] = DoNormalizeWeight SmoothSkinData[7][v]
                            for i = 1 to SmoothSkinData[7][v].count do SmoothSkinData[7][v][i] *= 2
                        )


                        if rbVertGroup.state != 4 do (
                            VertBros = SmoothSkinData[rbVertGroup.state * 2][v]
                            VertBrosRatio = SmoothSkinData[(rbVertGroup.state * 2) + 1][v]

                            for z = 1 to VertBros.count do for CurBone = 1 to (skinOps.GetVertexWeightCount skinMod VertBros[z]) do (
                                CurID = (skinOps.GetVertexWeightBoneID skinMod VertBros[z] CurBone)
                                if WeightArray[CurID] == undefined do WeightArray[CurID] = 0
                                WeightArray[CurID] += (skinOps.GetVertexWeight skinMod VertBros[z] CurBone) * VertBrosRatio[z]
                            )

                            for i = 1 to WeightArray.count where WeightArray[i] != undefined and WeightArray[i] > 0 do (
                                NewVal = (WeightArray[i] / 2)
                                if NewVal > 0.01 do (append BoneArray i; append FinalWeight NewVal)
                            )
                            FinalBoneArray[v] = BoneArray
                            FinalWeightArray[v] = FinalWeight
                        )
                    )

                    if rbVertGroup.state == 4 then (
                        convertTopoly tmpObj
                        polyObj = tmpObj

                        -- Only test selected
                        VertSelection = for v = 1 to obj.verts.count where (skinOps.IsVertexSelected skinMod v == 1) collect v
                        DoneEdge = (polyobj.edges as bitarray) - polyop.getEdgesUsingVert polyObj VertSelection
                        DoneFace = (polyobj.faces as bitarray) - polyop.getFacesUsingVert polyObj VertSelection

                        -- Elements
                        SmallElements = #()
                        for f = 1 to polyobj.faces.count where not DoneFace[f] do (
                            CurElement = polyop.getElementsUsingFace polyObj #{f}

                            CurVerts = polyop.getVertsUsingFace polyobj CurElement; MaxDist = 0
                            for v1 in CurVerts do for v2 in CurVerts where MaxDist < (spnDist.value * 2) do (
                                dist = distance polyobj.verts[v1].pos polyobj.verts[v2].pos
                                if dist > MaxDist do MaxDist = dist
                            )
                            if MaxDist < (spnDist.value * 2) do append SmallElements CurVerts
                            DoneFace += CurElement
                        )

                        -- Loops
                        EdgeLoops = #()
                        for ed in SmallElements do DoneEdge += polyop.getEdgesUsingVert polyobj ed
                        for ed = 1 to polyobj.edges.count where not DoneEdge[ed] do (
                            polyobj.selectedEdges = #{ed}
                            polyobj.ButtonOp #SelectEdgeLoop
                            CurEdgeLoop = (polyobj.selectedEdges as bitarray)
                            if CurEdgeLoop.numberSet > 2 do (
                                CurVerts = (polyop.getvertsusingedge polyobj CurEdgeLoop); MaxDist = 0
                                for v1 in CurVerts do for v2 in CurVerts where MaxDist < (spnDist.value * 2) do (
                                    dist = distance polyobj.verts[v1].pos polyobj.verts[v2].pos
                                    if dist > MaxDist do MaxDist = dist
                                )
                                if MaxDist < (spnDist.value * 2) do append EdgeLoops CurVerts
                            )
                            DoneEdge += CurEdgeLoop
                        )

                        modPanel.setCurrentObject SkinMod; subobjectLevel = 1
                        for z in #(SmallElements, EdgeLoops) do for i in z do (
                            VertList = for v3 in i where (skinOps.IsVertexSelected skinMod v3 == 1) collect v3
                            NewWeights = odcSkin.make_rigid_skin SkinMod VertList
                            for v3 in VertList do (FinalBoneArray[v3] = NewWeights[1]; FinalWeightArray[v3] = NewWeights[2])
                        )
                    )

                    SmoothSkinData[8] = spnDist.value

                    delete tmpObj
                    OldWeightArray = #(); OldBoneArray = #(); LastWeights = #()
                    for sv = 1 to FinalBoneArray.count where FinalBonearray[sv] != undefined and FinalBoneArray[sv].count != 0 do (
                        -- Home-Made undo
                        NumItem = skinOps.GetVertexWeightCount skinMod sv
                        OldWeightArray.count = OldBoneArray.count = NumItem
                        for CurBone = 1 to NumItem do (
                            OldBoneArray[CurBone] = (skinOps.GetVertexWeightBoneID skinMod sv CurBone)
                            OldWeightArray[CurBone] = (skinOps.GetVertexWeight skinMod sv CurBone)
                        )

                        append LastWeights #(skinMod, sv, deepcopy OldBoneArray, deepcopy OldWeightArray)
                        if UndoWeights.count >= SmoothSkinMaxUndo do deleteItem UndoWeights 1
                            --
                        skinOps.ReplaceVertexWeights skinMod sv FinalBoneArray[sv] FinalWeightArray[sv]
                    )

                    append UndoWeights LastWeights
                    btnUndo.enabled = true
                    prog = ((p as float / spn_iter.value as float) * 100.0)
                    pb_bar.value = prog
                    pb_bar.color.r = (255-((255/100)*prog))
                    pb_bar.color.g = ((255/100)*prog)
                    pb_bar.color.b = 0
                    )
                    else (messagebox "Select 1 Skin Modifier on the selected object.")
                )
            ) else (messagebox "Select 1 object with a skin modifier.")
    )

    on btnUndo pressed do (
            CurUndo = UndoWeights[UndoWeights.count]
            try(
                if modPanel.GetCurrentObject() != CurUndo[1][1] do (modPanel.setCurrentObject CurUndo[1][1]; subobjectLevel = 1)
                for i in CurUndo do skinOps.ReplaceVertexWeights i[1] i[2] i[3] i[4]
            )
            catch( print "Undo fail")
            deleteitem UndoWeights UndoWeights.count
            if UndoWeights.count == 0 do btnUndo.enabled = false
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

    on backfaceCullCkb changed state do (
        (modPanel.GetcurrentObject()).backfacecull = state
    )

    on vertexCkb changed state do (
        (modPanel.GetcurrentObject()).filter_vertices = state
        update_ui()
    )
)
