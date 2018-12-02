struct _MuscleBone (
    name, anim, helper, const, bone,

    boneSize = 2.0,
    linkNum = 1,
    squash = false,

    chainBoneArray = #(),
    boneName = "",
    
    splineKnotArray = #(),
    spline = undefined,
    splineName = "",

    splineHelperArray = #(),
    controlHelperArray = #(),
    controlHelperName = "",
    chainRootHelper = undefined,
    rootHelperName = "",


    fn reset = (
        boneSize = 2.0
        linkNum = 1
        squash = false

        chainBoneArray = #()
        boneName = ""
        
        splineKnotArray = #()
        spline = undefined
        splineName = ""

        splineHelperArray = #()
        controlHelperArray = #()
        controlHelperName = ""
        chainRootHelper = undefined
        rootHelperName = ""
    ),

    fn gen_name inName = (
        boneName = inName
        splineName = name.replace_type inName "Spn"
        splineName = name.replace_index splineName "0"
        controlHelperName = name.replace_type inName "Dum"
        rootHelperName = name.replace_type inName "Dum"
        rootHelperName = name.add_sufix_to_realName rootHelperName "Root"
        rootHelperName = name.replace_index rootHelperName "0"
    ),

    fn set_spline inSpline = (
        if classOf inSpline == line or classOf inSpline == SplineShape then spline = inSpline
        spline.name = splineName
    ),

    fn set_splineKnotArray = (
        splineKnotArray = #()

        for i = 1 to (numsplines spline) do (
            for k = 1 to (numKnots spline i) do (
                append splineKnotArray (getKnotPoint spline i k)
            )
        )
    ),

    fn init inName inSpline inLinkNum inBoneSize inSquash = (
        reset()

        linkNum = inLinkNum
        boneSize = inBoneSize
        squash = inSquash
        
        gen_name inName
        set_spline inSpline
        set_splineKnotArray()
    ),

    fn assign_splineIK type:1 tangentsBool:false =
    (
        local n=(numknots spline 1)   
        --Here is the creation of the Control Objects (the ones that will deform the spline)
        local controlsArray=#()
        for i=1 to n do
        (
            local controlVarName = name.replace_type controlHelperName "SpnCtr"
            controlVarName = name.replace_index controlVarName ((i - 1) as String)
            controlVar=point centerMarker:false axisTripod:false cross:false box:true size:(boneSize * 1.2) wirecolor:red name:controlVarName
            local controlRow1=pathTangent spline 1 ((i-1)/(n-1) as float)
            local controlRow3=normalize (cross controlRow1 [0,1,0])
            local controlRow2=normalize (cross controlRow3 controlRow1)
            local controlRow4=getknotpoint spline 1 i
            controlVar.transform=matrix3 controlRow1 controlRow2 controlRow3 controlRow4
            append controlsArray controlVar
        )
        
        --it's a need to select the spline and activate the modify panel, oterwise the script 
        --will crash when adding the control Objects in the skin modifier.
        select spline
        setCommandPanelTaskMode mode: #modify
        
        --Creates the Attachment, according to the type.
        if type==1 then --Spline IK Control
        (
            if tangentsBool then --With tangents
            (
                for i=1 to n do
                (
                    setknotType spline 1 i #beziercorner
                    local knotPos=(getKnotPoint spline 1 i)
                    setInVec spline 1 i (((getInVec spline 1 i)-knotPos)*(inverse controlsArray[i].transform.rotation)+knotPos)
                    setOutVec spline 1 i (((getOutVec spline 1 i)-knotPos)*(inverse controlsArray[i].transform.rotation)+knotPos)
                )
                updateshape spline
            )
            else    --Without tangents
                for i=1 to n do
                    setknotType spline 1 i #smooth
                
            addmodifier spline (Spline_IK_Control ()) 
            spline.modifiers[1].noLinking()
            spline.modifiers[1].helper_list=controlsArray
        )
        else --Skin
        (
            if tangentsBool then --With tangents
            (
                for i=1 to n do
                  setknotType spline 1 i #beziercorner 
                addmodifier spline (skin())     
                for i=1 to n do
                (
                    --First Creates The InVec Control Object, adds it to the skin and sets the respective weight,
                    --then the Vertex Control Object, and finally the OutVec Control Object
                    if i>1 then
                    (
                        controlVarInVec=copy controlsArray[i]
                        controlVarInVec.size=(boneSize * 1.2)
                        controlVarInVec.wirecolor=red
                        controlVarInVec.name = name.add_sufix_to_realName controlHelperName "SpnCtrChainInVec"
                        controlVarInVec.name = name.replace_index controlVarInVec.name (i as String)
                        controlVarInVec.parent=controlsArray[i]
                        controlVarInVec.position=getInVec spline 1 i
                        skinops.addbone spline.modifiers[1] controlVarInVec 0
                        classof spline 
                        skinops.setVertexWeights spline.modifiers[1] (i*3-2) (i*3-3) 1
                    )
                    skinops.addbone spline.modifiers[1] controlsArray[i] 0
                    classof spline
                    skinops.setVertexWeights spline.modifiers[1] (i*3-1) (i*3-2) 1      
                    if i==1 then
                        skinops.setVertexWeights spline.modifiers[1] (i*3-2) (i*3-2) 1      
                    if i<n then
                    (
                        controlVarOutVec=copy controlsArray[i]
                        controlVarOutVec.wirecolor=red
                        controlVarOutVec.size=(boneSize * 1.2)
                        controlVarOutVec.name = name.add_sufix_to_realName controlHelperName "SpnCtrChainOutVec"
                        controlVarOutVec.name = name.replace_index controlVarOutVec.name (i as String)
                        controlVarOutVec.parent=controlsArray[i]
                        controlVarOutVec.position=getOutVec spline 1 i
                        skinops.addbone spline.modifiers[1] controlVarOutVec 0
                        classof spline
                        skinops.setVertexWeights spline.modifiers[1] (i*3) (i*3-1) 1
                    )                         
                    else
                        skinops.setVertexWeights spline.modifiers[1] (i*3) (i*3-2) 1
                )
            )
            else --Without tangents
            (
                for i=1 to n do
                  setknotType spline 1 i #smooth
                addmodifier spline (skin())
                for i=1 to n do
                (
                    skinops.addbone spline.modifiers[1] controlsArray[i] 0
                    classof spline --this line is a need to update the skin, and to don't get a crash with the next line (setVertexWeights)
                    --set the vertex and its tangent points weights
                    skinops.setVertexWeights spline.modifiers[1] (i*3) i 1
                    skinops.setVertexWeights spline.modifiers[1] (i*3-1) i 1
                    skinops.setVertexWeights spline.modifiers[1] (i*3-2) i 1
              )
            )
        )
        splineHelperArray = deepCopy controlsArray
        return controlsArray
    ),

    /*******************************************/
    /* LookAtType
        1: LookAt Constraint
        2: Quaternion Aim
    /* RotationAverage
        RotationAverage[1] = Roll Average
        RotationAverage[2] = AverageType
            AverageType
                1: Orientation Constraint
                2: Euler Angles
        RotationAverage[3] = Average To
            Average To
                1: First and Last Controls
                2: All controls
                3: Spinner
        origin:#(true, 2, 1)
        orientation const enable:#(true, 1, 1)
    /*******************************************/
    function create_chain splineNode ControlsArray nBones widthVar taperVar SquashBool:false LookAtType:2 RotationAverage:#(true, 1, 1) ManCtrlsBool:true IKSolverBool:false =
    (
        --some variables
        local BoneArray=#()
        local SplineChainDef
        local rotScriptCtrl
        local lengthVar=curveLength splineNode
        local HelperArray=#()
        local RootHelper=point centerMarker:false axisTripod:false cross:false box:true size:(widthVar * 1.5) wirecolor:green name:rootHelperName
        RootHelper.transform=ControlsArray[1].transform
        ControlsArray.parent=RootHelper
        chainRootHelper = RootHelper
        local prevBoneVar=RootHelper
        
         --First loop, it creates each bone and defines its settings, it creates also its respective
         --helper and the controller to attach the bone to the helper (position constraint)
        for i=1 to nBones+1 do
        (
            BoneVar=bonesys.createBone [(lengthVar*(i-1)/nBones),0,0] [(lengthVar*i/nBones),0,0] [0,0,1]
            BoneVar.name = name.replace_index boneName ((i - 1) as string)
            BoneVar.parent=prevBoneVar
            BoneVar.taper=taperVar
            BoneVar.width=widthVar
            BoneVar.height=boneVar.width
            BoneVar.frontfin = off
            BoneVar.backfin = off
            BoneVar.sidefins = off

            local helperVarName = name.replace_index controlHelperName ((i - 1) as string)
            HelperVar=point centerMarker:false axisTripod:false cross:false box:true size:(widthVar * 0.5) wirecolor:blue name:helperVarName
            HelperVar.position=BoneVar.position
            --HelperVar.rotation=RootHelper.rotation
            BoneVar.position.controller=position_constraint()
            BoneVar.position.controller.appendTarget HelperVar 100
            prevBoneVar=BoneVar
            append BoneArray BoneVar
            append HelperArray HelperVar
        )
        --Here are some special settings for the End Bone
        BoneArray[nBones+1].taper=100
        BoneArray[nBones+1].width=BoneArray[nBones+1].width/2
        BoneArray[nBones+1].height=BoneArray[nBones+1].width
        BoneArray[nBones+1].length=BoneArray[nBones+1].width
        --If squash option active:
        if SquashBool then BoneArray.boneScaleType=#squash
            
        if (RotationAverage[3]==3) or IKSolverBool then
        (
            local defString="Attributes SplineChain\n(\n\tparameters SCParams rollout:SCRoll\n\t("
            local defParamString=""
            local defRollString=""
            if (RotationAverage[3]==3) then
            (
                defParamString+="\n\t\tRoll type:#float default:0 ui:UIRoll"
                defRollString+="\n\t\tspinner UIRoll \"Roll:\" range:[-999999999,999999999,0]"
            )
            if IKSolverBool then
            (
                defParamString+="\n\t\tStretch type:#float default:0 ui:UIStretch"
                defRollString+="\n\t\tspinner UIStretch \"Stretch Percent:\" range:[0,100,0] scale:0.5"
            )
            defString+=defParamString+"\n\t)"
            defString+="\n\trollout SCRoll \"Spline Chain Control\"\n\t("
            defString+=defRollString+"\n\t)\n)"
            
            local CtrlModifier=EmptyModifier()
            CtrlModifier.name="Control"
            custAttributes.add CtrlModifier (execute(defString))
            addModifier RootHelper CtrlModifier
            addModifier ControlsArray CtrlModifier
        )
            
        --Remove Helper's inheritance 
        if ((LookAtType==2) or (RotationAverage[1] and RotationAverage[2]==1 and RotationAverage[3]!=3)) then
                setInheritanceFlags HelperArray #{7,8,9}
        
        --This loop assigns the path_constraint to the helper objects
        for i=1 to HelperArray.count do
        (
            HelperArray[i].position.controller=path_constraint()
            HelperArray[i].position.controller.appendTarget splineNode 100
            deletekeys HelperArray[i].position.controller.percent.controller
            --the helper's percent over the spline depends on its position over the chain
            HelperArray[i].position.controller.percent=100*(i-1)/nBones as float
        )
        
        if IKSolverBool or ManCtrlsBool then (
            for i=1 to (nBones+1) do (
                HelperArray[i].position.controller=position_list()
            )
        )
        
        HelperArray.parent=RootHelper
        
        /*If the IKSolver option is active It creates an extra chain of helper objects with a spline ik 
        solver to the same spline, also creates the position constraints of the previosly created objects with
        these new helpers as targets and creates an expression_controller to control the weight of the position 
        constraint. This expression controller has a variable "value" that will need to be assigned by the user 
        to a spinner or a slider, it has to be done only once because all the weight controllers are instanced.*/
        if IKSolverBool then
        (
            local FirstHelperIK, LastHelperIK
            prevHelperIK=undefined
            WeightController=float_script()
            RootHelper.modifiers[1].SplineChain.Stretch.controller=bezier_float()
            WeightController.addTarget "Value" RootHelper.modifiers[1].SplineChain.Stretch.controller
            WeightController.script= "1-(Value/100)"
            for i=1 to HelperArray.count do
            (
                local helperIKSolverName = name.replace_type controlHelperName "IK"
                helperIKSolverName = name.replace_index helperIKSolverName ((i - 1) as string)
                HelperIKSolver=point centerMarker:false axisTripod:false cross:true box:false size:(widthVar*0.5) wirecolor:blue name:helperIKSolverName
                HelperIKSolver.parent=prevHelperIK
                HelperIKSolver.position=[lengthVar*(i-1)/nBones,0,0]
                HelperArray[i].position.controller[2].controller=position_constraint()
                HelperArray[i].position.controller[2].controller.appendTarget HelperIKSolver 100
                HelperArray[i].position.controller.weights[2].controller=WeightController
                if i==1 then FirstHelperIK=HelperIKSolver
                if i==HelperArray.count then LastHelperIK=HelperIKSolver
                prevHelperIK=HelperIKSolver
            )
            SplineIK=IKSys.IKChain FirstHelperIK LastHelperIK "SplineIKSolver"
            SplineIK.controller.pickShape=splineNode
            SplineIK.controller.goalSize=widthVar
            FirstHelperik.position.controller=path_constraint()
            FirstHelperik.position.controller.appendTarget splineNode 100
        )
        --if the manipulation controllers option is active then create an extra position_xyz controller for manual adjustments
        if ManCtrlsBool then
        (
            for i=1 to HelperArray.count do
            (
                HelperArray[i].position.controller.available.controller=position_xyz()
                HelperArray[i].position.controller.active=HelperArray[i].position.controller.count
            )
        )
        
        --if Look At Type equals LookAt Constraint, constraints each bone to the next level helper object
        --and use the current level helper as upNode
        if LookAtType==1 then   
        (
            --If the Average Constraint option is active then constraints the helpers to an average defined by the user
            --(by First and Last Control Objects, All Control Objects or Spinner)
            if RotationAverage[1] then
            (
                case RotationAverage[3] of
                (
                    --if "Average To" equals First and Last controls
                    1:
                    (
                         --If "Average Type" equals Orientation Constraint
                        if RotationAverage[2]==1 then
                        (
                            for i=1 to nBones do
                            (
                                HelperArray[i].rotation.controller=orientation_constraint()
                                --The weights in the orientation constraint depends on the helper's position in the chain
                                HelperArray[i].rotation.controller.appendTarget ControlsArray[1] (100*(nBones-i)/(nBones-1) as float)
                                HelperArray[i].rotation.controller.appendTarget ControlsArray[ControlsArray.count] (100*(i-1)/(nBones-1) as float)
                            )
                        )
                        --If Average Type equals Euler Angles Average
                        else
                        (
                            for i=1 to nBones do
                            (
                                HelperArray[i].rotation.controller=rotation_script()
                                HelperArray[i].rotation.controller.addObject "rotA" ControlsArray[1].rotation.controller
                                HelperArray[i].rotation.controller.addObject "rotB" ControlsArray[ControlsArray.count].rotation.controller
                                local tempScript = ""
                                tempScript += "rotX= (rotA.x_rotation*"+(((nBones-i)/(nBones-1) as float) as string)+"+rotB.x_rotation*"+(((i-1)/(nBones-1) as float)as string)+")\n"
                                tempScript += "rotY= (rotA.y_rotation*"+(((nBones-i)/(nBones-1) as float) as string)+"+rotB.y_rotation*"+(((i-1)/(nBones-1) as float)as string)+")\n"
                                tempScript += "rotZ= (rotA.z_rotation*"+(((nBones-i)/(nBones-1) as float) as string)+"+rotB.z_rotation*"+(((i-1)/(nBones-1) as float)as string)+")\n"
                                tempScript += "eulerangles rotX rotY rotZ"
                                HelperArray[i].rotation.controller.script=tempScript
                            )
                        )
                    )
                    --if "Average to" equals All controls
                    2:
                    (
                        --If "Average Type" equals Orientation Constraint
                        if RotationAverage[2]==1 then
                        (
                             --Loops throught the Control Objects and constraint the bones between them (the weight is a static value in respect percent by number of controls 
                             --instead dynamic distance calculation)
                            m =(ControlsArray.count-1)
                            l=nBones/m as float
                            for j=1 to m do
                            (
                                for i=(ceil ((j-1)*l+1)) to (ceil (j*l)) do
                                (
                                    HelperArray[i].parent=RootHelper
                                    HelperArray[i].rotation.controller=orientation_constraint()
                                    --The weights in the orientation constraint depends on the helper's position in the chain
                                    HelperArray[i].rotation.controller.appendTarget ControlsArray[j] (100*(j-(i-1)/l as float))
                                    HelperArray[i].rotation.controller.appendTarget ControlsArray[(j+1)] (100*((i-1)-(j-1)*l)/l as float)
                                )
                            )
                        )
                        --If Average Type equals Euler Angles Average
                        else
                        (
                            m =(ControlsArray.count-1)
                            l=nBones/m as float
                            for j=1 to m do
                            (
                                for i=(ceil ((j-1)*l+1)) to (ceil (j*l)) do
                                (
                                    HelperArray[i].parent=RootHelper
                                    HelperArray[i].rotation.controller=rotation_script()
                                    HelperArray[i].rotation.controller.addObject "rotA" ControlsArray[j].rotation.controller
                                    HelperArray[i].rotation.controller.addObject "rotB" ControlsArray[j+1].rotation.controller
                                    local tempScript = ""
                                    tempScript += "rotX= (rotA.x_rotation*"+((j-(i-1)/l as float) as string)+"+rotB.x_rotation*"+((((i-1)-(j-1)*l)/l as float) as string)+")\n"
                                    tempScript += "rotY= (rotA.y_rotation*"+((j-(i-1)/l as float)as string)+"+rotB.y_rotation*"+((((i-1)-(j-1)*l)/l as float) as string)+")\n"
                                    tempScript += "rotZ= (rotA.z_rotation*"+((j-(i-1)/l as float) as string)+"+rotB.z_rotation*"+((((i-1)-(j-1)*l)/l as float) as string)+")\n"
                                    tempScript += "eulerangles rotX rotY rotZ"
                                    HelperArray[i].rotation.controller.script=tempScript
                                )
                            )
                        )
                    )
                    -- if "Average to" equals Spinner
                    3:
                    (
                        RootHelper.modifiers[1].SplineChain.Roll.controller=bezier_float()
                        for i=1 to nBones do
                        (
                            HelperArray[i].rotation.x_rotation.controller=float_script()
                            HelperArray[i].rotation.x_rotation.controller.addTarget "rollValue" RootHelper.modifiers[1].SplineChain.Roll.controller
                            HelperArray[i].rotation.x_rotation.controller.script="degtorad rollValue*"+(((i-1)/(nBones-1) as float) as string)
                        )
                    )
                )
            )
            --if the manipulation controllers option is active then create an extra euler_xyz controller for manual adjustments
            if ManCtrlsBool and RotationAverage[1] then
            (
                for i=1 to HelperArray.count do
                (
                    HelperArray[i].rotation.controller=rotation_list()
                    HelperArray[i].rotation.controller[2].controller=euler_xyz()
                    HelperArray[i].rotation.controller.active=2
                )
            )
            for i=1 to nBones do
            (
                boneArray[i].rotation.controller=lookAt_constraint()
                boneArray[i].rotation.controller.appendTarget helperArray[(i+1)] 100
                boneArray[i].rotation.controller.lookat_vector_length=0
                boneArray[i].rotation.controller.pickupnode=helperArray[i]
                boneArray[i].rotation.controller.upnode_world=false
            )
        )
        --if Look At Type Equals Quaternion Aim,constraints each bone to the current level helper
        --the helper will do all the job with the quaternion script controller
        else
        (
            setTransformLockFlags HelperArray #{5,6,7,8,9}
            local quatScriptCtrl
            local scriptString=""
            scriptString += "posThis=posThisCtrl.value*inverse nodeParent.transform\n"
            scriptString += "posTarget=posTargetCtrl.value*inverse nodeParent.transform\n"
            scriptString += "vector=posTarget-posThis\n"
            scriptString += "axis=normalize (cross vector [1,0,0])\n"
            scriptString += "angle=acos (normalize vector).x\n"
            if ManCtrlsBool then
            (
                for i=1 to HelperArray.count do
                (
                    HelperArray[i].rotation.controller=rotation_list()
                    HelperArray[i].rotation.controller[2].controller=euler_xyz()
                    HelperArray[i].rotation.controller.active=2
                )
                quatScriptCtrl=rotation_script()
                helperArray[1].rotation.controller[1].controller=quatScriptCtrl
                quatScriptCtrl.addNode "nodeParent" RootHelper
                quatScriptCtrl.addObject "posTargetCtrl" helperArray[2].position.controller
                quatScriptCtrl.addObject "posThisCtrl" helperArray[1].position.controller
                quatScriptCtrl.script=scriptString+"(quat angle axis)*nodeParent.transform.rotation"
                scriptString+="(quat rotX [1,0,0])*(quat angle axis)*nodeParent.transform.rotation"
                for i=2 to nBones do
                (
                    quatScriptCtrl=rotation_script()
                    helperArray[i].rotation.controller[1].controller=quatScriptCtrl
                    quatScriptCtrl.addNode "nodeParent" helperArray[i-1]
                    quatScriptCtrl.addObject "posTargetCtrl" helperArray[i+1].position.controller
                    quatScriptCtrl.addObject "posThisCtrl" helperArray[i].position.controller
                    quatScriptCtrl.addTarget "rotX" helperArray[i-1].rotation.controller[2].x_rotation.controller
                    quatScriptCtrl.script=scriptString
                )
            )
            else
            (
                scriptString+="(quat angle axis)*nodeParent.transform.rotation"
                local prevHelper=RootHelper
                for i=1 to nBones do
                (
                    quatScriptCtrl=rotation_script()
                    helperArray[i].rotation.controller=quatScriptCtrl
                    quatScriptCtrl.addNode "nodeParent" prevHelper
                    quatScriptCtrl.addObject "posTargetCtrl" helperArray[i+1].position.controller
                    quatScriptCtrl.addObject "posThisCtrl" helperArray[i].position.controller
                    quatScriptCtrl.script=scriptString
                    prevHelper=helperArray[i]
                )
            )
            --If the Average Constraint option is active then constraints the helpers to an average defined by the user
            --(by First and Last Control Objects, All Control Objects or Spinner)
            if RotationAverage[1] then
            (
                if not ManCtrlsBool then
                    for i=1 to HelperArray.count do
                        HelperArray[i].rotation.controller=rotation_list()
                    
                case RotationAverage[3] of
                (
                    --if "Average To" equals First and Last controls
                    1:
                    (
                         --If "Average Type" equals Orientation Constraint
                        if RotationAverage[2]==1 then
                        (
                            rotScriptCtrl=rotation_script()
                            rotScriptCtrl.addNode "nodeA" RootHelper
                            rotScriptCtrl.addNode "nodeB" controlsArray[1]
                            rotScriptCtrl.script="rot=quatToEuler (nodeB.transform*inverse nodeA.transform).rotation order:7\n"+
                                                       "quat (rot.x+rot.z) [-1,0,0]"
                            HelperArray[1].rotation.controller.available.controller=rotScriptCtrl
                            rotScriptCtrl=copy rotScriptCtrl
                            rotScriptCtrl.setNode "nodeA" controlsArray[1]
                            rotScriptCtrl.setNode "nodeB" controlsArray[controlsArray.count]
                            for i=2 to nBones do
                            (
                                HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
                                HelperArray[i].rotation.controller.weight[HelperArray[i].rotation.controller.count]=100.0/(nBones-1)
                            )
                        )
                        --If Average Type equals Euler Angles Average
                        else
                        (
                            rotScriptCtrl=rotation_script()
                            rotScriptCtrl.addTarget "rotXA" controlsArray[1].rotation.controller.x_rotation.controller
                            rotScriptCtrl.script="quat rotXA [-1,0,0]"
                            HelperArray[1].rotation.controller.available.controller=rotScriptCtrl
                            rotScriptCtrl=copy rotScriptCtrl
                            rotScriptCtrl.addTarget "rotXB" controlsArray[controlsArray.count].rotation.controller.x_rotation.controller
                            rotScriptCtrl.script="quat ((rotXB-rotXA)*"+((1.0/(nBones-1)) as string)+") [-1,0,0]"       
                            for i=2 to nBones do
                                HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
                        )
                    )
                    --if "Average to" equals All controls
                    2:
                    (
                        --If "Average Type" equals Orientation Constraint
                        if RotationAverage[2]==1 then
                        (
                             --Loops throught the Control Objects and constraint the bones between them (the weight is a static value in respect percent by number of controls 
                             --instead dynamic distance calculation)
                            m =(ControlsArray.count-1)
                            l=nBones/m as float
                            rotScriptCtrl=rotation_script()
                            rotScriptCtrl.addNode "nodeA" RootHelper
                            rotScriptCtrl.addNode "nodeB" controlsArray[1]
                            rotScriptCtrl.script="rot=quatToEuler (nodeB.transform*inverse nodeA.transform).rotation order:7\n"+
                                                       "quat (rot.x+rot.z) [-1,0,0]"
                            HelperArray[1].rotation.controller.available.controller=rotScriptCtrl
                            for j=1 to m do
                            (
                                difIter=((j-1)*l+1)
                                minIter=(ceil difIter) 
                                difIter=minIter-difIter
                                maxIter=(ceil (j*l))
                                if j!=1 then
                                (
                                    HelperArray[minIter].rotation.controller.available.controller=rotScriptCtrl
                                    HelperArray[minIter].rotation.controller.weight[HelperArray[minIter].rotation.controller.count]=100.0*(1-difIter)/l
                                )
                                rotScriptCtrl=copy rotScriptCtrl
                                rotScriptCtrl.setNode "nodeA" controlsArray[j]
                                rotScriptCtrl.setNode "nodeB" controlsArray[j+1]
                                if difIter!=0 then
                                (
                                    HelperArray[minIter].rotation.controller.available.controller=rotScriptCtrl
                                    HelperArray[minIter].rotation.controller.weight[HelperArray[minIter].rotation.controller.count]=100.0*difIter/l
                                )
                                minIter+=1
                                for i=minIter to maxIter do
                                (
                                    HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
                                    HelperArray[i].rotation.controller.weight[HelperArray[i].rotation.controller.count]=100.0/l
                                )
                            )
                        )
                        --If Average Type equals Euler Angles Average
                        else
                        (
                             --Loops throught the Control Objects and constraint the bones between them (the weight is a static value in respect percent by number of controls 
                             --instead dynamic distance calculation)
                            m =(ControlsArray.count-1)
                            l=nBones/m as float
                            for j=1 to m do
                            (
                                difIter=((j-1)*l+1)
                                minIter=(ceil difIter) 
                                difIter=minIter-difIter
                                rotScriptCtrl=rotation_script()
                                rotScriptCtrl.addTarget "rotXA" controlsArray[j].rotation.controller.x_rotation.controller
                                local scriptString="quat"
                                if j!=1 then
                                (
                                    rotScriptCtrl.addTarget "rotXB" controlsArray[j-1].rotation.controller.x_rotation.controller
                                    scriptString+=" ((rotXA-rotXB)*"+((1.0*(1-difIter)/l) as string)
                                    if difIter !=0 then
                                    (
                                        rotScriptCtrl.addTarget "rotXC" controlsArray[j+1].rotation.controller.x_rotation.controller
                                        scriptString+="+(rotXC-rotXA)*"+((1.0*difIter/l) as string)
                                    )
                                    scriptString+=")"
                                )
                                else
                                    scriptString+=" rotXA"
                                scriptString+=" [-1,0,0]" 
                                rotScriptCtrl.script=scriptString
                                HelperArray[minIter].rotation.controller.available.controller=rotScriptCtrl
                                
                                rotScriptCtrl=rotation_script()
                                rotScriptCtrl.addTarget "rotXA" controlsArray[j].rotation.controller.x_rotation.controller
                                rotScriptCtrl.addTarget "rotXB" controlsArray[j+1].rotation.controller.x_rotation.controller
                                rotScriptCtrl.script="quat ((rotXB-rotXA)*"+((1.0/l) as string)+") [-1,0,0]"
                                for i=minIter+1 to (ceil (j*l)) do
                                    HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
                            )
                        )
                    )
                    -- if "Average to" equals Spinner
                    3:
                    (
                        RootHelper.modifiers[1].SplineChain.Roll.controller=bezier_float()
                        for i=1 to nBones do
                        (
                            local rotCtrl=euler_xyz()
                            HelperArray[i].rotation.controller.available.controller=rotCtrl
                            rotCtrl.x_rotation.controller=float_script()
                            rotCtrl.x_rotation.controller.addTarget "rollValue" RootHelper.modifiers[1].SplineChain.Roll.controller
                            rotCtrl.x_rotation.controller.script="degtorad rollValue*"+(((i-1)/(nBones-1) as float) as string)
                        )
                    )
                )
            )

            for i=1 to nBones do
            (
                boneArray[i].rotation.controller=orientation_constraint()
                boneArray[i].rotation.controller.appendTarget helperArray[i] 100
            )
        )

        chainBoneArray = deepCopy BoneArray
        controlHelperArray = deepCopy HelperArray
    ),

    fn create_one_link_chain splineNode ControlsArray widthVar SquashBool:false = (
        --some variables
        local BoneArray=#()
        local SplineChainDef
        local rotScriptCtrl
        local lengthVar=curveLength splineNode
        local HelperArray=#()
        local RootHelper=point centerMarker:false axisTripod:false cross:false box:true size:(widthVar * 1.5) wirecolor:green name:rootHelperName
        RootHelper.transform=ControlsArray[1].transform
        ControlsArray.parent=RootHelper
        chainRootHelper = RootHelper

        BoneArray = bone.create_bone #(ControlsArray[1], ControlsArray[ControlsArray.count]) boneName end:true delPoint:false parent:false size:widthVar
        BoneArray[1].parent = RootHelper

        for i = 1 to BoneArray.count do (
            local helperVarName = name.replace_index controlHelperName ((i - 1) as string)
            local HelperVar=point centerMarker:false axisTripod:false cross:false box:true size:(widthVar * 0.5) wirecolor:blue name:helperVarName
            HelperVar.transform.position = BoneArray[i].transform.position

            BoneArray[i].position.controller=position_constraint()
            BoneArray[i].position.controller.appendTarget HelperVar 100

            append HelperArray HelperVar
        )

        if SquashBool then BoneArray.boneScaleType=#squash
        setInheritanceFlags HelperArray #{7,8,9}

        HelperArray[1].position.controller=path_constraint()
        HelperArray[1].position.controller.appendTarget splineNode 100
        deletekeys HelperArray[1].position.controller.percent.controller
        --the helper's percent over the spline depends on its position over the chain
        HelperArray[1].position.controller.percent=0.0
        HelperArray[1].position.controller=position_list()
        HelperArray[2].position.controller=path_constraint()
        HelperArray[2].position.controller.appendTarget splineNode 100
        deletekeys HelperArray[2].position.controller.percent.controller
        --the helper's percent over the spline depends on its position over the chain
        HelperArray[2].position.controller.percent=100.0
        HelperArray[2].position.controller=position_list()

        HelperArray.parent=RootHelper

        for i = 1 to HelperArray.count do (
            HelperArray[i].position.controller.available.controller=position_xyz()
            HelperArray[i].position.controller.active=HelperArray[i].position.controller.count
        )

        setTransformLockFlags HelperArray #{5,6,7,8,9}
        local quatScriptCtrl
        local scriptString=""
        scriptString += "posThis=posThisCtrl.value*inverse nodeParent.transform\n"
        scriptString += "posTarget=posTargetCtrl.value*inverse nodeParent.transform\n"
        scriptString += "vector=posTarget-posThis\n"
        scriptString += "axis=normalize (cross vector [1,0,0])\n"
        scriptString += "angle=acos (normalize vector).x\n"

        for i=1 to HelperArray.count do (
            HelperArray[i].rotation.controller=rotation_list()
            HelperArray[i].rotation.controller[2].controller=euler_xyz()
            HelperArray[i].rotation.controller.active=2
        )
        quatScriptCtrl=rotation_script()
        helperArray[1].rotation.controller[1].controller=quatScriptCtrl
        quatScriptCtrl.addNode "nodeParent" RootHelper
        quatScriptCtrl.addObject "posTargetCtrl" helperArray[2].position.controller
        quatScriptCtrl.addObject "posThisCtrl" helperArray[1].position.controller
        quatScriptCtrl.script=scriptString+"(quat angle axis)*nodeParent.transform.rotation"
        scriptString+="(quat rotX [1,0,0])*(quat angle axis)*nodeParent.transform.rotation"

        rotScriptCtrl=rotation_script()
        rotScriptCtrl.addTarget "rotXA" controlsArray[1].rotation.controller.x_rotation.controller
        rotScriptCtrl.script="quat rotXA [-1,0,0]"
        HelperArray[1].rotation.controller.available.controller=rotScriptCtrl

        boneArray[1].rotation.controller=orientation_constraint()
        boneArray[1].rotation.controller.appendTarget helperArray[1] 100

        chainBoneArray = deepCopy BoneArray
        controlHelperArray = deepCopy HelperArray
    ),

    fn create = (
        if linkNum > 1 then (
            assign_splineIK()
            create_chain spline splineHelperArray linkNum boneSize 0 SquashBool:squash
        )
        if linkNum == 1 then (
            assign_splineIK()
            create_one_link_chain spline splineHelperArray boneSize SquashBool:squash
        )
    ),

    fn delAll = (
        -- delete_bones_safely boneArray
        -- delete_bones_safely controlHelperArray
        -- delete_bones_safely splineHelperArray
        -- delete_bones_safely #(spline)
        -- delete_bones_safely #(rootHelper)
        select chainBoneArray
        selectmore controlHelperArray
        selectmore splineHelperArray
        selectmore spline
        selectmore chainRootHelper

        delete selection

        reset()
    )
)
