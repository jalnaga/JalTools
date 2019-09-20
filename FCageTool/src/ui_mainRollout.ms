try(destroydialog jal.tools.facialCageTool) catch()
rollout mainRollout "Facial Cage Tool" width:300 height:400 (
    SubRollout mainSub "" align:#center height:385

    local minWidth = 300
    local minHeight = 400
    local subRollWidthOffset = 25
    local subRollHeightOffset = 15

    local facialCageMeshFullName = ""
    local facialRigFullName = ""
    local fCageMeshName = "FCage_000"
    local univFaceMeshName = "UnivHead_000"

    local vertMatchXml = ""

    include "facs.ms"
    local facs = _Facs()

    include "ui_vertMatchRollout.ms"
    include "ui_cageGenRollout.ms"
    include "ui_genFacsRollout.ms"
    include "ui_modFacsRollout.ms"

    on mainRollout open do
    (
        local tool_path = getINISetting ((GetDir #userMacros) + "\\jalScriptLauncher\\ini\\scriptPath.ini") "ExternalScript" "ScriptPath"
        tool_path = tool_path + "\\JalTools\\FCageTool"
        facialCageMeshFullName = tool_path + "\\maxScene\\FCage.max"
        facialRigFullName = tool_path + "\\maxScene\\FCageRig.max"
        vertMatchXml = tool_path + "\\data\\fCageInfo.xml"

        AddSubRollout mainSub vertMatchRollout
        AddSubRollout mainSub cageGenRollout
        AddSubRollout mainSub genFacsRollout
        AddSubRollout mainSub modFacsRollout
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

        jal.roll.update_subroll_when_resized mainSub vertMatchRollout
        jal.roll.update_subroll_when_resized mainSub cageGenRollout
        jal.roll.update_subroll_when_resized mainSub genFacsRollout
        jal.roll.update_subroll_when_resized mainSub modFacsRollout
    )
)
jal.tools.facialCageTool = mainRollout
createDialog jal.tools.facialCageTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
