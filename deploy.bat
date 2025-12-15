@echo off
echo ========================================
echo   LaporJTI - Deploy Notification
echo ========================================
echo.

echo [1/3] Checking Supabase CLI...
where supabase >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Supabase CLI not found!
    echo.
    echo Please install it first:
    echo   npm install -g supabase
    echo.
    pause
    exit /b 1
)
echo OK: Supabase CLI found

echo.
echo [2/3] Checking if project is linked...
if not exist ".\.git\supabase" (
    echo Project not linked yet.
    echo.
    echo Please run these commands first:
    echo   1. supabase login
    echo   2. supabase link --project-ref hwskzjaimgnrruxaeasu
    echo.
    pause
    exit /b 1
)
echo OK: Project is linked

echo.
echo [3/3] Deploying Edge Function...
supabase functions deploy send-notification

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   SUCCESS! Edge Function deployed!
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Set Firebase Service Account secret
    echo 2. Test notification by creating a report
    echo.
) else (
    echo.
    echo ========================================
    echo   DEPLOYMENT FAILED
    echo ========================================
    echo.
    echo Check the error above and try again.
    echo.
)

pause
