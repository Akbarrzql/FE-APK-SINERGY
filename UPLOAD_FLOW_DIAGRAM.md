# Profile Photo Upload Flow Diagram

## Complete Flow: User Picks Image → Upload to Server

```
┌─────────────────────────────────────────────────────────────────┐
│                     EditProfileScreen                            │
│                                                                   │
│  User taps edit button icon → _showImageSourceActionSheet()     │
│                                                                   │
│  ┌──────────────┐         ┌──────────────┐                      │
│  │ Pilih Galeri │         │ Ambil Foto   │                      │
│  └──────┬───────┘         └──────┬───────┘                      │
│         │                        │                               │
│         ▼                        ▼                               │
│  _pickImageFromGallery()  _pickImageFromCamera()                │
│         │                        │                               │
│         ▼                        ▼                               │
│  ┌─────────────────────────────────────┐                       │
│  │ PermissionHandlerHelper              │                       │
│  │ .requestPhotoLibraryWithStatus()     │                       │
│  │ / .requestCameraWithStatus()         │                       │
│  └──────────┬──────────────────────────┘                       │
│             │                                                    │
│     ┌───────┴────────┬──────────────┐                           │
│     │                │              │                           │
│  GRANTED         DENIED      PERMANENTLY DENIED                │
│     │                │              │                           │
│     ▼                ▼              ▼                           │
│  Continue    Show Error      Show Settings                     │
│  ImagePicker Dialog          Button Dialog                      │
│     │                │              │                           │
│     └────────┬───────┘────────┬─────┘                           │
│              │                │                                  │
│              ▼                ▼                                  │
│         User Picks      User Opens                             │
│         Image File      App Settings                           │
│              │              │                                   │
│              └─────┬────────┘                                   │
│                    │                                             │
│                    ▼                                             │
│        setState({ _pickedImageFile = picked; })               │
│        (XFile object from picker)                             │
│                    │                                             │
└────────────────────┼──────────────────────────────────────────┘
                     │
                     │ [UI Updates: Show Image Preview]
                     │
┌────────────────────┼──────────────────────────────────────────┐
│                    ▼                                             │
│           EditProfileScreen continues...                         │
│     (User fills other form fields, then taps Save)             │
│                    │                                             │
│  ┌────────────────────────────────────┐                        │
│  │ _onSave()                          │                        │
│  │ 1. Validate form                   │                        │
│  │ 2. Collect form data               │                        │
│  │ 3. Check _imageRemoved flag        │                        │
│  │ 4. Prepare File object if picked   │                        │
│  └────────┬───────────────────────────┘                        │
│           │                                                      │
│           ▼                                                      │
│  repo.updateProfile(body, profileImageFile: file)              │
│           │                                                      │
└───────────┼──────────────────────────────────────────────────┘
            │
            │
┌───────────┼──────────────────────────────────────────────────┐
│           ▼                                                     │
│    ProfileRepository.updateProfile()                           │
│                                                                 │
│    Get Bearer token from SharedCode                           │
│           │                                                     │
│           ▼                                                     │
│    if (profileImageFile != null && exists) {                  │
│       ┌────────────────────────────────────┐                 │
│       │ Use MultipartRequest                │                 │
│       │                                      │                 │
│       │ 1. Create PUT request               │                 │
│       │ 2. Add form fields from body        │                 │
│       │ 3. Add binary file as "profilePic" │                 │
│       │ 4. Send with Bearer header          │                 │
│       │                                      │                 │
│       │ Content-Type: multipart/form-data   │                 │
│       └────────────┬───────────────────────┘                 │
│    } else {                                                     │
│       ┌────────────────────────────────────┐                 │
│       │ Use Standard JSON PUT                │                 │
│       │                                      │                 │
│       │ (for text-only updates or remove)   │                 │
│       │ Content-Type: application/json       │                 │
│       └────────────┬───────────────────────┘                 │
│    }                                                             │
│           │                                                     │
│           ▼                                                     │
│           🌐 HTTP Request to Server 🌐                        │
│  PUT /api/v1/update/users/current                             │
│           │                                                     │
│     ┌─────┴──────┬──────────────┐                             │
│     │            │              │                             │
│  ✅ 200-299   ❌ 400-499    ❌ 500+                            │
│     │            │              │                             │
│     ▼            ▼              ▼                             │
│  Parse JSON  Parse Error   Parse Error                        │
│  Response    Message       Message                            │
│     │            │              │                             │
│     └─────┬──────┴──────────┬───┘                             │
│           │                 │                                  │
│           ▼                 ▼                                  │
│     Return              Throw                                 │
│  EditProfileModel     ApiException(msg)                       │
│           │                 │                                  │
└───────────┼─────────────────┼────────────────────────────────┘
            │                 │
            │                 │
┌───────────┼─────────────────┼────────────────────────────────┐
│           ▼                 ▼                                  │
│        [Back in _onSave()]                                   │
│           │                 │                                  │
│        Success           Error                                │
│           │                 │                                  │
│           ▼                 ▼                                  │
│     Show green        Show red SnackBar                      │
│     SnackBar          with error message                      │
│           │                 │                                  │
│  • Save token if      • User sees friendly                    │
│    returned           error message                           │
│  • Reload profile     • Does NOT pop screen                   │
│    via LoadProfile         │                                  │
│    event             [User can edit and retry]               │
│           │                                                    │
│           ▼                                                    │
│     Pop screen → Back to ProfileScreen                        │
│                                                                 │
└──────────────────────────────────────────────────────────────┘
```

