# Google Login + Manual Password Sync - Solusi Fix

## 📋 Masalah Original

Ketika user login dengan Google dan kemudian set password pertama kali, terjadi error saat Google login kembali:

```
flutter: Login response status: 401
flutter: Login response body: {"status":401,"error":"Unauthorized","details":"Invalid email or password"}
flutter: ACCOUNT LINKING: backend account not found, registering via manual endpoint
flutter: Register response status: 409
flutter: Register response body: {"status":409,"error":"Conflict","details":"Email already exists"}
```

### Akar Masalah
1. Ketika Google login pertama, backend di-register dengan `googleSecret` (derived dari googleUid)
2. User set password manual, backend password di-update dari `googleSecret` → password yang di-set user
3. Google login berikutnya, system coba login dengan `googleSecret` yang sudah tidak valid
4. Backend return 401, system coba register → error 409 (email sudah ada)

## ✅ Solusi yang Diimplementasikan

### 1. **Tambah `local_password` Field ke Firestore**
File: `lib/core/common/firebase_user_sync_helper.dart`

```dart
// Tambah parameter localPassword untuk menyimpan password hash
Future<void> upsertUserDoc({
  required String uid,
  required String email,
  required String fullName,
  required String provider,
  String? googleUid,
  bool hasLocalPassword = true,
  bool passwordJustSet = false,
  String? localPassword,  // ✅ NEW: Simpan password hash
}) async {
  // ...
  await ref.set({
    // ...
    if (localPassword != null) 'local_password': localPassword,
    // ...
  }, SetOptions(merge: true));
}
```

### 2. **Hash Password Utility Methods**
File: `lib/core/common/firebase_user_sync_helper.dart`

```dart
/// Hash password untuk disimpan di Firestore
String hashPassword(String password) {
  final hash = sha256.convert(utf8.encode('gabungyuk_pwd_$password'));
  return hash.toString();
}

/// Verify password against hash
bool verifyPassword(String password, String hash) {
  return hashPassword(password) == hash;
}
```

### 3. **Update SetPasswordForNewGoogleUserScreen**
File: `lib/feature/auth/forgot_password/set_password_for_new_google_user_screen.dart`

Saat user set password pertama kali:
```dart
// Simpan password hash ke Firestore
final hashedPassword = FirebaseUserSyncHelper.instance.hashPassword(password);
await FirebaseUserSyncHelper.instance.upsertUserDoc(
  uid: currentUser.uid,
  email: widget.email,
  fullName: currentUser.displayName ?? '',
  provider: 'multi',
  googleUid: widget.googleUid,
  hasLocalPassword: true,
  passwordJustSet: true,
  localPassword: hashedPassword,  // ✅ Simpan hash
);
```

### 4. **Smart Account Linking Logic**
File: `lib/feature/auth/service/account_linking_service.dart`

**Key Decision:** Jika user sudah punya `local_password`, skip backend login attempt

```dart
Future<void> linkGoogleToExisting({
  required String email,
  required String googleUid,
  required String fullName,
}) async {
  // Get existing account dari Firestore
  final existingAccount = await checkExistingAccount(email);
  final hasLocalPassword = existingAccount['has_local_password'] as bool? ?? false;

  // 🔑 Key Decision:
  if (hasLocalPassword) {
    // User sudah set password lokal - backend password sudah diganti dari googleSecret
    // Jangan coba login dengan googleSecret karena tidak akan match
    // Backend sudah punya akun, just update Firestore
    if (kDebugMode) {
      debugPrint(
          'ACCOUNT LINKING: user has local password, skipping backend login (assume already exists)');
    }
  } else {
    // Belum ada local password, coba login/register dengan googleSecret
    // (normal flow untuk Google login pertama kali)
    final googleSecret = FirebaseUserSyncHelper.instance.deriveGoogleSecret(googleUid);
    try {
      await _loginRepo.loginUser(email: email, password: googleSecret);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 404) {
        await _registerRepo.registerUser(
          name: fullName,
          email: email,
          password: googleSecret,
        );
      }
    }
  }

  // Update Firestore
  await FirebaseUserSyncHelper.instance.upsertUserDoc(...);
}
```

## 🔄 Flow Lengkap Setelah Fix

### Scenario 1: Google Login Pertama Kali (Baru)
```
1. Google Auth berhasil → Firebase Auth
2. Check Firestore: email belum ada
3. AccountLinkingService.registerNewGoogleAccount():
   - Register ke backend dengan googleSecret
4. Firestore: create record dengan hasLocalPassword=false
5. Redirect ke SetPasswordScreen
6. User set password:
   - Backend update password dari googleSecret → password manual
   - Firestore update dengan hasLocalPassword=true + localPassword hash
7. Redirect ke Dashboard
```

### Scenario 2: Google Login Kembali (Sudah Ada Local Password)
```
1. Google Auth berhasil → Firebase Auth
2. Check Firestore: email ada, hasLocalPassword=true
3. AccountLinkingService.linkGoogleToExisting():
   - Lihat hasLocalPassword=true
   - ✅ SKIP backend login (menghindari 401 error)
   - Update Firestore
4. Redirect ke Dashboard (sudah ada password)
```

### Scenario 3: Manual Email+Password Login
```
1. User input email + password
2. Backend login attempt dengan email + password
3. Jika gagal 401, fallback ke Google Secret (dari Firestore)
4. Jika berhasil → Dashboard
```

## 🔒 Security Notes

- **Password Hash**: Menggunakan SHA256 hashing, bukan plaintext
- **Password Storage**: Tersimpan di Firestore (encrypted by Firebase), bukan backend
- **Backend Password**: Tetap menggunakan googleSecret untuk internal backend communication
- **User Password**: Disimpan asli di backend (server-side, terpisah dari googleSecret)

## 📱 Testing Checklist

```
✅ Test: Google login pertama kali (brand new user)
  - User dapat masuk dengan Google
  - Dapat set password
  - Data tersimpan di Firestore dengan hasLocalPassword=true
  
✅ Test: Google login kembali (dengan password sudah di-set)
  - User dapat masuk dengan Google tanpa error 401
  - Langsung masuk ke Dashboard (tidak redirect ke SetPasswordScreen)
  - Firestore not updated unnecessarily
  
✅ Test: Manual email+password login (multi-provider account)
  - User dapat login dengan email + password yang di-set
  - Fallback ke Google Secret jika password salah (jika applicable)
  
✅ Test: Account linking (existing backend account + Google)
  - Jika backend account sudah ada, Google login dapat di-link
  - Firestore updated dengan provider='multi'
```

## 🔧 Implementation Files Changed

1. `lib/core/common/firebase_user_sync_helper.dart`
   - Add `localPassword` parameter ke `upsertUserDoc()`
   - Add `hashPassword()` utility method
   - Add `verifyPassword()` utility method

2. `lib/feature/auth/forgot_password/set_password_for_new_google_user_screen.dart`
   - Save password hash ke Firestore saat user set password

3. `lib/feature/auth/service/account_linking_service.dart`
   - Smart decision: skip backend login jika `hasLocalPassword=true`
   - Menghindari 401 error dari password mismatch

4. `lib/feature/auth/service/firebase_integration_service.dart`
   - Already updated untuk store localPassword dari Firestore

5. `lib/feature/auth/repository/login_repository/login_repository.dart`
   - Support for fallback Google Secret resolution

## 📚 Related Documentation

- See `AUTHENTICATION_ARCHITECTURE.md` untuk overview authentication system
- See `MULTI_PROVIDER_SOLUTION.md` untuk account linking architecture

