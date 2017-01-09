# Import Debug Library
$libDir = $env:USERPROFILE + "\Documents\WindowsPowerShell\lib"
Import-Module "${libDir}\debug.ps1" -Force
Set-Debug -init

# Set Default Colors
$Host.UI.RawUI.ForegroundColor = "Gray"

# Import Utilities & Global Settings
Set-Debug "Loading: utilities.ps1"
Import-Module "${libDir}\utilities.ps1" -Force

Set-Debug "Loading: settings.ps1"
Import-Module "${libDir}\settings.ps1" -Force

Set-Debug "Loading: aliases.ps1"
Import-Module "${libDir}\aliases.ps1" -Force

# Import 3rd Party Module Dependencies
Import-Module "/Program Files/WindowsPowerShell/Modules/posh-git"

$scriptsDir = $env:USERPROFILE + "\Documents\WindowsPowerShell\Scripts"
# Load all scripts & modules in the Scripts directory
# Get-ChildItem "${scriptDir}\*.ps1" -Force | %{.$_}
Set-Debug "Loading: GetPosixLs.ps1"
Import-Module "${scriptsDir}\GetPosixLs.ps1" -Force

# ALL SCRIPT LOADERS FAIL WHEN CALLED FROM THE PROFILE
# REGARDLESS OF EXECUTION POLICY or METHOD
# ALL METHODS WORK FROM THE TERMINAL THOUGH OF COURSE
# I WISH THESE WORKED
# $global:scriptdirectory = 'C:\powershellscripts'
# $global:loadedScripts = @{}

# function require {
#   param(
#     [string[]]$filenames,
#     [string]$path=$global:scriptsDir
#   )

#   Write-Host ("`$filenames: $($filenames)")
#   Write-Host ("`$path: $($path)")

#   $filenames= Get-ChildItem "${path}" | Select-Object -Expand Name

#   # if ($filenames -ne $null -and $filenames.length -eq 0) {
#   #   Write-Host ("`$filenames was null")
#   #   $scripts = $filenames
#   # } else {
#   #   Write-Host ("$($filenames)")
#   #   $scripts = $scripts | where { $_ -like "*.ps1"}
#   #   # foreach ($item in $pathItems) {
#   #   #   $newName = $script.split(".")
#   #   #   if ($newName.length -gt 1) {
#   #   #     $scripts += $item
#   #   #   }
#   #   # }
#   # }

#   Write-Host ("`$filenames: $($filenames)")
#   Write-Host ("`$scripts: $($path)")

#   if ($loadedScripts -ne $null) {
#     $unloadedFilenames = $filenames | where { -not $loadedScripts[$_] }
#     reload $unloadedFilenames $path
#   } else {
#     reload $scripts $path
#   }

# }

# $path = $env:USERPROFILE + "\Documents\WindowsPowerShell\Scripts\"
# Write-Host ("`$path: $($path)")

# Get-ChildItem "$($path)\*.ps1" | %{ .$_ }

# function reload {
#   param(
#     [string[]]$filenames,
#     [string]$path=$global:scriptsDir
#   )
#   if ($filenames -eq $null) {
#     $filenames= Get-ChildItem "${path}" | Where -Property "Name" -like "*.ps1" | Select-Object -Expand Name
#     $loadedScripts = @{}
#   }
#   Write-Host ("`$path: $($path)")
#   try {
#     Get-ChildItem "$($path)\*.ps1" | %{ .$_ }
#   } catch {
#     Write-Host("$($_.Exception.Message)")
#   }
#   # foreach( $filename in $filenames ) {
#   #   $joinedPath = Join-Path $path $filename
#   #   Write-Host ("Loading: $($joinedPath)")
#   #   # Get-ChildItem "${path}"
#   #   $loadedScripts[$filename] = Get-Date
#   # }
# }

# Importing doesn't ever work from the profile?!:%!?#%T>!Q#TJ FUCK YOU


# Import the other libraries
# $scriptsDir = ".\Documents\WindowsPowerShell\Scripts\"
# # Import-Scripts $scriptsDir
#   $scriptList = Get-ChildItem "${scriptsDir}" | Select-Object -Expand Name

# foreach ($script in $scriptList) {
#   $newName = $script.split(".")
#   if ($newName.length -gt 1) {
#     $newList += $script
#   }
# }
# # Write-Host ("`$newList: $($newList)")
#   Write-Host "`$scriptsDir: $($scriptsDir)"
#   Write-Host "`$newList: $($newList)"
# require -filenames $newList -path $scriptsDir

### Posh-Git? ####################################################################
# Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load all scripts & modules in the autoload directory
# Get-ChildItem "${psdir}\*.ps1" | %{.$_} 

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
  $settings = $global:Settings

  $Host.UI.RawUI.CursorSize = 100
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $identityArray = $identity.name.split('\')
  $hostAndUser = $identityArray[1] + '@' + $identityArray[0]
  $CurrentUser = Get-WmiObject win32_useraccount | Where-Object {$_.caption -match $env:USERNAME} | Select-Object -expand fullname | Format-Table -HideTableHeaders | Out-String

  $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

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

  # Show PromptStyle and overwrite git-posh's WindowTitle
  if ($isAdmin) {
    $host.ui.rawui.WindowTitle = 'Administrator'
    $promptStyle = '#'
  } else {
    $host.ui.rawui.WindowTitle = $CurrentUser
    $promptStyle = '$'
  }
  "$promptStyle "
}