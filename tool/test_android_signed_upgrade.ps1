param(
  [string]$Avd = 'EchoDay_API36_AOSP',
  [string]$CandidateVersion = '1.0.1',
  [int]$CandidateBuildNumber = 2,
  [int]$BootTimeoutSeconds = 240,
  [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$packageName = 'com.vanecho.echoday'
$baselineApk = Join-Path $projectRoot 'dist\android\EchoDay-v0.1.0-android-universal.apk'
$candidateApk = Join-Path $projectRoot 'build\app\outputs\flutter-apk\app-release.apk'
$sdkRoot = if ($env:ANDROID_SDK_ROOT) {
  $env:ANDROID_SDK_ROOT
} elseif ($env:ANDROID_HOME) {
  $env:ANDROID_HOME
} else {
  Join-Path $env:LOCALAPPDATA 'Android\Sdk'
}
$adb = Join-Path $sdkRoot 'platform-tools\adb.exe'
$emulator = Join-Path $sdkRoot 'emulator\emulator.exe'
$flutterCommand = Get-Command flutter -ErrorAction Stop

foreach ($path in @($baselineApk, $adb, $emulator)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Required upgrade-test input is missing: $path"
  }
}
if ($CandidateBuildNumber -le 1) {
  throw 'The upgrade candidate build number must be greater than 1.'
}
if ($Avd -notin (& $emulator -list-avds)) {
  throw "Android virtual device is missing: $Avd"
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

function Get-PackageField {
  param([Parameter(Mandatory = $true)][string]$Pattern)
  $match = & $adb -s emulator-5554 shell dumpsys package $packageName |
    Select-String -Pattern $Pattern |
    Select-Object -First 1
  if (-not $match) { throw "Package field was not found: $Pattern" }
  return $match.Line.Trim()
}

Push-Location $projectRoot
$existingBackendIds = @(
  Get-Process -Name 'qemu-system-x86_64-headless' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Id
)
try {
  if (-not $SkipBuild) {
    Invoke-Checked $flutterCommand.Source @(
      'build', 'apk', '--release',
      '--target-platform', 'android-x64',
      '--build-name', $CandidateVersion,
      '--build-number', "$CandidateBuildNumber"
    )
  }
  if (-not (Test-Path -LiteralPath $candidateApk)) {
    throw "Upgrade candidate was not generated: $candidateApk"
  }

  Start-Process `
    -FilePath $emulator `
    -ArgumentList @(
      '-avd', $Avd,
      '-port', '5554',
      '-no-window',
      '-no-audio',
      '-no-boot-anim',
      '-no-snapshot',
      '-read-only',
      '-gpu', 'host'
    ) `
    -WindowStyle Hidden | Out-Null

  $deadline = [DateTime]::UtcNow.AddSeconds($BootTimeoutSeconds)
  do {
    Start-Sleep -Seconds 2
    try {
      $booted = (& $adb -s emulator-5554 shell getprop sys.boot_completed 2>$null) -eq '1'
    } catch {
      $booted = $false
    }
  } until ($booted -or [DateTime]::UtcNow -ge $deadline)
  if (-not $booted) { throw "$Avd did not boot before the timeout." }

  & $adb -s emulator-5554 uninstall $packageName *> $null
  Invoke-Checked $adb @('-s', 'emulator-5554', 'install', $baselineApk)
  Invoke-Checked $adb @('-s', 'emulator-5554', 'shell', 'monkey', '-p', $packageName, '1')
  Start-Sleep -Seconds 3
  $baselineInstalledAt = Get-PackageField 'firstInstallTime='
  $baselineVersion = Get-PackageField 'versionName='

  Invoke-Checked $adb @('-s', 'emulator-5554', 'install', '-r', $candidateApk)
  $candidateInstalledAt = Get-PackageField 'firstInstallTime='
  $candidateVersionName = Get-PackageField 'versionName='
  $candidateVersionCode = Get-PackageField 'versionCode='
  if ($baselineInstalledAt -ne $candidateInstalledAt) {
    throw 'Android replaced app data instead of performing an in-place upgrade.'
  }
  if ($candidateVersionName -notmatch "versionName=$([regex]::Escape($CandidateVersion))") {
    throw "Unexpected upgraded version: $candidateVersionName"
  }
  if ($candidateVersionCode -notmatch "versionCode=$CandidateBuildNumber(\s|$)") {
    throw "Unexpected upgraded build number: $candidateVersionCode"
  }
  Invoke-Checked $adb @('-s', 'emulator-5554', 'shell', 'monkey', '-p', $packageName, '1')
  Start-Sleep -Seconds 3
  $processId = (& $adb -s emulator-5554 shell pidof $packageName).Trim()
  if ([string]::IsNullOrWhiteSpace($processId)) {
    throw 'The upgraded application did not remain running.'
  }

  [PSCustomObject]@{
    Avd = $Avd
    BaselineVersion = $baselineVersion
    CandidateVersion = $candidateVersionName
    CandidateBuild = $candidateVersionCode
    FirstInstallTimePreserved = $true
    UpgradedProcessId = $processId
  } | Format-List
} finally {
  & $adb -s emulator-5554 emu kill *> $null
  Start-Sleep -Seconds 2
  Get-Process -Name 'qemu-system-x86_64-headless' -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -notin $existingBackendIds } |
    Stop-Process -Force -ErrorAction SilentlyContinue
  Pop-Location
}
