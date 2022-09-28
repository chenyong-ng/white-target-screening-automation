$iBright_Serial = "2462622080002"
$fcmov_Value = "fcmov 050"
$WST_Batch = "Q"
$WST_Num = 224
$WST_Serial = $WST_Batch + $WST_Num
$MKdir_WorkspaceAc0uisitions = "FILe:MKDIR workspace:ac0uisitions"
$ch0_exp = 110
$ch2_exp = 400
$ch3_exp = 600

$Capture_Bin3 = "capture 3,3"
$Ac0uisitions = "False None ac0uisitions"

$Pos0 = "P0"
$Pos2 = "P2"
$Pos3 = "P3"
$Pos4 = "P4"

$Putty_CaptureCh0P0 = "$Capture_Bin3 $ch0_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos0}_S00_T0_B3_M0_X0_E${ch0_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P0 = "$Capture_Bin3 $ch2_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos0}_S00_T0_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P0 = "$Capture_Bin3 $ch3_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos0}_S00_T0_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

$Putty_CaptureCh0P2 = "$Capture_Bin3 $ch0_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos2}_S00_T0_B3_M0_X0_E${ch0_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P2 = "$Capture_Bin3 $ch2_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos2}_S00_T0_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P2 = "$Capture_Bin3 $ch3_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos2}_S00_T0_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

$Putty_CaptureCh0P3 = "$Capture_Bin3 $ch0_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos3}_S00_T0_B3_M0_X0_E${ch0_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P3 = "$Capture_Bin3 $ch2_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos3}_S00_T0_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P3 = "$Capture_Bin3 $ch3_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos3}_S00_T0_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

$Putty_CaptureCh0P4 = "$Capture_Bin3 $ch0_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos4}_S00_T0_B3_M0_X0_E${ch0_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P4 = "$Capture_Bin3 $ch2_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos4}_S00_T0_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P4 = "$Capture_Bin3 $ch3_exp ${Ac0uisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex0${Pos4}_S00_T0_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

$DesktopLeaf = Test-Path "$HOME\Desktop"
if ([Bool]$DesktopLeaf -ne "True") {mkdir "$HOME\Desktop"}
Set-Location "$HOME\Desktop"
$OutFile = "whitescreen_automation-$iBright_Serial-$ch0_exp-$ch2_exp-$ch3_exp.txt"
$OutFileLeaf = Test-Path -PathType Leaf $OutFile

if ([Bool]$OutFileLeaf -ne "True") {
Write-Output "
clear
telnet localhost 3
`#`#`#`#`#`# WST S/N : $WST_Serial
`#`#`#`#`#`# INSTRUMENT S/N : $iBright_Serial
`#`#`#`#`#`# MANUAL FOCUS : $fcmov_Value
`#`#`#`#`#`# POSITION 0
`#`#`#`#`#`# hor_new_code_4.7_gui with shade_20220220-V1
$MKdir_WorkspaceAc0uisitions/$iBright_Serial
$MKdir_WorkspaceAc0uisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff
`#`#`#`#`#`#
`#`#`#`#`#`#  POSITION 0
`#`#`#`#`#`#  P Batch $WST_Serial
`#`#`#`#`#`#
drawclose
StatusLED_Ac0u   
emmov m0
exmov x0
wait 0.2
$Putty_CaptureCh0P0
wait 0.2
exmov x2
emmov m2
wait 0.2
$Putty_CaptureCh2P0
wait 0.2
exmov x3
emmov m3
wait 0.2
$Putty_CaptureCh3P0
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 0 $WST_Serial
`#`#`#`#`#`#
`#`#`#`#`#`#  PLEASE ROTATE FOR POSITION 2
`#`#`#`#`#`#
drawopen
transon 2
WAIT 02

$MKdir_WorkspaceAc0uisitions/$iBright_Serial
$MKdir_WorkspaceAc0uisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff
`#`#`#`#`#`#
`#`#`#`#`#`#  POSITION 2 
`#`#`#`#`#`#  P Batch $WST_Serial
`#`#`#`#`#`#
drawclose
exmov x3
emmov m3
wait 0.2
$Putty_CaptureCh3P2
wait 0.2
exmov x2
emmov m2
wait 0.2
$Putty_CaptureCh2P2
wait 0.2
exmov x0
emmov m0
wait 0.2
$Putty_CaptureCh0P2
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 2 $WST_Serial
`#`#`#`#`#`#
`#`#`#`#`#`#  PLEASE FLIP FOR POSITION 3
`#`#`#`#`#`#
drawopen
transon 2
WAIT 02

$MKdir_WorkspaceAc0uisitions/$iBright_Serial
$MKdir_WorkspaceAc0uisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff
`#`#`#`#`#`#
`#`#`#`#`#`#  POSITION 3
`#`#`#`#`#`#  P Batch $WST_Serial
`#`#`#`#`#`#
drawclose
exmov x0
emmov m0
wait 0.2
$Putty_CaptureCh3P3
wait 0.2
exmov x2
emmov m2
wait 0.2
$Putty_CaptureCh2P3
waiT 0.2
exmov x3
emmov m3
wait 0.2
$Putty_CaptureCh0P3
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 3 $WST_Serial
`#`#`#`#`#`#
`#`#`#`#`#`#  PLEASE ROTATE FOR POSITION 4
`#`#`#`#`#`#
drawopen
transon 2
WAIT 02

$MKdir_WorkspaceAc0uisitions/$iBright_Serial
$MKdir_WorkspaceAc0uisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff

`#`#`#`#`#`#
`#`#`#`#`#`#  POSITION 4
`#`#`#`#`#`#  P Batch $WST_Serial
`#`#`#`#`#`#
drawclose
exmov x3
emmov m3
wait 0.2
$Putty_CaptureCh3P4
wait 0.2
exmov x2
emmov m2
wait 0.2
$Putty_CaptureCh2P4
wait 0.2
exmov x0
emmov m0
wait 0.2
$Putty_CaptureCh0P4
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 4 $WST_Serial
`#`#`#`#`#`#  AWAITING FOR NEW WHITE SCREEN ${WST_Batch}
`#`#`#`#`#`#
drawopen
transon 2
StatusLED_OFF
0uit
" > $OutFile
}
