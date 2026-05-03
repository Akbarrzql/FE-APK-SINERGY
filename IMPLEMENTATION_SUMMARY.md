# Implementation Summary: Runtime Permissions & Multipart Upload

## Overview
Implementasi **runtime permission handling** untuk Android & iOS, serta **multipart upload** untuk profile photo di place of base64 encoding.

---

## 1. Dependency Management

### pubspec.yaml
- ✅ Added `permission_handler: ^11.4.4`
- Status: Installed successfully

---

## 2. Android Configuration

### android/app/src/main/AndroidManifest.xml
Added runtime permissions:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**Note for Android 13+**: `READ_MEDIA_IMAGES` replaced `READ_EXTERNAL_STORAGE`. The `permission_handler` package automatically handles this selection based on minSdkVersion.

---

## 3. iOS Configuration

### ios/Runner/Info.plist
Added permission descriptions (required by iOS):
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses ke kamera untuk mengambil foto profil Anda.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi membutuhkan akses ke galeri foto Anda untuk memilih foto profil.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Aplikasi membutuhkan izin untuk menyimpan foto ke galeri Anda.</string>
```

---

## 4. New Permission Helper Class

### lib/core/common/permission_handler.dart
Utility class untuk request permissions dengan user-friendly messages:

**Key Methods:**
- `requestCameraPermission()` - Request camera access
- `requestPhotoLibraryPermission()` - Request photo library access
- `requestCameraWithStatus()` - Request camera with detailed status
- `requestPhotoLibraryWithStatus()` - Request photo library with detailed status
- `getPermissionMessage()` - Get Indonesian permission messages
- `openAppSettings()` - Open app settings if permission denied permanently

**Usage:**
```dart
final status = await PermissionHandlerHelper.requestCameraWithStatus();
if (status.isDenied) {
  // Handle denied
} else if (status.isPermanentlyDenied) {
  // Suggest opening settings
}
```

---

## 5. ProfileRepository Updates

### lib/feature/profile/repository/profile_repository.dart

**Changed Method Signature:**
```dart
// OLD
Future<EditProfileModel> updateProfile(Map<String, dynamic> body)

// NEW
Future<EditProfileModel> updateProfile(Map<String, dynamic> body, {File? profileImageFile})
```

**Implementation Details:**
- If `profileImageFile` is provided:
  - Uses `http.MultipartRequest` (PUT request)
  - Sends form fields from body + binary image file
  - Field name for image: `profilePicture`
  - Automatically sets correct headers (multipart/form-data)

- If `profileImageFile` is null:
  - Uses standard JSON `http.put` (backward compatible)
  - Useful when user only updates text fields or removes image (sends `'profilePicture': ''`)

**Benefit:**
- More efficient for large images (no base64 encoding)
- Server receives actual binary file instead of massive JSON string
- Better compatibility with standard file upload implementations

---

## 6. EditProfileScreen Updates

### lib/feature/profile/presentation/screens/edit_profile_screen.dart

**Class Variables Changed:**
```dart
// OLD
XFile? _pickedImageFile;
String? _pickedImageDataUri; // base64 data URI

// NEW
XFile? _pickedImageFile; // just store file reference
bool _imageRemoved = false; // flag for explicit removal
```

**Permission Handling Added:**
- `_pickImageFromGallery()`: Requests photo library permission before picking
- `_pickImageFromCamera()`: Requests camera permission before taking photo
- `_showPermissionDeniedDialog()`: User-friendly denial message
- `_showPermissionPermanentlyDeniedDialog()`: Allows user to open Settings

**Upload Logic in _onSave():**
```dart
File? imageFileToUpload;
if (_pickedImageFile != null) {
  imageFileToUpload = File(_pickedImageFile!.path);
}

