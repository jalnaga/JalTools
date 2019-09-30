
(
    local MS_Poly = undefined
    local MS_VertList = #()
    local axisoffset = 0
    local dist_Threshold = 0.001                  --- Change this to change the mirror threshold
    local MS_Class = 0

    function readObjectVerts obj =
    (
        vertcount = obj.vertices.count
        MS_VertList = #()
        oxlist = #()

        if MS_Class == 1 then gv = polyop.getVert
        if MS_Class == 2 then gv = meshop.getVert

        for v = 1 to vertcount do
        (
            vpos = gv obj v
            append MS_VertList vpos
            append oxlist vpos.x
        )
        a = amin oxlist
        b = amax oxlist
        c = ((b-a) / 2)
        axisoffset = (b-c)
        oxlist = #()
    )

    function mirrorVerts SelVerts =
    (
        enableUpdate = false
        mirrorSel = #()

        minx = miny = minz = 999999
        maxx = maxy = maxz = -999999

        for v=1 to SelVerts.count do
        (
            if MS_VertList[selverts[v]].x < minx then minx = MS_VertList[selverts[v]].x
            if MS_VertList[selverts[v]].y < miny then miny = MS_VertList[selverts[v]].y
            if MS_VertList[selverts[v]].z < minz then minz = MS_VertList[selverts[v]].z

            if MS_VertList[selverts[v]].x > maxx then maxx = MS_VertList[selverts[v]].x
            if MS_VertList[selverts[v]].y > maxy then maxy = MS_VertList[selverts[v]].y
            if MS_VertList[selverts[v]].z > maxz then maxz = MS_VertList[selverts[v]].z
        )

    --  bbx = abs(maxx - minx)
    --  bby = abs(maxy - miny)
    --  bbz = abs(maxz - minz)
        bbx = bby = bbz = 1

        minx = minx - bbx
        miny = miny - bby
        minz = minz - bbz

        maxx = maxx + bbx
        maxy = maxy + bby
        maxz = maxz + bbz

        bbArray = #()
        for v=1 to MS_VertList.count do
        (
            if ( ((MS_VertList[v].x) <= (- minx)) AND ((MS_VertList[v].x) >= (- maxx)) AND ((MS_VertList[v].y) >= (miny)) AND ((MS_VertList[v].y) <= (maxy)) AND ((MS_VertList[v].z) >= (minz)) AND ((MS_VertList[v].z) <= (maxz)) ) do
            (
                append bbArray v
            )
        )

        for b=1 to SelVerts.count do
        (
            originalpos =  copy (MS_VertList[SelVerts[b]])
            originalpos.x = ((originalpos.x) - (axisoffset))

            mirrorpos = originalpos
            ax = (mirrorpos.x)
            ax = (-(ax))
            mirrorpos = [(ax + axisoffset), mirrorpos.y, mirrorpos.z]
            distList = #()
            for v=1 to bbArray.count do
            (
                vPos = MS_VertList[bbArray[v]]
                dist = distance mirrorPos vPos
                append distList dist
                if (dist <= dist_Threshold) then exit
            )

            minDist = amin distList
            minVert = findItem distList minDist
            if minVert != 0 then append mirrorSel bbArray[minVert]
        )
        return mirrorSel
    )

    obj = (getCurrentSelection())[1]
    MS_Poly = modpanel.getCurrentObject()
    class = classof MS_Poly
    if class == Editable_Poly then MS_Class = 1
    if class == Editable_Mesh then MS_Class = 2
    if class == Edit_Mesh     then MS_Class = 2

    if (MS_Class != 0) do
    (
        subobjectlevel = 1
        readObjectVerts obj
        if (MS_Class == 1) then vertSel = polyop.getVertSelection MS_Poly
        if (MS_Class == 2) then
        (
            if class == Editable_Mesh then vertSel = getVertSelection obj
            else vertSel = getVertSelection obj MS_Poly
        )
        mirVerts = mirrorVerts (vertSel as array)
        if (MS_Class == 1) then vertSel = polyOp.setVertSelection MS_Poly mirVerts
        if (MS_Class == 2) then
        (
            if class == Editable_Mesh then vertSel = setVertSelection obj mirVerts
            else vertSel = setVertSelection obj MS_Poly mirVerts
        )
        forceCompleteRedraw()
    )
    gc()
)
