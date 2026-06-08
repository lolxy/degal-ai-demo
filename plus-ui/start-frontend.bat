@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title Plus-UI Frontend Dev Server

echo ============================================
echo   Plus-UI Frontend Dev Server Launcher
echo ============================================
echo.

echo [1/3] Checking working directory...
cd /d "%~dp0"
if errorlevel 1 (
    echo [ERROR] Failed to change directory to: %~dp0
    pause
    exit /b 1
)
echo [OK] Working directory: %cd%

echo.
echo [2/3] Checking node_modules...
if not exist "node_modules" (
    echo [WARN] node_modules not found, installing...
    call npm install --registry=https://registry.npmmirror.com
    if errorlevel 1 (
        echo [ERROR] npm install failed!
        pause
        exit /b 1
    )
)
echo [OK] Dependencies ready.

echo.
echo [3/3] Starting frontend dev server on port 8081...
echo ============================================
echo   Access: http://localhost:8081
echo   Login: admin / admin123
echo ============================================
echo.

set "LOG_FILE=frontend-startup.log"
echo Starting frontend... > "%LOG_FILE%"
echo Time: %date% %time% >> "%LOG_FILE%"

call npm run dev >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Frontend startup failed!
    echo Check log file: %LOG_FILE%
    type "%LOG_FILE%"
    pause
    exit /b 1
)

pause