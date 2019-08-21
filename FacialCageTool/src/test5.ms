(
    struct _XMLNode (
        tag,
        parent,
        dotnetNode,

        fn init inDnNode = (
            dotnetNode = inDnNode
            tag = inDnNode.LocalName
            parent = inDnNode.ParentNode
        ),

        fn get_tag = (
            return dotnetNode.Name
        ),

        fn set_tag inNewTag = (
            try (dotnetNode.Name = inNewTag)
            catch(false)
        ),

        fn get_text = (
            return dotnetNode.InnerText
        ),

        fn set_text inText = (
            dotnetNode.InnerText = inText
        ),

        fn add_attribute inAtt inVal = (
            dotnetNode.SetAttribute inAtt inVal
        ),

        fn get_attribute inAtt = (
            dotnetNode.GetAttribute inAtt
        ),

        fn set_attribute inAtt inNewVal = (
            dotnetNode.SetAttribute inAtt inNewVal
        ),

        fn remove_attribute inAtt = (
            dotnetNode.RemoveAttribute inAtt
        ),

        fn get_all_attribute = (
            local returnVal = #()
            local atts = dotnetNode.Attributes
            for i = 0 to (atts.Count - 1) do (
                local temp = #()
                local item = (atts.ItemOf i)
                append temp item.Name
                append temp item.Value
                append returnVal temp
            )
            return returnVal
        ),

        fn has_attribute inAtt = (
            dotnetNode.HasAttribute inAtt
        ),

        fn append_child_node inNewNode = (
            if classof inNewNode == _XMLNode then (
                dotnetNode.AppendChild inNewNode.dotnetNode
                return true
            )
            else return false
        ),

        fn get_child inIndex = (
            local dNode = dotnetNode.ChildNodes.ItemOf inIndex
            if dNode.Name != "#text" then (
                local newNode = _XMLNode()
                newNode.init dNode
                return newNode
            )
            else return undefined
        ),

        fn get_children = (
            local returnNodes = #()
            for i = 0 to (dotnetNode.ChildNodes.Count - 1) do (
                local dNode = dotnetNode.ChildNodes.ItemOf i
                local newNode = _XMLNode()
                newNode.init dNode
                append returnNodes newNode
            )
            return returnNodes
        ),

        fn remove_child inChildNode = (
            if classof inChildNode == _XMLNode then (
                dotnetNode.RemoveChild inChildNode.dotnetNode
                return true
            )
            else return false
        )
    )
    struct _XMLDoc (
        file = undefined,
        rootNode = undefined,
        dom = dotNetObject "System.Xml.XmlDocument",
        loaded = false,

        fn load_file inFullFileName = (
            file = inFullFileName
            doc = dom.Load file
            loaded = true

            return true
        ),

        fn save_file fileName:"" = (
            if loaded then (
                local saveFileFullName = ""
                if fileName == "" then saveFileFullName = file
                else saveFileFullName = fileName
                dom.Save saveFileFullName
                return true
            )
            else return false
        ),

        fn get_root_node = (
            rootNode = _XMLNode()
            rootNode.init dom.DocumentElement
            return rootNode
        ),

        fn create_node inTag = (
            local dNode = dom.CreateElement inTag
            local newNode = _XMLNode()
            newNode.init dNode
            return newNode
        ),

        fn append_node inNewNode = (
            if classof inNewNode == _XMLNode then (
                dom.AppendChild inNewNode.dotnetNode
                return true
            )
            else return false
        ),

        fn save_pretty fileName:"" = (
            if loaded then (
                local saveFileFullName = ""
                if fileName == "" then saveFileFullName = file
                else saveFileFullName = fileName

                local writer = dotNetClass "System.Xml.XmlTextWriter"
                local wSettings = dotNetObject "System.Xml.XmlWriterSettings"
                wSettings.indent = true

                local w = writer.create saveFileFullName wSettings
                dom.writeContentTo w
                w.close()
                return true
            )
            else return false
        ),

        fn create_root_node = (
            local rNode = create_node "RootNode"
            append_node rNode
            rNode = get_root_node()
            return rNode
        ),

        fn create_file inFullFileName = (
            local returnNode = undefined
            file = inFullFileName
            loaded = true

            returnNode = create_root_node()
            return returnNode
        )
    )

    local xDoc = _XMLDoc()
    local outName = ((GetDir #export)+"/fCageInfo.xml")

    local distThresh = 0.02905
    local hMesh = $Head
    local lMesh = $Avg_MaleFace_00_Cage
    local boneArray = getCurrentSelection() as Array

    local lMeshVertCount = polyop.getNumVerts lMesh
    local hMeshVertCount = polyop.getNumVerts hMesh

    local matchVertsArray = #()
    local matchBonesArray = #()

    for i = 1 to lMeshVertCount do (
        local lMeshVertPos = polyop.getVert lMesh i
        for k = 1 to hMeshVertCount do (
            local pairVertArray = #()

            local hMeshVertPos = polyop.getVert hMesh k
            local vertDist = distance lMeshVertPos hMeshVertPos
            if vertDist <= distThresh then (
                append pairVertArray i
                append pairVertArray k
                append matchVertsArray pairVertArray
                exit
            )
        )
        for j = 1 to boneArray.count do (
            local pairBoneArray = #()

            local bonePos = boneArray[j].position
            local boneDist = distance lMeshVertPos bonePos
            if boneDist <= distThresh then (
                append pairBoneArray i
                append pairBoneArray boneArray[j].name
                append matchBonesArray pairBoneArray
                exit
            )
        )
    )

    xDoc.create_file outName
    local rNode = xDoc.get_root_node()
    local cageNode = xDoc.create_node "CageMesh"

    cageNode.add_attribute "totalVertNum" "189"
    for i = 1 to matchVertsArray.count do (
        local vertInfoNode = xDoc.create_node "VertInfo"
        vertInfoNode.add_attribute "index" (matchVertsArray[i][1] as String)
        vertInfoNode.add_attribute "highMeshVertIndex" (matchVertsArray[i][2] as String)
        vertInfoNode.add_attribute "boneName" matchBonesArray[i][2]

        cageNode.append_child_node vertInfoNode
    )
    rNode.append_child_node cageNode
    xDoc.save_pretty()
)
