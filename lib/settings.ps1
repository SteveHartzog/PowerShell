# Custom Global Settings Object
$global:Settings = New-Object PSObject -Property @{
  Debug = $true
}

# Defaults
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

Set-Debug " >> Finished settings.ps1: `
          `t`t   * `$global:Settings.debug: $($global:Settings.debug)"