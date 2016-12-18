# Defaul Shell Colors
$Host.UI.RawUI.ForegroundColor = "Gray"

### Posh-Git ####################################################################
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-git module from current directory
Import-Module "/Program Files/WindowsPowerShell/Modules/posh-git"

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git



# Load all scripts in autoload directory
$psdir= $env:USERPROFILE + "\Documents\WindowsPowershell\autoload"  
Get-ChildItem "${psdir}\*.ps1" | %{.$_} 

# Not Tested
function get-FileTimeStamps {
  Param (
    [Parameter(mandatory=$true)]
    [system.io.fileinfo]$file)

    $file = resolve-path $file
    "$(($file).CreationTime)"
    "$(($file).LastAccessTime)"
    "$(($file).LastWriteTime)"
}

$console = $host.ui.RawUI

$console.ForegroundColor = "white"
$console.BackgroundColor = "black"

$buffer = $console.BufferSize
$buffer.width = 130
$buffer.height = 2000
$console.BufferSize = $buffer

$size = $console.windowSize
$size.width = 130
$size.height = 50
$console.WindowSize = $size

$colors = $host.PrivateData
$colors.VerboseForegroundColor = "white"
$colors.VerboseBackgroundColor = "black"
$colors.WarningForegroundColor = "yellow"
$colors.WarningBackgroundColor = "black"
$colors.ErrorForegroundColor = "red"
$colors.ErrorBackgroundColor = "black"

function getPath {
  if ((Convert-Path .) -eq $env:USERPROFILE) {
    Write-Host ("~") -NoNewline -ForegroundColor "Cyan" # ⛾
  } else {
    [System.Collections.ArrayList]$pathArray = (Convert-Path .).split('\')
    $pathArray.RemoveAt(0)
    $path = $pathArray -join '/'
    Write-Host ("$path") -NoNewline -ForegroundColor "white"
  }
}

function prompt {
  $Host.UI.RawUI.CursorSize = 100
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $identityArray = $identity.name.split('\')
  $hostAndUser = $identityArray[1] + '@' + $identityArray[0]
  $CurrentUser = Get-WmiObject win32_useraccount | Where-Object {$_.caption -match $env:USERNAME} | Select-Object -expand fullname | Format-Table -HideTableHeaders | Out-String

  $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if ($isAdmin) {
    $host.ui.rawui.WindowTitle = 'Administrator'
    $promptStyle = '#'
  } else {
    $host.ui.rawui.WindowTitle = $CurrentUser
    $promptStyle = '$'
  }

  # History
  $history = @(get-history)
  if($history.Count -gt 0) {
    $lastItem = $history[$history.Count - 1]
    $lastId = $lastItem.Id
  }
  # $gitStatus = (Write-VcsStatus -NoNewLine)
  $nextCommand = '[' + ($lastId + 1) + ']'

  # Write-Host ("──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────") -NoNewline -ForegroundColor "DarkGray"
  Write-Host ("`n$hostAndUser") -NoNewline -ForegroundColor "green"
  Write-Host (":/") -NoNewline -ForegroundColor "White"
  Write-Host ("$(getPath)") -NoNewline
  Write-VcsStatus -NoNewline
  Write-Host (" ($((Get-ChildItem).count))") -NoNewline -ForegroundColor "DarkGray"
  # Write-Host ("$($gitStatus) ") -NoNewline
  Write-Host ("`n$nextCommand ") -NoNewline

  # Show PromptStyle without tacking that stupid "PS" on the end
  "$promptStyle "
}

# Set-Location C:\users\shart

Clear-Host

Write-Host 'Windows PowerShell'
Write-Host 'Copyright (C) 2016 Microsoft Corporation. All rights reserved.'
Write-Host ''