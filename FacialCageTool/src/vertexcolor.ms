struct _VertexColor
(
    obj,
    originalVC = #(),
    vertArray = #(),
    HSVCArray = #(),

    fn store_vertcolor inputObj =
    (
        tempArray=#()
        for i in 1 to getNumCPVVerts inputObj do
        (
            append tempArray (getVertColor inputObj i)
        )
        return tempArray
    ),


    fn flatten_vertcolor inputObj =
    (
        if superclassof inputObj == GeometryClass and canConvertto inputObj Mesh and getNumCPVVerts inputObj.mesh > 0 then
        (
            try
            (
                local obj_mesh = inputObj.mesh
                local new_colors_array = #()
                local new_face_index =#()

                for i = 1 to obj_mesh.numverts do
                (
                    local average_color_r = 0
                    local average_color_g = 0
                    local average_color_b = 0
                    local average_counter = 0
                    local array_of_faces = meshop.getFacesUsingVert obj_mesh i
                    for j = 1 to array_of_faces.count do
                    (
                        if array_of_faces[j] == true then
                        (
                            get_face = getface obj_mesh j
                            if get_face.x == i then v_index = 1
                            if get_face.y == i then v_index = 2
                            if get_face.z == i then v_index = 3
                            get_color_face = getVCFace obj_mesh j
                            case v_index of
                            (
                                1: cv_index = get_color_face.x
                                2: cv_index = get_color_face.y
                                3: cv_index = get_color_face.z
                            )
                            get_color_vert = getVertColor obj_mesh cv_index
                            new_face_index[cv_index] = (new_colors_array.count+1)
                            average_color_r += get_color_vert.r
                            average_color_g += get_color_vert.g
                            average_color_b += get_color_vert.b
                            average_counter += 1
                        )--end if
                    )--end j
                    average_color_r /= average_counter
                    average_color_g /= average_counter
                    average_color_b /= average_counter
                    average_color = color average_color_r average_color_g average_color_b
                    append new_colors_array average_color
                )--end i

                new_obj = copy inputObj
                new_obj.name = uniquename ("FlatCPV_"+inputObj.name)
                converttomesh new_obj
                setNumCPVVerts new_obj new_colors_array.count false
                buildVCFaces new_obj false
                for i = 1 to new_colors_array.count do
                (
                    setVertColor new_obj i new_colors_array[i]\
                )

                for i = 1 to inputObj.mesh.numfaces do
                (
                    old_vc_face = getVCFace inputObj.mesh i
                    new_vc_face = [new_face_index[old_vc_face.x], new_face_index[old_vc_face.y], new_face_index[old_vc_face.z]]
                    setVCFace new_obj i new_vc_face
                )
                update new_obj
                new_obj.showVertexColors = true
            )
            catch(format "FlattenVertexColors: Some error occured. \nPlease make sure you have Avguard Extensions installed\nor contact the author if you need assistance.\n")
            new_obj.name = inputObj.name
            delete inputObj
            select new_obj

            return new_obj
        )
        else format "FlattenVertexColors: Invalid Object!\n"
    ),


    fn kill_Dups thisArray =
    (
        local newArray = #()
        for s = 1 to thisArray.count do
        (
            local ch = true
            for z = 1 to newArray.count do
            (
                if (thisArray[s] == newArray[z]) then ch = false
            )
            if (ch == true) then newArray[newArray.count+1] = thisArray[s]
        )
        return newArray
    ),


    fn get_vert_list myArray idx =
    (
        tempArray = filterstring myArray[idx] ","
        newArray = #()
        for i = 1 to tempArray.count do
        (
            append newArray (tempArray[i] as integer)
        )
        tempArray = kill_Dups newArray
        return tempArray
    ),


    fn fill_vert_array inputObj=
    (
        local myArray = #()
        for i = 1 to (getNumFaces inputObj) do
        (
            thisFace = getface inputObj i

            -- initialize elements so they're not undefined
            if myArray[thisFace.x] == undefined then myArray[thisFace.x] = ""
            if myArray[thisFace.y] == undefined then myArray[thisFace.y] = ""
            if myArray[thisFace.z] == undefined then myArray[thisFace.z] = ""

            -- for each X, add Y and Z to its adj. list, do similar for Y and Z.  Ugly.
            myArray[thisFace.x] += ((thisFace.y as integer) as string) + ","
            myArray[thisFace.x] += ((thisFace.z as integer) as string) + ","
            myArray[thisFace.y] += ((thisFace.x as integer) as string) + ","
            myArray[thisFace.y] += ((thisFace.z as integer) as string) + ","
            myArray[thisFace.z] += ((thisFace.y as integer) as string) + ","
            myArray[thisFace.z] += ((thisFace.x as integer) as string) + ","
        )
        return myArray
    ),

    fn average_adjacent inputObj vertNum =
    (
        adjacentArray = get_vert_list vertArray vertNum
        avgColor = [0,0,0]
        for i = 1 to adjacentArray.count do
        (
            avgColor += getVertColor inputObj adjacentArray[i]
        )
        return (avgColor/adjacentArray.count)
    ),


    fn blur_vertcolor blurAmount:1.0 useSelVerts:false =
    (
        blurAmt = blurAmount

        vertArray = fill_vert_array obj
        HSVCArray = #()

        if useSelVerts == true then
        (
            HSVCArray = #()
            for i = 1 to obj.selectedVerts.count do
            (
                a = obj.selectedVerts[i].index
                append HSVCArray a
            )
        )
        else
        (
            HSVCArray = #()
            for i = 1 to getNumVerts(obj) do append HSVCArray i
        )

        local newVertColors = #()
        for i in 1 to HSVCArray.count do
        (
            vertListArray = get_vert_list vertArray HSVCArray[i]
            newcolor = (getVertColor obj (HSVCArray[i])) + (((average_adjacent obj (HSVCArray[i])) - (getVertColor obj (HSVCArray[i]))) * blurAmt)

            newVertColors[i] = newcolor
        )

        for i = 1 to HSVCArray.count do setVertColor obj HSVCArray[i] newVertColors[i]

        update obj
        return obj
    ),

    fn init inputObj =
    (
        obj = undefined
        originalVC = #()
        vertArray = #()
        HSVCArray = #()
        --Runs Flatten Vertex Function
        select inputObj
        convertToMesh inputObj

        obj = inputObj
        if (getNumVerts inputObj) != (getNumCPVVerts inputObj) then
        (
            obj = flatten_vertcolor inputObj
        )
        --Capturing original vertex colors
        originalVC = store_vertcolor obj
    )
)
