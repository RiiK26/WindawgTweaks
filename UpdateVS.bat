@echo off
title Update and Cleanup Visual Studio Layout

:: --- JALUR DINAMIS OTOMATIS ---
:: %USERPROFILE% otomatis mendeteksi "C:\Users\NamaUserSaatIni"
set "InstallerPath=%USERPROFILE%\Downloads\VisualStudioSetup.exe"

:: Ganti dengan lokasi folder layout offline Anda (Pastikan drive/foldernya sama di tiap PC)
set "LayoutPath=D:\VS_Offline"
:: ----------------------------------------

:VERIFIKASI
cls
echo ======================================================
echo  PERSIAPAN UPDATE VISUAL STUDIO
echo ======================================================
echo Apakah Anda SUDAH mendownload file VisualStudioSetup.exe TERBARU
echo dari internet dan file tersebut saat ini berada di:
echo "%InstallerPath%" ?
echo.
echo Pilihan:
echo [Y] Lanjut - File baru sudah siap di folder Downloads, mulai proses update!
echo [T] Tahan  - Tunggu sebentar, file belum selesai di-download.
echo [N] Stop   - Batal, keluar dari program.
echo ======================================================
set /p konfirmasi="Masukkan pilihan Anda (Y/T/N): "

if /i "%konfirmasi%"=="Y" goto PROSES_UPDATE
if /i "%konfirmasi%"=="T" goto PROSES_TAHAN
if /i "%konfirmasi%"=="N" goto PROSES_BATAL

:: Jika user salah input, kembali ke menu verifikasi
goto VERIFIKASI

:PROSES_TAHAN
echo.
echo Silakan download file VisualStudioSetup.exe sekarang dan biarkan di folder Downloads.
echo Jika sudah selesai, tekan tombol apa saja untuk kembali ke menu konfirmasi...
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
:: Mengecek apakah file installer benar-benar ada di folder Downloads
if not exist "%InstallerPath%" (
    echo [ERROR] File VisualStudioSetup.exe tidak ditemukan di folder Downloads!
    echo Silakan pastikan file sudah selesai didownload dan namanya tidak berubah.
    echo Kembali ke menu verifikasi...
    pause
    goto VERIFIKASI
)

echo Memulai update, proses ini akan mengunduh paket terbaru...
"%InstallerPath%" --layout "%LayoutPath%"
echo Update selesai.

echo.
echo ======================================================
echo  PROSES 2: MEMBERSIHKAN FILE VERSI LAMA (CLEANUP)
echo ======================================================
if not exist "%LayoutPath%\Archive" (
    echo Folder Archive belum ada. Tidak ada file lama yang perlu dibersihkan saat ini.
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
:: Opsional: Menghapus bootstrapper dari folder Downloads agar tidak menumpuk
echo.
set /p hapusInstaller="Apakah Anda ingin menghapus VisualStudioSetup.exe dari folder Downloads? (Y/N): "
if /i "%hapusInstaller%"=="Y" (
    del /q "%InstallerPath%"
    echo File installer berhasil dihapus dari Downloads.
)

pause
