@echo off
setlocal EnableDelayedExpansion

echo ===========================================
echo Building EtherCAT Master C++ Application
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

REM Find MSBuild
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

REM Try .NET Framework MSBuild as fallback
if %MSBUILD_PATH%=="" (
    if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
        set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    ) else if exist "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" (
        set MSBUILD_PATH="C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
    )
)

if %MSBUILD_PATH%=="" (
    echo ERROR: MSBuild not found!
    echo Please install Visual Studio 2019 or 2022 with C++ development tools.
    echo Alternatively, you can install Visual Studio Build Tools.
    echo.
    echo You can also try building with CMake:
    echo   mkdir build ^&^& cd build
    echo   cmake ..
    echo   cmake --build . --config %BUILD_CONFIG%
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
    echo Cleaning previous build...
    %MSBUILD_PATH% "EtherCATMaster.vcxproj" /t:Clean /p:Configuration=%BUILD_CONFIG% /p:Platform=%BUILD_PLATFORM% /v:minimal
    echo.
)

REM Build the project
echo Building project...
%MSBUILD_PATH% "EtherCATMaster.vcxproj" /t:Build /p:Configuration=%BUILD_CONFIG% /p:Platform=%BUILD_PLATFORM% /v:minimal /m

if !ERRORLEVEL! EQU 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Output file: %BUILD_PLATFORM%\%BUILD_CONFIG%\EtherCATMaster.exe
    echo.
    echo To run the application:
    echo   cd %BUILD_PLATFORM%\%BUILD_CONFIG%
    echo   EtherCATMaster.exe
    echo.
    echo Make sure TwinCAT3 is running before executing!
) else (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo.
    echo Common issues:
    echo 1. TwinCAT3 SDK not found - check installation
    echo 2. Missing Visual Studio C++ tools
    echo 3. Incorrect platform/configuration
    echo.
    echo Try:
    echo   build.cmd clean debug x64
    echo   build.cmd release x86
)

echo.
echo Usage: build.cmd [clean] [debug^|release] [x86^|x64]
echo   clean    - Clean before building
echo   debug    - Build Debug configuration (default: Release)
echo   release  - Build Release configuration
echo   x86      - Build for 32-bit platform
echo   x64      - Build for 64-bit platform (default)
echo.

pause

