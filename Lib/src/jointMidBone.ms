struct _JointMidBone (
    name,
    anim,
    helper,
    bone,
    const,

    baseName = "",
    boneSize = 2.0,

    boneArray = #(),
    rotDir = [0.0, 0.0, -1.0],
    
    upperObj,
    underObj,
    upperWeight = 50.0,
    underWeight = 50.0,

    upperDummy,
    underDummy,

    helperArray = #(),

    fn init inBaseName inUpper inUnder inBoneSize:2.0 inRotDir:[0.0, 0.0, -1.0] inUpperWeight:50.0 inUnderWeight:50.0 = (
        filteringChar = inFilteringChar
        boneSize = inBoneSize
        baseName = inBaseName
        rotDir = inRotDir
        upperObj = inUpper
        underObj = inUnder
        upperWeight = inUpperWeight
        underWeight = inUnderWeight

        boneArray = #()
        helperArray = #()
    ),

    fn gen_helpers = (
        upperDummy = helper.create_point (name.replace_type baseName "Dum") size:1 boxToggle:on
        upperDummy.name = name.replace_index upperDummy.name "0"
        upperDummy.name = name.add_sufix_to_realName upperDummy.name "Upper"

        underDummy = helper.create_point (name.replace_type baseName "Dum") size:1.5 boxToggle:on
        underDummy.name = name.replace_index underDummy.name "0"
        upperDummy.name = name.add_sufix_to_realName underDummy.name "Under"

        helperArray = #()
        append helperArray upperDummy
        append helperArray underDummy
        return helperArray
    ),

    fn create = (
        gen_helpers()
        local pickMiddleBone = bone.create_simple_bone (boneSize * 2) baseName size:boneSize

        upperDummy.transform = underObj.transform
        underDummy.transform = underObj.transform
        upperDummy.parent = upperObj
        underDummy.parent = underObj
        
        pickMiddleBone[1].transform = underObj.transform
        anim.rotate_local pickMiddleBone[1] (rotDir.x * 0) (rotDir.y * 0) (rotDir.z * 90)
        
        pickMiddleBone[1].rotation.controller = Orientation_Constraint ()
        pickMiddleBone[1].rotation.controller.appendTarget upperDummy upperWeight
        pickMiddleBone[1].rotation.controller.appendTarget underDummy underWeight
        pickMiddleBone[1].rotation.controller.relative = on

        pickMiddleBone[1].position.controller = Position_Constraint ()
        pickMiddleBone[1].position.controller.appendTarget upperDummy upperWeight
        pickMiddleBone[1].position.controller.appendTarget underDummy underWeight
        pickMiddleBone[1].position.controller.relative = on

        pickMiddleBone[1].parent = underObj.parent
        
        boneArray = #()

        append boneArray pickMiddleBone[1]
        append boneArray pickMiddleBone[2]
    ),

    fn delAll = (
        bone.delete_bones_safely boneArray
        bone.delete_bones_safely helperArray
    ),

    fn set_weight inUpperWeight inUnderWeight = (
        delAll()
        upperWeight = inUpperWeight
        underWeight = inUnderWeight

        create()
    )
)
