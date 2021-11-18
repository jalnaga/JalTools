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
include "twistBone.ms"
include "joystick.ms"

include "progress.ms"
include "rollout.ms"

include "poly.ms"
include "morph.ms"

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

    twistBone = _TwistBone(),

    joystick = _JoystickGenerator(),

    prog = _Progress(),
    roll = _Rollout(),

    poly = _Poly(),
    mor = _Morph(),

    tools = _Tools(),

    on create do (
        name.str = str
        helper.name = name

        const.name = name
        const.helper = helper

        bone.name = name
        bone.anim = anim
        bone.helper = helper
        bone.const = const

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

        twistBone.name = name
        twistBone.anim = anim
        twistBone.helper = helper
        twistBone.bone = bone
        twistBone.const = const
        twistBone.bip = bip

        joystick.name = name
        joystick.anim = anim
        joystick.const = const
    )
)
