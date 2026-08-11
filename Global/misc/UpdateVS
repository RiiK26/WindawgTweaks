@echo off
setlocal enabledelayedexpansion
title Update and Cleanup Visual Studio Community 2026

set "LayoutPath=%~dp0"
set "LayoutPath=%LayoutPath:~0,-1%"
set "ConfigFile=%LayoutPath%\Custom.vsconfig"
set "DirectDownloadLink=https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&channel=Stable&version=VS18&source=VSLandingPage&cid=2500&passive=false"

:FIND_INSTALLER
set "InstallerPath="
for /f "delims=" %%I in ('dir /b /a-d /o-d "%USERPROFILE%\Downloads\VisualStudioSetup*.exe" "%USERPROFILE%\Downloads\vs_*.exe" 2^>nul') do (
    set "InstallerPath=%USERPROFILE%\Downloads\%%I"
    goto VERIFICATION
)

:VERIFICATION
cls
echo ======================================================
echo  UPDATE VISUAL STUDIO COMMUNITY 2026 LAYOUT
echo ======================================================
echo Lokasi Layout : "%LayoutPath%"
echo Lokasi Config : "%ConfigFile%"
echo.
if defined InstallerPath (
    echo [OK] Installer DITEMUKAN:
    echo "%InstallerPath%"
) else (
    echo [!] Installer BELUM DITEMUKAN di folder Downloads.
)
echo.
echo Pilihan Aksi:
if defined InstallerPath echo [Y] Lanjut   - Mulai proses update menggunakan installer di atas!
echo [D] Download - Buka link otomatis, dan PAUSE sampai download selesai.
echo [N] Batal    - Keluar dari program.
echo ======================================================
set /p Confirmation="Masukkan pilihan (Y/D/N): "

if /i "%Confirmation%"=="Y" if defined InstallerPath goto UPDATE_PROCESS
if /i "%Confirmation%"=="D" goto DOWNLOAD_PROCESS
if /i "%Confirmation%"=="N" goto CANCEL_PROCESS

goto VERIFICATION

:DOWNLOAD_PROCESS
echo.
echo Membuka link download otomatis di browser...

start "" "%DirectDownloadLink%"
echo.
echo Silakan tunggu sampai proses download di browser selesai 100%%.
echo Jika download sudah selesai, tekan tombol apa saja di keyboard...
pause >nul

goto FIND_INSTALLER

:CANCEL_PROCESS
echo.
echo Proses dibatalkan.
timeout /t 3 >nul
exit /b

:UPDATE_PROCESS
echo.
echo ======================================================
echo  PROSES 1: MENGUPDATE LAYOUT ^& KOMPONEN
echo ======================================================
if not exist "%ConfigFile%" (
    echo [ERROR] File Custom.vsconfig tidak ditemukan di folder layout!
    pause
    goto VERIFICATION
)

echo Membaca daftar komponen dari Custom.vsconfig...
echo SELAMA PROSES BERJALAN, HARAP JANGAN DITUTUP CONSOLE INI
echo KARENA PROSES PEMBERSIHAN AKAN OTOMATIS BERJALAN SETELAH UPDATE SELESAI
echo 
"%InstallerPath%" --layout "%LayoutPath%" --config "%ConfigFile%"
echo Update selesai.

echo.
echo ======================================================
echo  PROSES 2: MEMBERSIHKAN FILE VERSI LAMA
echo ======================================================
if not exist "%LayoutPath%\Archive" (
    echo Folder Archive belum ada. Tidak ada file usang.
    goto DONE
)

for /d %%D in ("%LayoutPath%\Archive\*") do (
    if exist "%%D\Catalog.json" (
        echo.
        echo [Membersihkan file usang di: %%D]
        "%InstallerPath%" --layout "%LayoutPath%" --clean "%%D\Catalog.json"
        
        echo Menghapus sisa folder...
        rmdir /s /q "%%D"
    )
)

:DONE
echo.
echo ======================================================
echo  SELESAI! LAYOUT SUDAH TERUPDATE DAN BERSIH.
echo ======================================================
echo.
set /p DeleteInstaller="Apakah Anda ingin langsung menghapus installer dari folder Downloads? (Y/N): "
if /i "%DeleteInstaller%"=="Y" (
    del /q "%InstallerPath%"
    echo File installer berhasil dihapus.
)

pause
