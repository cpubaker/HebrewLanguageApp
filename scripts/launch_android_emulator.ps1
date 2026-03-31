param(
    [string]$AvdName = "Medium_Phone_API_36.1",
    [int]$X = 40,
    [int]$Y = 40,
    [int]$Width = 460,
    [int]$Height = 920,
    [switch]$ColdBoot
)

$ErrorActionPreference = "Stop"

function Get-EmulatorExecutable {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Android\Sdk\emulator\emulator.exe"),
        (Join-Path $env:ANDROID_SDK_ROOT "emulator\emulator.exe"),
        (Join-Path $env:ANDROID_HOME "emulator\emulator.exe")
    ) | Where-Object { $_ -and (Test-Path $_) }

    $emulatorExe = $candidates | Select-Object -First 1
    if (-not $emulatorExe) {
        throw "Could not find emulator.exe in the standard Android SDK locations."
    }

    return $emulatorExe
}

function Get-NewestEmulatorProcess {
    return Get-Process emulator -ErrorAction SilentlyContinue |
        Sort-Object StartTime -Descending |
        Select-Object -First 1
}

function Get-EmulatorWindowProcess {
    $qemuProcess = Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 } |
        Sort-Object StartTime -Descending |
        Select-Object -First 1

    if ($qemuProcess) {
        return $qemuProcess
    }

    return Get-Process emulator -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 } |
        Sort-Object StartTime -Descending |
        Select-Object -First 1
}

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class WindowTools {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(
        IntPtr hWnd,
        int X,
        int Y,
        int nWidth,
        int nHeight,
        bool bRepaint
    );

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

$emulatorProcess = Get-NewestEmulatorProcess

if (-not $emulatorProcess) {
    $emulatorExe = Get-EmulatorExecutable
    $arguments = @("-avd", $AvdName)

    if ($ColdBoot) {
        $arguments += "-no-snapshot-load"
    }

    Start-Process -FilePath $emulatorExe -ArgumentList $arguments | Out-Null
}

$deadline = (Get-Date).AddSeconds(45)
$windowHandle = [IntPtr]::Zero
$emulatorProcess = $null

while ((Get-Date) -lt $deadline) {
    $emulatorProcess = Get-EmulatorWindowProcess
    if ($emulatorProcess -and $emulatorProcess.MainWindowHandle -ne 0) {
        $windowHandle = $emulatorProcess.MainWindowHandle
        break
    }

    Start-Sleep -Milliseconds 500
}

if ($windowHandle -eq [IntPtr]::Zero) {
    throw "The emulator window did not become available within 45 seconds."
}

[WindowTools]::ShowWindowAsync($windowHandle, 9) | Out-Null
[WindowTools]::MoveWindow($windowHandle, $X, $Y, $Width, $Height, $true) | Out-Null
[WindowTools]::SetForegroundWindow($windowHandle) | Out-Null

Write-Host "Emulator window moved to X=$X Y=$Y Width=$Width Height=$Height"
