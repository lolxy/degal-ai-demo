@echo off
setlocal enabledelayedexpansion
set "PYTHONIOENCODING=utf-8"
set "JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8"
chcp 65001 >nul 2>&1
title RuoYi-Vue-Plus Backend Server

set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-25.0.3.9-hotspot"
set "MVN_CMD=C:\Program Files\apache-maven-3.9.16\bin\mvn.cmd"
set "REDIS_PWD=ruoyi123"
set "MONITOR_PORT=9090"
set "PATH=%JAVA_HOME%\bin;%PATH%"

set "LOG_FILE=backend-startup.log"
echo ============================================ > "%LOG_FILE%"
echo   RuoYi-Vue-Plus Backend Server Launcher >> "%LOG_FILE%"
echo   Time: %date% %time% >> "%LOG_FILE%"
echo ============================================ >> "%LOG_FILE%"

echo ============================================
echo   RuoYi-Vue-Plus Backend Server Launcher
echo ============================================
echo.

echo [1/6] Checking working directory...
cd /d "%~dp0"
if errorlevel 1 (
    echo [ERROR] Failed to change directory to: %~dp0
    echo [ERROR] Failed to change directory >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo [OK] Working directory: %cd%
echo [OK] Working directory: %cd% >> "%LOG_FILE%"

echo.
echo [2/6] Checking Java...
"%JAVA_HOME%\bin\java.exe" -version >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Java not found at: %JAVA_HOME%
    echo [ERROR] Java not found >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo [OK] Java environment ready.
echo [OK] Java environment ready >> "%LOG_FILE%"

echo.
echo [3/6] Checking Redis...
"C:\Program Files\Redis\redis-cli.exe" ping >nul 2>&1
if errorlevel 1 (
    echo [WARN] Redis not running, trying to start service...
    echo [WARN] Redis not running >> "%LOG_FILE%"
    net start Redis >nul 2>&1
    if errorlevel 1 (
        echo [WARN] Failed to start Redis service, trying direct start...
        start "Redis Server" "C:\Program Files\Redis\redis-server.exe"
        timeout /t 3 >nul
    )
    timeout /t 2 >nul
)

echo [INFO] Setting Redis password...
"C:\Program Files\Redis\redis-cli.exe" CONFIG SET requirepass "%REDIS_PWD%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to set Redis password!
    echo [ERROR] Failed to set Redis password >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo [INFO] Testing Redis connection with password...
"C:\Program Files\Redis\redis-cli.exe" -a "%REDIS_PWD%" ping >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Cannot connect to Redis with password!
    echo [ERROR] Redis connection failed >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo [OK] Redis connection ready.
echo [OK] Redis connection ready >> "%LOG_FILE%"

echo.
echo [4/6] Building and starting Monitor Admin (port %MONITOR_PORT%)...
if not exist "ruoyi-extend\ruoyi-monitor-admin\target\ruoyi-monitor-admin.jar" (
    echo [INFO] Building monitor admin...
    echo [INFO] Building monitor admin... >> "%LOG_FILE%"
    call "%MVN_CMD%" clean package -DskipTests -pl ruoyi-extend/ruoyi-monitor-admin -am -T 4 >> "%LOG_FILE%" 2>&1
    if errorlevel 1 (
        echo [ERROR] Maven build failed for monitor admin!
        echo [ERROR] Maven build failed for monitor admin >> "%LOG_FILE%"
        echo Check log file: %LOG_FILE%
        type "%LOG_FILE%"
        pause
        exit /b 1
    )
)
echo [INFO] Starting Spring Boot Admin on port %MONITOR_PORT%...
start "RuoYi-Vue-Plus Monitor" "%JAVA_HOME%\bin\java.exe" -Dfile.encoding=UTF-8 -jar ruoyi-extend/ruoyi-monitor-admin/target/ruoyi-monitor-admin.jar
echo [OK] Monitor Admin starting on port %MONITOR_PORT% (wait ~15s)...
echo [OK] Monitor Admin starting >> "%LOG_FILE%"
timeout /t 15 /nobreak >nul

echo.
echo [5/6] Checking backend jar...
if not exist "ruoyi-admin\target\ruoyi-admin.jar" (
    echo [WARN] ruoyi-admin.jar not found, building...
    echo [WARN] Building jar... >> "%LOG_FILE%"
    call "%MVN_CMD%" clean package -DskipTests -pl ruoyi-admin -am -T 4 >> "%LOG_FILE%" 2>&1
    if errorlevel 1 (
        echo [ERROR] Maven build failed!
        echo [ERROR] Maven build failed >> "%LOG_FILE%"
        echo Check log file: %LOG_FILE%
        type "%LOG_FILE%"
        pause
        exit /b 1
    )
)
echo [OK] Backend jar ready.
echo [OK] Backend jar ready >> "%LOG_FILE%"

echo.
echo [6/6] Starting backend server on port 8080...
echo ============================================
echo   Backend:   http://localhost:8080
echo   API Doc:   http://localhost:8080/doc.html
echo   Monitor:   http://localhost:%MONITOR_PORT%
echo   Login:     admin / admin123
echo ============================================
echo.

echo [INFO] Starting backend server... >> "%LOG_FILE%"
"%JAVA_HOME%\bin\java.exe" -Dfile.encoding=UTF-8 -jar ruoyi-admin\target\ruoyi-admin.jar
if errorlevel 1 (
    echo [ERROR] Backend startup failed!
    echo [ERROR] Backend startup failed with exit code: %errorlevel% >> "%LOG_FILE%"
    echo Check log file: %LOG_FILE%
    type "%LOG_FILE%"
    pause
    exit /b 1
)

pause