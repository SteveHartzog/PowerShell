############################################
# ls
if (Test-Path Alias:ls) {
  Remove-Item Alias:ls
}
New-Alias -name ls -value GetUnixLs

############################################
# grep
if (Test-Path Alias:grep) {
  Remove-Item Alias:grep
}
New-Alias -name grep -value findstr

Set-Debug " >> Finished aliases.ps1"