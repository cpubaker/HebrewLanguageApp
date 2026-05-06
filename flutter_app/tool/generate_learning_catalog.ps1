$ErrorActionPreference = "Stop"

$flutterRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$inputRoot = Join-Path $flutterRoot "assets\learning\input"

$lessonCatalogRelativePaths = @(
    "guide",
    "verbs",
    "reading"
)

if (-not (Test-Path $inputRoot)) {
    throw "Learning input root not found: $inputRoot"
}

$lessonCatalog = [ordered]@{}

foreach ($relativePath in $lessonCatalogRelativePaths) {
    $sourcePath = Join-Path $inputRoot $relativePath
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

$lessonCatalogPath = Join-Path $inputRoot "lesson_catalog.json"
$lessonCatalog |
    ConvertTo-Json -Depth 4 |
    Set-Content -LiteralPath $lessonCatalogPath -Encoding UTF8

Write-Host "Generated learning lesson catalog at $lessonCatalogPath"
