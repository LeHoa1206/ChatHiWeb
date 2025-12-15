# 📱 Hướng dẫn Build APK Android

## Bước 1: Chuẩn bị môi trường

1. **Cài đặt Flutter SDK** (nếu chưa có):
   - Download từ: https://flutter.dev/docs/get-started/install
   - Thêm Flutter vào PATH

2. **Cài đặt Android Studio**:
   - Download từ: https://developer.android.com/studio
   - Cài đặt Android SDK và build tools

## Bước 2: Kiểm tra môi trường

Mở Command Prompt/Terminal và chạy:

```bash
flutter doctor
```

Đảm bảo tất cả ✓ (có thể bỏ qua iOS nếu không cần)

## Bước 3: Build APK

Trong thư mục project, chạy:

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build APK debug (nhanh hơn, để test)
flutter build apk --debug

# Build APK release (tối ưu, để sử dụng)
flutter build apk --release
```

## Bước 4: Tìm file APK

APK sẽ được tạo tại:
- **Debug**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release**: `build/app/outputs/flutter-apk/app-release.apk`

## Bước 5: Cài đặt trên điện thoại

### Cách 1: Transfer file APK
1. Copy file APK vào điện thoại
2. Bật "Unknown sources" trong Settings > Security
3. Tap vào file APK để cài đặt

### Cách 2: Cài đặt trực tiếp
1. Bật USB Debugging trên điện thoại
2. Kết nối điện thoại với máy tính
3. Chạy: `flutter install`

## Lưu ý quan trọng:

- **Debug APK**: Kích thước lớn hơn, có debug info
- **Release APK**: Tối ưu, kích thước nhỏ hơn
- **Permissions**: App sẽ xin quyền camera, microphone khi sử dụng
- **Firebase**: Cần internet để hoạt động

## Troubleshooting:

### Lỗi "Gradle build failed":
```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### Lỗi "SDK not found":
- Mở Android Studio > SDK Manager
- Cài đặt Android SDK mới nhất

### App crash khi mở:
- Kiểm tra Firebase configuration
- Xem logs: `flutter logs`