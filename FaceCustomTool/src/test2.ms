(
    local selObjs = for item in selection collect item
    for item in selObjs do (
        local realName = jal.name.get_type item.name
        local type = jal.name.get_realName item.name
        item.name = jal.name.replace_realName item.name realName
        item.name = jal.name.replace_type item.name type
        item.name = jal.name.replace_base item.name "Cage"
    )
)
