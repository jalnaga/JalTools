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

    local xmlFile = ""

    --local facialCageMaxVertNum = 500
    --include "facialCage.ms"
    --local fCage = _FacialCage()

    --include "ui_facialBoneRollout.ms"
    include "ui_facialCageInfoGenRollout.ms"
    include "ui_facialCageGeneratorRollout.ms"

    on mainRollout open do
    (
        local tool_path = getINISetting ((GetDir #userMacros) + "\\jalScriptLauncher\\ini\\scriptPath.ini") "ExternalScript" "ScriptPath"
        tool_path = tool_path + "\\JalTools\\FacialCageTool"
        facialCageMeshFullName = tool_path + "\\maxScene\\FCage.max"
        facialRigFullName = tool_path + "\\maxScene\\FCageRig.max"
        xmlFile = tool_path + "\\data\\fCageInfo.xml"

        AddSubRollout mainSub facialCageInfoGenRollout
        AddSubRollout mainSub facialCageGeneratorRollout

        facialCageInfoGenRollout.open = false
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

        jal.roll.update_subroll_when_resized mainSub facialCageInfoGenRollout
        jal.roll.update_subroll_when_resized mainSub facialCageGeneratorRollout
    )
)
jal.tools.facialCageTool = mainRollout
createDialog jal.tools.facialCageTool style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_maximizebox)
