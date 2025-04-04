include "string.ms"
include "name.ms"
include "anim.ms"

include "helper.ms"
include "constraint.ms"
include "bone.ms"

include "bip.ms"

include "mirror.ms"
include "layer.ms"
include "align.ms"
include "select.ms"
include "link.ms"

include "skin.ms"

include "hip.ms"
include "jointMidBone.ms"
include "muscleBone.ms"
include "figureBone.ms"
include "autoClavicleBone.ms"
include "shoulderBone.ms"
include "breastBone.ms"
include "chestBone.ms"
include "sartoriusBone.ms"
include "kneeBone.ms"
include "twistBone.ms"

include "joystick.ms"

include "progress.ms"
include "rollout.ms"

include "poly.ms"
include "morph.ms"

include "xml.ms"

include "tools.ms"

struct _JalLib (
    str = _String(),
    name = _Name(),
    anim = _Anim(),

    helper = _Helper(),
    const = _Constraint(),
    bone = _Bone(),

    bip = _Bip(),

    mirror = _Mirror(),
    layer = _Layer(),
    align = _Align(),
    sel = _Select(),
    link = _Link(),

    skin = _Skin(),

    hip = _Hip(),
    jointMid = _JointMidBone(),
    muscleBone = _MuscleBone(),

    figureBone = _FigureBone(),

    autoClavicleBone = _AutoClavicleBone(),
    shoulderBone = _ShoulderBone(),
    chestBone = _ChestBone(),
    breastBone = _BreastBone(),
    sartoriusBone = _SartoriusBone(),
    kneeBone = _KneeBone(),
    twistBone = _TwistBone(),

    joystick = _JoystickGenerator(),

    prog = _Progress(),
    roll = _Rollout(),

    poly = _Poly(),
    mor = _Morph(),

    xml = _XMLDoc(),

    tools = _Tools(),

    on create do (
        name.str = str
        helper.name = name

        const.str = str
        const.name = name
        const.helper = helper

        bone.str = str
        bone.name = name
        bone.anim = anim
        bone.helper = helper
        bone.const = const

        bip.name = name
        bip.anim = anim
        bip.bone = bone

        mirror.name = name
        mirror.bone = bone
        sel.name = name
        sel.bone = bone

        skin.name = name
        skin.prog = prog

        hip.name = name
        hip.anim = anim
        hip.helper = helper
        hip.bone = bone
        hip.const = const
        hip.bip = bip
        jointMid.name = name
        jointMid.anim = anim
        jointMid.helper = helper
        jointMid.bone = bone
        jointMid.const = const
        muscleBone.name = name
        muscleBone.anim = anim
        muscleBone.helper = helper
        muscleBone.bone = bone
        muscleBone.const = const

        figureBone.name = name
        figureBone.anim = anim
        figureBone.bone = bone
        figureBone.helper = helper

        autoClavicleBone.name = name
        autoClavicleBone.anim = anim
        autoClavicleBone.helper = helper
        autoClavicleBone.bone = bone
        autoClavicleBone.const = const
        autoClavicleBone.bip = bip

        shoulderBone.name = name
        shoulderBone.anim = anim
        shoulderBone.helper = helper
        shoulderBone.bone = bone
        shoulderBone.const = const

        chestBone.name = name
        chestBone.anim = anim
        chestBone.helper = helper
        chestBone.bone = bone
        chestBone.const = const

        breastBone.name = name
        breastBone.anim = anim
        breastBone.helper = helper
        breastBone.bone = bone
        breastBone.const = const

        sartoriusBone.name = name
        sartoriusBone.anim = anim
        sartoriusBone.helper = helper
        sartoriusBone.bone = bone
        sartoriusBone.const = const

        kneeBone.name = name
        kneeBone.anim = anim
        kneeBone.helper = helper
        kneeBone.bone = bone
        kneeBone.const = const
        kneeBone.bip = bip

        twistBone.name = name
        twistBone.anim = anim
        twistBone.helper = helper
        twistBone.bone = bone
        twistBone.const = const
        twistBone.bip = bip

        joystick.str = str
        joystick.name = name
        joystick.anim = anim
        joystick.const = const
    )
)
