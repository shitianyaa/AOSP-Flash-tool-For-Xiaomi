@echo off
chcp 65001 >nul 2>&1
title AOSP Flash Tool

echo ============================================
echo      AOSP Flash Tool
echo ============================================
echo.

where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell not found
    pause
    exit /b 1
)

echo Starting...
powershell -ExecutionPolicy Bypass -File "%~dp0Flash-AOSP.ps1"

echo.
echo ============================================
echo Script finished.
echo ============================================
pause
