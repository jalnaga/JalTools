rollout _progressRollout "Now Processing..." width:300 height:120
(
    label totalProgressLabel "Total Progress: " across:2
    label currentStepLabel ""
    progressBar totalProgressbar "" value:0 height:15

    label progressLabel ""
    progressbar theProgressbar "" value:0 color:orange height:30
    button cancelBtn "Cancel"

    local keepGoing = true

    on cancelBtn pressed do keepGoing = false
)

struct _Progress (
    progressWindow = _progressRollout,
    currentStep = 0,
    totalStepNum = 1,
    progressText = "",
    dialog = true,
    keepGoing = true,

    fn start_progress inProgressName totalStep:1 useDialog:true = (
        dialog = useDialog
        progressText = inProgressName
        totalStepNum = totalStep

        disableSceneRedraw()

        if dialog then CreateDialog progressWindow
        else progressStart inProgressName
    ),

    fn end_progress = (
        if dialog then DestroyDialog progressWindow
        else progressEnd()

        currentStep = 0

        enableSceneRedraw()
        redrawViews()
    ),

    fn update_progress inCurrentIndex inTotalIndex inProgressText:"" inCurrentStep:1 = (
        local percentage = ((inCurrentIndex as float) / (inTotalIndex)) * 100
        if inProgressText != "" then progressText = inProgressText

        if dialog then (
            currentStep = inCurrentStep
            progressWindow.currentStepLabel.text = (currentStep as String) + " / " + (totalStepNum as String)
            progressWindow.totalProgressbar.value = ((currentStep as float) / totalStepNum) * 100
            progressWindow.progressLabel.text = progressText + " " + (percentage as String) + "%"
            progressWindow.theProgressbar.value = percentage

            windows.processPostedMessages()

            if progressWindow.keepGoing == false then (
                end_progress()
                exit
            )
        )
        else (
            if currentStep < inCurrentStep then (
                progressStart (progressText + " " + ((currentStep + 1) as String))
                currentStep = inCurrentStep
            )
            progressUpdate percentage
            if (getProgressCancel()) then keepGoing = false
            if keepGoing == false then (
                end_progress()
                exit
            )
        )
    )
)
