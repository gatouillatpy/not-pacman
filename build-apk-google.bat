@echo off

:: AIR application packaging
:: More information:
:: http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_5.html#1035959

del bin\*.apk
del bin\*.ipa
del _deploy\*.apk
del _deploy\*.ipa
del _deploy\google\*.apk

:: Path to Flex SDK binaries
set PATH="C:\Program Files (x86)\Java\jdk1.7.0_07\bin";%PATH%
set PATH="C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0 - AIR 3.4 (release)\bin";%PATH%

:: Signature (see 'CreateCertificate.bat')
set CERTIFICATE=certificates/android/impulse12.p12
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERTIFICATE%
if not exist %CERTIFICATE% goto certificate

:: Output
if not exist _deploy md _deploy
if not exist _deploy\google md _deploy\google
set APK_FILE=_deploy\google\P4cM4n-Google.apk

:: Input
set APP_XML=bin/NotPacman-app.xml
set FILE_OR_DIR=-C bin .

echo Signing AIR setup using certificate %CERTIFICATE%.
call adt -package -target apk-captive-runtime %SIGNING_OPTIONS% %APK_FILE% %APP_XML% -extdir ext\and %FILE_OR_DIR%
if errorlevel 1 goto failed

echo.
echo AIR apk setup created.
echo.
goto end

:certificate
echo Certificate not found: %CERTIFICATE%
echo.
goto end

:failed
echo AIR setup creation FAILED.
echo.

:end
pause