---

## Key Scenarios

### Scenario 1: Update Photo + Text Fields
```
Form Data (JSON fields):
- namaLengkap: "Marion Herman"
- email: "marion@example.com"
- institusi: "PT ABC"
- bio: "Developer"
- keahlian: ""  ← cleared
- lokasi: "Jakarta"
- whatsapp: "62812345"

Image File: [Binary file from disk]

→ MultipartRequest with all fields + binary file
```

### Scenario 2: Clear Photo (Keep Text)
```
Form Data:
- ... (same as above, text fields)
- profilePicture: "" ← explicitly empty

Image File: null

→ Standard JSON PUT with empty profilePicture
→ Server clears the photo
```

### Scenario 3: Text Only Update (No Photo)
```
Form Data:
- namaLengkap: "Marion Herman Updated"
- ... (other fields)
- profilePicture: "" ← send empty or omit

Image File: not picked

→ Standard JSON PUT
→ Photo remains unchanged on server
```

---

## Code Reference

### Permission Flow
```dart
final status = await PermissionHandlerHelper.requestCameraWithStatus();

if (status.isDenied) {
  // Show error: "Izin akses kamera ditolak."
  _showPermissionDeniedDialog('Kamera', '...');
} else if (status.isPermanentlyDenied) {
  // Show: "Izin ditolak permanen. Buka Pengaturan?"
  _showPermissionPermanentlyDeniedDialog('Kamera');
} else {
  // Permission granted, proceed with image picker
  final picked = await _picker.pickImage(...);
}
```

### MultipartRequest Details
```dart
final request = http.MultipartRequest('PUT', url)
  ..headers['Authorization'] = 'Bearer $token';

// Add text fields
request.fields['namaLengkap'] = 'Marion Herman';
request.fields['bio'] = 'Developer';

// Add binary file
final stream = http.ByteStream(file.openRead());
final multipartFile = http.MultipartFile(
  'profilePicture', // ← field name expected by server
  stream,
  length,
  filename: 'image.jpg',
);
request.files.add(multipartFile);

final streamResponse = await request.send();
```

---

## Performance & Storage Benefits

### Before (Base64 in JSON)
- Image file (2MB) → encode to base64 (2.7MB) → JSON string → Send
- Total request size: ~2.7MB (33% larger)
- Server receives massive text string, must decode

### After (Multipart Binary)
- Image file (2MB) → directly upload as binary → Send
- Total request size: ~2MB (actual file size)
- Server receives actual file stream, no decoding needed
- ⚡ **~25% reduction in request size**
- ⚡ **Faster upload**

---

## Testing Instructions

### Android
```bash
# 1. Build and run on Android device/emulator
flutter run

# 2. Navigate to Profile → Edit Profile
# 3. Tap image edit icon
# 4. Select "Pilih dari Galeri" or "Ambil Foto"
# 5. Grant permissions when prompted (first time only)
# 6. Pick/take photo
# 7. Fill form and tap "Simpan"

# Check Logcat for multipart request details
```

### iOS
```bash
# 1. Build and run on iOS device/simulator
flutter run

# 2. Same flow as Android
# 3. Check Xcode console for request logs
# 4. Verify Info.plist permission descriptions appear

# Note: On real device, permissions require on-device installation
```

### Server Testing
```bash
# Inspect multipart request (using network tool/proxy):
# Should see:
# - Content-Type: multipart/form-data; boundary=----...
# - Form fields (namaLengkap, email, etc.)
# - Binary file field (profilePicture)
# - Authorization: Bearer <token>
```

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Permission dialog not showing | First run, or permissions already granted | Check permission status manually |
| File not found | XFile path invalid | Verify image_picker returned valid file |
| Multipart 400 error | Field name mismatch | Check server expects "profilePicture" field |
| Multipart 500 error | Server file handling issue | Check server file upload handler logs |
| Large timeout | Large file upload | Increase http timeout or compress image more |

---

## Next Optimization Steps

1. **Add progress bar** during upload
   ```dart
   // Track upload progress using request.send() with stream callback
   ```

2. **Image compression** (already optimized: quality: 75, maxWidth: 1200)
   ```dart
   // Already applied in image_picker call
   ```

3. **Validate file size/type** before upload
   ```dart
   if (file.lengthSync() > 5 * 1024 * 1024) {
     throw Exception('File too large (max 5MB)');
   }
   ```

4. **Cache downloaded images**
   ```dart
   // Use cached_network_image package
   ```

---

## Server-Side Implementation Hint

If your server doesn't yet support multipart file upload, you can:

### Option 1: Store as base64 JSON (client side: keep old code)
```dart
// Fallback if server can't handle multipart
final bytes = await File(_pickedImageFile!.path).readAsBytes();
body['profilePicture'] = base64Encode(bytes);
await _repo.updateProfile(body); // no file parameter
```

### Option 2: Migrate server to support multipart
```python
# Example Django/Flask endpoint
@app.route('/api/v1/update/users/current', methods=['PUT'])
def update_profile():
    profile_picture = request.files.get('profilePicture')
    name = request.form.get('namaLengkap')
    
    if profile_picture:
        # Save to storage
        filename = secure_filename(profile_picture.filename)
        profile_picture.save(f'/uploads/{filename}')
        # Update DB with file path or URL
```

The client is ready. Your server just needs to handle multipart/form-data! 🚀

