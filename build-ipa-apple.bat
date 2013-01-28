@echo off

:: AIR application packaging
:: More information:
:: http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_5.html#1035959

del bin\*.apk
del bin\*.ipa
del _deploy\*.apk
del _deploy\*.ipa
del _deploy\apple\*.ipa

:: Path to Flex SDK binaries
set PATH="C:\Program Files (x86)\Java\jdk1.7.0_07\bin";%PATH%
set PATH="C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0 - AIR 3.4 (release)\bin";%PATH%

:: Signature (see 'CreateCertificate.bat')
set CERTIFICATE=certificates\ios\appstore\impulse12.p12
set PROVISIONING_PROFILE=certificates\ios\appstore\impulse12.mobileprovision
set PROFILE_OPTIONS=-provisioning-profile %PROVISIONING_PROFILE%
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERTIFICATE%
if not exist %CERTIFICATE% goto certificate
if not exist %PROVISIONING_PROFILE% goto mobileprovision

:: Output
if not exist _deploy md _deploy
if not exist _deploy\apple md _deploy\apple
set IPA_FILE=_deploy\apple\P4cM4n-Apple.ipa

:: Input
set APP_XML=bin\NotPacman-app.xml
set FILE_OR_DIR=-C bin .

echo Signing AIR setup using certificate %CERTIFICATE%.
rem call adt -package -target ipa-debug-interpreter %PROFILE_OPTIONS% %SIGNING_OPTIONS% %IPA_FILE% %APP_XML% -extdir ext\ios %FILE_OR_DIR%
call adt -package -target ipa-app-store %PROFILE_OPTIONS% %SIGNING_OPTIONS% %IPA_FILE% %APP_XML% -extdir ext\ios %FILE_OR_DIR%
if errorlevel 1 goto failed

echo.
echo AIR ipa setup created.
echo.
goto end

:certificate
echo Certificate not found: %CERTIFICATE%
echo.
goto end

:mobileprovision
echo Provisioning profile not found: %PROVISIONING_PROFILE%
echo.
goto end

:failed
echo AIR setup creation FAILED.
echo.

:end
pause
