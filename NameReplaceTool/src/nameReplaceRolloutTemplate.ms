struct _CtrAndEvent (
    control = "",
    event = "",
    editTextTemplate = "editText strTxt% \" \" labelOnTop:true align:#left across:2\n",
    checkboxTemplate = "checkbox removeCkb% \"Remove\" offset:[0, 20] align:#right\n",
    sideRdoTemplate = "radiobuttons sideCahrRdo% \" \" labels:sideCharArray columns:sideCharArray.count default:1 align:#left across:2\n"
)
fn gen_edit_control_template inArray = (
    local returnVal = ""
    if inArray.count > 0 then (
        for i = 1 to inArray.count do (
            returnVal += "editText strTxt" + (i as String )+ "\" \" labelOnTop:true width:80 align:#center\n"
            returnVal += "checkbox removeCkb" + (i as String )+ "\"Remove\" offset:[0, 20] align:#center\n"
        )
    )
    return returnVal
)

fn gen_edit_event_template inNum = (
    local returnVal = ""
    if inNum > 0 then (
    )
    return returnVal
)

local templateStr = ""
templateStr += "rollout replaceNameRollout \"Replace Name\" (\n"
templateStr += "radiobuttons filteringCharRdo \"Filtering:\" labels:#(\"None\", \"(Blank)\", \"_\") columns:3 default:2 align:#left\n"
templateStr += ")\n"
