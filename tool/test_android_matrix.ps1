param(
  [string[]]$Avds = @(
    'EchoDay_API24_AOSP',
    'EchoDay_API29_AOSP',
    'EchoDay_API34_AOSP',
    'EchoDay_API36_AOSP'
  ),
  [int]$BootTimeoutSeconds = 240
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sdkRoot = if ($env:ANDROID_SDK_ROOT) {
  $env:ANDROID_SDK_ROOT
} elseif ($env:ANDROID_HOME) {
  $env:ANDROID_HOME
} else {
  Join-Path $env:LOCALAPPDATA 'Android\Sdk'
}
$adb = Join-Path $sdkRoot 'platform-tools\adb.exe'
$emulator = Join-Path $sdkRoot 'emulator\emulator.exe'
$testPath = 'integration_test\android_quality_test.dart'

foreach ($required in @($adb, $emulator)) {
  if (-not (Test-Path -LiteralPath $required)) {
    throw "Required Android tool is missing: $required"
  }
}

$availableAvds = & $emulator -list-avds
foreach ($avd in $Avds) {
  if ($avd -notin $availableAvds) {
    throw "Android virtual device is missing: $avd"
  }
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)][string]$Command,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )
  & $Command @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$Command failed with exit code $LASTEXITCODE."
  }
}

Push-Location $projectRoot
try {
  foreach ($avd in $Avds) {
    $serial = 'emulator-5554'
    $emulatorProcess = $null
    $existingBackendIds = @(
      Get-Process -Name 'qemu-system-x86_64-headless' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Id
    )
    Write-Output "Starting $avd on $serial..."
    try {
      $emulatorProcess = Start-Process `
        -FilePath $emulator `
        -ArgumentList @(
          '-avd', $avd,
          '-port', '5554',
          '-no-window',
          '-no-audio',
          '-no-boot-anim',
          '-no-snapshot',
          '-read-only',
          '-gpu', 'host'
        ) `
        -WindowStyle Hidden `
        -PassThru

      $deadline = [DateTime]::UtcNow.AddSeconds($BootTimeoutSeconds)
      $booted = $false
      while ([DateTime]::UtcNow -lt $deadline) {
        try {
          $state = & $adb -s $serial get-state 2>$null
        } catch {
          $state = ''
        }
        if ($state -eq 'device') {
          try {
            $completed = (
              & $adb -s $serial shell getprop sys.boot_completed 2>$null
            ).Trim()
          } catch {
            $completed = ''
          }
          if ($completed -eq '1') {
            $booted = $true
            break
          }
        }
        Start-Sleep -Seconds 2
      }
      if (-not $booted) {
        throw "$avd did not boot within $BootTimeoutSeconds seconds."
      }

      & $adb -s $serial shell settings put global window_animation_scale 0 *> $null
      & $adb -s $serial shell settings put global transition_animation_scale 0 *> $null
      & $adb -s $serial shell settings put global animator_duration_scale 0 *> $null
      Invoke-Checked flutter @('test', $testPath, '-d', $serial)
      Write-Output "PASS $avd"
    } finally {
      try {
        & $adb -s $serial emu kill *> $null
      } catch {
        # The emulator may have exited before ADB accepted connections.
      }
      if ($null -ne $emulatorProcess) {
        Start-Sleep -Seconds 2
        $emulatorProcess.Refresh()
        if (-not $emulatorProcess.HasExited) {
          Stop-Process -Id $emulatorProcess.Id -Force
        }
      }
      $createdBackends = Get-Process `
        -Name 'qemu-system-x86_64-headless' `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -notin $existingBackendIds }
      foreach ($backend in $createdBackends) {
        Stop-Process -Id $backend.Id -Force
      }
    }
  }
} finally {
  Pop-Location
}
