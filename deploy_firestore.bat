@echo off
echo Deploying Firestore rules and indexes...

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Firebase CLI is not installed. Installing...
    npm install -g firebase-tools
)

REM Deploy rules and indexes
echo Deploying Firestore rules...
firebase deploy --only firestore:rules

echo Deploying Firestore indexes...
firebase deploy --only firestore:indexes

echo.
echo Deployment complete!
echo Note: Indexes may take 5-10 minutes to build.
pause