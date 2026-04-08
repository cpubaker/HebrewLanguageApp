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

$lessonCatalogRelativePaths = @(
    "guide",
    "verbs",
    "reading"
)

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

Copy-Item `
    -LiteralPath (Join-Path $sourceRoot "hebrew_words.json") `
    -Destination (Join-Path $targetRoot "hebrew_words.json") `
    -Force

Copy-Item `
    -LiteralPath (Join-Path $sourceRoot "guide_metadata.json") `
    -Destination (Join-Path $targetRoot "guide_metadata.json") `
    -Force

foreach ($relativePath in $pathsToMirror) {
    $sourcePath = Join-Path $sourceRoot $relativePath
    $destinationPath = Join-Path $targetRoot $relativePath

    if (-not (Test-Path $sourcePath)) {
        continue
    }

    New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null

    Get-ChildItem -LiteralPath $destinationPath -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "AGENTS.md" } |
        Where-Object { -not (Test-Path (Join-Path $sourcePath $_.Name)) } |
        Remove-Item -Recurse -Force

    Get-ChildItem -LiteralPath $sourcePath -Force |
        Where-Object { $_.Name -ne "AGENTS.md" } |
        Copy-Item -Destination $destinationPath -Recurse -Force
}

$lessonCatalog = @{}

foreach ($relativePath in $lessonCatalogRelativePaths) {
    $sourcePath = Join-Path $sourceRoot $relativePath
    if (-not (Test-Path $sourcePath)) {
        continue
    }

    $resolvedSourcePath = (Resolve-Path $sourcePath).Path.TrimEnd("\")

    $lessonCatalog[$relativePath] = @(
        Get-ChildItem -LiteralPath $sourcePath -Recurse -File |
            Where-Object { $_.Extension -eq ".md" } |
            Where-Object { $_.Name -ne "AGENTS.md" } |
            ForEach-Object {
                $_.FullName.Substring($resolvedSourcePath.Length).TrimStart("\").Replace("\", "/")
            } |
            Sort-Object
    )
}

$lessonCatalogPath = Join-Path $targetRoot "lesson_catalog.json"
$lessonCatalog |
    ConvertTo-Json -Depth 4 |
    Set-Content -LiteralPath $lessonCatalogPath -Encoding UTF8

Write-Host "Flutter assets synced from $sourceRoot"
