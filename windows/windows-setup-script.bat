@echo off
setlocal EnableDelayedExpansion

:: Check for Administrative Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] This script must be run as Administrator to modify Security settings.
    pause
    exit /b
)

:: Disable Real-Time Protection
echo [!] Temporarily disabling Windows Defender Real-Time Monitoring...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"

:: Ensure Scoop is installed
echo [1/3] Checking for Scoop...
where scoop >nul 2>nul
if %errorlevel% neq 0 (
    echo Scoop not found. Installing...
    powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; iwr -useb get.scoop.sh | iex"
)

:: Optional: Add a permanent Exclusion for the Scoop folder
:: This prevents Defender from scanning things Scoop installs in the future.
echo [*] Adding Scoop directory to Defender exclusions...
powershell -Command "Add-MpPreference -ExclusionPath '$env:USERPROFILE\scoop'"

echo [*] Adding buckets...
:: We use 'scoop bucket add' and redirect error output to nul 
:: so it stays clean if the bucket already exists.
scoop bucket add extras >nul 2>&1
scoop bucket add versions >nul 2>&1
echo [ok] Buckets ready.

:: --- CORE INSTALLS ---
echo [*] Installing git and 7zip...
scoop install git 7zip scoop-import
:: To install all apps from the json file you can run scoop import scoop-apps.json (path of the .json file)

:: Prompt for optional install
set /p choice="Do you want to install Neovim? (y/n): "
if /i "%choice%"=="y" (
    scoop install neovim
)

set /p choice="Do you want to install Openvpn community edition? (y/n): "
if /i "%choice%"=="y" (
    scoop install openvpn
)

set /p choice="Do you want to install qbittorrent? (y/n): "
if /i "%choice%"=="y" (
    scoop install qbittorrent
)

set /p choice="Do you want to install Spotify? (y/n): "
if /i "%choice%"=="y" (
    powershell -Command "iex "& { $(iwr -useb 'https://raw.githubusercontent.com/SpotX-Official/SpotX/refs/heads/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -podcasts_off -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify""
)

:: Re-enable Real-Time Protection
echo [!] Re-enabling Windows Defender Real-Time Monitoring...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"

echo.
echo Done!
pause