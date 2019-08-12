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

    on create do (
        --DotNet.LoadAssembly "System.Xml"
    ),

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
