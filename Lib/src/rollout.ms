struct _Rollout (
    fn sync_value_between_slider_and_spinner inSlider inSpinner inValue:undefined = (
        local value = undefined
        if inValue == undefined then value = inSlider.value
        else value = inValue
        inSlider.value = value
        inSpinner.value = value
    ),

    fn save_control_properties_in_rollout inRollout =
    (
        local returnArray = #()

        for control in inRollout.controls do
        (
            local controlStatus = #()
            append controlStatus control.caption
            append controlStatus control.enabled

            case (classOf control) of
            (
                SpinnerControl: append controlStatus control.value
                CheckButtonControl: append controlStatus control.checked
                EditTextControl: append controlStatus control.text
                ListBoxControl: append controlStatus control.items
                CheckBoxControl: append controlStatus control.checked
                default: append controlStatus 0
            )

            append returnArray controlStatus
        )

        return returnArray
    ),

    fn update_control_properties_in_rollout inRollout inPropertyArray =
    (
        local controlIndex = 1
        for control in inRollout.controls do
        (
            control.caption = inPropertyArray[controlIndex][1]
            control.enabled = inPropertyArray[controlIndex][2]

            case (classOf control) of
            (
                SpinnerControl: control.value = inPropertyArray[controlIndex][3]
                CheckButtonControl: control.checked = inPropertyArray[controlIndex][3]
                EditTextControl: control.text = inPropertyArray[controlIndex][3]
                ListBoxControl: control.items = inPropertyArray[controlIndex][3]
                CheckBoxControl: control.checked = inPropertyArray[controlIndex][3]
            )

            controlIndex += 1
        )
    ),

    fn update_subroll_when_resized inSubRoll inUpdatedRollout =
    (
        local controlsText = save_control_properties_in_rollout inUpdatedRollout
        RemoveSubRollout inSubRoll inUpdatedRollout
        AddSubRollout inSubRoll inUpdatedRollout
        update_control_properties_in_rollout inUpdatedRollout controlsText
    )
)
