# 🍎 Hướng dẫn Build iOS App từ Windows

## Vấn đề: Windows không thể build iOS
- iOS apps chỉ có thể build trên macOS với Xcode
- Apple không cho phép build iOS trên Windows

## ✅ Giải pháp: Cloud Build Services

### 1. Codemagic (Miễn phí - Khuyến nghị)

**Bước 1: Chuẩn bị**
1. Push code lên GitHub/GitLab
2. Đăng ký tại: https://codemagic.io
3. Connect với GitHub account

**Bước 2: Setup Project**
1. Add project từ GitHub
2. Chọn Flutter framework
3. Configure build settings:
   ```yaml
   # codemagic.yaml
   workflows:
     ios-workflow:
       name: iOS Workflow
       max_build_duration: 120
       environment:
         flutter: stable
         xcode: latest
       scripts:
         - name: Set up code signing settings on Xcode project
           script: xcode-project use-profiles
         - name: Get Flutter packages
           script: flutter packages pub get
         - name: Build ipa for distribution
           script: flutter build ipa --release --export-options-plist=/Users/builder/export_options.plist
       artifacts:
         - build/ios/ipa/*.ipa
   ```

**Bước 3: Build**
1. Click "Start new build"
2. Chọn iOS workflow
3. Đợi 10-15 phút
4. Download IPA file

### 2. GitHub Actions (Free)

Tạo file `.github/workflows/ios.yml`:

```yaml
name: iOS Build
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.4'
    - run: flutter pub get
    - run: flutter build ios --release --no-codesign
    - name: Upload IPA
      uses: actions/upload-artifact@v3
      with:
        name: ios-app
        path: build/ios/iphoneos/Runner.app
```

### 3. Bitrise (Free tier)
1. Đăng ký: https://bitrise.io
2. Add project từ GitHub
3. Chọn iOS workflow template
4. Build và download

## 📱 Cài đặt trên iPhone

### Cách 1: TestFlight (Cần Apple Developer Account - $99/năm)
1. Upload IPA lên App Store Connect
2. Submit for TestFlight review
3. Invite testers qua email
4. Install từ TestFlight app

### Cách 2: Sideload (Miễn phí nhưng phức tạp)
1. **AltStore** (Windows/Mac):
   - Download AltServer: https://altstore.io
   - Install AltStore trên iPhone
   - Sideload IPA file (7 ngày expire)

2. **3uTools** (Windows):
   - Download: http://3u.com
   - Connect iPhone
   - Install IPA file

3. **Xcode** (Cần Mac):
   - Mở project trong Xcode
   - Connect iPhone
   - Run directly từ Xcode

## 🔧 Chuẩn bị Firebase cho iOS

### 1. Tạo iOS app trong Firebase Console
1. Vào Firebase Console
2. Project Settings > Add app > iOS
3. Bundle ID: `com.hiweb.chat` (hoặc tùy chỉnh)
4. Download `GoogleService-Info.plist`

### 2. Thêm vào project
- Đặt `GoogleService-Info.plist` vào `ios/Runner/`
- Commit và push lên GitHub

## ⚠️ Lưu ý quan trọng

### Code Signing
- **Development**: Cần Apple ID (miễn phí)
- **Distribution**: Cần Apple Developer Account ($99/năm)
- **Enterprise**: Cần Enterprise Account ($299/năm)

### Limitations
- **Free Apple ID**: 7 ngày expire, 3 apps max
- **Developer Account**: 1 năm expire, unlimited apps
- **TestFlight**: 90 ngày expire, 10,000 testers max

## 🚀 Quy trình build hoàn chỉnh

1. **Push code** lên GitHub
2. **Setup Codemagic** workflow
3. **Add Firebase config** (GoogleService-Info.plist)
4. **Configure signing** (certificates)
5. **Build** trên cloud
6. **Download IPA**
7. **Install** qua TestFlight/Sideload

## 💡 Tips

- Dùng **Codemagic** cho build đơn giản
- Dùng **GitHub Actions** nếu đã quen CI/CD
- **TestFlight** là cách chính thức nhất
- **Sideload** cho testing nhanh (7 ngày limit)