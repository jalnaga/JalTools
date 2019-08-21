(
    local hMesh = $Univ_Head_Zavodszky
    local lMesh = $Avg_Zavodszky_00_Cage
    local inName = ((GetDir #export)+"/vertMatch.dat")
    local inFile = openFile inName
    local vertMatchArray = #()
    for i = 1 to 189 do (
        local pairArray = readValue inFile
        append vertMatchArray pairArray
    )
    close inFile
    for item in vertMatchArray do (
        local targetPos = polyop.getVert hMesh item[2]
        polyop.setVert lMesh item[1] targetPos
    )
)
