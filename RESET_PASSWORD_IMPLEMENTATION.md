# Reset Password Flow Implementation - Dokumentasi Lengkap

## 📋 Overview
Implementasi flow reset password **tanpa dynamic link** dengan auto-sync password setelah login. User mengubah password melalui email Firebase, dan ketika login ulang, password akan otomatis tersinkronisasi ke Firestore dan backend.

---

## 🔄 Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    RESET PASSWORD FLOW                          │
└─────────────────────────────────────────────────────────────────┘

1. USER REQUEST RESET (ForgotPasswordScreen)
   └─> Input email → Firebase kirim email reset
       └─> User buka email → Klik link reset password
           └─> User ubah password di Firebase

2. USER LOGIN ULANG
   ├─> Manual Login: email + password baru
   │   └─> Backend accept → Firebase session di-create
   │       └─> _safeFirebaseSignIn dipanggil
   │           └─> PasswordSyncHelper.checkAndSyncPasswordIfChanged()
   │               └─> Cek Firestore vs password baru
   │                   └─> Jika berbeda → sync ke backend & Firestore
   │
   └─> Google Login: sign in with Google
       └─> Backend account linking
           └─> Firebase account linking
               └─> PasswordSyncHelper.syncGoogleUserPassword()
                   └─> Sync derived password ke backend & Firestore

3. APP STATE UPDATED
   └─> Password di Firestore & backend = password di Firebase
       └─> User berhasil login dengan password baru
           └─> Navigate ke Dashboard
```

---

## 📁 Files yang Diubah/Dibuat

### 1. ✅ `lib/core/common/password_sync_helper.dart` (BARU)
**Fungsi**: Handle auto-sync password setelah login

**Method utama**:
- `checkAndSyncPasswordIfChanged()` - untuk manual login
  - Cek hash password di Firestore vs password login yang baru
  - Jika berbeda, call backend + update Firestore
- `syncGoogleUserPassword()` - untuk Google login
  - Sync derived password ke backend & Firestore

**Diagram Logic**:
```
checkAndSyncPasswordIfChanged(email, password)
  │
  ├─> 1. Get user dari Firestore
  │      └─> Jika tidak ada → return false
  │
  ├─> 2. Hash password login
  │      └─> Banding dengan hash di Firestore
  │
  ├─> 3. Jika sama → password tidak berubah, return false
  │
  └─> 4. Jika berbeda:
         ├─> Call _syncToBackend(idToken, password)
         │   └─> POST /api/v1/users/firebase
         │       └─> Backend update password
         │
         └─> Update Firestore dengan hash & timestamp
             └─> Return true (sync berhasil)
```

---

### 2. ✏️ `lib/main.dart`
**Perubahan**: Hapus dynamic link logic
- Hapus import `firebase_dynamic_links.dart`
- Hapus import `deep_link_service.dart`
- Hapus `_initDynamicLinks()` method
- Hapus `_handleLink()` method
- Hapus `_flushPendingLink()` method
- Hapus `_schedulePendingLinkFlush()` method

**Alasan**: Sudah tidak perlu dynamic link karena flow sekarang hanya bergantung pada manual Firebase email reset

---

### 3. ✏️ `lib/feature/splash_screen/splash_screen.dart`
**Perubahan**: Hapus deep_link_service reference
- Hapus import `deep_link_service.dart`
- Hapus pengecekan `DeepLinkService.instance.bypassSplash`

**Alasan**: Splash tidak perlu di-bypass lagi

---

### 4. ✏️ `lib/feature/auth/login/login_screen.dart`
**Perubahan**: Tambah password sync logic
- Add import: `password_sync_helper.dart`
- Update `_safeFirebaseSignIn()`:
  ```dart
  // Setelah Firebase sign in berhasil
  await PasswordSyncHelper.instance.checkAndSyncPasswordIfChanged(
    email: email,
    currentPassword: password,
  );
  ```
- Method ini di-call setelah login backend berhasil

---

### 5. ✏️ `lib/feature/auth/service/firebase_integration_service.dart`
**Perubahan**: Tambah password sync untuk Google users
- Add import: `password_sync_helper.dart`
- Setelah Google Firebase Auth success:
  ```dart
  // Sync password untuk Google users yang sudah punya password
  if (hasLocalPassword) {
    await PasswordSyncHelper.instance.syncGoogleUserPassword(
      email: email,
      googleUid: googleUid,
      fullName: fullName,
    );
  }
  ```

---

### 6. ✏️ `lib/feature/auth/forgot_password/forgot_password_screen.dart`
**Perubahan**: Simplifikasi - hapus manual sync form
- Hapus form kedua ("Sudah mengganti kata sandi? Sinkronkan ke server")
- Hapus `_syncNewPassword()` method
- Hapus import yang tidak perlu
- Keep hanya: input email → send reset email via Firebase
- Add instruksi yang jelas untuk user:
  1. Periksa email (termasuk spam folder)
  2. Klik link di email untuk ubah password
  3. Login kembali dengan password baru
  4. Password otomatis tersinkronisasi

**Alasan**: Sync akan automatic di login ulang, tidak perlu manual action

---

## 🔐 Teknologi yang Dipakai

### Firebase Integration:
1. **Firebase Auth** - untuk email reset password
2. **Firestore** - menyimpan password hash & metadata user
3. **Google Sign-In** - untuk Google login (optional)

### Backend Integration:
- **Endpoint**: `POST /api/v1/users/firebase`
- **Payload**:
  ```json
  {
    "idToken": "firebase_id_token",
    "newPassword": "password_baru_atau_derived"
  }
  ```
- **Respons**: accept dan update password di backend

### Hashing Algorithm:
```dart
// Password di-hash sebelum disimpan di Firestore
String hashPassword(String password) {
  final hash = sha256.convert(utf8.encode('gabungyuk_pwd_$password'));
  return hash.toString();
}

