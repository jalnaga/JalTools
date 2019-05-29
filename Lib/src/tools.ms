struct _Tools (
    handyTool = undefined,
    namingTool = undefined,
    batchNamingTool = undefined,
    boneTool = undefined,
    skinTool = undefined,
    skinWeightTool = undefined,
    joystickTool = undefined,
    facialTool = undefined,
    hairTool = undefined,
    faceCustomTool = undefined,
    facialCageTool = undefined,

    fn delete_unwantedScripts = (
        local userStartScriptsDir = getDir #userStartupScripts
        local rootStartScriptsDir = getDir #startupScripts
        local unwantedScriptsArray = #("vrdematcleanbeta.mse", "vrdematcleanbeta.msex")
        local startScriptsArray = #(userStartScriptsDir, rootStartScriptsDir)

        local System_IO_Directory = dotNetClass "System.IO.Directory"

        for dir in startScriptsArray do (
            local dellScriptsArray = System_IO_Directory.getFiles dir
            for scriptFullPath in dellScriptsArray do (
                local scriptFileName = filenameFromPath scriptFullPath
                if (findItem unwantedScriptsArray scriptFileName) > 0 then (
                    setFileAttribute scriptFullPath #readOnly false
                    setFileAttribute scriptFullPath #hidden false
                    setFileAttribute scriptFullPath #system false
                    deleteFile scriptFullPath
                )
            )
        )
    ),

    fn delete_persistanceGlobal = (
        local pGlbVars = persistents.gather()
        for item in pGlbVars do (
            if item != #CAT_UINum then persistents.remove item
        )

        z=1
        while z !=undefined do (
            x = rootscene
            z = custattributes.getdef x 1
            custAttributes.delete x z
        )

        z=2
        while z !=undefined do (
            x = meditmaterials
            z = custattributes.getdef x 1
            custAttributes.delete x z
        )

        z=3
        while z !=undefined do (
            x = rootscene.Anim_Layer_Control_Manager
            z = custattributes.getdef x 1
            custAttributes.delete x z
        )
    )
)
