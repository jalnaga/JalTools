try(destroydialog _FacialMocapTool) catch()
rollout mainRollout "Facial Mocap Tool" width:300 height:400 (
    SubRollout mainSub "" align:#center height:385

    local minWidth = 300
    local minHeight = 400
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    include "xml.ms"
    include "facialMocapConverter.ms"

    local fmc = _FacialMocapConverter()
    local xDoc = _XMLDoc()

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
    )

    include "ui_mocapFileExportRollout.ms"
    include "ui_mocapFileImportRollout.ms"

    on mainRollout open do
    (
        AddSubRollout mainSub mocapFileExportRollout
        AddSubRollout mainSub mocapFileImportRollout
    )
    on mainRollout resized newSize do
    (
        if newSize[1] > minWidth then
        mainSub.width = newSize[1] - subRollWidthOffset
        else (
            mainRollout.width = minWidth
            mainSub.width = minWidth - subRollWidthOffset
        )
        if newSize[2] > minHeight then mainSub.height = newSize[2] - subRollHeightOffset
        else (
            mainRollout.height = minHeight
            mainSub.height = minHeight - subRollHeightOffset
        )

        jal.roll.update_subroll_when_resized mainSub mocapFileExportRollout
        jal.roll.update_subroll_when_resized mainSub mocapFileImportRollout
    )
)
_FacialMocapTool = mainRollout
createDialog _FacialMocapTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
