<#
Write-Output "
WST_BATCH = Q
WST_BASE_NUM = 001
WST_COUTER = 42
" > WST_Counter.txt
#>
WST_BASE_NUM = 001

$Source_WST_Cnt = (Get-ChildItem WST_Counter.txt | Select-String "WST_BASE_NUM").Line.Split('=') | Select-Object -last 1
$INT_New_WST_Num_Cnt = [INT]$Source_WST_Cnt

$Source_WST = (Get-ChildItem WST_Counter.txt | Select-String "WST_COUTER").Line.Split('=') | Select-Object -last 1
$INT_New_WST_Num = [INT]$Source_WST
$New_WST_Num = $INT_New_WST_Num_Cnt + 1

Get-Variable INT_New_WST_Num_Cnt

Get-Variable New_WST_Num

#export to temp file
#>

(Get-Content WST_Counter.txt) -Replace $INT_New_WST_Num_Cnt, $New_WST_Num | Set-Content -Force WST_Counter.txt
<#
((Get-Content $OutFile) -join "`n") + "`n" | Set-Content -NoNewline $OutFile
Get-Content $OutFile | Set-Clipboard
#>
#C:\"Program Files (x86)"\Notepad++\notepad++.exe $OutFile