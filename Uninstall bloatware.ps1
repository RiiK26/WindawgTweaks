Write-Host "Starting Cleanup Windows..." -ForegroundColor Cyan
Write-Host "Phase 1: Uninstall OneDrive..." -ForegroundColor Yellow

Stop-Process -Name "OneDrive" -ErrorAction SilentlyContinue
$path = "$env:SystemRoot\System32\OneDriveSetup.exe"
$path64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"

if (Test-Path $path64) {
    Start-Process $path64 "/uninstall" -Wait
} else {
    Start-Process $path "/uninstall" -Wait
}

Remove-Item -Path "HKCU:\Software\Microsoft\OneDrive" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\Software\Microsoft\OneDrive" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LocalAppdata\Microsoft\OneDrive" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\Microsoft\OneDrive" -Recurse -ErrorAction SilentlyContinue

$regPath = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
if (Test-Path $regPath) {
    Set-ItemProperty -Path $regPath -Name "System.IsPinnedToNameSpaceTree" -Value 0
}


Write-Host "Phase 2: Cleanup Bloatware..." -ForegroundColor Yellow
$MasterAppList = @(
    "*Clipchamp*",
    "*Teams*",
    "*bingnews*",
    "*bingweather*",
    "*MicrosoftSolitaireCollection*",
    "*MicrosoftStickyNotes*",
    "*Todos*",
    "*PowerAutomateDesktop*",
    "*OutlookForWindows*",

    "*XboxApp*",
    "*Xbox.TCUI*",
    "*XboxGamingOverlay*",
    "*XboxIdentityProvider*",
    "*XboxSpeechToTextOverlay*",
    "*YourPhone*",
    "*CrossDevice*",
    "*MicrosoftFamily*",
    "*Windows.DevHome*",

    "*Microsoft.GetHelp*",
    "*WebExperience*",
    "*WindowsAlarms*",
    "*WindowsFeedbackHub*",
    "*WindowsStore*",
    "*StorePurchaseApp*",
    "*Copilot*",

    "*WindowsMediaPlayer*",
    "*ZuneVideo*",
    "*ZuneMusic*",
    "*QuickAssist*",
    "*WebMediaExtensions*",
    "*RemoteDesktop*",          #Microsoft store version. if fail. manually uninstall via control panel

    # --- Bloatware Acer ---
    "*AcerSense*",
    "*AcerPurifier*",
    "*IntelligoTechnologyInc.AcerPurifiedVoice*"
)

foreach ($app in $MasterAppList) {
    Write-Host "  -> Executing: $app" -ForegroundColor DarkGray
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}


Write-Host "Phase 3: Cleanup via winget..." -ForegroundColor Yellow
$WingetApps = @(
    "Acer Purifier voice console",
    "Acer sense"
)

foreach ($app in $WingetApps) {
    winget uninstall --name "$app" --silent --accept-source-agreements --No-upgrade
}

Write-Host "Done!." -ForegroundColor Green
Write-Host "Restart your computer to clear cache." -ForegroundColor Magenta