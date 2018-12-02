(
local selObj = $
local selMesh = selObj.mesh
local genMeshArray = #()

fn convert_p3_to_array inP3 = (
    #(inP3.x, inP3.y, inP3.z)
)

fn get_first_item inBitArray item:0 = (
    for i in inBitArray while Not item > 0 do item = i
    item
)

for i = 1 to selObj.numverts do (
    local vertPos = (getVert selMesh i) * selObj.objectTransform
    local row1 = (getNormal selMesh i) * selObj.objectTransform.rotation
    local row2 = normalize (cross row1 [0,0,-1])
    local row3 = normalize (cross row1 row2)
    local helperMatrix = matrix3 row1 row2 row3 vertPos

    local genPoint = point size:1.0
    genPoint.transform = helperMatrix
    append genMeshArray genPoint

    local face = get_first_item (meshop.getFacesUsingVert selMesh i)
    local faceVerts = convert_p3_to_array (getFace selMesh face)
    local attachConst = Attachment node:selObj
    attachConst.align = false

    genPoint.position.controller = attachConst
    local key = AttachCtrl.addNewKey attachConst 0
    key.face = face - 1
    key.coord = #([1,0], [0,1], [0,0])[findItem faceVerts i]
)

jal.sel.set_selectionSet_to_point()
)
