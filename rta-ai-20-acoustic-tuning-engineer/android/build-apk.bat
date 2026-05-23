@echo off
chcp 65001 >nul
title 小白汽车调音 - APK Builder
echo ============================================
echo   小白汽车调音 APK 编译工具
echo ============================================
echo.

:: Check Java
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 Java JDK
    echo 请安装 JDK 17+: https://adoptium.net/download/
    echo 或安装 Android Studio (自带JDK)
    pause
    exit /b 1
)
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do echo [OK] Java %%v

:: Find Android SDK
if exist "%ANDROID_HOME%" set "SDK=%ANDROID_HOME%"
if exist "%ANDROID_SDK_ROOT%" set "SDK=%ANDROID_SDK_ROOT%"
if exist "%LOCALAPPDATA%\Android\Sdk" set "SDK=%LOCALAPPDATA%\Android\Sdk"
if exist "C:\Android\Sdk" set "SDK=C:\Android\Sdk"

if not defined SDK (
    echo [错误] 未找到 Android SDK
    echo 请安装 Android Studio 或设置 ANDROID_HOME 环境变量
    echo 下载: https://developer.android.com/studio
    pause
    exit /b 1
)
echo [OK] Android SDK: %SDK%

:: Create/update local.properties
echo sdk.dir=%SDK:\=/%> local.properties

:: Check gradle-wrapper.jar validity
set JAR_OK=0
if exist "gradle\wrapper\gradle-wrapper.jar" (
    for %%A in ("gradle\wrapper\gradle-wrapper.jar") do set JAR_SIZE=%%~zA
    if !JAR_SIZE! GTR 1000 set JAR_OK=1
)
if !JAR_OK!==0 (
    echo.
    echo [下载] 正在下载 Gradle Wrapper...
    del "gradle\wrapper\gradle-wrapper.jar" 2>nul
    powershell -Command "try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.5.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'gradle\wrapper\gradle-wrapper.jar' } catch {}" 2>nul
    if not exist "gradle\wrapper\gradle-wrapper.jar" (
        echo [警告] 无法下载gradle-wrapper.jar，尝试使用gradle命令...
        where gradle >nul 2>nul
        if %ERRORLEVEL% NEQ 0 (
            echo [错误] 请手动下载: https://services.gradle.org/distributions/gradle-8.5-bin.zip
            echo 解压后将 gradle-8.5/lib/gradle-wrapper-*.jar 复制到 gradle\wrapper\gradle-wrapper.jar
            pause
            exit /b 1
        )
    )
)
echo [OK] Gradle 就绪

:: Build
echo.
echo ============================================
echo   正在编译 APK (可能需要几分钟)...
echo ============================================

:: Use gradle command directly, fallback to gradlew
where gradle >nul 2>nul
if %ERRORLEVEL%==0 (
    gradle assembleDebug
) else (
    call gradlew.bat assembleDebug
)

if exist "app\build\outputs\apk\debug\app-debug.apk" (
    copy /y "app\build\outputs\apk\debug\app-debug.apk" "..\小白汽车调音.apk" >nul
    echo.
    echo ============================================
    echo   ✅ 编译成功!
    echo   APK: ..\小白汽车调音.apk
    for %%A in ("..\小白汽车调音.apk") do echo   大小: %%~zA bytes
    echo ============================================
    echo.
    echo 将APK传到手机安装即可使用
) else (
    echo.
    echo ============================================
    echo   ❌ 编译失败，请检查上方错误信息
    echo ============================================
    echo 常见问题:
    echo 1. Android SDK 版本不匹配 - 安装 Android 34 SDK
    echo 2. JDK 版本过低 - 需要 JDK 17+
    echo 3. 网络问题 - gradle-wrapper.jar 下载失败
)
pause