// Untuk Google users, password di-derive:
String deriveGoogleSecret(String googleUid) {
  final hash = sha256.convert(utf8.encode('gabungyuk_google_$googleUid'));
  return '${hash.toString().substring(0, 24)}Ab@1';
}
```

---

## 📊 Data Structure di Firestore

```dart
users/{email}
├─ uid: String (Firebase UID)
├─ email: String
├─ full_name: String
├─ provider: String ('email', 'google', atau 'multi')
├─ has_local_password: bool
├─ local_password: String (password hash SHA256)
├─ plain_password: String (optional, plain text untuk reference)
├─ google_uid: String (jika provider = 'google' atau 'multi')
├─ password_updated_at: Timestamp (terakhir di-update)
├─ password_set_at: Timestamp (pertama kali di-set)
├─ google_sync_at: Timestamp (terakhir Google sync)
├─ updated_at: Timestamp
└─ created_at: Timestamp
```

---

## 🔄 Sequence Diagram - Manual Login dengan Password Reset

```
User                    App                  Firebase           Backend         Firestore
 │                       │                       │                  │                │
 ├──────input email──────>│                       │                  │                │
 │                       │━━━send reset email━━━>│                  │                │
 │                       │<━━━━━email sent━━━━━━━│                  │                │
 │                       │                       │                  │                │
 │<─────email received───│<────user check───────│                  │                │
 │  (click reset link)   │                       │                  │                │
 │                       │                       │                  │                │
 │  (ubah password)      │                       │                  │                │
 │  via Firebase email   │                       │                  │                │
 │                       │                       │<─update────────┼─│                │
 │                       │                       │                  │                │
 ├──login email+password─>│                       │                  │                │
 │                       ├───backend login──────>│                  │                │
 │                       ├───Firebase signIn────>│                  │                │
 │                       │<────success──────────│                  │                │
 │                       │                       │                  │                │
 │                       ├─get idToken──────────>│                  │                │
 │                       ├─check password hash──┼──────GET user───>│                │
 │                       │<─user data (old hash)┼─────────────────┼─│                │
 │                       │                       │                  │<─old hash──────│
 │                       │                       │                  │                │
 │                       │  (hash baru ≠ old)   │                  │                │
 │                       ├─sync to backend──────┼────POST /firebase┼─────────────────>│
 │                       │  (idToken, password) │                  │                │
 │                       │                       │                  │<─update────────│
 │                       │                       │                  │                │
 │                       ├─update Firestore─────┼──────────────────┼───────────────>│
 │                       │  (new hash, timestamp)│                  │                │
 │                       │                       │                  │                │
 │<────navigate to app───│                       │                  │                │
