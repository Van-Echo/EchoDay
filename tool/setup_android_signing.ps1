param(
  [string]$SigningDirectory = (Join-Path $env:USERPROFILE '.echoday\android-signing')
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$androidDirectory = Join-Path $projectRoot 'android'
$propertiesPath = Join-Path $androidDirectory 'key.properties'
$profileRoot = [System.IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\') + '\'
$signingRoot = [System.IO.Path]::GetFullPath($SigningDirectory)
if (-not $signingRoot.StartsWith($profileRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "SigningDirectory must be inside the current user profile: $profileRoot"
}

$keystorePath = Join-Path $signingRoot 'echoday-upload.jks'
$credentialsPath = Join-Path $signingRoot 'EchoDay-Android-signing-credentials.txt'
foreach ($path in @($keystorePath, $credentialsPath, $propertiesPath)) {
  if (Test-Path -LiteralPath $path) {
    throw "Refusing to overwrite existing signing material: $path"
  }
}

$keytoolCandidates = @(
  $(if ($env:JAVA_HOME) { Join-Path $env:JAVA_HOME 'bin\keytool.exe' }),
  'D:\Program Files\Android\Android Studio\jbr\bin\keytool.exe',
  'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
$keytool = $keytoolCandidates | Select-Object -First 1
if (-not $keytool) {
  throw 'keytool.exe was not found. Install Android Studio or set JAVA_HOME.'
}

function New-RandomSecret {
  $bytes = New-Object byte[] 32
  $generator = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  try {
    $generator.GetBytes($bytes)
  } finally {
    $generator.Dispose()
  }
  return [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

$password = New-RandomSecret
New-Item -ItemType Directory -Path $signingRoot -Force | Out-Null
& $keytool -genkeypair `
  -keystore $keystorePath `
  -storetype JKS `
  -storepass $password `
  -keypass $password `
  -alias echoday `
  -keyalg RSA `
  -keysize 4096 `
  -validity 10000 `
  -dname 'CN=Wan Yikou (Van Echo), OU=EchoDay, O=EchoDay, C=CN'
if ($LASTEXITCODE -ne 0) {
  throw "keytool failed with exit code $LASTEXITCODE."
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$properties = @(
  "storePassword=$password"
  "keyPassword=$password"
  'keyAlias=echoday'
  "storeFile=$($keystorePath.Replace('\', '/'))"
) -join "`n"
[System.IO.File]::WriteAllText($propertiesPath, "$properties`n", $utf8NoBom)

$credentials = @(
  'EchoDay Android signing credentials'
  "Created: $([DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz'))"
  "Keystore: $keystorePath"
  'Alias: echoday'
  "Store password: $password"
  "Key password: $password"
  ''
  'Keep this file and the .jks file together in at least two secure backups.'
  'Losing either the keystore or password prevents future in-place app upgrades.'
) -join "`r`n"
[System.IO.File]::WriteAllText($credentialsPath, "$credentials`r`n", $utf8NoBom)

Write-Output "Signing keystore created: $keystorePath"
Write-Output "Private credentials saved: $credentialsPath"
Write-Output "Gradle properties created: $propertiesPath"
