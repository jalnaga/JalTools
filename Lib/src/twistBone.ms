struct _TwistBone (
    name, anim, helper, bone, const, bip,

    baseName = "",
    filteringChar = " ",
    bipObj = undefined,
    upperArmNum = 0,
    foreArmNum = 0,
    thighNum = 0,
    calfNum = 0,
    boneSize = 2.0,
    lUpperArmBoneArray = #(),
    rUpperArmBoneArray = #(),
    lForeArmBoneArray = #(),
    rForeArmBoneArray = #(),
    lThighBoneArray = #(),
    rThighBoneArray = #(),
    lCalfBoneArray = #(),
    rCalfBoneArray = #(),


    fn init inBip inBoneSize = (
        if (isValidNode inBip) then (
            if (classOf inBip) == Biped_Object then (
                bip.get_bip_nodes inBip
                bipObj = bip.com
                baseName = bip.rootName
                filteringChar = " "
                upperArmNum = (bip.get_twist_bone_number inBip)[1]
                foreArmNum = (bip.get_twist_bone_number inBip)[2]
                thighNum = (bip.get_twist_bone_number inBip)[3]
                calfNum = (bip.get_twist_bone_number inBip)[4]
                
                boneSize = inBoneSize

                lUpperArmBoneArray = #()
                rUpperArmBoneArray = #()
                lForeArmBoneArray = #()
                rForeArmBoneArray = #()
                lThighBoneArray = #()
                rThighBoneArray = #()
                lCalfBoneArray = #()
                rCalfBoneArray = #()

                return true
            )
        )

        return false
    ),

    fn create_simple_type noEnd:false = (
        if bip.com == undefined then return false

        local RLegAux = bip.rThigh
        local LLegAux = bip.lThigh
        local PelvisAux = bip.pelvis
        RLegAux.parent=LLegAux.parent=PelvisAux

        local bipLimbs=#()
        bipLimbs[1]=#(#larm, 2, upperArmNum - 1, 1, " L UpperArm")
        bipLimbs[2]=#(#rarm, 2, upperArmNum - 1, 1, " R UpperArm")
        bipLimbs[3]=#(#larm, 3, foreArmNum - 1, 2, " L ForeArm")
        bipLimbs[4]=#(#rarm, 3, foreArmNum - 1, 2, " R ForeArm")
        bipLimbs[5]=#(#lleg, 1, thighNum - 1, 3, " L Thigh")
        bipLimbs[6]=#(#rleg, 1, thighNum - 1, 3, " R Thigh")
        bipLimbs[7]=#(#lleg, 2, calfNum - 1, 4, " L Calf")
        bipLimbs[8]=#(#rleg, 2, calfNum - 1, 4, " R Calf")

        local TBExpressionA = ""
        TBExpressionA += "try(\n"
        TBExpressionA += "TM=Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionA += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionA += "angle=acos (normalize TM.row1).x\n"
        TBExpressionA += "(quat angle vector)*inverse TM.rotation)\n"
        TBExpressionA += "catch((quat 0 0 0 1))"

        local TBExpressionBa = ""
        TBExpressionBa += "try(\n"
        TBExpressionBa += "TM=(matrix3 [1,0,0] [0,0,-1] [0,1,0] [0,0,0])*Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionBa += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionBa += "angle=acos (normalize TM.row1).x\n"
        TBExpressionBa += "TM.rotation*(quat -angle vector))\n"
        TBExpressionBa += "catch((quat 0 0 0 1))"

        local TBExpressionBb = ""
        TBExpressionBb += "try(\n"
        TBExpressionBb += "TM=(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])*Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionBb += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionBb += "angle=acos (normalize TM.row1).x\n"
        TBExpressionBb += "TM.rotation*(quat -angle vector))\n"
        TBExpressionBb += "catch((quat 0 0 0 1))"

        local TBExpressionC = ""
        TBExpressionC += "try(\n"
        TBExpressionC += "TM=Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionC += "vector=normalize (cross -TM.row1 [1,0,0])\n"
        TBExpressionC +=  "angle=acos -(normalize TM.row1).x\n"
        TBExpressionC += "(quat 0 1 0 0)*(quat angle vector)*inverse TM.rotation)\n"
        TBExpressionC += "catch((quat 0 0 0 1))"

        local TBExpressionD = ""
        TBExpressionD += "try(\n"
        TBExpressionD += "TM=Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionD += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionD += "angle=acos (normalize TM.row1).x\n"
        TBExpressionD += "TM.rotation*(quat -angle vector))\n"
        TBExpressionD += "catch((quat 0 0 0 1))"

        local TBExtraExpressionA = ""
        TBExtraExpressionA += "try(\n"
        TBExtraExpressionA += "(Limb.transform*inverse LimbParent.transform).rotation\n"
        TBExtraExpressionA += ")catch((quat 0 0 0 1))"
        
        local TBExtraExpressionB="try(dependson TB\nTB.rotation.controller[1].value\n)catch((quat 0 0 0 1))"

        for index = 1 to bipLimbs.count do
        (
            local k = bipLimbs[index]
            local boneChainArray = #()
            if (k[3]>0) then
            (
                local Limb=biped.getNode bipObj.controller k[1] link:k[2]
                local distanceVar=(distance limb limb.Children[1])

                local TBExpression=""
                local ControllerLimb=Limb
                local weightVar=100
                
                case k[4] of
                (
                    1:(TBExpression=TBExpressionA)
                    2:(
                    if k[1]==#larm then TBExpression=TBExpressionBb else TBExpression=TBExpressionBa
                    ControllerLimb=Limb.children[1]
                    weightVar=100/k[3]
                    )
                    3:(TBExpression=TBExpressionC)
                    4:(
                    TBExpression=TBExpressionD
                    ControllerLimb=Limb.children[1]
                    weightVar=100/k[3]
                    )
                )
                
                local TwistBone=BoneSys.createBone Limb.transform.position Limb.transform.position [0,0,1]
                local boneName = bip.rootName+k[5]+ "Twist"
                TwistBone.name=boneName + " 0"
                TwistBone.parent=Limb
                --TwistBone.parent=Limb.parent
                TwistBone.Length=distanceVar/(k[3]+1)
                TwistBone.Width=distanceVar/8
                TwistBone.Height=TwistBone.Width
                TwistBone.taper=0
                TwistBone.sidefins=off
                TwistBone.frontfin=off
                TwistBone.backfin=off
                TwistBone.rotation.controller=Rotation_List()
                TwistBone.rotation.controller[1].controller=rotation_script()
                TwistBone.rotation.controller[1].AddNode "Limb" ControllerLimb
                TwistBone.rotation.controller[1].SetExpression TBExpression
                TwistBone.rotation.controller.weight[1]=weightVar
                
                append boneChainArray TwistBone
                
                local TBExtraController=rotation_script()
                case of
                (
                    (k[4]==1 or k[4]==3):(
                    TBExtraController.AddNode "Limb" Limb 
                    TBExtraController.AddNode "LimbParent" TwistBone 
                    TBExtraController.setExpression TBExtraExpressionA
                    )
                    (k[4]==2 or k[4]==4):(
                    TBExtraController.AddNode "TB" TwistBone
                    TBExtraController.setExpression TBExtraExpressionB
                    )
                )
                
                local PrevTBE=TwistBone
                
                local middleTwistBonesArray = #()
                for j=2 to k[3] do
                (
                    local TwistBoneExtra=BoneSys.createBone [0,0,0] [1,0,0] [0,0,1]
                    local matAux=matrix3 1
                    matAux.position=[(distanceVar/(k[3]+1)),0,0]
                    TwistBoneExtra.transform=matAux*PrevTBE.transform
                    TwistBoneExtra.name=boneName + " " +((j-1) as string)
                    TwistBoneExtra.parent=PrevTBE
                    TwistBoneExtra.Length=distanceVar/(k[3]+1)
                    TwistBoneExtra.Width=PrevTBE.Width
                    TwistBoneExtra.Height=PrevTBE.Height
                    TwistBoneExtra.taper=0
                    TwistBoneExtra.sidefins=off
                    TwistBoneExtra.frontfin=off
                    TwistBoneExtra.backfin=off
                    TwistBoneExtra.rotation.controller=Rotation_List()
                    TwistBoneExtra.rotation.controller[1].controller=TBExtraController
                    TwistBoneExtra.rotation.controller.weight[1]=100/k[3]
                    PrevTBE=TwistBoneExtra
                    
                    append boneChainArray TwistBoneExtra
                )
                
                local TwistBoneEnd = BoneSys.createBone [0,0,0] [1,0,0] [0,0,1] 
                local matAux=matrix3 1
                
                matAux.position=[(distanceVar/(k[3]+1)),0,0]
                TwistBoneEnd.transform=matAux*PrevTBE.transform
                TwistBoneEnd.name=boneName + " " + (k[3] as string)
                TwistBoneEnd.parent=getNodeByName (bip.rootName + k[5])
                TwistBoneEnd.Length=distanceVar/(k[3]+1)
                TwistBoneEnd.Width=PrevTBE.Width
                TwistBoneEnd.Height=PrevTBE.Height
                TwistBoneEnd.taper=0
                TwistBoneEnd.sidefins=off
                TwistBoneEnd.frontfin=off
                TwistBoneEnd.backfin=off
                
                append boneChainArray TwistBoneEnd
            )

            case index of
            (
                1:(for item in boneChainArray do append lUpperArmBoneArray item)
                2:(for item in boneChainArray do append rUpperArmBoneArray item)
                3:(for item in boneChainArray do append lForeArmBoneArray item)
                4:(for item in boneChainArray do append rForeArmBoneArray item)
                5:(for item in boneChainArray do append lThighBoneArray item)
                6:(for item in boneChainArray do append rThighBoneArray item)
                7:(for item in boneChainArray do append lCalfBoneArray item)
                8:(for item in boneChainArray do append rCalfBoneArray item)
            )
        )

        -- sort forearm and calf bones' order and counting name
        if foreArmNum > 0 then
        (
            local lForeArmObj = lForeArmBoneArray[1]
            local rForeArmObj = rForeArmBoneArray[1]
            local lForeArmEndObj = lForeArmBoneArray[lForeArmBoneArray.count]
            local rForeArmEndObj = rForeArmBoneArray[rForeArmBoneArray.count]
            
            anim.move_local lForeArmObj lForeArmObj.length 0 0
            anim.move_local rForeArmObj rForeArmObj.length 0 0
            anim.move_local lForeArmEndObj -(lForeArmObj.length * (foreArmNum - 1)) 0 0
            anim.move_local rForeArmEndObj -(rForeArmObj.length * (foreArmNum - 1)) 0 0

            for i = 1 to (lForeArmBoneArray.count - 1) do lForeArmBoneArray[i].name = (bip.rootName + " L ForeArmTwist " + (i as string))
            lForeArmEndObj.name = (bip.rootName + " L ForeArmTwist 0")
            
            for i = 1 to (lForeArmBoneArray.count - 1) do rForeArmBoneArray[i].name = (bip.rootName + " R ForeArmTwist " + ((i+1) as string))
            rForeArmEndObj.name = (bip.rootName + " R ForeArmTwist 0")

            local tempLForeArmArray = #(lForeArmEndObj)
            local tempRForeArmArray = #(rForeArmEndObj)

            for i = 1 to (lForeArmBoneArray.count - 1) do (
                append tempLForeArmArray lForeArmBoneArray
                append tempRForeArmArray rForeArmBoneArray
            )
            lForeArmBoneArray = #()
            rForeArmBoneArray = #()

            lForeArmBoneArray = deepCopy tempLForeArmArray
            rForeArmBoneArray = deepCopy tempRForeArmArray
        )
        if calfNum > 0 then
        (
            local lCalfObj = lCalfBoneArray[1]
            local rCalfObj = rCalfBoneArray[1]
            local lCalfEndObj = lCalfBoneArray[lCalfBoneArray.count]
            local rCalfEndObj = rCalfBoneArray[rCalfBoneArray.count]
            
            anim.move_local lCalfObj lCalfObj.length 0 0
            anim.move_local rCalfObj rCalfObj.length 0 0
            anim.move_local lCalfEndObj -(lCalfObj.length * (calfNum - 1)) 0 0
            anim.move_local rCalfEndObj -(rCalfObj.length * (calfNum - 1)) 0 0

            for i = 1 to (lCalfBoneArray.count - 1) do lCalfBoneArray[i].name = (bip.rootName + " L CalfTwist " + (i as string))
            lCalfEndObj.name = (bip.rootName + " L CalfTwist 0")
            
            for i = 1 to (lCalfBoneArray.count - 1) do rCalfBoneArray[i].name = (bip.rootName + " R CalfTwist " + ((i+1) as string))
            rCalfEndObj.name = (bip.rootName + " R CalfTwist 0")

            local tempLCalfArray = #(lCalfEndObj)
            local tempRCalfArray = #(rCalfEndObj)

            for i = 1 to (lCalfBoneArray.count - 1) do (
                append tempLCalfArray lCalfBoneArray
                append tempRCalfArray rCalfBoneArray
            )
            lCalfBoneArray = #()
            rCalfBoneArray = #()

            lCalfBoneArray = deepCopy tempLCalfArray
            rCalfBoneArray = deepCopy tempRCalfArray
        )

        bip.turn_on_figureMode bipObj
        bipObj.controller.upperarmTwistLinks = 0
        bipObj.controller.forearmTwistLinks = 0
        bipObj.controller.thighTwistLinks = 0
        bipObj.controller.calfTwistLinks = 0
        bip.turn_off_figureMode bipObj
    ),

    fn create_bones inObj inTwistNum inExpression inExtraExpression inControllerLimb inWeightVar = (
        local Limb = inObj
        local distanceVar = (distance Limb Limb.children[1])

        local TBExpression=""
        local ControllerLimb = inControllerLimb
        local weightVar = inWeightVar

        TBExpression = inExpression

        local boneChainArray = #()
        
        local TwistBone = BoneSys.createBone Limb.transform.position Limb.transform.position [0,0,1]
        local boneName = (name.get_string inObj.name) + "Twist"
        TwistBone.name = name.replace_index boneName "0"
        TwistBone.parent = Limb
        TwistBone.Length = distanceVar/inTwistNum
        TwistBone.Width = distanceVar/8
        TwistBone.Height = TwistBone.Width
        TwistBone.taper = 0
        TwistBone.sidefins = off
        TwistBone.frontfin = off
        TwistBone.backfin = off
        TwistBone.rotation.controller = Rotation_List()
        TwistBone.rotation.controller[1].controller = rotation_script()
        TwistBone.rotation.controller[1].AddNode "Limb" ControllerLimb
        TwistBone.rotation.controller[1].SetExpression TBExpression
        TwistBone.rotation.controller.weight[1] = weightVar
        
        append boneChainArray TwistBone
        
        local TBExtraController = rotation_script()
        if (matchPattern inExtraExpression pattern:"*\nTB.*") then (
            TBExtraController.AddNode "TB" TwistBone
        )
        else (
            TBExtraController.AddNode "Limb" Limb
            TBExtraController.AddNode "LimbParent" TwistBone 
        )
        TBExtraController.setExpression inExtraExpression
        
        local PrevTBE = TwistBone
        
        local middleTwistBonesArray = #()
        for j = 2 to (inTwistNum - 1) do
        (
            local TwistBoneExtra = BoneSys.createBone [0,0,0] [1,0,0] [0,0,1]
            local matAux = matrix3 1
            matAux.position = [(distanceVar/inTwistNum), 0, 0]
            TwistBoneExtra.transform = matAux*PrevTBE.transform
            TwistBoneExtra.name = name.replace_index boneName ((j-1) as string)
            TwistBoneExtra.parent = PrevTBE
            TwistBoneExtra.Length = distanceVar/inTwistNum
            TwistBoneExtra.Width = PrevTBE.Width
            TwistBoneExtra.Height = PrevTBE.Height
            TwistBoneExtra.taper = 0
            TwistBoneExtra.sidefins = off
            TwistBoneExtra.frontfin = off
            TwistBoneExtra.backfin = off
            TwistBoneExtra.rotation.controller = Rotation_List()
            TwistBoneExtra.rotation.controller[1].controller = TBExtraController
            TwistBoneExtra.rotation.controller.weight[1] = 100/(inTwistNum - 1)
            PrevTBE = TwistBoneExtra
            
            append boneChainArray TwistBoneExtra
        )
        
        local TwistBoneEnd = BoneSys.createBone [0,0,0] [1,0,0] [0,0,1] 
        local matAux = matrix3 1
        
        matAux.position = [(distanceVar/inTwistNum), 0, 0]
        TwistBoneEnd.transform = matAux*PrevTBE.transform
        TwistBoneEnd.name = name.replace_index boneName ((inTwistNum-1) as string)
        TwistBoneEnd.parent = inObj
        TwistBoneEnd.Length = distanceVar/inTwistNum
        TwistBoneEnd.Width = PrevTBE.Width
        TwistBoneEnd.Height = PrevTBE.Height
        TwistBoneEnd.taper = 0
        TwistBoneEnd.sidefins = off
        TwistBoneEnd.frontfin = off
        TwistBoneEnd.backfin = off
        
        append boneChainArray TwistBoneEnd

        boneChainArray
    ),

    fn reorder_bones inBoneChainArray = (
        local  boneChainArray = deepCopy inBoneChainArray

        local foreArmBone = boneChainArray[1]
        local foreArmEndBone = boneChainArray[boneChainArray.count]
        
        for i = 1 to (boneChainArray.count-1) do anim.move_local boneChainArray[i] foreArmBone.length 0 0
        anim.move_local foreArmEndBone -(foreArmBone.length * (boneChainArray.count - 1)) 0 0

        for i = 1 to (boneChainArray.count - 1) do boneChainArray[i].name = name.replace_index boneChainArray[i].name (i as string)
        foreArmEndBone.name = name.replace_index foreArmEndBone.name "0"
        
        local tempForeArmArray = #(foreArmEndBone)
        for i = 1 to (boneChainArray.count - 1) do append tempForeArmArray boneChainArray[i]
        boneChainArray = #()
        boneChainArray = deepCopy tempForeArmArray
        tempForeArmArray = #()

        boneChainArray
    ),

    fn create_upperArm_type inObj inTwistNum = (
        if inObj.parent == undefined or inObj.children.count == 0 then return false

        local TBExpressionA = ""
        TBExpressionA += "try(\n"
        TBExpressionA += "TM=Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionA += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionA += "angle=acos (normalize TM.row1).x\n"
        TBExpressionA += "(quat angle vector)*inverse TM.rotation)\n"
        TBExpressionA += "catch((quat 0 0 0 1))"

        local TBExtraExpressionA = ""
        TBExtraExpressionA += "try(\n"
        TBExtraExpressionA += "(Limb.transform*inverse LimbParent.transform).rotation\n"
        TBExtraExpressionA += ")catch((quat 0 0 0 1))"

        create_bones inObj inTwistNum TBExpressionA TBExtraExpressionA inObj 100
    ),

    fn create_foreArm_type inObj inTwistNum side:#left = (
        if inObj.parent == undefined or inObj.children.count == 0 then return false

        local boneChainArray = #()
        local TBExpressionBa = ""
        TBExpressionBa += "try(\n"
        TBExpressionBa += "TM=(matrix3 [1,0,0] [0,0,-1] [0,1,0] [0,0,0])*Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionBa += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionBa += "angle=acos (normalize TM.row1).x\n"
        TBExpressionBa += "TM.rotation*(quat -angle vector))\n"
        TBExpressionBa += "catch((quat 0 0 0 1))"

        local TBExpressionBb = ""
        TBExpressionBb += "try(\n"
        TBExpressionBb += "TM=(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])*Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionBb += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionBb += "angle=acos (normalize TM.row1).x\n"
        TBExpressionBb += "TM.rotation*(quat -angle vector))\n"
        TBExpressionBb += "catch((quat 0 0 0 1))"

        local TBExtraExpressionB="try(dependson TB\nTB.rotation.controller[1].value\n)catch((quat 0 0 0 1))"

        local TBExpression = ""

        if side == #left then TBExpression = TBExpressionBb else TBExpression = TBExpressionBa

        boneChainArray = create_bones inObj inTwistNum TBExpression TBExtraExpressionB (inObj.children[1]) (100/(inTwistNum - 1))

        reorder_bones boneChainArray
    ),

    fn create_thigh_type inObj inTwistNum = (
        if inObj.parent == undefined or inObj.children.count == 0 then return false

        local TBExpressionC = ""
        TBExpressionC += "try(\n"
        TBExpressionC += "TM=Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionC += "vector=normalize (cross -TM.row1 [1,0,0])\n"
        TBExpressionC +=  "angle=acos -(normalize TM.row1).x\n"
        TBExpressionC += "(quat 0 1 0 0)*(quat angle vector)*inverse TM.rotation)\n"
        TBExpressionC += "catch((quat 0 0 0 1))"

        local TBExtraExpressionA = ""
        TBExtraExpressionA += "try(\n"
        TBExtraExpressionA += "(Limb.transform*inverse LimbParent.transform).rotation\n"
        TBExtraExpressionA += ")catch((quat 0 0 0 1))"

        create_bones inObj inTwistNum TBExpressionC TBExtraExpressionA inObj 100
    ),

    fn create_calf_typ inObj inTwistNum side:#left = (
        if inObj.parent == undefined or inObj.children.count == 0 then return false

        local TBExpressionD = ""
        TBExpressionD += "try(\n"
        TBExpressionD += "TM=Limb.transform*inverse Limb.parent.transform\n"
        TBExpressionD += "vector=normalize (cross TM.row1 [1,0,0])\n"
        TBExpressionD += "angle=acos (normalize TM.row1).x\n"
        TBExpressionD += "TM.rotation*(quat -angle vector))\n"
        TBExpressionD += "catch((quat 0 0 0 1))"

        local TBExtraExpressionB="try(dependson TB\nTB.rotation.controller[1].value\n)catch((quat 0 0 0 1))"

        reorder_bones (create_bones inObj inTwistNum TBExpressionD TBExtraExpressionB inObj.children[1] 100/(inTwistNum - 1))
    ),

    fn create_bend_type = (
    )
)
