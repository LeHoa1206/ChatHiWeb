#!/bin/bash

echo "🍎 Building iOS App..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS build requires macOS"
    echo "Please run this script on a Mac with Xcode installed"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Check iOS setup
echo "🔍 Checking iOS setup..."
flutter doctor --verbose

# Build for iOS Simulator
echo "📱 Building for iOS Simulator..."
flutter build ios --simulator --debug

# Build for iOS Device (Release)
echo "📱 Building for iOS Device (Release)..."
flutter build ios --release

echo "✅ iOS build completed!"
echo ""
echo "To run on simulator:"
echo "flutter run -d ios"
echo ""
echo "To run on device:"
echo "flutter run -d [device-id]"
echo ""
echo "To open in Xcode:"
echo "open ios/Runner.xcworkspace"