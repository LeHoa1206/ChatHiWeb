@echo off
echo 🤖 Building Android App...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Flutter is not installed
    pause
    exit /b 1
)

REM Clean and get dependencies
echo 🧹 Cleaning and getting dependencies...
flutter clean
flutter pub get

REM Build APK for release
echo 📱 Building APK (Release)...
flutter build apk --release

REM Build APK for debug (faster)
echo 📱 Building APK (Debug)...
flutter build apk --debug

echo ✅ Android build completed!
echo.
echo APK files location:
echo - Release: build\app\outputs\flutter-apk\app-release.apk
echo - Debug: build\app\outputs\flutter-apk\app-debug.apk
echo.
echo To install on your phone:
echo 1. Enable "Unknown sources" in Android settings
echo 2. Transfer APK file to your phone
echo 3. Install the APK
echo.
echo Or connect your phone and run: flutter run
pause