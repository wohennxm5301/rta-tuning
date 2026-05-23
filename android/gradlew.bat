@echo off
set APP_HOME=%~dp0
set JAR=%APP_HOME%gradle\wrapper\gradle-wrapper.jar
if not exist "%JAR%" (
    echo >> gradle-wrapper.jar not found. Please run build-apk.bat first.
    echo >> Or install Gradle 8.5 manually.
    exit /b 1
)
java -jar "%JAR%" %*
