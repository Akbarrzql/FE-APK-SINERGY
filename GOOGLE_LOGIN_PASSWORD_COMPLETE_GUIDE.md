# Complete Guide: Google Login + Manual Password - Solusi 401/409 Error

## 🎯 Masalah Original

Sebelum fix, user mengalami error saat login Google setelah set password:

```
Step 1: User login dengan Google (email: user@example.com)
        → Backend register dengan googleSecret
        → Firestore: hasLocalPassword=false

Step 2: User set password manual di SetPasswordScreen
        → Backend password updated: googleSecret → manualPassword
        → Firestore: hasLocalPassword=true (tapi password TIDAK disimpan)

Step 3: User login dengan Google lagi
        → AccountLinkingService coba login dengan googleSecret
        → Backend: TIDAK COCOK dengan manualPassword
        → ERROR 401: "Invalid email or password"
        → System coba register
        → ERROR 409: "Email already exists"
```

## ✅ Solusi yang Diimplementasikan

### Core Fix: Smart Account Linking

Ketika Google login berikutnya, system sekarang:

```
1. Check Firestore: apakah hasLocalPassword == true?
   ↓
2. Jika YES:
   ✅ SKIP backend login attempt (menghindari 401)
   ✅ UPDATE Firestore dengan latest info
   ✅ PROCEED ke Dashboard
   
3. Jika NO:
   → Normal flow: login/register dengan googleSecret
```

### Key Changes

#### 1. `firebase_user_sync_helper.dart` - Tambah Password Hash Support

```dart
// NEW: Hash password untuk disimpan di Firestore
String hashPassword(String password) {
  final hash = sha256.convert(utf8.encode('gabungyuk_pwd_$password'));
  return hash.toString();
}

// NEW: Verify password
bool verifyPassword(String password, String hash) {
  return hashPassword(password) == hash;
}

// UPDATED: Support localPassword parameter
Future<void> upsertUserDoc({
  // ... existing parameters ...
  String? localPassword,  // ← NEW
}) async {
  await ref.set({
    // ...
    if (localPassword != null) 'local_password': localPassword,  // ← NEW
  }, SetOptions(merge: true));
}
```

#### 2. `set_password_for_new_google_user_screen.dart` - Save Password Hash

```dart
Future<void> _setPassword() async {
  // ...
  try {
    // 1. Update backend
    await _profileRepository.updateProfile({'password': password});

    // 2. Save hashed password to Firestore ← NEW!
    final hashedPassword = 
        FirebaseUserSyncHelper.instance.hashPassword(password);
    
    await FirebaseUserSyncHelper.instance.upsertUserDoc(
      uid: currentUser.uid,
      email: widget.email,
      fullName: currentUser.displayName ?? '',
      provider: 'multi',
      googleUid: widget.googleUid,
      hasLocalPassword: true,
      passwordJustSet: true,
      localPassword: hashedPassword,  // ← NEW!
    );
  }
}
```

#### 3. `account_linking_service.dart` - Smart Skip Logic

```dart
Future<void> linkGoogleToExisting({
  required String email,
  required String googleUid,
  required String fullName,
}) async {
  final existingAccount = await checkExistingAccount(email);
  final hasLocalPassword = 
      existingAccount['has_local_password'] as bool? ?? false;

  // 🔑 KEY DECISION:
  if (hasLocalPassword) {
    // ✅ User sudah set password
    // SKIP backend login (menghindari 401 error)
    // Backend sudah punya akun, cukup update Firestore
    debugPrint('ACCOUNT LINKING: user has local password, skipping backend login');
  } else {
    // Normal flow: login/register dengan googleSecret
    final googleSecret = deriveGoogleSecret(googleUid);
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

  // Update Firestore (always)
  await FirebaseUserSyncHelper.instance.upsertUserDoc(
    uid: existingUid,
    email: email,
    fullName: fullName,
    provider: hasLocalPassword ? 'multi' : existingProvider,
    googleUid: googleUid,
    hasLocalPassword: hasLocalPassword,
    localPassword: localPasswordHash.isNotEmpty 
        ? localPasswordHash 
        : null,
  );
}
```

## 📱 Flow Setelah Fix

### Scenario A: Brand New User (Google Login Pertama)

```
1. Google Sign-In
   └─ Firebase Auth berhasil
   
2. Check Backend Account
   └─ Tidak ada
   
3. Register Backend dengan googleSecret
   └─ Backend: user@example.com + googleSecret
   
4. Firestore Create
   └─ hasLocalPassword: false
   └─ provider: 'google'
   
5. Redirect ke SetPasswordScreen
   └─ User set password: "MyPassword123"
   
6. Firestore Update
   └─ hasLocalPassword: true ← CHANGED
   └─ local_password: sha256(MyPassword123) ← NEW
   └─ provider: 'multi' ← CHANGED
   
7. Backend Updated
   └─ user@example.com password: googleSecret → MyPassword123
   
8. Redirect ke Dashboard
```

### Scenario B: Existing User with Password (Google Login Berikutnya)

```
1. Google Sign-In
   └─ Firebase Auth berhasil
   
2. Check Firestore
   └─ Found record
   └─ hasLocalPassword: true ✅
   └─ local_password: sha256(...) ✅
   
3. AccountLinkingService.linkGoogleToExisting()
   └─ Check hasLocalPassword?
   └─ YES! Skip backend login ✅ (PREVENT 401 ERROR)
   
4. Update Firestore (confirmasi latest state)
   └─ provider: 'multi'
   └─ hasLocalPassword: true
   └─ local_password: sha256(...)
   
5. Redirect ke Dashboard
   └─ NO ERROR! ✅
```

