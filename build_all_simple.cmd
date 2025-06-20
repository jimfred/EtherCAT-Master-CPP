@echo off
echo ===========================================
echo Building All 3 EtherCAT Master Applications
echo ===========================================
echo.

REM Find MSBuild
set MSBUILD_PATH=""
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
) else (
    echo ERROR: MSBuild not found!
    pause
    exit /b 1
)

echo Found MSBuild at: %MSBUILD_PATH%
echo.

REM Build Application 1: Basic EtherCAT Master (main.cpp)
echo ==========================================
echo Building 1/3: Basic EtherCAT Master
echo ==========================================
%MSBUILD_PATH% "BasicMaster.vcxproj" /p:Configuration=Release /p:Platform=x64 /p:TargetName=EtherCATMaster_Basic /v:minimal

if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: Built EtherCATMaster_Basic.exe
) else (
    echo FAILED: Basic EtherCAT Master build failed
)

echo.

REM Build Application 2: State-Aware EtherCAT Master (EtherCATStateMaster.cpp)
echo ==========================================
echo Building 2/3: State-Aware EtherCAT Master
echo ==========================================

REM Create temporary project for state master
copy "EtherCATMaster.vcxproj" "temp_state.vcxproj" >nul 2>&1
powershell -Command "(Get-Content temp_state.vcxproj) -replace 'main\.cpp', '<!-- main.cpp -->' -replace '<!-- Other source files excluded -->', 'ClCompile Include=\"EtherCATStateMaster.cpp\" /' | Set-Content temp_state.vcxproj"

%MSBUILD_PATH% "temp_state.vcxproj" /p:Configuration=Release /p:Platform=x64 /p:TargetName=EtherCATMaster_StateAware /v:minimal

if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: Built EtherCATMaster_StateAware.exe
) else (
    echo FAILED: State-Aware EtherCAT Master build failed
)

del "temp_state.vcxproj" >nul 2>&1

echo.

REM Build Application 3: Direct EtherCAT Master Demo (DirectEtherCATMaster.cpp)
echo ==========================================
echo Building 3/3: Direct EtherCAT Master Demo
echo ==========================================

REM Create temporary project for direct master
copy "EtherCATMaster.vcxproj" "temp_direct.vcxproj" >nul 2>&1
powershell -Command "(Get-Content temp_direct.vcxproj) -replace 'main\.cpp', '<!-- main.cpp -->' -replace '<!-- Other source files excluded -->', 'ClCompile Include=\"DirectEtherCATMaster.cpp\" /' -replace 'TcAdsDll\.lib', 'TcAdsDll.lib;iphlpapi.lib;ws2_32.lib' | Set-Content temp_direct.vcxproj"

%MSBUILD_PATH% "temp_direct.vcxproj" /p:Configuration=Release /p:Platform=x64 /p:TargetName=EtherCATMaster_Direct /v:minimal

if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: Built EtherCATMaster_Direct.exe
) else (
    echo FAILED: Direct EtherCAT Master build failed
)

del "temp_direct.vcxproj" >nul 2>&1

echo.
echo ==========================================
echo BUILD SUMMARY
echo ==========================================

echo Output directory: x64\Release\
echo.

if exist "x64\Release\*.exe" (
    echo Built applications:
    dir "x64\Release\*.exe" /b
    echo.
    
    echo Application Descriptions:
    echo.
    echo 1. EtherCATMaster_Basic.exe      - Basic EtherCAT Master
    echo    - Connects via ADS to TwinCAT
    echo    - Monitors system status
    echo    - Does NOT control EtherCAT states
    echo.
    echo 2. EtherCATMaster_StateAware.exe - State-Aware EtherCAT Master  
    echo    - All features of Basic PLUS:
    echo    - Can start/stop TwinCAT
    echo    - CAN get EtherCAT to OP mode
    echo    - Interactive state control
    echo.
    echo 3. EtherCATMaster_Direct.exe     - Direct EtherCAT Demo
    echo    - Network adapter enumeration
    echo    - Educational example
    echo    - Shows direct EtherCAT concepts
    echo.
    
    echo To run any application:
    echo   cd x64\Release
    echo   EtherCATMaster_Basic.exe
    echo   EtherCATMaster_StateAware.exe  
    echo   EtherCATMaster_Direct.exe
    echo.
    
) else (
    echo ERROR: No executables were built successfully!
)

echo Press any key to continue...
pause >nul

