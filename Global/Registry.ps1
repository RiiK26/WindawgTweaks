if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "FAILED: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please close PowerShell, right-click 'Windows PowerShell' then select 'Run as Administrator', and try again." -ForegroundColor Yellow
    exit
}

Write-Host "Starting Windows optimization process..." -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

# Applying Registry Configuration & Optimization
Write-Host "`nApplying Registry configurations and optimizations..." -ForegroundColor Yellow

$registrySettings = @(
    # Copilot (CU)
    @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"; Name = "TurnOffWindowsCopilot"; Value = 1 },
    # Copilot (LM)
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; Name = "TurnOffWindowsCopilot"; Value = 1 },
    # Copilot Taskbar
    @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowCopilotButton"; Value = 0 },
    # GameConfigStore
    @{ Path = "HKCU:\System\GameConfigStore"; Name = "GameDVR_Enabled"; Value = 0 },
    # GameDVR
    @{ Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"; Name = "AppCaptureEnabled"; Value = 0 },
    # Web Search Start Menu
    @{ Path = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; Name = "DisableSearchBoxSuggestions"; Value = 1 },
    # Classic Context Menu Desktop
    @{ Path = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"; Name = ""; Value = "" }
)

foreach ($reg in $registrySettings) {
    if (!(Test-Path $reg.Path)) { 
        New-Item -Path $reg.Path -Force | Out-Null 
    }
    if ($reg.Name -eq "") {
        Set-Item -Path $reg.Path -Value $reg.Value -Force
    } else {
        Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWord -Force
    }
}

# Removing "Open with Studio" (AnyCode)
$AnyCodePaths = @(
    "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\AnyCode",
    "Registry::HKEY_CLASSES_ROOT\Directory\shell\AnyCode"
)

foreach ($Path in $AnyCodePaths) {
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Registry configurations successfully applied." -ForegroundColor Green

# Restart Windows Explorer to apply UI changes
Write-Host "`n==============================================================" -ForegroundColor Cyan
Write-Host "All processes complete! Restarting Windows Explorer to apply interface changes..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
Stop-Process -Name explorer -Force
Write-Host "Optimization process has been completely finished!" -ForegroundColor Green
