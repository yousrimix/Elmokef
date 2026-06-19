@echo off
REM ===== Elmokef One-Click Start =====
REM Run this as Administrator if needed

echo 🔧 Starting Elmokef...

:: 1. Backend (NestJS)
echo [1/4] Starting Backend...
start /B node "E:\charika\backend\dist\main.js"
timeout /t 3 /nobreak >nul

:: 2. API Wrapper
echo [2/4] Starting API Wrapper...
start /B node "E:\charika\backend\api-wrapper.js"
timeout /t 2 /nobreak >nul

:: 3. SPA + API Proxy Server
echo [3/4] Starting SPA Server (port 5181)...
start /B node "E:\charika\spa-server.js"
timeout /t 2 /nobreak >nul

:: 4. Admin Panel
echo [4/4] Starting Admin Panel (port 3003)...
start /B node "E:\charika\elmokef-admin\serve.cjs"
timeout /t 2 /nobreak >nul

echo.
echo ✅ All servers running:
echo    App/API: http://localhost:5181
echo    Admin:   http://localhost:3003
echo.
echo To expose online, run in separate terminals:
echo    cloudflared tunnel --url http://localhost:5181
echo    cloudflared tunnel --url http://localhost:3003
echo.
