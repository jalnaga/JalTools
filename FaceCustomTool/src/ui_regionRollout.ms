rollout regionRollout "Region" (
    multiListBox regionLst "Region"
    button addNewRegionBtn "Add" across:3 align:#left
    button renameRegionBtn "Rename" align:#center
    button delRegionBtn "Delete" align:#right

    rollout addRegionRollout "Add Region" (
        editText newRegionTxt "" width:200
        button okBtn "OK" across:2
        button cancelBtn "Cancel"
    )

    rollout renameRegionRollout "Rename Region" (
        editText renameRegionTxt "" width:200
        button okBtn "OK" across:2
        button cancelBtn "Cancel"
    )

    on regionRollout open do (
        fc.set_region #("Face", "Eye", "Brow", "Nose", "Nostrill", "LipUpper", "LipLower", "Chin", "Jaw", "Cheek", "Ear")
    )
)
