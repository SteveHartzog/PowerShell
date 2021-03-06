$voice = New-Object -ComObject SAPI.SPVoice
$voice.Rate = -3

function invoke-speech {
  param([Parameter(ValueFromPipeline=$true)][string] $say )
  process {
    $voice.Speak($say) | out-null;
  }
}
if (!(Test-Path Alias:out-voice)) {
  new-alias -name out-voice -value invoke-speech
}

# alias which
if (!(Test-Path Alias:which)) {
  new-alias -name which -value get-command
}

function reload-profile {
  @(
    $Profile.AllUsersAllHosts,
    $Profile.AllUsersCurrentHost,
    $Profile.CurrentUserAllHosts,
    $Profile.CurrentUserCurrentHost
  ) | ForEach-Object {
    if(Test-Path $_){
      Write-Verbose "Running $_"
      . $_
    }
  }
}

function Import-Scripts {
  Param(
    [string]$directory = $(Throw "Please provide a directory to look for modules.")
  )

  $scriptList = Get-ChildItem "${directory}\*.ps1" | Select-Object -Expand Name
  Set-Debug "Import-Scripts Dir: $($directory)"
  Set-Debug "Import-Scripts List: $($scriptList)"

  foreach ($script in $scriptList) {
    Set-Debug "'$($directory)\$($script)': Started loading."
    Import-Module "$($directory)\$($script)" -Force
  }
}




function truncate-string {
  Param(
    [string]$string,
    [int]$width,
    [AllowNull()]
    [bool]$ellipses = $true
  )
  if ($string.Length -gt $width) {
    $truncString = $string[0..$width] -join ""
    if ($true -eq $ellipses) {
      return $truncString + "..."
    } else {
      return $truncString
    }
  } else {
    return $string
  }
}

# Unicode Stuff
function Get-Shruggie { # ¯\_(ツ)_/¯
  "¯\_($([char]0x30C4))_/¯" | Set-Clipboard
}

function Get-Coffee { # ⛾
  "$([char]0x26FE)" | Set-Clipboard
}

function get-yinyang { # ☯
  "$([char]0x262F)" | Set-Clipboard
}

function get-coffee2 { # ☕
  "☕" | Set-Clipboard
}


function get-folder { #
  "$([char]0xF4C2)" # 1F4C1 (closed) or 1F4C2 (open)
}

Set-Debug " >> Finished utilities.ps1"