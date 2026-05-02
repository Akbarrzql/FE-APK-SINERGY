# iOS MissingPluginException Fix

## ❌ Error yang Terjadi

```
MissingPluginException(No implementation found for method 
requestPermissions on channel flutter.baseflow.com/permissions/methods)
```

## 🔧 Solusi (Sudah Dilakukan)

### 1. ✅ Clean Flutter Build
```bash
flutter clean
```

### 2. ✅ Remove iOS Pods & Lock File
```bash
cd ios
rm -rf Pods
rm Podfile.lock
cd ..
```

### 3. ✅ Enable Platform in Podfile
Edit `ios/Podfile` - uncomment platform line:
```ruby
# Uncomment to specify minimum iOS version
platform :ios, '12.0'
```

### 4. ✅ Get Dependencies
```bash
flutter pub get
```

### 5. ✅ Install CocoaPods
```bash
cd ios
pod install --repo-update
cd ..
```

---

## 🚀 Jalankan Aplikasi

### Option A: Gunakan Device Available
```bash
# List available devices
flutter devices

# Run on available iOS simulator
flutter run -d <device-id> --no-fast-start
```

### Option B: Buat Simulator Baru (jika diperlukan)
```bash
# Create new simulator
xcrun simctl create "iPhone-Test" com.apple.CoreSimulator.SimRuntime.iOS-18-2

# List simulators
xcrun simctl list devices
```

### Option C: Bersihkan Xcode Cache
```bash
# Clean Xcode build cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Then run
flutter run --no-fast-start
```

---

## 📝 Langkah Lengkap untuk iOS Testing

### 1. Verifikasi Instalasi
```bash
flutter doctor -v
# Pastikan iOS toolchain terinstall dengan baik
```

### 2. Bersihkan Project
```bash
cd /Users/akbarrzql/StudioProjects/gabungyuk

# Clean everything
flutter clean
cd ios && rm -rf Pods Podfile.lock && cd ..
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### 3. Reinstall Everything
```bash
flutter pub get
cd ios && pod install --repo-update && cd ..
```

### 4. Run Aplikasi
```bash
# Check device tersedia
flutter devices

# Jalankan pada simulator yang tersedia
flutter run -d "iPhone 16"  # atau device ID lainnya
```

---

## iOS Permission Handler - Known Issues & Fixes

### Issue: Permission Dialog Doesn't Appear in Simulator

**Cause:** iOS simulator mungkin memerlukan reset permissions atau build tidak berisi plugin.

**Solutions:**

#### Fix 1: Reset Simulator Permissions
```bash
# Erase & reset simulator
xcrun simctl erase all

# atau specific device
xcrun simctl erase "3600B2DC-FDF9-490E-AA37-408C97229804"
```

#### Fix 2: Build iOS dari Scratch
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock build
pod install --repo-update
cd ..
flutter run --no-fast-start -v
```

#### Fix 3: Tangkap Build Errors (-v flag)
```bash
# Run dengan verbose untuk melihat masalah
flutter run -v

# Look for errors containing:
# - "permission_handler_apple"
# - "Method not found"
# - "Plugin registration"
```

---

## Info.plist - Pastikan Sudah Diset

Verify your iOS permissions are in Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses ke kamera untuk mengambil foto profil Anda.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi membutuhkan akses ke galeri foto Anda untuk memilih foto profil.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Aplikasi membutuhkan izin untuk menyimpan foto ke galeri Anda.</string>
```

---

## Xcode Configuration Check

### Method 1: Buka Project di Xcode
```bash
cd ios
open Runner.xcworkspace  # Important: use .xcworkspace, NOT .xcodeproj
```

Then check:
1. Runner project → Target "Runner"
2. Build Phases → check "Run Script" includes permission_handler
3. Frameworks, Libraries... → check "permission_handler_apple" sudah link

### Method 2: Command Line Check
```bash
# Check if permission_handler plugin registered
grep -r "permission_handler" ios/Pods/

