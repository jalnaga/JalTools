macroscript jalSWT_selVertByBoneMcr category:"jalSkinWeightTool" tooltip:"Select Vertices by Bone" (
    on isVisible return ((classof(modPanel.GetcurrentObject())) == Skin)
    on isEnabled return ((classof(modPanel.GetcurrentObject())) == Skin)
    on execute do (
        if __jalSkinWeightToolRollout != undefined then (
            skinOps.selectVerticesByBone __jalSkinWeightToolRollout.workingSkinMod
            __jalSkinWeightToolRollout.update_ui()
        )
    )
)

macroscript jalSWT_shrinkMcr category:"jalSkinWeightTool" tooltip:"Selection Shrink" (
    on isVisible return ((classof(modPanel.GetcurrentObject())) == Skin)
    on isEnabled return ((classof(modPanel.GetcurrentObject())) == Skin)
    on execute do (
        if __jalSkinWeightToolRollout != undefined then (
            skinOps.shrinkSelection __jalSkinWeightToolRollout.workingSkinMod
            __jalSkinWeightToolRollout.update_ui()
        )
    )
)

macroscript jalSWT_growMcr category:"jalSkinWeightTool" tooltip:"Selection Grow" (
    on isVisible return ((classof(modPanel.GetcurrentObject())) == Skin)
    on isEnabled return ((classof(modPanel.GetcurrentObject())) == Skin)
    on execute do (
        if __jalSkinWeightToolRollout != undefined then (
            skinOps.growSelection __jalSkinWeightToolRollout.workingSkinMod
            __jalSkinWeightToolRollout.update_ui()
        )
    )
)

macroscript jalSWT_ringSelMcr category:"jalSkinWeightTool" tooltip:"Ring Select" (
    on isVisible return ((classof(modPanel.GetcurrentObject())) == Skin)
    on isEnabled return ((classof(modPanel.GetcurrentObject())) == Skin)
    on execute do (
        if __jalSkinWeightToolRollout != undefined then (
            skinOps.ringSelection __jalSkinWeightToolRollout.workingSkinMod
            __jalSkinWeightToolRollout.update_ui()
        )
    )
)

macroscript jalSWT_loopSelMcr category:"jalSkinWeightTool" tooltip:"Loop Select" (
    on isVisible return ((classof(modPanel.GetcurrentObject())) == Skin)
    on isEnabled return ((classof(modPanel.GetcurrentObject())) == Skin)
    on execute do (
        if __jalSkinWeightToolRollout != undefined then (
            skinOps.loopSelection __jalSkinWeightToolRollout.workingSkinMod
            __jalSkinWeightToolRollout.update_ui()
        )
    )
)

macroscript jalSWT_copyWeightMcr category:"jalSkinWeightTool" tooltip:"Copy Weight" (
    on isVisible return ( (classof(modPanel.GetcurrentObject())) == Skin)
    on isEnabled return ((classof(modPanel.GetcurrentObject())) == Skin)
    on execute do (
        if __jalSkinWeightToolRollout != undefined then (
            skinOps.CopyWeights __jalSkinWeightToolRollout.workingSkinMod
            __jalSkinWeightToolRollout.update_ui()
        )
    )
)

macroscript jalSWT_pasteWeightMcr category:"jalSkinWeightTool" tooltip:"Paste Weight" (
    on isVisible return ((classof(modPanel.GetcurrentObject())) == Skin)
    on isEnabled return ((classof(modPanel.GetcurrentObject())) == Skin)
    on execute do (
        if __jalSkinWeightToolRollout != undefined then (
            skinOps.PasteWeights __jalSkinWeightToolRollout.workingSkinMod
            __jalSkinWeightToolRollout.update_ui()
        )
    )
)
