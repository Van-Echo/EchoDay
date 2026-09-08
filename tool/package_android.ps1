param(
  [switch]$SkipBuild,
  [switch]$BuildAppBundle
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'
$versionLine = Get-Content -LiteralPath $pubspecPath |
  Where-Object { $_ -match '^version:\s*' } |
  Select-Object -First 1
if (-not $versionLine -or $versionLine -notmatch '^version:\s*([^+\s]+)') {
  throw 'Could not read the application version from pubspec.yaml.'
}
$version = $Matches[1]
$distributionDirectory = Join-Path $projectRoot 'dist\android'
$universalSource = Join-Path $projectRoot 'build\app\outputs\flutter-apk\app-release.apk'
$arm64Source = Join-Path $projectRoot 'build\app\outputs\flutter-apk\app-arm64-v8a-release.apk'
$bundleSource = Join-Path $projectRoot 'build\app\outputs\bundle\release\app-release.aab'
$universalTarget = Join-Path $distributionDirectory "EchoDay-v$version-android-universal.apk"
$arm64Target = Join-Path $distributionDirectory "EchoDay-v$version-android-arm64-v8a.apk"
$bundleTarget = Join-Path $distributionDirectory "EchoDay-v$version-android.aab"
$checksumPath = Join-Path $distributionDirectory "EchoDay-v$version-android.sha256"

function Assert-WorkspacePath {
  param([Parameter(Mandatory = $true)][string]$Path)
  $fullPath = [System.IO.Path]::GetFullPath($Path)
  $rootPrefix = $projectRoot.TrimEnd('\') + '\'
  if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to modify a path outside the workspace: $fullPath"
  }
}

function Find-Flutter {
  $command = Get-Command flutter -ErrorAction SilentlyContinue
  if ($command) { return $command.Source }
  $localSdk = Join-Path $projectRoot '..\tools\flutter\bin\flutter.bat'
  if (Test-Path -LiteralPath $localSdk) { return (Resolve-Path $localSdk).Path }
  throw 'Flutter was not found in PATH or the adjacent tools directory.'
}

function Find-JavaHome {
  $candidates = @(
    $env:JAVA_HOME,
    'D:\Program Files\Android\Android Studio\jbr',
    'C:\Program Files\Android\Android Studio\jbr'
  ) | Where-Object {
    $_ -and (Test-Path -LiteralPath (Join-Path $_ 'bin\java.exe'))
  }
  $javaHome = $candidates | Select-Object -First 1
  if (-not $javaHome) {
    throw 'A Java runtime was not found. Install Android Studio or set JAVA_HOME.'
  }
  return $javaHome
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

function Assert-NoPrivatePayload {
  param([Parameter(Mandatory = $true)][string]$ArchivePath)
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)
  try {
    $forbidden = $archive.Entries | Where-Object {
      $_.FullName -match '(?i)(key\.properties|\.jks$|\.keystore$|\.sqlite3?$|\.db$|EchoDay-backup-|before-clear-|before-restore-|signing-credentials)'
    }
    if ($forbidden) {
      throw "Private or user-data payload found in $ArchivePath`: $($forbidden.FullName -join ', ')"
    }
  } finally {
    $archive.Dispose()
  }
}

$flutter = Find-Flutter
$javaHome = Find-JavaHome
$jarSigner = Join-Path $javaHome 'bin\jarsigner.exe'
if (-not (Test-Path -LiteralPath $jarSigner)) {
  throw "jarsigner.exe was not found under $javaHome."
}
$sdkRoot = if ($env:ANDROID_SDK_ROOT) {
  $env:ANDROID_SDK_ROOT
} elseif ($env:ANDROID_HOME) {
  $env:ANDROID_HOME
} else {
  Join-Path $env:LOCALAPPDATA 'Android\Sdk'
}
$buildTools = Get-ChildItem -LiteralPath (Join-Path $sdkRoot 'build-tools') -Directory |
  Sort-Object { [version]$_.Name } -Descending |
  Select-Object -First 1
if (-not $buildTools) { throw "Android build-tools were not found under $sdkRoot." }
$apkSigner = Join-Path $buildTools.FullName 'apksigner.bat'
if (-not (Test-Path -LiteralPath $apkSigner)) {
  throw "apksigner.bat was not found: $apkSigner"
}

foreach ($path in @($distributionDirectory, $universalTarget, $arm64Target, $bundleTarget, $checksumPath)) {
  Assert-WorkspacePath $path
}
New-Item -ItemType Directory -Path $distributionDirectory -Force | Out-Null

Push-Location $projectRoot
$previousJavaHome = $env:JAVA_HOME
try {
  $env:JAVA_HOME = $javaHome
  if (-not $SkipBuild) {
    Invoke-Checked -Command $flutter -Arguments @('build', 'apk', '--release')
    Invoke-Checked -Command $flutter -Arguments @('build', 'apk', '--release', '--split-per-abi')
    if ($BuildAppBundle) {
      Invoke-Checked -Command $flutter -Arguments @('build', 'appbundle', '--release')
    }
  }

  foreach ($source in @($universalSource, $arm64Source)) {
    if (-not (Test-Path -LiteralPath $source)) {
      throw "Required Android build output is missing: $source"
    }
    Assert-NoPrivatePayload $source
    Invoke-Checked -Command $apkSigner -Arguments @(
      'verify',
      '--verbose',
      '--print-certs',
      $source
    )
  }
  Copy-Item -LiteralPath $universalSource -Destination $universalTarget -Force
  Copy-Item -LiteralPath $arm64Source -Destination $arm64Target -Force

  $artifacts = @($universalTarget, $arm64Target)
  if ($BuildAppBundle) {
    if (-not (Test-Path -LiteralPath $bundleSource)) {
      throw "Required Android App Bundle is missing: $bundleSource"
    }
    Assert-NoPrivatePayload $bundleSource
    & $jarSigner -verify $bundleSource *> $null
    if ($LASTEXITCODE -ne 0) {
      throw "AAB signature verification failed with exit code $LASTEXITCODE."
    }
    Write-Output 'AAB signature verified.'
    Copy-Item -LiteralPath $bundleSource -Destination $bundleTarget -Force
    $artifacts += $bundleTarget
  } elseif (Test-Path -LiteralPath $bundleTarget) {
    Remove-Item -LiteralPath $bundleTarget -Force
  }

  $checksumLines = foreach ($artifact in $artifacts) {
    $hash = (Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $([System.IO.Path]::GetFileName($artifact))"
  }
  $checksumLines | Set-Content -LiteralPath $checksumPath -Encoding ascii

  Write-Output 'Android release artifacts:'
  foreach ($artifact in $artifacts) { Write-Output "  $artifact" }
  Write-Output "Checksums: $checksumPath"
} finally {
  $env:JAVA_HOME = $previousJavaHome
  Pop-Location
}
