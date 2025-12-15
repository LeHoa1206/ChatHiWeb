@echo off
echo 🌐 Building Web App...

REM Build for web
flutter build web --release

echo ✅ Web build completed!
echo.
echo Files are in: build\web\
echo.
echo To deploy:
echo 1. Upload build\web\ folder to your web hosting
echo 2. Or use Firebase Hosting: firebase deploy --only hosting
echo 3. Or use GitHub Pages, Netlify, Vercel
echo.
echo Your app will be accessible via web browser on any device!
pause