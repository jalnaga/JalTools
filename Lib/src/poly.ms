struct _Poly (
    fn attach_to_last_sel = (
        if selection.count > 1 then (
            local selPolyArray = for item in selection where ((classOf item) == Editable_Poly) collect item
            for i = 1 to selPolyArray.count - 1 do (
                polyop.attach selPolyArray[selPolyArray.count] selPolyArray[i]
            )
        )
    ),

    fn detach_to_face inObj = (
        local returnVal = false
        local targetObj = inObj
        if classOf inObj == Editable_Poly then (
            local polyNum = polyop.getNumFaces targetObj
            for i = 1 to polyNum do (
                polyop.detachFaces targetObj #{i} asNode:false
            )
            returnVal = true
        )

        returnVal
    )
)
