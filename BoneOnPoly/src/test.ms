__BoneOnFace = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __BoneOnFace
(
    gc()
    include "boneOnPoly.ms"
    local bop = _BoneOnPoly()
    bop.cageMesh = (getCurrentSelection())[1]
    local filterVertArray = bop.get_filtered_vertex_by_vertexSelection()
    local genHelperArray = bop.gen_placer_on_vertex filterVertArray alignToNormal:true
    bop.attach_controller_to_helper genHelperArray filterVertArray
    --local oriObj = selection[1]
    --local newObj = selection[2]
    --local oldAttCtrl = oriObj.position.controller
    --local oldKey = AttachCtrl.getKey oldAttCtrl 1
    --local newAttCtrl = Attachment node:$Cage_Body
    --newAttCtrl.align = false
    --newObj.position.controller.Available.controller = newAttCtrl
    --local newKey = AttachCtrl.addNewKey newAttCtrl 0
    --newKey.face = oldKey.face
    --newKey.coord = oldKey.coord
    --newObj.position.controller.setActive newObj.position.controller.count
    --hide oriObj
    --hide newObj
)
