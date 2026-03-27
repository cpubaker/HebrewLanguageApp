$ErrorActionPreference = "Stop"

$flutterRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$repoRoot = (Resolve-Path (Join-Path $flutterRoot "..")).Path
$sourceRoot = Join-Path $repoRoot "data\input"
$targetRoot = Join-Path $flutterRoot "assets\learning\input"

$pathsToMirror = @(
    "contexts",
    "guide",
    "verbs",
    "reading"
)

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

Copy-Item `
    -LiteralPath (Join-Path $sourceRoot "hebrew_words.json") `
    -Destination (Join-Path $targetRoot "hebrew_words.json") `
    -Force

foreach ($relativePath in $pathsToMirror) {
    $sourcePath = Join-Path $sourceRoot $relativePath

    if (-not (Test-Path $sourcePath)) {
        continue
    }

    Copy-Item -LiteralPath $sourcePath -Destination $targetRoot -Recurse -Force
}

Write-Host "Flutter assets synced from $sourceRoot"
