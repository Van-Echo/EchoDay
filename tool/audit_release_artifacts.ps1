param(
  [string[]]$Artifacts
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if (-not $Artifacts -or $Artifacts.Count -eq 0) {
  $Artifacts = @(
    Get-ChildItem -LiteralPath (Join-Path $projectRoot 'dist') -Recurse -File `
      -ErrorAction SilentlyContinue |
      Where-Object { $_.Extension -in @('.zip', '.apk', '.aab') } |
      Select-Object -ExpandProperty FullName
  )
}
if ($Artifacts.Count -eq 0) {
  throw 'No ZIP, APK, or AAB release artifacts were found under dist.'
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$forbiddenNamePattern =
  '(?i)(^|/|\\)(key\.properties|[^/\\]+\.(jks|keystore|sqlite3?|db|pem)|' +
  'EchoDay-backup-[^/\\]*\.json|before-(clear|restore)-[^/\\]*\.json|' +
  'signing-credentials[^/\\]*|device\.sync\.client\.profile)(/|\\|$)'
$textExtensions = @(
  '.json', '.txt', '.md', '.properties', '.yaml', '.yml', '.ini', '.config', '.pem'
)
$secretContentPatterns = @(
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----',
  '(?im)^\s*(storePassword|keyPassword)\s*=',
  '(?im)^\s*ECHODAY_(STORE_PASSWORD|KEY_PASSWORD)\s*='
)

foreach ($artifactInput in $Artifacts) {
  $artifact = (Resolve-Path -LiteralPath $artifactInput).Path
  $archive = [System.IO.Compression.ZipFile]::OpenRead($artifact)
  try {
    $forbiddenEntries = @(
      $archive.Entries | Where-Object { $_.FullName -match $forbiddenNamePattern }
    )
    if ($forbiddenEntries.Count -gt 0) {
      throw "Private or user-data files found in $artifact`: $($forbiddenEntries.FullName -join ', ')"
    }

    foreach ($entry in $archive.Entries) {
      $extension = [System.IO.Path]::GetExtension($entry.FullName).ToLowerInvariant()
      if ($extension -notin $textExtensions -or $entry.Length -gt 5MB) {
        continue
      }
      $stream = $entry.Open()
      $reader = [System.IO.StreamReader]::new($stream, $true)
      try {
        $content = $reader.ReadToEnd()
      } finally {
        $reader.Dispose()
        $stream.Dispose()
      }
      foreach ($pattern in $secretContentPatterns) {
        if ($content -match $pattern) {
          throw "Possible secret content found in $artifact entry $($entry.FullName)."
        }
      }
    }

    Write-Output "PASS $([System.IO.Path]::GetFileName($artifact)) ($($archive.Entries.Count) entries)"
  } finally {
    $archive.Dispose()
  }
}
