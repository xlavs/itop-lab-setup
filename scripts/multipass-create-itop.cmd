@echo off
REM ------------------------------------------------------------------------------
REM scripts\multipass-create-itop.cmd - Create 'itop' VM via 
REM Multipass with project folder mounted to /workplace in the `itop` VM.
REM ------------------------------------------------------------------------------
setlocal enabledelayedexpansion

REM Detect project root from script location
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
for %%F in ("%PROJECT_ROOT%") do set WORKSPACE_WIN=%%~fF

REM Set default VM name and mount paths
set VM_NAME=itop
set LAB_WORKSPACE=/workspace

REM Check if Multipass is installed
where multipass >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Multipass CLI not found in PATH!
    echo [INFO] Please install it from:
    echo        https://canonical.com/multipass/download/windows
    echo.
    pause
    exit /b 1
)

REM Check Multipass mount permission
for /f "tokens=* usebackq" %%M in (`multipass get local.privileged-mounts 2^>nul`) do set PRIV_MOUNT=%%M

if /I not "%PRIV_MOUNT%"=="true" (
    echo [ERROR] Multipass setting 'local.privileged-mounts' is not enabled.
    echo [INFO] You need to run this command before mounts will work:
    echo.
    echo        multipass set local.privileged-mounts=true
    echo.
    pause
    exit /b 1
)

REM Launch VM if not running
echo [INFO] Ensuring VM '!VM_NAME!' is running...
multipass info !VM_NAME! --format json >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo [INFO] Launching '!VM_NAME!' with docker stack...
  multipass launch docker ^
  --name !VM_NAME! ^
  --cpus 4 --memory 8G --disk 50G ^
  --cloud-init config\cloud-init\itop.yaml
)

REM Mount workspace (safe to re-run)
echo [INFO] Mounting project folder %WORKSPACE_WIN%:!LAB_WORKSPACE! ...
multipass mount "%WORKSPACE_WIN%" !VM_NAME!:!LAB_WORKSPACE! 2>nul

REM Show VM status
multipass info !VM_NAME!

