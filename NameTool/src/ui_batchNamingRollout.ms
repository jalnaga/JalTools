rollout batchNamingRollout "Batch Naming" (
    button windowLaunchBtn "Batch Rename" widht:200 height:40 across:2
    button nameReplacerBtn "Replace Name" widht:200 height:40

    local batchWindow = undefined
    local replaceWindow = undefined

    include "ui_batchNamingListRollout.ms"
    include "ui_replaceNameRollout.ms"

    on batchNamingRollout open do (
        batchWindow = batchNamingListRollout
        replaceWindow = replaceNameRollout
    )

    on windowLaunchBtn pressed do (
        createDialog batchWindow modal:true
    )

    on nameReplacerBtn pressed do (
        createDialog replaceNameRollout modal:true
    )
)
