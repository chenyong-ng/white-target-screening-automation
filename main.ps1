. $PSScriptRoot\whitescreen_automation_template.ps1


$source = "C:\Users\chenyong.ng\OneDrive - Thermo Fisher Scientific\Desktop\Source\Main\white-target-screening-automation-1\whitescreen_automation_template.ps1"
<#$Source_WST = ((Get-ChildItem $source | Select-String "WST_Num").Line.Split('=').TrimStart() | Select-Object -First 2) | Select-Object -Last 1
$INT_New_WST_Num = [INT]$Source_WST
$New_WST_Num = $INT_New_WST_Num++
$New_WST_Serial = $WST_Batch + $New_WST_Num
#>
Get-Variable WST_Num
$New_WST_Num = $WST_Num + 1
Get-Variable WST_Serial
Get-Variable New_WST_Num
$New_WST_Serial = $WST_Batch + $New_WST_Num

#export to temp file

(Get-Content $source) -Replace $WST_Serial, $New_WST_Serial | Set-Content -Force $source

((Get-Content $OutFile) -join "`n") + "`n" | Set-Content -NoNewline $OutFile
Get-Content $OutFile | Set-Clipboard

#C:\"Program Files (x86)"\Notepad++\notepad++.exe $OutFile