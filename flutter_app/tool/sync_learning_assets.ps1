$ErrorActionPreference = "Stop"

$flutterRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$repoRoot = (Resolve-Path (Join-Path $flutterRoot "..")).Path
$sourceRoot = Join-Path $repoRoot "data\input"
$targetRoot = Join-Path $flutterRoot "assets\learning\input"

$pathsToMirror = @(
    "contexts",
    "guide",
    "verbs",
    "reading",
    "audio\verbs",
    "images\verbs"
)

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

Copy-Item `
    -LiteralPath (Join-Path $sourceRoot "hebrew_words.json") `
    -Destination (Join-Path $targetRoot "hebrew_words.json") `
    -Force

foreach ($relativePath in $pathsToMirror) {
    $sourcePath = Join-Path $sourceRoot $relativePath
    $destinationPath = Join-Path $targetRoot $relativePath

    if (-not (Test-Path $sourcePath)) {
        continue
    }

    New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
    Get-ChildItem -LiteralPath $sourcePath -Force | Copy-Item -Destination $destinationPath -Recurse -Force
}

Write-Host "Flutter assets synced from $sourceRoot"
