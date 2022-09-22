
###### WST S/N : $WST_Serial
###### INSTRUMENT S/N : $iBright_Serial
###### MANUAL FOCUS : $fcmov_Value
###### POSITION 1
###### hor_new_code_4.7_gui with shade_20220220-V1

FILe:MKDIR workspace:acquisitions/$iBright_Serial
FILe:MKDIR workspace:acquisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff
######
######  POSITION 1
######  P Batch $WST_Serial
######
drawclose
StatusLED_Acqu   
emmov m1
exmov x1
wait 0.2
capture 3,3 110 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P1_S01_T1_B3_M1_X1_E110_A0_G55.tiff False False
wait 0.2
exmov x2
emmov m2
wait 0.2
capture 3,3 400 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P1_S01_T1_B3_M2_X2_E400_A0_G55.tiff False False
wait 0.2
exmov x3
emmov m3
wait 0.2
capture 3,3 600 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P1_S01_T1_B3_M3_X3_E600_A0_G55.tiff False False
wait 0.2
######
######  END OF POSITION 1 $WST_Serial
######
######  PLEASE ROTATE FOR POSITION 2
######
drawopen
transon 2
WAIT 12

FILe:MKDIR workspace:acquisitions/$iBright_Serial
FILe:MKDIR workspace:acquisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff
######
######  POSITION 2 
######  P Batch $WST_Serial
######
drawclose
exmov x3
emmov m3
wait 0.2
capture 3,3 600 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P2_S01_T1_B3_M3_X3_E600_A0_G55.tiff False False
wait 0.2
exmov x2
emmov m2
wait 0.2
capture 3,3 400 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P2_S01_T1_B3_M2_X2_E400_A0_G55.tiff False False
wait 0.2
exmov x1
emmov m1
wait 0.2
capture 3,3 110 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P2_S01_T1_B3_M1_X1_E110_A0_G55.tiff False False
wait 0.2
######
######  END OF POSITION 2 $WST_Serial
######
######  PLEASE FLIP FOR POSITION 3
######
drawopen
transon 2
WAIT 12

FILe:MKDIR workspace:acquisitions/$iBright_Serial
FILe:MKDIR workspace:acquisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff
######
######  POSITION 3
######  P Batch $WST_Serial
######
drawclose
exmov x1
emmov m1
wait 0.2
capture 3,3 110 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P3_S01_T1_B3_M1_X1_E110_A0_G55.tiff False False
wait 0.2
exmov x2
emmov m2
wait 0.2
capture 3,3 400 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P3_S01_T1_B3_M2_X2_E400_A0_G55.tiff False False
waiT 0.2
exmov x3
emmov m3
wait 0.2
capture 3,3 600 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P3_S01_T1_B3_M3_X3_E600_A0_G55.tiff False False
wait 0.2
######
######  END OF POSITION 3 $WST_Serial
######
######  PLEASE ROTATE FOR POSITION 4
######
drawopen
transon 2
WAIT 12

FILe:MKDIR workspace:acquisitions/$iBright_Serial
FILe:MKDIR workspace:acquisitions/$iBright_Serial/$WST_Serial
$fcmov_Value
cam:gain 55
apmov 0
epion 99
transoff

######
######  POSITION 4
######  P Batch $WST_Serial
######
drawclose
exmov x3
emmov m3
wait 0.2
capture 3,3 600 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P4_S01_T1_B3_M3_X3_E600_A0_G55.tiff False False
wait 0.2
exmov x2
emmov m2
wait 0.2
capture 3,3 400 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P4_S01_T1_B3_M2_X2_E400_A0_G55.tiff False False
wait 0.2
exmov x1
emmov m1
wait 0.2
capture 3,3 110 False None acquisitions:$iBright_Serial/$WST_Serial/$iBright_Serial_$WST_Serial_imagex1P4_S01_T1_B3_M1_X1_E110_A0_G55.tiff False False
wait 0.2
######
######  END OF POSITION 4 $WST_Serial
######  AWAITING FOR NEW WHITE SCREEN
######
drawopen
transon 2
StatusLED_OFF