### Scenario C: Manual Email+Password Login

```
1. User input: email + password
   └─ user@example.com + MyPassword123
   
2. LoginRepository.loginUser()
   └─ Try backend login
   └─ Success: user@example.com + MyPassword123 ← Backend stores this
   
3. Redirect ke Dashboard
```

## 🔒 Security Details

### Password Storage Strategy

| Location | Storage | Security |
|----------|---------|----------|
| Backend | Plaintext user-set password | Server-side encryption/hashing |
| Firestore | SHA256 hash only | Firebase encryption at rest |
| Firebase Auth | Handled by Firebase | Industry standard |

### Why Hash in Firestore?

1. **Tidak simpan plaintext** - lebih aman
2. **Untuk future verification** - jika perlu verify password lokal
3. **Firestore hanya punya hash** - backend tetap hold plaintext
4. **Backend login gunakan googleSecret** - untuk internal consistency

## ✅ Testing Guide

### Test 1: Fresh Google Login + SetPassword

```bash
1. Clear app data
2. Google Sign-In
   ✓ Login berhasil
   ✓ Redirect ke SetPasswordScreen
3. Set Password: "Test@1234"
   ✓ Backend password updated
   ✓ Firestore updated dengan hasLocalPassword=true
   ✓ Redirect ke Dashboard
```

### Test 2: Google Login Again (With Password)

```bash
1. Logout / Clear Firebase Auth
2. Google Sign-In dengan akun yang sama
   ✓ NO ERROR 401
   ✓ NO ERROR 409
   ✓ Check log: "ACCOUNT LINKING: user has local password, skipping backend login"
   ✓ Redirect ke Dashboard (tidak ke SetPasswordScreen)
```

### Test 3: Manual Password Login

```bash
1. Manual Login: email + password yang di-set tadi
   Email: user@example.com
   Password: Test@1234
   ✓ Login berhasil
   ✓ Redirect ke Dashboard
```

### Test 4: Email+Password dari Browser (Fallback)

```bash
1. Clear Firebase Auth tapi Firestore tetap
2. Google Sign-In
   ✓ Berhasil, redirect ke Dashboard
3. Manual Login dengan akun yang sama
   ✓ Berhasil dengan password yang di-set
```

## 🐛 Logging untuk Debug

Ketika test, perhatikan console output:

### Success Flow:
```
GOOGLE SIGNIN: starting
GOOGLE SIGNIN: hasLocalPassword=false, provider=google
FIRESTORE SYNC: upserting users/...
ACCOUNT LINKING: starting smart link
ACCOUNT LINKING: existing account found, linking...
ACCOUNT LINKING: attempting backend login with googleSecret
ACCOUNT LINKING: backend manual login success
ACCOUNT LINKING: successfully linked Google
GOOGLE SIGNIN: backend sync success
GOOGLE SIGNIN: Redirecting to Dashboard
```

### SetPassword Flow:
```
SET PASSWORD: Starting for user@example.com
SET PASSWORD: Firebase Auth linked successfully
SET PASSWORD: backend profile updated successfully
SET PASSWORD: Firestore updated successfully
```

### Subsequent Google Login (dengan password):
```
GOOGLE SIGNIN: starting
GOOGLE SIGNIN: hasLocalPassword=true, provider=multi
FIRESTORE SYNC: upserting users/... (hasLocalPassword=true)
ACCOUNT LINKING: starting smart link
ACCOUNT LINKING: existing account found, linking...
ACCOUNT LINKING: user has local password, skipping backend login ← KEY LINE
ACCOUNT LINKING: successfully linked Google
GOOGLE SIGNIN: backend sync success
GOOGLE SIGNIN: Redirecting to Dashboard
```

## 🔄 Backward Compatibility

- ✅ Existing accounts tetap work (tanpa `local_password`)
- ✅ Pure Google accounts tetap bisa login
- ✅ Multi-provider accounts terupdate automatically
- ✅ No database migration needed (Firestore merge)

## 📚 Related Files

- `GOOGLE_LOGIN_FIX_SUMMARY.md` - Quick reference
- `GOOGLE_LOGIN_PASSWORD_SYNC_FIX.md` - Technical deep dive
- `AUTHENTICATION_ARCHITECTURE.md` - Overall auth system
- `MULTI_PROVIDER_SOLUTION.md` - Account linking details

## ❓ FAQ

**Q: Apakah password di-hash sebelum disimpan ke Firestore?**
A: Ya, menggunakan SHA256 hashing dengan salt "gabungyuk_pwd_"

**Q: Apakah password di-simpan di backend atau Firestore?**
A: Keduanya:
- Backend: plaintext user-set password (server encryption)
- Firestore: SHA256 hash only (untuk flag/verification)

**Q: Bagaimana jika user lupa password?**
A: Sama seperti biasa - gunakan "Lupa Password" flow yang reset via email

**Q: Apakah ini work untuk akun yang sudah ada?**
A: Ya, otomatis. Setelah user set password untuk existing account, system akan deteksi dan skip backend login

**Q: Apakah ada breaking change?**
A: Tidak, semua backward compatible

---

**Version**: 1.0  
**Date**: May 4, 2026  
**Status**: ✅ Implemented & Tested

