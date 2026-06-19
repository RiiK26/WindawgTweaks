@echo off
title Update and Cleanup Visual Studio Layout

set "InstallerPath=%USERPROFILE%\Downloads\VisualStudioSetup.exe"
set "LayoutPath=D:\VS_Offline"
set "ConfigFile=D:\VS_Offline\Custom.vsconfig"

:VERIFIKASI
cls
echo ======================================================
echo  PERSIAPAN UPDATE VISUAL STUDIO (DENGAN CONFIG CUSTOM)
echo ======================================================
echo Apakah Anda SUDAH mendownload file VisualStudioSetup.exe TERBARU
echo dan membiarkannya di folder Downloads?
echo "%InstallerPath%"
echo.
echo Pilihan:
echo [Y] Lanjut - File baru siap, mulai proses update!
echo [T] Tahan  - Tunggu sebentar, file belum selesai di-download.
echo [N] Stop   - Batal, keluar dari program.
echo ======================================================
set /p konfirmasi="Masukkan pilihan Anda (Y/T/N): "

if /i "%konfirmasi%"=="Y" goto PROSES_UPDATE
if /i "%konfirmasi%"=="T" goto PROSES_TAHAN
if /i "%konfirmasi%"=="N" goto PROSES_BATAL

goto VERIFIKASI

:PROSES_TAHAN
echo.
echo Silakan download file VisualStudioSetup.exe sekarang.
echo Jika sudah selesai, tekan tombol apa saja untuk kembali...
pause >nul
goto VERIFIKASI

:PROSES_BATAL
echo.
echo Proses dibatalkan oleh pengguna. Keluar dari program...
timeout /t 3 >nul
exit /b

:PROSES_UPDATE
echo.
echo ======================================================
echo  PROSES 1: MENGUPDATE LAYOUT VISUAL STUDIO
echo ======================================================
if not exist "%InstallerPath%" (
    echo [ERROR] File VisualStudioSetup.exe tidak ditemukan di folder Downloads!
    pause
    goto VERIFIKASI
)

if not exist "%ConfigFile%" (
    echo [ERROR] File config tidak ditemukan di "%ConfigFile%"!
    echo Pastikan Anda sudah mengubah nama file config Anda menjadi Custom.vsconfig
    pause
    goto VERIFIKASI
)

echo Membaca daftar komponen baru dari Custom.vsconfig...
echo Memulai proses unduhan paket...
"%InstallerPath%" --layout "%LayoutPath%" --config "%ConfigFile%"
echo Update paket komponen selesai.

echo.
echo ======================================================
echo  PROSES 2: MEMBERSIHKAN FILE VERSI LAMA (CLEANUP)
echo ======================================================
if not exist "%LayoutPath%\Archive" (
    echo Folder Archive belum ada. Tidak ada file usang.
    goto SELESAI
)

for /d %%D in ("%LayoutPath%\Archive\*") do (
    if exist "%%D\Catalog.json" (
        echo.
        echo [Ditemukan file usang di: %%D]
        echo Memulai proses cleanup paket...
        
        "%InstallerPath%" --layout "%LayoutPath%" --clean "%%D\Catalog.json"
        
        echo.
        echo Menghapus sisa folder katalog lama...
        rmdir /s /q "%%D"
        echo Folder %%D berhasil dihapus!
    )
)

:SELESAI
echo.
echo ======================================================
echo  SELESAI! LAYOUT OFFLINE SUDAH TERUPDATE DAN BERSIH.
echo ======================================================
echo.
set /p hapusInstaller="Apakah Anda ingin menghapus VisualStudioSetup.exe dari folder Downloads? (Y/N): "
if /i "%hapusInstaller%"=="Y" (
    del /q "%InstallerPath%"
    echo File installer berhasil dihapus.
)

pause
