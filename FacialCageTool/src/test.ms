__FacialTool = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __FacialTool
(
    clearlistener()
    include "facial.ms"
    local tempFacial = _Facial()
    tempFacial.cageMesh = (getCurrentSelection() as Array)[1]

    tempFacial.gen_placer_on_vertex()
    tempFacial.gen_bone_on_placer()
    gc()
)
