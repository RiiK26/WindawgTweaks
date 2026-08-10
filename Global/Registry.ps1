# 1. retrive classic context menu desktop
$ClassicMenuPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
New-Item -Path $ClassicMenuPath -Value "" -Force | Out-Null

# 2. delete "Open with Studio" (AnyCode) menu
$AnyCodePaths = @(
    "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\AnyCode",
    "Registry::HKEY_CLASSES_ROOT\Directory\shell\AnyCode"
)

foreach ($Path in $AnyCodePaths) {
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 3. Restart Windows Explorer
Stop-Process -Name explorer -Force