# Output should show permission_handler_apple framework
```

---

## Alternate: Fallback untuk Simulator Testing

Jika simulator permissioning tidak bekerja, Anda bisa:

### Option 1: Test on Real Device
```bash
# Connect iPhone via USB
flutter devices
flutter run -d <device-id>
```

### Option 2: Mock Permissions dalam Code
```dart
// Temporarily mock for quick testing
if (defaultTargetPlatform == TargetPlatform.iOS) {
  print('iOS Simulator - Skipping permission check');
  // Proceed directly to image picker
} else {
  // Real permission logic
}
```

### Option 3: Environment-Based Testing
```dart
// In permission_handler.dart or edit_profile_screen.dart
const bool isTestingMode = bool.fromEnvironment('TEST_MODE', defaultValue: false);

if (isTestingMode) {
  // Skip permission in test mode
  return PermissionStatus.granted;
}
```

---

## Complete Testing Flow

### Step 1: Clean Build
```bash
cd /Users/akbarrzql/StudioProjects/gabungyuk

# Full clean
flutter clean
cd ios && rm -rf Pods Podfile.lock build
pod install --repo-update
cd ..
```

### Step 2: Build Fresh
```bash
# List available devices
flutter devices

# Build for iOS (no run yet, just build)
flutter build ios --debug
```

### Step 3: Run
```bash
# Pick from available devices
flutter run -d "iPhone 16"

# Or verbose mode to see errors
flutter run -v
```

### Step 4: Test in App
1. Buka app di simulator
2. Navigate to Profile → Edit Profile
3. Tap camera icon
4. Select "Pilih dari Galeri" atau "Ambil Foto"
5. Check if permission dialog appears
6. Grant permission
7. Select photo

---

## Debugging: Enable Verbose Logging

### Flutter Verbose Mode
```bash
flutter run -v 2>&1 | tee build.log
```

### Check for Plugin Errors
```bash
# Search the log for permission errors
grep -i "permission" build.log
grep -i "plugin" build.log
grep -i "error" build.log
```

### Xcode Build Output
```bash
# Run in foreground to see build messages
flutter run -v
```

---

## If Still Not Working: Nuclear Option

```bash
# 1. Complete project clean
cd /Users/akbarrzql/StudioProjects/gabungyuk
flutter clean
rm -rf build/
rm -rf ios/Pods ios/Podfile.lock ios/Flutter/Flutter.podspec

# 2. Xcode cache clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Developer/Xcode/Archives/*

# 3. CocoaPods cache clean
rm -rf ~/.cocoapods

# 4. Reinstall from scratch
flutter pub get
cd ios && pod install --repo-update && cd ..

# 5. Build debug
flutter run --debug -v
```

---

## Common iOS Emulator vs Real Device Differences

| Feature | Simulator | Real Device |
|---------|-----------|------------|
| Camera Permission | Requires mockup | Auto prompt |
| Photo Library | Limited access | Full access |
| Performance | Faster build | Slower build |
| Debugging | Easier | Console access needed |

---

## Next Steps

1. **Try the build again** with clean setup above
2. **Test on simulator** if available
3. **Test on real device** if simulator issues persist (recommended for production)
4. **Check `build.log`** if problems occur
5. **Share error** from verbose output

---

## Reference Files

- Plugin file: `lib/core/common/permission_handler.dart`
- iOS config: `ios/Runner/Info.plist`
- CocoaPods: `ios/Podfile`
- Edit screen: `lib/feature/profile/presentation/screens/edit_profile_screen.dart`

---

## Support

If issues persist after above steps:

1. Run: `flutter doctor -v` → check iOS setup
2. Run: `flutter run -v` → capture full build log
3. Check device logs: Xcode console
4. Try real device: `flutter run -d <real-device-id>`

**iOS simulator permissions can be finicky. Real device is the most reliable test platform.** 🍎

