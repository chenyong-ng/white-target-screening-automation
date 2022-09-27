#Clear-Variable -Name "Positsion"
$iBright_Serial = "2462622080002"
$fcmov_Value = "fcmov 150"
$WST_Batch = "Q"
$WST_Num = 201
$New_WST_Num = ++$WST_Num
$WST_Serial = ${WST_Batch} + ${WST_Num}
$MKdir_WorkspaceAcquisitions = "FILe:MKDIR workspace:acquisitions"
$ch1_exp = 110
$ch2_exp = 400
$ch3_exp = 600

$Capture_Bin3 = "capture 3,3"
$Acquisitions = "False None acquisitions"

$Pos1 = "P1"
$Pos2 = "P2"
$Pos3 = "P3"
$Pos4 = "P4"

$Putty_CaptureCh1P1 = "$Capture_Bin3 $ch1_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos1}_S01_T1_B3_M1_X1_E${ch1_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P1 = "$Capture_Bin3 $ch2_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos1}_S01_T1_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P1 = "$Capture_Bin3 $ch3_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos1}_S01_T1_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

$Putty_CaptureCh1P2 = "$Capture_Bin3 $ch1_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos2}_S01_T1_B3_M1_X1_E${ch1_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P2 = "$Capture_Bin3 $ch2_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos2}_S01_T1_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P2 = "$Capture_Bin3 $ch3_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos2}_S01_T1_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

$Putty_CaptureCh1P3 = "$Capture_Bin3 $ch1_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos3}_S01_T1_B3_M1_X1_E${ch1_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P3 = "$Capture_Bin3 $ch2_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos3}_S01_T1_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P3 = "$Capture_Bin3 $ch3_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos3}_S01_T1_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

$Putty_CaptureCh1P4 = "$Capture_Bin3 $ch1_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos4}_S01_T1_B3_M1_X1_E${ch1_exp}_A0_G55.tiff False False"
$Putty_CaptureCh2P4 = "$Capture_Bin3 $ch2_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos4}_S01_T1_B3_M2_X2_E${ch2_exp}_A0_G55.tiff False False"
$Putty_CaptureCh3P4 = "$Capture_Bin3 $ch3_exp ${Acquisitions}:$iBright_Serial/$WST_Serial/${iBright_Serial}_${WST_Serial}_imagex1${Pos4}_S01_T1_B3_M3_X3_E${ch3_exp}_A0_G55.tiff False False"

Set-Location "C:\Users\chenyong.ng\OneDrive - Thermo Fisher Scientific\Desktop"

$OutFile = "whitescreen_automation-$iBright_Serial-$ch1_exp-$ch2_exp-$ch3_exp.txt"

Write-Output "
clear
telnet localhost 2323
`#`#`#`#`#`# WST S/N : $WST_Serial
`#`#`#`#`#`# INSTRUMENT S/N : $iBright_Serial
`#`#`#`#`#`# MANUAL FOCUS : $fcmov_Value
`#`#`#`#`#`# POSITION 1
`#`#`#`#`#`# hor_new_code_4.7_gui with shade_20220220-V1
$MKdir_WorkspaceAcquisitions/$iBright_Serial
$MKdir_WorkspaceAcquisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff
`#`#`#`#`#`#
`#`#`#`#`#`#  POSITION 1
`#`#`#`#`#`#  P Batch $WST_Serial
`#`#`#`#`#`#
drawclose
StatusLED_Acqu   
emmov m1
exmov x1
wait 0.2
$Putty_CaptureCh1P1
wait 0.2
exmov x2
emmov m2
wait 0.2
$Putty_CaptureCh2P1
wait 0.2
exmov x3
emmov m3
wait 0.2
$Putty_CaptureCh3P1
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 1 $WST_Serial
`#`#`#`#`#`#
`#`#`#`#`#`#  PLEASE ROTATE FOR POSITION 2
`#`#`#`#`#`#
drawopen
transon 2
WAIT 12

$MKdir_WorkspaceAcquisitions/$iBright_Serial
$MKdir_WorkspaceAcquisitions/$iBright_Serial/$WST_Serial
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
exmov x1
emmov m1
wait 0.2
$Putty_CaptureCh1P2
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 2 $WST_Serial
`#`#`#`#`#`#
`#`#`#`#`#`#  PLEASE FLIP FOR POSITION 3
`#`#`#`#`#`#
drawopen
transon 2
WAIT 12

$MKdir_WorkspaceAcquisitions/$iBright_Serial
$MKdir_WorkspaceAcquisitions/$iBright_Serial/$WST_Serial
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
exmov x1
emmov m1
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
$Putty_CaptureCh1P3
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 3 $WST_Serial
`#`#`#`#`#`#
`#`#`#`#`#`#  PLEASE ROTATE FOR POSITION 4
`#`#`#`#`#`#
drawopen
transon 2
WAIT 12

$MKdir_WorkspaceAcquisitions/$iBright_Serial
$MKdir_WorkspaceAcquisitions/$iBright_Serial/$WST_Serial
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
exmov x1
emmov m1
wait 0.2
$Putty_CaptureCh1P4
wait 0.2
`#`#`#`#`#`#
`#`#`#`#`#`#  END OF POSITION 4 $WST_Serial
`#`#`#`#`#`#  AWAITING FOR NEW WHITE SCREEN ${WST_Batch}${WST_Num}
`#`#`#`#`#`#
drawopen
transon 2
StatusLED_OFF
quit
" > $OutFile

(Get-Content $OutFile) |
ForEach-Object { $_ -Replace '${WST_Num}', '${New_WST_Num}'} |
Set-Content $OutFile

((Get-Content $OutFile) -join "`n") + "`n" | Set-Content -NoNewline $OutFile
Get-Content $OutFile | Set-Clipboard