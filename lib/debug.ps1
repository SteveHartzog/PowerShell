function Set-Debug {
  Param(
    [switch]$show,
    [switch]$clear,
    [switch]$init,
    [parameter(ValueFromRemainingArguments=$true)]$appendMessage
  )

  if ($init) {
    $message = New-Object PSObject -Property @{
      datetime = get-date -format "yyyy-MM-dd HH:mm:ss"
      message = "Log started."
    }

    $global:log = @()
    Try {
      $global:log += $message
    } Catch {
      $assanineError = "Catching bullshit op_addition error that serves no fucking purpose"
    }
  }

  if ($clear) {
    $global:log = @()
  }
  if ($appendMessage) {
    $message = New-Object PSObject -Property @{
      datetime = get-date -format "yyyy-MM-dd HH:mm:ss"
      message = $appendMessage
    }
    Try {
      $global:log += $message
    } Catch {
      $assanineError = "Catching bullshit op_addition error that serves no fucking purpose"
    }
  }
  if ($show) {
    Write-Host ("$("_"*(100))")
    Write-Host (" *** Debug Log ***")
    $log = $global:log
    ForEach ($message in $log) {
      Write-Host (" [$($message.datetime)] ") -ForegroundColor "Gray" -NoNewline
      Write-Host ("$($message.message)")
    }
  }
}
