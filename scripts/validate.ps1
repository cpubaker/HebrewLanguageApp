param(
    [ValidateSet("all", "flutter", "content", "python")]
    [string]$Mode = "all",

    [string]$Flutter = "C:\src\Flutter\flutter\bin\flutter.bat"
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$flutterAppRoot = Join-Path $projectRoot "flutter_app"
$learningCatalogScript = Join-Path $flutterAppRoot "tool\generate_learning_catalog.ps1"
$contentIndexScript = Join-Path $projectRoot "scripts\generate_content_index.py"

function Resolve-CommandPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    if (Test-Path -LiteralPath $Command) {
        return (Resolve-Path -LiteralPath $Command).Path
    }

    $resolvedCommand = Get-Command $Command -ErrorAction SilentlyContinue
    if ($null -ne $resolvedCommand) {
        return $resolvedCommand.Source
    }

    throw "$Description not found: $Command"
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Description not found: $Path"
    }
}

function Invoke-ValidationStep {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string]$Command,

        [string[]]$Arguments = @()
    )

    Write-Host ""
    Write-Host "==> $Name"
    Write-Host "    cwd: $WorkingDirectory"
    Write-Host "    command: $Command $($Arguments -join ' ')"

    Push-Location -LiteralPath $WorkingDirectory
    try {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            & $Command @Arguments 2>&1 | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $message = $_.Exception.Message
                    if (-not [string]::IsNullOrWhiteSpace($message)) {
                        Write-Host $message
                    }
                }
                else {
                    Write-Host $_
                }
            }
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            throw "$Name failed with exit code $exitCode"
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-ContentValidation {
    Invoke-ValidationStep `
        -Name "Generate Flutter lesson catalog" `
        -WorkingDirectory $flutterAppRoot `
        -Command "powershell.exe" `
        -Arguments @(
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            $learningCatalogScript
        )

    Invoke-ValidationStep `
        -Name "Generate compact content index" `
        -WorkingDirectory $projectRoot `
        -Command "python" `
        -Arguments @($contentIndexScript)

    Invoke-PythonValidation
}

function Invoke-FlutterValidation {
    $flutterCommand = Resolve-CommandPath `
        -Command $Flutter `
        -Description "Flutter command"

    Invoke-ValidationStep `
        -Name "Flutter analyze" `
        -WorkingDirectory $flutterAppRoot `
        -Command $flutterCommand `
        -Arguments @("analyze")

    Invoke-ValidationStep `
        -Name "Flutter test" `
        -WorkingDirectory $flutterAppRoot `
        -Command $flutterCommand `
        -Arguments @("test")
}

function Invoke-PythonValidation {
    Invoke-ValidationStep `
        -Name "Python tests" `
        -WorkingDirectory $projectRoot `
        -Command "python" `
        -Arguments @("-m", "unittest", "discover", "-s", "tests", "-v")
}

Assert-PathExists -Path $flutterAppRoot -Description "Flutter app root"
Assert-PathExists -Path $learningCatalogScript -Description "Learning catalog script"
Assert-PathExists -Path $contentIndexScript -Description "Content index script"

Write-Host "Validation mode: $Mode"

switch ($Mode) {
    "all" {
        Invoke-ContentValidation
        Invoke-FlutterValidation
    }
    "flutter" {
        Invoke-FlutterValidation
    }
    "content" {
        Invoke-ContentValidation
    }
    "python" {
        Invoke-PythonValidation
    }
}

Write-Host ""
Write-Host "Validation completed: $Mode"
