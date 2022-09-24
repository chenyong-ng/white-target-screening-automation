# Convert CRLFs to LFs only.
# https://stackoverflow.com/questions/19127741/replace-crlf-using-powershell/19128003#19128003
# Note:
#  * (...) around Get-Content ensures that $file is read *in full*
#    up front, so that it is possible to write back the transformed content
#    to the same file.
#  * + "`n" ensures that the file has a *trailing LF*, which Unix platforms
#     expect.
((Get-Content $file) -join "`n") + "`n" | Set-Content -NoNewline $file