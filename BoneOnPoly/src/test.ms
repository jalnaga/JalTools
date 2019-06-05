__BoneOnFace = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __BoneOnFace
(
    gc()
    include "boneOnPoly.ms"
    local bop = _BoneOnPoly()
    bop.cageMesh = (getCurrentSelection())[1]
    bop.gen_placer_on_vertex alignToNormal:true
)
