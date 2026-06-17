if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "GAGAL: Script ini harus dijalankan sebagai Administrator!" -ForegroundColor Red
    Write-Host "Silakan tutup PowerShell, klik kanan 'Windows PowerShell' lalu pilih 'Run as Administrator', dan coba lagi." -ForegroundColor Yellow
    exit
}

Write-Host "Memulai proses debloat dan optimasi Windows..." -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

# 1. Menghapus Bloatware (Get Help, Tips, Xbox Game Bar, Phone Link)
$bloatwares = @(
    "*Microsoft.GetHelp*",
    "*Microsoft.Getstarted*",
    "*Microsoft.XboxGamingOverlay*",
    "*Microsoft.YourPhone*"
)

Write-Host "`n[1/5] Menghapus Bloatware Umum..." -ForegroundColor Yellow
foreach ($app in $bloatwares) {
    # Hapus untuk user saat ini
    Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
    # Hapus dari sistem agar tidak kembali saat update/buat user baru
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}
Write-Host "Bloatware berhasil dihapus." -ForegroundColor Green

# 2. Menghapus Microsoft Store
Write-Host "`n[2/5] Menghapus Microsoft Store..." -ForegroundColor Yellow
Get-AppxPackage *Microsoft.WindowsStore* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*Microsoft.WindowsStore*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Write-Host "Microsoft Store berhasil dihapus." -ForegroundColor Green

# 3. Menghapus dan Mematikan Copilot
Write-Host "`n[3/5] Menghapus dan Menonaktifkan Windows Copilot..." -ForegroundColor Yellow
# Hapus aplikasinya
Get-AppxPackage *Microsoft.Windows.Ai.Copilot.Provider* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*Microsoft.Windows.Ai.Copilot.Provider*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# Matikan fiturnya via Registry
$regPathCU_Copilot = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
if (!(Test-Path $regPathCU_Copilot)) { New-Item -Path $regPathCU_Copilot -Force | Out-Null }
Set-ItemProperty -Path $regPathCU_Copilot -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

$regPathLM_Copilot = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
if (!(Test-Path $regPathLM_Copilot)) { New-Item -Path $regPathLM_Copilot -Force | Out-Null }
Set-ItemProperty -Path $regPathLM_Copilot -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

# Sembunyikan ikon dari Taskbar
$taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $taskbarPath -Name "ShowCopilotButton" -Value 0 -Type DWord -Force
Write-Host "Copilot berhasil dimatikan." -ForegroundColor Green

# 4. Mematikan Pop-up Xbox Game Bar & GameDVR
Write-Host "`n[4/5] Mematikan Pop-up Xbox Shortcut & GameDVR..." -ForegroundColor Yellow
$gameConfigPath = "HKCU:\System\GameConfigStore"
if (!(Test-Path $gameConfigPath)) { New-Item -Path $gameConfigPath -Force | Out-Null }
Set-ItemProperty -Path $gameConfigPath -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force

$gameDVRPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
if (!(Test-Path $gameDVRPath)) { New-Item -Path $gameDVRPath -Force | Out-Null }
Set-ItemProperty -Path $gameDVRPath -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
Write-Host "Integrasi Xbox Game Bar berhasil dimatikan." -ForegroundColor Green

# 5. Mematikan Web Search di Start Menu
Write-Host "`n[5/5] Mematikan Web Search pada Start Menu..." -ForegroundColor Yellow
$searchRegPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
if (!(Test-Path $searchRegPath)) { New-Item -Path $searchRegPath -Force | Out-Null }
Set-ItemProperty -Path $searchRegPath -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force
Write-Host "Web Search berhasil dimatikan." -ForegroundColor Green

# 6. Restart Windows Explorer untuk menerapkan perubahan UI
Write-Host "`n==============================================================" -ForegroundColor Cyan
Write-Host "Semua proses selesai! Me-restart Windows Explorer untuk menerapkan perubahan antarmuka..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
Stop-Process -Name explorer -Force
Write-Host "Proses optimalisasi telah sepenuhnya selesai!" -ForegroundColor Green
