@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title RuoYi-Vue-Plus All-in-One Launcher

set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-25.0.3.9-hotspot"
set "MAVEN_HOME=C:\Program Files\apache-maven-3.9.16"
set "PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PATH%"

echo ============================================
echo   RuoYi-Vue-Plus All-in-One Launcher
echo ============================================
echo.

echo [1/4] Checking Java...
"%JAVA_HOME%\bin\java.exe" -version 2>&1 | findstr "version" >nul
if errorlevel 1 (
    echo [ERROR] Java not found! Please check JAVA_HOME.
    pause
    exit /b 1
)
echo [OK] Java ready.

echo.
echo [2/4] Checking Redis...
"C:\Program Files\Redis\redis-cli.exe" -a ruoyi123 ping >nul 2>&1
if errorlevel 1 (
    echo [WARN] Redis not accessible with password, trying no-password...
    "C:\Program Files\Redis\redis-cli.exe" ping >nul 2>&1
    if not errorlevel 1 (
        echo [INFO] Setting Redis password...
        "C:\Program Files\Redis\redis-cli.exe" CONFIG SET requirepass "ruoyi123" >nul 2>&1
    ) else (
        echo [WARN] Redis not running, trying to start service...
        net start Redis >nul 2>&1
        timeout /t 3 >nul
    )
)
echo [OK] Redis ready.

echo.
echo [3/4] Starting backend server...
if not exist "D:\projects\RuoYi-Vue-Plus\ruoyi-admin\target\ruoyi-admin.jar" (
    echo [ERROR] ruoyi-admin.jar not found! Run build first.
    pause
    exit /b 1
)
for %%F in ("D:\projects\RuoYi-Vue-Plus\ruoyi-admin\target\*.jar") do set "JAR=%%~fF"
start "RuoYi-Vue-Plus Backend" "%JAVA_HOME%\bin\java.exe" -jar "%JAR%"
echo [OK] Backend starting on port 8080 (wait ~60s)...

echo.
echo [4/4] Starting frontend dev server...
if not exist "D:\projects\plus-ui\node_modules" (
    echo [WARN] node_modules not found, installing...
    cd /d "D:\projects\plus-ui"
    call npm install --registry=https://registry.npmmirror.com
    if errorlevel 1 (
        echo [ERROR] npm install failed!
        pause
        exit /b 1
    )
)
start "Plus-UI Frontend" cmd /c "cd /d D:\projects\plus-ui && npm run dev"
echo [OK] Frontend starting on port 8081...

echo.
echo ============================================
echo   All services launched!
echo   Backend:  http://localhost:8080
echo   API Doc:  http://localhost:8080/doc.html
echo   Frontend: http://localhost:8081
echo   Login:    admin / admin123
echo ============================================
echo.
echo Press any key to exit (services will keep running)...
pause >nul