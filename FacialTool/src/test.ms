__FacialTool = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __FacialTool
(
    clearlistener()
    include "facialCage.ms"
    local tempFacial = _FacialCage()
    tempFacial.cageMesh = (getCurrentSelection() as Array)[1]

    tempFacial.gen_placer_on_vertex alignToVertexNormal:true
    tempFacial.gen_bone_on_placer()
    gc()
)
