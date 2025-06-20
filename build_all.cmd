@echo off
setlocal EnableDelayedExpansion

echo ===========================================
echo Building All EtherCAT Master Applications
echo ===========================================

REM Check if project file exists
if not exist "EtherCATMaster.vcxproj" (
    echo ERROR: Project file not found!
    echo Make sure you're running this from the project directory.
    pause
    exit /b 1
)

REM Set default build configuration
set BUILD_CONFIG=Release
set BUILD_PLATFORM=x64

REM Parse command line arguments
:parse_args
if "%1"=="debug" (
    set BUILD_CONFIG=Debug
    shift
    goto parse_args
)
if "%1"=="release" (
    set BUILD_CONFIG=Release
    shift
    goto parse_args
)
if "%1"=="x86" (
    set BUILD_PLATFORM=Win32
    shift
    goto parse_args
)
if "%1"=="x64" (
    set BUILD_PLATFORM=x64
    shift
    goto parse_args
)
if "%1"=="clean" (
    set CLEAN_BUILD=1
    shift
    goto parse_args
)
if not "%1"=="" (
    shift
    goto parse_args
)

echo Build Configuration: %BUILD_CONFIG%
echo Build Platform: %BUILD_PLATFORM%
echo.

REM Find MSBuild (same logic as original build.cmd)
set MSBUILD_PATH=""

REM Try Visual Studio 2022 paths
if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
)

REM Try Visual Studio 2019 paths if 2022 not found
if %MSBUILD_PATH%=="" (
    if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
        set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
        set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
        set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    )
)

if %MSBUILD_PATH%=="" (
    echo ERROR: MSBuild not found!
    echo Please install Visual Studio 2019 or 2022 with C++ development tools.
    pause
    exit /b 1
)

echo Found MSBuild at: %MSBUILD_PATH%
echo.

REM Check TwinCAT installation
if not exist "C:\TwinCAT\AdsApi\TcAdsDll\Include\TcAdsDef.h" (
    echo WARNING: TwinCAT ADS SDK not found at C:\TwinCAT\AdsApi\
    echo Please ensure TwinCAT3 is properly installed.
    echo Build may fail if SDK paths are incorrect.
    echo.
)

REM Clean build if requested
if defined CLEAN_BUILD (
    echo Cleaning previous builds...
    if exist "%BUILD_PLATFORM%" rmdir /s /q "%BUILD_PLATFORM%"
    echo.
)

REM Create output directory structure
mkdir "%BUILD_PLATFORM%\%BUILD_CONFIG%" 2>nul

echo ==========================================
echo Building Application 1: Basic EtherCAT Master
echo ==========================================

REM Compile main.cpp (Basic EtherCAT Master)
%MSBUILD_PATH% /nologo ^
    /p:Configuration=%BUILD_CONFIG% ^
    /p:Platform=%BUILD_PLATFORM% ^
    /p:OutputPath=%BUILD_PLATFORM%\%BUILD_CONFIG%\ ^
    /p:TargetName=EtherCATMaster_Basic ^
    /p:ClCompileExcluded="EtherCATStateMaster.cpp;DirectEtherCATMaster.cpp" ^
    /v:minimal

if !ERRORLEVEL! NEQ 0 (
    echo FAILED to build Basic EtherCAT Master
    set BUILD_ERRORS=1
) else (
    echo SUCCESS: Built EtherCATMaster_Basic.exe
)

echo.
echo ==========================================
echo Building Application 2: State-Aware EtherCAT Master  
echo ==========================================

REM Create temporary project file for EtherCATStateMaster
copy "EtherCATMaster.vcxproj" "temp_state.vcxproj" >nul
powershell -Command "(Get-Content temp_state.vcxproj) -replace 'main\.cpp', 'EtherCATStateMaster.cpp' -replace 'DirectEtherCATMaster\.cpp', '<!-- DirectEtherCATMaster.cpp -->' | Set-Content temp_state.vcxproj"

%MSBUILD_PATH% "temp_state.vcxproj" /nologo ^
    /p:Configuration=%BUILD_CONFIG% ^
    /p:Platform=%BUILD_PLATFORM% ^
    /p:OutputPath=%BUILD_PLATFORM%\%BUILD_CONFIG%\ ^
    /p:TargetName=EtherCATMaster_StateAware ^
    /v:minimal

if !ERRORLEVEL! NEQ 0 (
    echo FAILED to build State-Aware EtherCAT Master
    set BUILD_ERRORS=1
) else (
    echo SUCCESS: Built EtherCATMaster_StateAware.exe
)

del "temp_state.vcxproj" 2>nul

echo.
echo ==========================================
echo Building Application 3: Direct EtherCAT Master Demo
echo ==========================================

REM Create temporary project file for DirectEtherCATMaster
copy "EtherCATMaster.vcxproj" "temp_direct.vcxproj" >nul
powershell -Command "(Get-Content temp_direct.vcxproj) -replace 'main\.cpp', 'DirectEtherCATMaster.cpp' -replace 'EtherCATStateMaster\.cpp', '<!-- EtherCATStateMaster.cpp -->' | Set-Content temp_direct.vcxproj"

%MSBUILD_PATH% "temp_direct.vcxproj" /nologo ^
    /p:Configuration=%BUILD_CONFIG% ^
    /p:Platform=%BUILD_PLATFORM% ^
    /p:OutputPath=%BUILD_PLATFORM%\%BUILD_CONFIG%\ ^
    /p:TargetName=EtherCATMaster_Direct ^
    /p:AdditionalDependencies="TcAdsDll.lib;iphlpapi.lib;ws2_32.lib;kernel32.lib;user32.lib;gdi32.lib;winspool.lib;shell32.lib;ole32.lib;oleaut32.lib;uuid.lib;comdlg32.lib;advapi32.lib" ^
    /v:minimal

if !ERRORLEVEL! NEQ 0 (
    echo FAILED to build Direct EtherCAT Master Demo
    set BUILD_ERRORS=1
) else (
    echo SUCCESS: Built EtherCATMaster_Direct.exe
)

del "temp_direct.vcxproj" 2>nul

echo.
echo ==========================================
echo BUILD SUMMARY
echo ==========================================

if defined BUILD_ERRORS (
    echo Some builds failed. Check error messages above.
    echo.
) else (
    echo ALL BUILDS SUCCESSFUL!
    echo.
)

echo Output directory: %BUILD_PLATFORM%\%BUILD_CONFIG%\
echo.
echo Built applications:
dir "%BUILD_PLATFORM%\%BUILD_CONFIG%\*.exe" 2>nul

echo.
echo Application Descriptions:
echo 1. EtherCATMaster_Basic.exe      - Basic ADS connection and monitoring
echo 2. EtherCATMaster_StateAware.exe - Can control TwinCAT states and get to OP mode
echo 3. EtherCATMaster_Direct.exe     - Network adapter enumeration demo
echo.

echo To run an application:
echo   cd %BUILD_PLATFORM%\%BUILD_CONFIG%
echo   EtherCATMaster_Basic.exe
echo   EtherCATMaster_StateAware.exe
echo   EtherCATMaster_Direct.exe
echo.

echo Usage: build_all.cmd [clean] [debug^|release] [x86^|x64]
echo   clean    - Clean before building
echo   debug    - Build Debug configuration
echo   release  - Build Release configuration (default)
echo   x86      - Build for 32-bit platform  
echo   x64      - Build for 64-bit platform (default)
echo.

pause

