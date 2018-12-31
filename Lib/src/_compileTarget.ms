__TemplateScriptPath = getFilenamePath (getThisScriptFilename())
sysInfo.currentdir = __TemplateScriptPath
(
include "jalLibHeader.ms"

global testJal = _JalLib()
--testJal.name.get_front_back "mast_b_r_b_main_flag_004_l_f"
--testJal.name.get_string "RMain4Arm001F"
--testJal.name.get_nonRealName "Bip001 Cage Dum LB ForeArm 001 R B"
--"Bip R ForeArm L F 001 R" "ForeArm L F 001 R" "Bip" "R" "" ""
--"R ForeArm L F 001 R" "ForeArm L F 001 R" "R" "" ""
--"Bip L R ForeArm R B 001" "ForeArm R B" "Bip" "R" "L"
testJal.name.set_name_parts_order #("Base", "Type", "Index", "Side", "FrontBack", "RealName")
local testArray = testJal.name.split_into_refined_nameArray "Bip001 L B UpperForeArm2"
format "%\n" testArray
testJal.name.get_side "Bip001 L B UpperForeArm2"
)
