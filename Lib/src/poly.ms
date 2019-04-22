struct _Poly (
    fn attach_to_last_sel = (
        if selection.count > 1 then (
            local selPolyArray = for item in selection where ((classOf item) == Editable_Poly) collect item
            for i = 1 to selPolyArray.count - 1 do (
                polyop.attach selPolyArray[selPolyArray.count] selPolyArray[i]
            )
        )
    )
)
