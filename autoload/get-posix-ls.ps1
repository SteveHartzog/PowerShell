function Get-Posix-ls {
  $fore = $Host.UI.RawUI.ForegroundColor
  $back = $Host.UI.RawUI.BackgroundColor

  $directoryColor = "Cyan"
  $compressedColor = "Red"
  $exeColor = "DarkGreen"
  $textColor = "Gray"
  $imageColor = "Magenta"
  $docColor = "White"

  $currentScreenWidth = $Host.UI.RawUI.WindowSize.Width
  $permissionsWidth = 40
  $fileSizeWidth = 8
  $lastWriteTimeWidth = 13
  $fileNameWidth = $currentScreenWidth-$permissionsWidth-$fileSizeWidth-$lastWriteTimeWidth-8

  $files = get-childitem | Select-Object Directory, Name, FullName, Length, Mode, @{Name="LastWriteTime";Expression={$_.LastWriteTime.ToString("MMM dd HH:mm")}}

  # Header
  Write-Host ("  {0,$("-" + ($permissionsWidth-1))}  " -f "Permissions") -NoNewline
  Write-Host (" {0,$("-" + ($fileSizeWidth-1))}  " -f "Size") -NoNewline
  Write-Host (" {0,$("-" + ($lastWriteTimeWidth-2))}  " -f "Last Write") -NoNewline
  Write-Host (" {0,$("-" + ($fileNameWidth-2))} " -f "Name")
  Write-Host (" $("-"*($permissionsWidth))  ") -NoNewline
  Write-Host ("$("-"*($fileSizeWidth))  ") -NoNewline
  Write-Host ("$("-"*($lastWriteTimeWidth-1))  ") -NoNewline
  Write-Host ("$("-"*($fileNameWidth-1)) ")
  foreach ($file in $files) {
    $fileSizeNumber = [long]$file.Length
    $fileSizeForeColor = "DarkGray"
    $fileSizeBackColor = $back
    if ($fileSizeNumber -gt 1) {
      if ($file.Length/1GB -gt 1) {
        $fileSizeForeColor = "Magenta"
        # $fileSizeBackColor = "White"
        $fileSizeNumber = $file.Length/1GB
        $fileSize = "{0:N3} GB" -f $fileSizeNumber
      } elseif ($file.Length/1MB -gt 1) {
        $fileSizeForeColor = "Cyan"
        $fileSizeNumber = $file.Length/1MB
        $fileSize = "{0:N2} MB" -f $fileSizeNumber
      } elseif ($file.Length/1kb -gt 1) {
        $fileSizeForeColor = "White"
        $fileSizeNumber = $file.length/1kb
        $fileSize = "{0:N0} kb" -f $fileSizeNumber
      } else {
        $fileSize = "{0}  b" -f $fileSizeNumber
      }
    } else {
      $fileSize = ""
    }
    # File Type
    if ($file.Mode -like 'd*') {
      $fileType = "directory"
    } else {
      $fileType = get-filetype -file $file.Name
    }

    # Permission, Owner & Group
    $unixPermissions = get-unix-permissions (get-acl $file.FullName)
    if ($fileType -eq "directory") {
      Write-Host (" d{0,$("-" + $($permissionsWidth-1))}  " -f $unixPermissions) -NoNewline
    } else {
      Write-Host (" -{0,$("-" + $($permissionsWidth-1))}  " -f $unixPermissions) -NoNewline      
    }

    # Size
    Write-Host ("{0,$($fileSizeWidth)}  " -f $fileSize) -NoNewline -ForegroundColor $fileSizeForeColor -BackgroundColor $fileSizeBackColor 

    # Last Saved
    Write-Host ("{0,$("-" + $lastWriteTimeWidth)} " -f $file.LastWriteTime) -NoNewline
    
    # File Name
    $fileName = (truncate-string -string $file.Name -width $fileNameWidth)
    switch ($fileType) {
      "directory" {
        Write-Host ("$($fileName)") -ForegroundColor $directoryColor
      }
      "compressed" {
        Write-Host ("$($fileName)") -ForegroundColor $compressedColor
      }
      "executable" {
        Write-Host ("$($fileName)") -ForegroundColor $exeColor
      }
      "text" {
        Write-Host ("$($fileName)") -ForegroundColor $textColor
      }
      "image" {
        Write-Host ("$($fileName)") -ForegroundColor $imageColor
      }
      "document" {
        Write-Host ("$($fileName)") -ForegroundColor $docColor
      }
      default {
        Write-Host ("$($fileName)") -ForegroundColor "Gray"
      }
    }

    # # Reset Colors
    # $Host.UI.RawUI.ForegroundColor = $fore
    
  }
}
if (Test-Path Alias:ls) { Remove-Item Alias:ls }
new-alias -name ls -value Get-Posix-ls

