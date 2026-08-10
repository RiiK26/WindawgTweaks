if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run PowerShell as administrator!" -ForegroundColor Red
    exit
}

Write-Host "Uninstalling bloatware..." -ForegroundColor Cyan

$Apps = @(
    "MicrosoftDataCollectorSet",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCamera",
    "Microsoft.549981C3F5F10", # Cortana
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.ZuneMusic",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsMaps",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.ZuneVideo",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Office.OneNote",
    "Microsoft.MSPaint",
    "Microsoft.Paint3D",
    "Microsoft.People",
    "Microsoft.Windows.Photos",
    "Microsoft.RemoteDesktop",
    "Microsoft.SkypeApp",
    "Microsoft.ScreenSketch",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.BingWeather",
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.Xbox.TCUI",

    # Windows built-in apps
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",    # Tips
    "Microsoft.YourPhone"      # Your Phone / Phone Link
)

foreach ($App in $Apps) {

    # 1. Remove installed packages for all users
    $InstalledPackages = Get-AppxPackage -AllUsers -Name "*$App*" -ErrorAction SilentlyContinue

    foreach ($Package in $InstalledPackages) {
        Write-Host "Removing Package: $($Package.PackageFullName)" -ForegroundColor Yellow

        try {
            Remove-AppxPackage -Package $Package.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "  -> Removed successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "  -> Could not remove package (may already be gone or system-protected)." -ForegroundColor DarkYellow
        }
    }

    # 2. Remove provisioned packages
    #    This prevents the app from being installed for new Windows users
    $ProvisionedPackages = Get-AppxProvisionedPackage -Online |
        Where-Object { $_.PackageName -Like "*$App*" }

    foreach ($ProvPackage in $ProvisionedPackages) {
        Write-Host "Removing Provisioned: $($ProvPackage.PackageName)" -ForegroundColor Yellow

        try {
            Remove-AppxProvisionedPackage -Online -PackageName $ProvPackage.PackageName -ErrorAction Stop
            Write-Host "  -> Provisioned package removed." -ForegroundColor Green
        }
        catch {
            Write-Host "  -> Could not remove provisioned package." -ForegroundColor DarkYellow
        }
    }
}

# ------------------------------------------------------------
# Uninstall Microsoft Edge
# ------------------------------------------------------------

$EdgeInstallerPath = Get-ChildItem `
    "C:\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe" `
    -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName

if ($EdgeInstallerPath) {
    Write-Host "Force uninstalling Microsoft Edge..." -ForegroundColor Yellow

    Start-Process `
        -FilePath $EdgeInstallerPath `
        -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" `
        -Wait
}

# ------------------------------------------------------------
# Uninstall Microsoft OneDrive
# ------------------------------------------------------------

Write-Host "Uninstalling Microsoft OneDrive..." -ForegroundColor Yellow

taskkill.exe /f /im OneDrive.exe 2>&1 | Out-Null

$OneDrive64 = "$env:SystemRoot\System32\OneDriveSetup.exe"
$OneDrive32 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"

if (Test-Path $OneDrive64) {
    Start-Process `
        -FilePath $OneDrive64 `
        -ArgumentList "/uninstall" `
        -NoNewWindow `
        -Wait
}
elseif (Test-Path $OneDrive32) {
    Start-Process `
        -FilePath $OneDrive32 `
        -ArgumentList "/uninstall" `
        -NoNewWindow `
        -Wait
}

Write-Host ""
Write-Host "Uninstalling done, please restart your PC!" -ForegroundColor Green
