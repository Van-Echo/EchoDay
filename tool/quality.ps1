param(
  [switch]$SkipPubGet,
  [switch]$BuildWindows,
  [switch]$RunIntegration
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutterCommand) {
  $flutter = $flutterCommand.Source
} else {
  $localSdk = Join-Path $projectRoot '..\tools\flutter\bin\flutter.bat'
  if (-not (Test-Path $localSdk)) {
    throw 'Flutter was not found in PATH or the adjacent tools directory.'
  }
  $flutter = (Resolve-Path $localSdk).Path
}
$dart = Join-Path (Split-Path -Parent $flutter) 'dart.bat'

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  & $Command @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$Command failed with exit code $LASTEXITCODE."
  }
}

Push-Location $projectRoot
try {
  if (-not $SkipPubGet) {
    Invoke-Checked $flutter @('pub', 'get')
  }
  Invoke-Checked $flutter @('gen-l10n')
  Invoke-Checked $dart @('run', 'build_runner', 'build')
  Invoke-Checked $dart @(
    'format',
    '--output=none',
    '--set-exit-if-changed',
    'lib',
    'test',
    'integration_test'
  )
  Invoke-Checked $flutter @('analyze')
  Invoke-Checked $flutter @('test')
  if ($BuildWindows) {
    Invoke-Checked $flutter @('build', 'windows', '--debug')
  }
  if ($RunIntegration) {
    Invoke-Checked $flutter @(
      'test',
      'integration_test',
      '-d',
      'windows'
    )
    # Integration tests reuse the Debug runner output with a test entrypoint.
    # Restore normal application assets so EchoDay.exe remains double-clickable.
    Invoke-Checked $flutter @('build', 'windows', '--debug')
  }
} finally {
  Pop-Location
}
