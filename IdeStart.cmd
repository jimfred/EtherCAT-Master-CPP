@echo off
echo ===========================================
echo Starting Visual Studio IDE for EtherCAT Master
echo ===========================================

REM Check if project file exists
if not exist "EtherCATMaster.vcxproj" (
    echo ERROR: Project file not found!
    echo Make sure you're running this from the project directory.
    pause
    exit /b 1
)

echo Opening Visual Studio with EtherCATMaster project...

REM Try to find Visual Studio in common locations
set VS2022_PATH="C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
set VS2022_COMMUNITY_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
set VS2019_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"
set VS2019_COMMUNITY_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"

REM Check for Visual Studio 2022 Professional
if exist %VS2022_PATH% (
    echo Found Visual Studio 2022 Professional
    start "" %VS2022_PATH% "EtherCATMaster.vcxproj"
    goto :end
)

REM Check for Visual Studio 2022 Community
if exist %VS2022_COMMUNITY_PATH% (
    echo Found Visual Studio 2022 Community
    start "" %VS2022_COMMUNITY_PATH% "EtherCATMaster.vcxproj"
    goto :end
)

REM Check for Visual Studio 2019 Professional
if exist %VS2019_PATH% (
    echo Found Visual Studio 2019 Professional
    start "" %VS2019_PATH% "EtherCATMaster.vcxproj"
    goto :end
)

REM Check for Visual Studio 2019 Community
if exist %VS2019_COMMUNITY_PATH% (
    echo Found Visual Studio 2019 Community
    start "" %VS2019_COMMUNITY_PATH% "EtherCATMaster.vcxproj"
    goto :end
)

REM Try using default Windows association
echo Visual Studio not found in standard locations.
echo Trying to open with default application...
start "" "EtherCATMaster.vcxproj"

:end
echo IDE startup command completed.
echo If Visual Studio didn't open, you may need to:
echo 1. Install Visual Studio 2019 or 2022
echo 2. Modify the paths in this script
echo 3. Manually open the .vcxproj file
pause

