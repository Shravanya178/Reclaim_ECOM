@echo off
echo Starting Local Server for ReClaim Landing Page...
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo Python found! Starting HTTP server...
    echo.
    echo Landing page will be available at: http://localhost:8000
    echo Press Ctrl+C to stop the server
    echo.
    python -m http.server 8000
) else (
    echo Python not found. Trying Node.js...
    npx --version >nul 2>&1
    if %errorlevel% == 0 (
        echo Node.js found! Starting HTTP server...
        echo.
        echo Landing page will be available at: http://localhost:3000
        echo Press Ctrl+C to stop the server
        echo.
        npx serve . -p 3000
    ) else (
        echo Neither Python nor Node.js found.
        echo Opening file directly in browser...
        start "" "index.html"
    )
)

pause