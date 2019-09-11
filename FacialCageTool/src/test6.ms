(
    local facsArray = for item in selection collect item
    for item in facsArray do (
        addModifier item (Morpher())
        item.modifiers[1].Autoload_of_targets = 1
        jal.mor.init item
        jal.mor.add_target $Avg_Neutral_Cage 1
        jal.mor.set_channel_value_by_index 1 100.0
    )
)