final res = await _repo.updateProfile(body, profileImageFile: imageFileToUpload);
```

**Image Removal:**
```dart
if (_imageRemoved) {
  body['profilePicture'] = ''; // Send empty string to clear
}
```

**Avatar Display Updated:**
- Shows picked file from disk (no base64 encoding)
- Handles data URI from server (falls back to network URL)
- Shows placeholder when image removed

---

## 7. Testing Checklist

### Android Testing
- [ ] Test "Pilih dari Galeri" → shows permission dialog (first run)
- [ ] Test "Ambil Foto" → shows camera permission dialog (first run)
- [ ] Test denying permission → shows friendly error dialog
- [ ] Test permanently denying → shows "Buka Pengaturan" action
- [ ] Pick image → verify multipart request sent to server
- [ ] Upload image → verify image file received on server (not base64)

### iOS Testing
- [ ] Test "Pilih dari Galeri" → shows permission dialog
- [ ] Test "Ambil Foto" → shows camera permission dialog
- [ ] Verify permission descriptions appear in dialog
- [ ] Deny permission → shows error dialog
- [ ] Permanently deny → shows Settings action
- [ ] Pick image → verify server receives binary file

### API Testing
```bash
# Check that multipart request is sent:
# Headers should include:
# Content-Type: multipart/form-data; boundary=...

# Form fields:
# - namaLengkap, email, institusi, bio, keahlian, lokasi, whatsapp (text)
# - profilePicture (binary file with filename)
```

---

## 8. Server-Side Expectations

### Expected Multipart Request Format
```
PUT /api/v1/update/users/current HTTP/1.1
Authorization: Bearer <token>
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary...

------WebKitFormBoundary...
Content-Disposition: form-data; name="namaLengkap"

Marion Herman
------WebKitFormBoundary...
Content-Disposition: form-data; name="profilePicture"; filename="image.jpg"
Content-Type: image/jpeg

<binary image data>
------WebKitFormBoundary...--
```

### Server Response Should Include
```json
{
  "message": "Profil berhasil diperbarui",
  "data": {
    "token": "new_token_if_rotated",
    "expiredAt": 1234567890,
    "namaLengkap": "Marion Herman",
    "email": "marion@example.com",
    "profilePicture": "https://cdn.example.com/photos/user123.jpg" // or base64/data URI
  }
}
```

---

## 9. Migration Notes

### If Server Expects Different Format:

**Option A: Base64 JSON (if server prefers)**
```dart
// Install http_parser package
final bytes = await File(_pickedImageFile!.path).readAsBytes();
final base64 = base64Encode(bytes);
body['profilePicture'] = base64;

final res = await _repo.updateProfile(body); // no file parameter
```

**Option B: Multipart with different field name**
```dart
// Edit ProfileRepository line 72:
final multipartFile = http.MultipartFile(
  'photo', // or 'image', 'file', etc. - change to match server
  stream,
  length,
  filename: profileImageFile.path.split('/').last,
);
```

**Option C: Mixed (some fields might need special handling)**
- Server request likely expects specific field names
- Adjust `body` keys or multipart field names accordingly

---

## 10. Troubleshooting

### Permission Dialog Not Showing
- Ensure you're running on real device or emulator configured with permissions
- Check iOS/Android logs for permission errors
- Verify Info.plist descriptions are set correctly (iOS)

### Multipart Upload Failing
- Check server is expecting PUT (not PATCH)
- Verify field name 'profilePicture' matches server expectation
- Check server can handle binary file uploads
- Enable logging to see request headers

### File Not Found Error
- Verify `XFile` to `File` conversion is correct
- Check image picker actually returned a valid file
- Ensure file path exists when updateProfile is called

---

## 11. Next Steps (Optional)

1. **Progress Indicator**: Add upload progress during multipart upload
   ```dart
   // Use onProgress callback in MultipartRequest
   ```

2. **Image Validation**: Validate file size/type before upload
   ```dart
   if (imageFile.lengthSync() > 5 * 1024 * 1024) {
     showError('Ukuran file terlalu besar (max 5MB)');
   }
   ```

3. **Compression**: Compress image before upload to reduce bandwidth
   ```dart
   // Use image_picker compression option (already using imageQuality: 75)
   ```

4. **Caching**: Cache downloaded profile image locally
   ```dart
   // Use cached_network_image package
   ```

---

## Summary of Changes

| File | Change | Type |
|------|--------|------|
| pubspec.yaml | Added permission_handler | Dependency |
| AndroidManifest.xml | Added CAMERA, READ permissions | Android Config |
| Info.plist | Added camera/photo descriptions | iOS Config |
| permission_handler.dart | NEW file - Permission utilities | Utility Class |
| profile_repository.dart | Added multipart upload in updateProfile | Feature |
| edit_profile_screen.dart | Permission handling + multipart flow | UI Update |

All changes are backward compatible and follow best practices for mobile app permissions and file uploads.

