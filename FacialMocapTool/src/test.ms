(
    /*local dum = $grp_Dum
    local bipHead = $'Bip001 Head'
    with animate on (
        for i = 0 to 1278 do (
            at time i (
                bipHead.transform = dum.transform
            )
        )
    )*/

    fn remap_range inVal inPrevMin inPrevMax inNewMin inNewMax = (
        local returnVal = inNewMin + (inVal - inPrevMin) * (inNewMax - inNewMin) / (inPrevMax - inPrevMin)

        return returnVal
    )

    remap_range 20.0 0.0 100.0 -60.0 100.0
)
