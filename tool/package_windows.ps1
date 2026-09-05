param(
  [switch]$SkipBuild
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
$releaseDirectory = Join-Path $projectRoot 'build\windows\x64\runner\Release'
$packageRoot = Join-Path $projectRoot 'build\windows\package'
$stageDirectory = Join-Path $packageRoot "EchoDay-v$version-windows-x64"
$distributionDirectory = Join-Path $projectRoot 'dist'
$archivePath = Join-Path $distributionDirectory "EchoDay-v$version-windows-x64-portable.zip"
$checksumPath = "$archivePath.sha256"
$runtimeDllNames = @(
  'msvcp140.dll',
  'vcruntime140.dll',
  'vcruntime140_1.dll'
)

function Assert-WorkspacePath {
  param([Parameter(Mandatory = $true)][string]$Path)
  $fullPath = [System.IO.Path]::GetFullPath($Path)
  $rootPrefix = $projectRoot.TrimEnd('\') + '\'
  if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to modify a path outside the workspace: $fullPath"
  }
}

Assert-WorkspacePath $stageDirectory
Assert-WorkspacePath $archivePath
Assert-WorkspacePath $checksumPath

Push-Location $projectRoot
try {
  if (-not $SkipBuild) {
    & flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
      throw "Flutter Windows build failed with exit code $LASTEXITCODE."
    }
  }
  if (-not (Test-Path -LiteralPath (Join-Path $releaseDirectory 'EchoDay.exe'))) {
    throw 'Windows Release output is missing EchoDay.exe.'
  }

  if (Test-Path -LiteralPath $stageDirectory) {
    Remove-Item -LiteralPath $stageDirectory -Recurse -Force
  }
  New-Item -ItemType Directory -Path $stageDirectory -Force | Out-Null
  New-Item -ItemType Directory -Path $distributionDirectory -Force | Out-Null

  Copy-Item -Path (Join-Path $releaseDirectory '*') -Destination $stageDirectory -Recurse -Force
  Copy-Item -LiteralPath (Join-Path $projectRoot 'LICENSE') -Destination $stageDirectory
  Copy-Item -LiteralPath (Join-Path $projectRoot 'packaging\windows\PORTABLE_README.txt') -Destination (Join-Path $stageDirectory 'README.txt')
  Copy-Item -LiteralPath (Join-Path $projectRoot 'docs\USER_BACKUP_GUIDE.md') -Destination $stageDirectory
  Copy-Item -LiteralPath (Join-Path $projectRoot 'docs\RELEASE_NOTES_v0.1.0.md') -Destination $stageDirectory

  # Flutter's Windows deployment guide allows these VC++ runtime DLLs to be
  # distributed app-locally. Keeping them beside EchoDay.exe makes the portable
  # package usable without a separate Visual C++ Redistributable installation.
  foreach ($runtimeDllName in $runtimeDllNames) {
    $packagedRuntimePath = Join-Path $stageDirectory $runtimeDllName
    if (Test-Path -LiteralPath $packagedRuntimePath) {
      continue
    }
    $systemRuntimePath = Join-Path "$env:WINDIR\System32" $runtimeDllName
    if (-not (Test-Path -LiteralPath $systemRuntimePath)) {
      throw "Required Windows runtime DLL is missing: $systemRuntimePath"
    }
    Copy-Item -LiteralPath $systemRuntimePath -Destination $packagedRuntimePath
  }

  $userDataArtifacts = Get-ChildItem -LiteralPath $stageDirectory -Recurse -File |
    Where-Object {
      $_.Extension -in @('.sqlite', '.sqlite3', '.db') -or
      $_.Name -like 'EchoDay-backup-*.json' -or
      $_.Name -like 'before-clear-*.json' -or
      $_.Name -like 'before-restore-*.json'
    }
  foreach ($userDataArtifact in $userDataArtifacts) {
    Assert-WorkspacePath $userDataArtifact.FullName
    Write-Warning "Excluding user data from portable package: $($userDataArtifact.Name)"
    Remove-Item -LiteralPath $userDataArtifact.FullName -Force
  }
  $remainingUserData = Get-ChildItem -LiteralPath $stageDirectory -Recurse -File |
    Where-Object {
      $_.Extension -in @('.sqlite', '.sqlite3', '.db') -or
      $_.Name -like 'EchoDay-backup-*.json' -or
      $_.Name -like 'before-clear-*.json' -or
      $_.Name -like 'before-restore-*.json'
    }
  if ($remainingUserData) {
    $artifactList = ($remainingUserData.FullName -join ', ')
    throw "Failed to remove user data from package staging: $artifactList"
  }

  if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
  }
  if (Test-Path -LiteralPath $checksumPath) {
    Remove-Item -LiteralPath $checksumPath -Force
  }
  Compress-Archive -Path (Join-Path $stageDirectory '*') -DestinationPath $archivePath -CompressionLevel Optimal
  $hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
  "$hash  $([System.IO.Path]::GetFileName($archivePath))" |
    Set-Content -LiteralPath $checksumPath -Encoding ascii

  Write-Output "Archive: $archivePath"
  Write-Output "SHA256:  $hash"
} finally {
  Pop-Location
}
