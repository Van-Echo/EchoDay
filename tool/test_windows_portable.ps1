param(
  [string]$ArchivePath = '',
  [int]$LaunchSeconds = 5
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($ArchivePath)) {
  $ArchivePath = Join-Path $projectRoot 'dist\EchoDay-v0.1.0-windows-x64-portable.zip'
}
$archive = (Resolve-Path -LiteralPath $ArchivePath).Path
$checksumFile = "$archive.sha256"
$installRoot = [System.IO.Path]::GetFullPath(
  (Join-Path $projectRoot 'build\windows\m6_install_test')
)
$workspacePrefix = $projectRoot.TrimEnd('\') + '\'
if (-not $installRoot.StartsWith(
    $workspacePrefix,
    [System.StringComparison]::OrdinalIgnoreCase
  )) {
  throw "Install test path escaped the workspace: $installRoot"
}
if ($installRoot -eq $projectRoot -or $installRoot.Length -le $workspacePrefix.Length) {
  throw "Install test path is too broad: $installRoot"
}
if (-not (Test-Path -LiteralPath $checksumFile)) {
  throw "Checksum file is missing: $checksumFile"
}

$expectedHash = ((Get-Content -LiteralPath $checksumFile) -split '\s+')[0]
$actualHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $expectedHash) {
  throw 'Package checksum mismatch.'
}

function Get-RetryHash {
  param([Parameter(Mandatory = $true)][string]$Path)
  for ($attempt = 0; $attempt -lt 5; $attempt++) {
    try {
      return (Get-FileHash -LiteralPath $Path -Algorithm SHA256 -ErrorAction Stop).Hash
    } catch {
      Start-Sleep -Milliseconds 300
    }
  }
  return $null
}

if (Test-Path -LiteralPath $installRoot) {
  Remove-Item -LiteralPath $installRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $installRoot | Out-Null
Expand-Archive -LiteralPath $archive -DestinationPath $installRoot

$executable = Join-Path $installRoot 'EchoDay.exe'
if (-not (Test-Path -LiteralPath $executable)) {
  throw 'Extracted package does not contain EchoDay.exe.'
}
$requiredRuntimeDlls = @(
  'msvcp140.dll',
  'vcruntime140.dll',
  'vcruntime140_1.dll'
)
foreach ($runtimeDllName in $requiredRuntimeDlls) {
  if (-not (Test-Path -LiteralPath (Join-Path $installRoot $runtimeDllName))) {
    throw "Extracted package is missing app-local runtime: $runtimeDllName"
  }
}
$packagedUserData = Get-ChildItem -LiteralPath $installRoot -Recurse -File |
  Where-Object {
    $_.Extension -in @('.sqlite', '.sqlite3', '.db') -or
    $_.Name -like 'EchoDay-backup-*.json' -or
    $_.Name -like 'before-clear-*.json' -or
    $_.Name -like 'before-restore-*.json'
  }
if ($packagedUserData) {
  throw "Portable package contains user data: $($packagedUserData.FullName -join ', ')"
}

$process = $null
try {
  $process = Start-Process `
    -FilePath $executable `
    -WorkingDirectory $installRoot `
    -WindowStyle Hidden `
    -PassThru
  Start-Sleep -Seconds $LaunchSeconds
  $process.Refresh()
  if ($process.HasExited) {
    throw "Portable EchoDay exited early with code $($process.ExitCode)."
  }
} finally {
  if ($null -ne $process) {
    $process.Refresh()
    if (-not $process.HasExited) {
      Stop-Process -Id $process.Id
      Wait-Process -Id $process.Id -ErrorAction SilentlyContinue
    }
  }
}

Start-Sleep -Milliseconds 750

$documents = [Environment]::GetFolderPath('MyDocuments')
$databasePath = Join-Path $documents 'echoday.sqlite'
if (-not (Test-Path -LiteralPath $databasePath)) {
  throw "User database was not created at $databasePath."
}
$databaseHashBefore = Get-RetryHash -Path $databasePath

Remove-Item -LiteralPath $installRoot -Recurse -Force
if (Test-Path -LiteralPath $installRoot) {
  throw 'Portable uninstall simulation did not remove the program directory.'
}
if (-not (Test-Path -LiteralPath $databasePath)) {
  throw 'Portable uninstall simulation removed the user database.'
}
$databaseHashAfter = Get-RetryHash -Path $databasePath
$databasePreserved = if ($null -ne $databaseHashBefore -and $null -ne $databaseHashAfter) {
  $databaseHashBefore -eq $databaseHashAfter
} else {
  Write-Warning 'Database was locked; preservation was verified by its external path and continued existence.'
  Test-Path -LiteralPath $databasePath
}
if (-not $databasePreserved) {
  throw 'The user database changed while removing the portable program directory.'
}

[PSCustomObject]@{
  PackageSha256 = $actualHash
  LaunchPid = $process.Id
  DatabasePath = $databasePath
  DatabasePreserved = $databasePreserved
  ProgramDirectoryRemoved = -not (Test-Path -LiteralPath $installRoot)
} | Format-List