```

---

## 🔄 Sequence Diagram - Google Login

```
User               App              Google         Firebase       Backend       Firestore
 │                  │                  │              │              │              │
 ├─click Google────>│                  │              │              │              │
 │ Sign-In          │                  │              │              │              │
 │                  ├──auth request───>│              │              │              │
 │                  │<─auth response───│              │              │              │
 │                  │                  │              │              │              │
 │                  ├─Firebase signIn─────────────────>│              │              │
 │                  │<─success, Firebase UID──────────│              │              │
 │                  │                  │              │              │              │
 │                  ├─account linking──────────────────────────────>│              │
 │                  │<─success─────────────────────────────────────│              │
 │                  │                  │              │              │              │
 │                  ├─Firestore lookup user────────────────────────┼────────────>│
 │                  │<─user data (hasLocalPassword)──┼──────────────────────────│
 │                  │                  │              │              │              │
 │ [Jika sudah ada password:]          │              │              │              │
 │                  │                  │              │              │              │
 │                  ├─get idToken──────────────────────>│              │              │
 │                  ├─syncGoogleUserPassword─────────────────────────────────────>│
 │                  │  (idToken, derivedPassword)    │              │              │
 │                  │                  │              │              │<─update─────│
 │                  │                  │              │              │              │
 │                  │<─success─────────────────────────────────────────────────────│
 │                  │                  │              │              │              │
 │<─navigate to app─│                  │              │              │              │
```

---

## 💻 Implementation Checklist

✅ **1. Password Sync Helper dibuat**
   - Method untuk check password berubah
   - Method untuk sync ke backend
   - Method untuk sync Google users

✅ **2. Login screen diupdate**
   - Call PasswordSyncHelper setelah Firebase signIn
   - Handle password sync silently

✅ **3. Google login service diupdate**
   - Call PasswordSyncHelper untuk Google users
   - Handle password sync after account linking

✅ **4. Forgot password screen disederhanakan**
   - Hapus manual sync form
   - Keep hanya: send reset email dari Firebase
   - Clear instruksi untuk user

✅ **5. Main.dart dan Splash screen dibersihkan**
   - Hapus dynamic link logic
   - Simplify app initialization

---

## 🧪 Testing Checklist

### Manual Login dengan Password Reset:
- [ ] User input email di ForgotPasswordScreen
- [ ] Firebase kirim email reset
- [ ] User klik link di email
- [ ] User ubah password via Firebase
- [ ] User login dengan email + password baru
- [ ] Backend login berhasil
- [ ] PasswordSyncHelper detect password berubah
- [ ] Backend sync succeed
- [ ] Firestore update dengan password hash baru
- [ ] User navigate ke dashboard

### Google Login:
- [ ] User click "Masuk dengan Google"
- [ ] Google auth succeed
- [ ] Firebase signIn succeed
- [ ] Backend account linking succeed
- [ ] [Jika user punya password]: PasswordSyncHelper.syncGoogleUserPassword() called
- [ ] Password di-sync ke backend & Firestore
- [ ] User navigate ke dashboard

### Edge Cases:
- [ ] Network error during sync → graceful fallback
- [ ] Backend endpoint down → app tetap work tapi password tidak tersync
- [ ] Password berbeda tapi sync fail → retry otomatis di login berikutnya

---

## 📝 Backend Endpoint Requirements

Pastikan backend memiliki endpoint:

```
POST /api/v1/users/firebase
```

**Expected body**:
```json
{
  "idToken": "firebase_id_token_dari_user",
  "newPassword": "password_yang_sudah_diubah_di_firebase"
}
```

**Expected response (sukses)**:
```json
{
  "success": true,
  "message": "Password updated",
  "data": {
    "token": "app_token_jika_ada",
    "expiredAt": 1234567890
  }
}
```

**Expected response (error)**:
```json
{
  "success": false,
  "error": "error_message"
}
```

---

## 🚀 Deployment Notes

1. **Firebase Console**: Pastikan password reset email sudah dikonfigurasi
2. **Backend**: Implementasi endpoint `/api/v1/users/firebase` jika belum ada
3. **Testing**: Test flow di development sebelum production
4. **Monitoring**: Monitor log untuk PasswordSyncHelper errors

---

## 📚 Related Files

- `lib/core/common/firebase_user_sync_helper.dart` - User sync helper
- `lib/core/common/shared_code.dart` - Utility functions
- `lib/feature/auth/service/firebase_integration_service.dart` - Firebase integration
- `lib/feature/auth/service/account_linking_service.dart` - Account linking

---

## 🔗 Summary

**Tanpa Dynamic Link**, flow reset password sekarang:
1. **Simple**: User cukup pakai email reset dari Firebase
2. **Auto-sync**: Password otomatis sync ketika login ulang
3. **Works offline**: Jika sync gagal, app tetap jalan (password akan retry di login berikutnya)
4. **Reliable**: Password selalu konsisten antara Firebase, Firestore, dan Backend

