Write-Host " WINDOWS 10 ACCESSORIES REMOVAL" -ForegroundColor Cyan

# 1. CHARACTER MAP
Write-Host "`n[1/8] Character Map" -ForegroundColor Yellow

$charMap = "$env:WINDIR\System32\charmap.exe"

if (Test-Path $charMap) {
    Write-Host "Cannot uninstall, this is system app." -ForegroundColor DarkYellow
}
else {
    Write-Host "Character Map not found." -ForegroundColor DarkGray
}

# 2. INTERNET EXPLORER
Write-Host "`n[2/8] Internet Explorer" -ForegroundColor Yellow

$ie = Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "Browser.InternetExplorer*" -and
        $_.State -eq "Installed"
    }

if ($ie) {
    foreach ($item in $ie) {
        Write-Host "Deleting $($item.Name)..." -ForegroundColor Cyan
        Remove-WindowsCapability -Online -Name $item.Name -ErrorAction SilentlyContinue
    }
    Write-Host "Internet Explorer uninstalled." -ForegroundColor Green
}
else {
    Write-Host "Internet Explorer not found, skip." -ForegroundColor DarkGray
}

# 3. MATH INPUT PANEL / MATH RECOGNIZER
Write-Host "`n[3/8] Math Input Panel / Math Recognizer" -ForegroundColor Yellow

$math = Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "MathRecognizer*" -and
        $_.State -eq "Installed"
    }

if ($math) {
    foreach ($item in $math) {
        Write-Host "Deleting $($item.Name)..." -ForegroundColor Cyan
        Remove-WindowsCapability -Online -Name $item.Name -ErrorAction SilentlyContinue
    }
    Write-Host "Math Recognizer uninstalled." -ForegroundColor Green
}
else {
    Write-Host "Math Recognizer not found." -ForegroundColor DarkGray
}

# 4. QUICK ASSIST
Write-Host "`n[4/8] Quick Assist" -ForegroundColor Yellow

$qaCapability = Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "*QuickAssist*" -and
        $_.State -eq "Installed"
    }

if ($qaCapability) {
    foreach ($item in $qaCapability) {
        Write-Host "Deleting Capability $($item.Name)..." -ForegroundColor Cyan
        Remove-WindowsCapability -Online -Name $item.Name -ErrorAction SilentlyContinue
    }
}

$quickAssistPackages = Get-AppxPackage -AllUsers -Name "*QuickAssist*" -ErrorAction SilentlyContinue
if ($quickAssistPackages) {
    foreach ($pkg in $quickAssistPackages) {
        Write-Host "Deleting Appx Package $($pkg.Name)..." -ForegroundColor Cyan
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageFullName -ErrorAction SilentlyContinue
    }
    Write-Host "Quick Assist uninstalled." -ForegroundColor Green
} else {
    Write-Host "Quick Assist not found or already uninstalled." -ForegroundColor DarkGray
}

# 5. STEPS RECORDER
Write-Host "`n[5/8] Steps Recorder" -ForegroundColor Yellow

$steps = Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "App.StepsRecorder*" -and
        $_.State -eq "Installed"
    }

if ($steps) {
    foreach ($item in $steps) {
        Write-Host "Deleting $($item.Name)..." -ForegroundColor Cyan
        Remove-WindowsCapability -Online -Name $item.Name -ErrorAction SilentlyContinue
    }
    Write-Host "Steps Recorder uninstalled." -ForegroundColor Green
}
else {
    Write-Host "Steps Recorder not found." -ForegroundColor DarkGray
}

# 6. WINDOWS FAX AND SCAN
Write-Host "`n[6/8] Windows Fax and Scan" -ForegroundColor Yellow

$fax = Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "Print.Fax.Scan*" -and
        $_.State -eq "Installed"
    }

if ($fax) {
    foreach ($item in $fax) {
        Write-Host "Deleting $($item.Name)..." -Registry-Error -ErrorAction SilentlyContinue
        Remove-WindowsCapability -Online -Name $item.Name -ErrorAction SilentlyContinue
    }
    Write-Host "Windows Fax and Scan uninstalled." -ForegroundColor Green
}
else {
    Write-Host "Windows Fax and Scan not found." -ForegroundColor DarkGray
}

# 7. WINDOWS MEDIA PLAYER
Write-Host "`n[7/8] Windows Media Player" -ForegroundColor Yellow

$wmp = Get-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -ErrorAction SilentlyContinue

if ($wmp -and $wmp.State -eq "Enabled") {
    Write-Host "Disabling Windows Media Player..." -ForegroundColor Cyan

    Disable-WindowsOptionalFeature `
        -Online `
        -FeatureName "WindowsMediaPlayer" `
        -Remove `
        -NoRestart `
        -ErrorAction SilentlyContinue

    Write-Host "Windows Media Player disabled." -ForegroundColor Green
}
else {
    Write-Host "Windows Media Player already disabled" -ForegroundColor DarkGray
}

# 8. WORDPAD
Write-Host "`n[8/8] WordPad" -ForegroundColor Yellow

$wordpadCaps = Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "*WordPad*" -and
        $_.State -eq "Installed"
    }

if ($wordpadCaps) {
    foreach ($cap in $wordpadCaps) {
        Write-Host "Removing capability $($cap.Name)..." -ForegroundColor Cyan
        Remove-WindowsCapability -Online -Name $cap.Name -ErrorAction SilentlyContinue
    }
}

$wordpadFiles = @(
    "$env:ProgramFiles\Windows NT\Accessories\wordpad.exe",
    "$env:ProgramFiles\Windows NT\Accessories\write.exe",
    "$env:ProgramFiles\Windows NT\Accessories\wordpadfilter.dll",
    "$env:ProgramFiles(x86)\Windows NT\Accessories\wordpad.exe",
    "$env:ProgramFiles(x86)\Windows NT\Accessories\write.exe"
)

$found = $false

foreach ($file in $wordpadFiles) {
    if (Test-Path $file) {
        $found = $true
        Takeown.exe /f $file /a 2>&1 | Out-Null
        icacls.exe $file /grant "Administrators:F" 2>&1 | Out-Null
        
        Write-Host "Deleting: $file" -ForegroundColor Cyan
        Remove-Item $file -Force -ErrorAction SilentlyContinue
    }
}

if ($wordpadCaps -or $found) {
    Write-Host "WordPad uninstalled." -ForegroundColor Green
}
else {
    Write-Host "WordPad not found." -ForegroundColor DarkGray
}

Write-Host "`n==============================================" -ForegroundColor Cyan
Write-Host " Done" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan

Write-Host "`nRestart needed." -ForegroundColor Yellow

$restart = Read-Host "Restart now? (Y/N)"

if ($restart -match "^[Yy]$") {
    Restart-Computer
}