function old-ls {
  Param(
    [switch] $al,
    [switch] $ad,
    [switch] $d,
    [switch] $dl,
    [switch][Alias('--color')] $color
  )

  if ($al) {
    Get-ChildItem -Name
  } elseif ($ad) {
      Get-ChildItem -Directory -Hidden
  } elseif ($d) {
      Get-ChildItem -Directory
  } elseif ($dl) {
      Get-ChildItem -Directory -Name
  } else {
    Get-ChildItem
  }  
  if ($color) {
    Write-Host ("Color!")
  }
}

function get-unix-permissions {
  Param(
    $acl
  )
    # Owner
    $ownerFileSystemRights = (($acl.Access | Where-Object {$_.IdentityReference -eq $acl.Owner})).FileSystemRights
    $ownerName = $acl.Owner.Split('\')[1]
    $ownerName = truncate-string -string $ownerName -width 14 -ellipses $false
    $ownerName = "{0,-14}" -f $ownerName
    
    # Group
    $groupFileSystemRights = (($acl.Access | Where-Object {$_.IdentityReference -eq $acl.Group})).FileSystemRights
    $groupName = $acl.Group.Split('\')[1]
    $groupName = truncate-string -string $groupName -width 14 -ellipses $false
    $groupName = "{0,-14}" -f $groupName

    # Owner Rights
    if ($ownerFileSystemRights -match "FullControl") {
      $output = "rwx"
    }

    # Group Rights
    if ($groupFileSystemRights -match "FullControl") {
      $output += "rwx"
    }
    
    # Other?
    $output += "---"
    
    $output += " " + $ownerName
    $output += " " + $groupName

    # return $output
    return $output
}

function get-filetype {
  Param(
    [string]$fileName
  )
  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase `
    -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
  $compressed = New-Object System.Text.RegularExpressions.Regex(
    '\.(zip|tar|gz|rar|jar|war)$', $regex_opts)
  $executable = New-Object System.Text.RegularExpressions.Regex(
    '\.(exe|msi|msu|bat|cmd|pl|ps1|psm1|vbs|reg)$', $regex_opts)
  $text_files = New-Object System.Text.RegularExpressions.Regex(
    '\.(txt|cfg|log|ini|csv|log|xml|c|cpp|cs)$', $regex_opts)
  $image_files = New-Object System.Text.RegularExpressions.Regex(
  '\.(jpg|png|svg|gif|ico)$', $regex_opts)
  $doc_files = New-Object System.Text.RegularExpressions.Regex(
  '\.(md|doc|docx|xls|xlsx|pdf)$', $regex_opts)
  $code_files = New-Object System.Text.RegularExpressions.Regex(
  '\.(ps1|js|ts|cs)$', $regex_opts)
  $config_files = New-Object System.Text.RegularExpressions.Regex(
  '\.(.conf.js|json)$', $regex_opts)

  if ($compressed.IsMatch($fileName)) {
    return "compressed"
  } elseif ($executable.IsMatch($fileName)) {
    return "executable"
  } elseif ($text_files.IsMatch($fileName)) {
    return "text"
  } elseif ($image_files.IsMatch($fileName)) {
    return "image"
  } elseif ($doc_files.IsMatch($fileName)) {
    return "document"
  } elseif ($code_files.IsMatch($fileName)) {
    return "code"
  } elseif ($config_files.IsMatch($fileName)) {
    return "config"
  } else {
    return ""
  }
}

Write-Host "get-posix-ls loaded."