# iOS Permission Handler - Simulator Workaround

## 🎯 Quick Fix

Jika Anda mengalami `MissingPluginException` pada iOS simulator, ikuti **EXACTLY** langkah ini:

### 1️⃣ Terminal Commands (Copy & Paste)

```bash
# Navigate to project
cd /Users/akbarrzql/StudioProjects/gabungyuk

# Step 1: Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Step 2: Get fresh dependencies
flutter pub get

# Step 3: Reinstall iOS pods
cd ios
pod install --repo-update
cd ..

# Step 4: List available devices
flutter devices

# Step 5: Run with verbose
flutter run -v
```

---

## ✅ Verification Checklist

After running commands above, check:

- [ ] No errors from `pod install --repo-update`
- [ ] `pod install` output shows:
  - `Installing permission_handler_apple`
  - `Pod installation complete!`
- [ ] `flutter devices` shows at least one iOS simulator
- [ ] App builds and runs (may take 2-3 mins for first build)

---

## 📱 Test Permission Flow

### On Simulator:

1. **Open app** → wait for main screen
2. **Go to Profile** → tap Profile tab/screen
3. **Tap Edit Profile** button
4. **Tap camera icon** on profile picture
5. **Select "Pilih dari Galeri"** or **"Ambil Foto"**
6. **Expect:** Permission dialog appears

### Results:

✅ **Permission dialog appears** → Plugin working!
❌ **Error message instead** → Follow troubleshooting below

---

## 🔧 If Still Getting Error

### Try These (in order):

#### Method 1: Erase Simulator
```bash
# Get simulator name/id
flutter devices

# Erase it completely
xcrun simctl erase "DEVICE_ID_HERE"

# Then run again
flutter run -v
```

#### Method 2: Use Xcode Build
```bash
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination generic/platform=iOS -derivedDataPath build

cd ..
```

#### Method 3: Check Pods Installation
```bash
# Verify permission_handler was installed
pod list | grep permission_handler

# Or check directly
ls -la ios/Pods/permission_handler_apple/

# Should show plugin files
```

#### Method 4: View Xcode Logs
```bash
# Open in Xcode and build
cd ios
open Runner.xcworkspace

# In Xcode:
# 1. Select "Runner" target
# 2. Build (Cmd+B)
# 3. Check build output for errors
# 4. Look for permission_handler in log
```

---

## 🚨 Last Resort: Workaround Code

Jika emulator benar-benar tidak kooperatif, gunakan workaround ini:

Edit file: `lib/feature/profile/presentation/screens/edit_profile_screen.dart`

Find this:
```dart
Future<void> _pickImageFromGallery() async {
  try {
    final status = await perm_helper.PermissionHandlerHelper.requestPhotoLibraryWithStatus();
```

Replace dengan:
```dart
Future<void> _pickImageFromGallery() async {
  try {
    // Workaround for iOS simulator permission handler issues
    final status = await perm_helper.PermissionHandlerHelper.requestPhotoLibraryWithStatus();
    
    // Debug: Print status
    print('PhotoLibrary Permission Status: $status');
```

And in camera method:
```dart
Future<void> _pickImageFromCamera() async {
  try {
    // Workaround for iOS simulator permission handler issues
    final status = await perm_helper.PermissionHandlerHelper.requestCameraWithStatus();
    
    // Debug: Print status
    print('Camera Permission Status: $status');
```

Then run with verbose:
```bash
flutter run -v

# Watch for "Permission Status" logs
```

---

## 📊 Comparison: Real Device vs Simulator

| Issue | Simulator | Real Device |
|-------|-----------|------------|
| Permission request | Sometimes fails | Always works |
| Plugin loading | Can delay | Instant |
| Performance | Fast | Slower |
| Recommendation | Dev only | Testing & Production |

**Best Practice:** Test permissions on real iOS device before production! 🍎

---

## 🔄 Real Device Testing

If simulator not cooperating, use real device:

### 1. Connect iPhone via USB
```bash
# See connected device
flutter devices

# ID will show like "dcf00c34e2b9e87a3c8b7d..."
```

### 2. Run on Real Device
```bash
flutter run -d <device-id>
```

### 3. Permissions on Real Device
- First tap: Permission dialog appears
- User taps "Allow" → Permission granted
- Subsequent taps: No dialog (already granted)
- Can reset in Settings → App → Permissions

---

## 🐛 Debug Output Interpretation

### ✅ Good Signs:
```
Installing permission_handler_apple (9.3.0)  ← Check version matches
Pod installation complete!                      ← Success
permission_handler plugin registered             ← Plugin loaded
```

### ❌ Bad Signs:
```
MissingPluginException                          ← Plugin not found
permission_handler NOT found in pods            ← Not installed
Error downloading permission_handler_apple     ← Network issue
```

---

## 💡 Pro Tips

### Tip 1: Force iOS Build
```bash
# If build seems cached, force it
flutter run --no-fast-start -v
```

### Tip 2: Check Info.plist
Verify this file exists and has permissions:
```bash
cat ios/Runner/Info.plist | grep -A2 "NSCamera"
```

Should show:
```xml
<key>NSCameraUsageDescription</key>
<string>...description...</string>
```

### Tip 3: Monitor Logs in Real-Time
```bash
# Build and tail logs
flutter run -v 2>&1 | grep -i "permission\|error\|install"
```

### Tip 4: Clean Build Cache
```bash
# Most thorough clean
flutter clean && \
rm -rf ios/Pods ios/Podfile.lock && \
rm -rf ~/Library/Developer/Xcode/DerivedData/* && \
flutter pub get && \
cd ios && pod install --repo-update && cd .. && \
flutter run
```

---

## ✨ Success Criteria

When everything works, you should see:

```
✓ App launches on iOS simulator
✓ No errors in console
✓ Profile screen loads
✓ Edit Profile button clickable
✓ Camera icon tapable
✓ Permission dialog appears when tapping "Pilih dari Galeri"
✓ Image picker opens after granting permission
✓ Selected image preview appears
✓ Form can be submitted
✓ "Simpan" uploads successfully (with server running)
```

---

## 📞 If Nothing Works

Last options:

1. **Test on real device** (most reliable)
2. **Contact Flutter team** with full build logs
3. **Update Flutter** to latest version:
   ```bash
   flutter upgrade
   ```

4. **Remove permission_handler temporarily** for testing:
   - Comment out permission check in code
   - Test image picker without permissions
   - Re-enable after confirming other logic works

---

## Reference

- Plugin GitHub: https://github.com/Baseflow/flutter-permission-handler
- Known Issues: Common problem on simulators
- Solution: Usually pod install fixes it

**Most common cause: Pods not properly installed on iOS. If `pod install` completes successfully, it should work!** ✅

