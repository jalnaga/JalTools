struct _FileIO (
    fn get_merged_obj inMergeFile nameArray:#() = (
        local currentObjNum = objects.count
        local returnVal = #()
        if nameArray.count == 0 then mergeMaxFile inMergeFile #neverReparent #AutoRenameDups
        else mergeMaxFile inMergeFile nameArray #neverReparent #AutoRenameDups
        if objects.count > currentObjNum then (
            local lasObjNum = objects.count
            returnVal = for objIndex = (currentObjNum+1) to lasObjNum collect (objects[objIndex])
        )

        returnVal
    ),

    fn get_fbx_classNum import:true export:false = (
        local exportClass = exporterPlugin.classes
        local importClass = importerPlugin.classes
        local returnVal = 0

        if export then (
            for i = 1 to exportClass.count do (
                if exportClass[i] == FBXEXP then (
                    returnVal = i
                )
            )
        )

        if import then (
            for i = 1 to importClass.count do (
                if importClass[i] == FBXIMP then (
                    returnVal = i
                )
            )
        )

        return returnVal
    ),

    fn get_fbx_importer_class = (
        local retrunVal = importerPlugin.classes
        local index = get_fbx_classNum import:true export:false
        return returnVal[index]
    ),

    fn get_fbx_exporter_class = (
        local retrunVal = exporterPlugin.classes
        local index = get_fbx_classNum import:false export:true
        return returnVal[index]
    )
)
