.\whitescreen_automation_template.ps1

Get-Content $OutFile |
ForEach-Object { $_ -Replace $WST_Num, $New_WST_Num } |
Set-Content -Force $OutFile 

((Get-Content $OutFile) -join "`n") + "`n" | Set-Content -NoNewline $OutFile
Get-Content $OutFile | Set-Clipboard