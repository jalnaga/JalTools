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

include "progress.ms"
include "rollout.ms"

include "poly.ms"
include "morph.ms"

include "xml.ms"

include "fileIO.ms"

include "tools.ms"

struct _JalLib (
    str = _String(),
    nameManager = _Name_Idf_Manager(),
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

    prog = _Progress(),
    roll = _Rollout(),

    poly = _Poly(),
    mor = _Morph(),

    xml = _XMLDoc(),
    fileIO = _FileIO(),

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
        skin.xml = xml
    )
)
