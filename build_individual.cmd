@echo off
setlocal EnableDelayedExpansion

echo ===========================================
echo EtherCAT Master - Individual Application Builder
echo ===========================================

if "%1"=="" (
    echo Usage: build_individual.cmd [app] [options]
    echo.
    echo Applications:
    echo   basic      - Basic EtherCAT Master (main.cpp)
    echo   state      - State-Aware EtherCAT Master (EtherCATStateMaster.cpp)  
    echo   direct     - Direct EtherCAT Master Demo (DirectEtherCATMaster.cpp)
    echo   all        - Build all three applications
    echo.
    echo Options:
    echo   debug      - Build Debug configuration
    echo   release    - Build Release configuration (default)
    echo   x86        - Build for 32-bit platform
    echo   x64        - Build for 64-bit platform (default)
    echo   clean      - Clean before building
    echo.
    echo Examples:
    echo   build_individual.cmd basic
    echo   build_individual.cmd state debug
    echo   build_individual.cmd all clean release x64
    pause
    exit /b 1
)

set APP_TYPE=%1
shift

REM Set defaults
set BUILD_CONFIG=Release
set BUILD_PLATFORM=x64
set CLEAN_BUILD=

REM Parse remaining arguments
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

echo Building: %APP_TYPE%
echo Configuration: %BUILD_CONFIG%
echo Platform: %BUILD_PLATFORM%
echo.

REM Find MSBuild
call :find_msbuild
if "%MSBUILD_PATH%"=="" (
    echo ERROR: MSBuild not found!
    pause
    exit /b 1
)

echo Found MSBuild at: %MSBUILD_PATH%
echo.

REM Build based on application type
if "%APP_TYPE%"=="basic" (
    call :build_basic
) else if "%APP_TYPE%"=="state" (
    call :build_state
) else if "%APP_TYPE%"=="direct" (
    call :build_direct
) else if "%APP_TYPE%"=="all" (
    call :build_basic
    call :build_state
    call :build_direct
) else (
    echo ERROR: Unknown application type: %APP_TYPE%
    echo Use: basic, state, direct, or all
    pause
    exit /b 1
)

echo.
echo ==========================================
echo BUILD COMPLETE
echo ==========================================
echo Output directory: %BUILD_PLATFORM%\%BUILD_CONFIG%\
if exist "%BUILD_PLATFORM%\%BUILD_CONFIG%\*.exe" (
    echo.
    echo Built executables:
    dir "%BUILD_PLATFORM%\%BUILD_CONFIG%\*.exe" /b
)
echo.
pause
exit /b 0

REM ==========================================
REM SUBROUTINES
REM ==========================================

:find_msbuild
set MSBUILD_PATH=""
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
)
exit /b 0

:build_basic
echo Building Basic EtherCAT Master...
cl.exe /nologo ^
    /I"C:\TwinCAT\AdsApi\TcAdsDll\Include" ^
    /I"C:\TwinCAT\3.1\SDK\Include" ^
    main.cpp ^
    /link ^
    /LIBPATH:"C:\TwinCAT\AdsApi\TcAdsDll\x64\lib" ^
    TcAdsDll.lib ^
    /OUT:"%BUILD_PLATFORM%\%BUILD_CONFIG%\EtherCATMaster_Basic.exe"

if !ERRORLEVEL! EQU 0 (
    echo SUCCESS: Built EtherCATMaster_Basic.exe
) else (
    echo FAILED: Basic EtherCAT Master build failed
)
exit /b 0

:build_state  
echo Building State-Aware EtherCAT Master...
cl.exe /nologo ^
    /I"C:\TwinCAT\AdsApi\TcAdsDll\Include" ^
    /I"C:\TwinCAT\3.1\SDK\Include" ^
    EtherCATStateMaster.cpp ^
    /link ^
    /LIBPATH:"C:\TwinCAT\AdsApi\TcAdsDll\x64\lib" ^
    TcAdsDll.lib ^
    /OUT:"%BUILD_PLATFORM%\%BUILD_CONFIG%\EtherCATMaster_StateAware.exe"

if !ERRORLEVEL! EQU 0 (
    echo SUCCESS: Built EtherCATMaster_StateAware.exe
) else (
    echo FAILED: State-Aware EtherCAT Master build failed
)
exit /b 0

:build_direct
echo Building Direct EtherCAT Master Demo...
cl.exe /nologo ^
    /I"C:\TwinCAT\AdsApi\TcAdsDll\Include" ^
    /I"C:\TwinCAT\3.1\SDK\Include" ^
    DirectEtherCATMaster.cpp ^
    /link ^
    /LIBPATH:"C:\TwinCAT\AdsApi\TcAdsDll\x64\lib" ^
    TcAdsDll.lib iphlpapi.lib ws2_32.lib ^
    /OUT:"%BUILD_PLATFORM%\%BUILD_CONFIG%\EtherCATMaster_Direct.exe"

if !ERRORLEVEL! EQU 0 (
    echo SUCCESS: Built EtherCATMaster_Direct.exe
) else (
    echo FAILED: Direct EtherCAT Master build failed
)
exit /b 0

