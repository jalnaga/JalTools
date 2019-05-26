(
    local targetObj = (getCurrentSelection() as Array)[1]
    clearSelection()
    local polyNum = polyop.getNumFaces targetObj
    for i = 1 to polyNum do (
        polyop.detachFaces targetObj #{i} asNode:false
    )
)
