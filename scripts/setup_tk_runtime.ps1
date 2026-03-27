$ErrorActionPreference = "Stop"

$pythonHome = Split-Path -Parent (Get-Command python).Source
$sourceTcl = Join-Path $pythonHome "tcl\tcl8.6"
$sourceTk = Join-Path $pythonHome "tcl\tk8.6"
$targetRoot = Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path "tk_runtime\lib"

if (-not (Test-Path $sourceTcl) -or -not (Test-Path $sourceTk)) {
    throw "Could not find Tcl/Tk folders under $pythonHome"
}

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
Copy-Item -LiteralPath $sourceTcl -Destination $targetRoot -Recurse -Force
Copy-Item -LiteralPath $sourceTk -Destination $targetRoot -Recurse -Force

Write-Host "Tk runtime prepared in $targetRoot"
