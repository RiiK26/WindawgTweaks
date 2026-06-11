# 1. Mengembalikan menu klik kanan ke gaya Classic
$ClassicMenuPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
New-Item -Path $ClassicMenuPath -Value "" -Force | Out-Null

# 2. Menghapus menu "Open with Studio" (AnyCode)
$AnyCodePaths = @(
    "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\AnyCode",
    "Registry::HKEY_CLASSES_ROOT\Directory\shell\AnyCode"
)

foreach ($Path in $AnyCodePaths) {
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 3. Restart Windows Explorer untuk menerapkan semua perubahan
Stop-Process -Name explorer -Force