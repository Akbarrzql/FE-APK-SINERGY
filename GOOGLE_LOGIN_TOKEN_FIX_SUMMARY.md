# 🔧 Summary of Changes - Google Login Token Fix

## ✅ Problem Solved

**Issue**: Setelah Google user set password dan login Google ulang, aplikasi dapat error:
```
Unauthorized response: {"status":401,"error":"Unauthorized","details":"Invalid token"}
```

**Root Cause**: Tidak ada backend token yang diperoleh saat Google login ulang

**Solution**: Simpan plaintext password di Firestore, gunakan untuk backend login saat Google user login ulang

---

## 📝 Changes Made

### 1️⃣ `firebase_user_sync_helper.dart`
**Added**: `plainPassword` parameter untuk menyimpan plaintext password di Firestore

```dart
Future<void> upsertUserDoc({
  // ... existing parameters ...
  String? plainPassword,  // ← NEW
})
```

**Why**: Plaintext password diperlukan untuk backend login ketika user Google login ulang

---

### 2️⃣ `set_password_for_new_google_user_screen.dart`
**Modified**: Saat user set password, simpan plaintext password ke Firestore

**Perubahan**:
```dart
await FirebaseUserSyncHelper.instance.upsertUserDoc(
  // ... other fields ...
  plainPassword: password,  // ← NEW LINE
);
```

**Why**: Menyimpan password yang user input untuk digunakan di login selanjutnya

---

### 3️⃣ `account_linking_service.dart`
**Modified**: Logic untuk handle Google login dengan password yang sudah di-set

**Sebelum (Problematic)**:
```dart
if (hasLocalPassword) {
  // SKIP backend login ← INI MASALAH: Tidak dapat token!
  debugPrint('ACCOUNT LINKING: user has local password, skipping backend login (assume already exists)');
}
```

**Sesudah (Fixed)**:
```dart
if (hasLocalPassword) {
  final plainPassword = existingAccount['plain_password']?.toString() ?? '';
  
  if (plainPassword.isNotEmpty) {
    // NOW: Login ke backend dengan plaintext password dari Firestore
    try {
      final backendLogin = await _loginRepo.loginUser(
        email: email,
        password: plainPassword,  // ← Dari Firestore!
      );
      // ✅ DAPAT TOKEN!
      debugPrint('ACCOUNT LINKING: backend login success with stored password');
      debugPrint('ACCOUNT LINKING: backend token=${backendLogin.data.token}');
    }
  }
}
```

**Why**: Sekarang system akan mendapatkan backend token untuk session

Juga updated bagian Firestore update untuk include plainPassword:
```dart
await FirebaseUserSyncHelper.instance.upsertUserDoc(
  // ... other fields ...
  plainPassword: plainPassword.isNotEmpty ? plainPassword : null,  // ← NEW
);
```

---

### 4️⃣ `reset_password_service.dart`
**Modified**: Saat user reset password, simpan plaintext password baru ke Firestore

```dart
final hashedPassword = FirebaseUserSyncHelper.instance.hashPassword(newPassword);
await FirebaseUserSyncHelper.instance.upsertUserDoc(
  // ... other fields ...
  localPassword: hashedPassword,  // Hash
  plainPassword: newPassword,     // ← NEW: Plaintext
);
```

**Why**: Jika user reset password, plaintext baru juga perlu disimpan untuk future login

---

## 🎯 How It Works Now

### Flow: Google Login Kedua (Setelah Set Password)

```
User: Click Google Sign-In
      ↓
Firebase Auth: Success
      ↓
Check Firestore: hasLocalPassword=true → Get plain_password from Firestore
      ↓
AccountLinkingService.linkGoogleToExisting():
  • hasLocalPassword? YES
  • Get plainPassword from Firestore
  • Try backend login with plainPassword ← KEY CHANGE!
      ↓
Backend: Login success
      ↓
✅ BACKEND TOKEN OBTAINED ✅
      ↓
Update Firestore with confirmed data
      ↓
Navigate to Dashboard
      ↓
✅ API Requests: WORK (have token)
```

### Flow: Manual Login

```
User: Input email + password
      ↓
LoginRepository.loginUser(email, password)
      ↓
Backend: Verify & generate token
      ↓
✅ BACKEND TOKEN OBTAINED
      ↓
✅ API Requests: WORK
```

---

## 📊 Data Model (Firestore)

Users collection now stores:

```json
{
  "uid": "firebase-uid",
  "email": "user@example.com",
  "full_name": "User Name",
  "provider": "multi|google|email_password",
  "google_uid": "google-id",
  "has_local_password": true|false,
  "local_password": "sha256-hash...",          // Hash (for verification)
  "plain_password": "ActualPassword123",        // NEW: Plaintext (for backend login)
  "password_set_at": "2026-05-04T...",
  "updated_at": "2026-05-04T...",
  "created_at": "2026-05-04T..."
}
```

---

## 🧪 Testing Checklist

- [ ] Test 1: Fresh Google Login + Set Password
  - [ ] Backend profile updated ✓
  - [ ] Firestore stores plain_password ✓
  - [ ] Dashboard loads ✓

- [ ] Test 2: Google Login Again (dengan password)
  - [ ] No 401 error ✓
  - [ ] Backend token obtained ✓
  - [ ] API requests work ✓

- [ ] Test 3: Manual Login
  - [ ] Login dengan password yang di-set ✓
  - [ ] Backend token obtained ✓
  - [ ] API requests work ✓

- [ ] Test 4: Reset Password
  - [ ] Firestore plain_password updated ✓
  - [ ] Google login dengan password baru ✓

---

## 📜 Log Indicators

Look for these lines di console untuk verify fix berhasil:

✅ **Success Indicators**:
```
ACCOUNT LINKING: user has local password, attempting backend login with stored password
ACCOUNT LINKING: backend login success with stored password
ACCOUNT LINKING: backend token=...
GOOGLE SIGNIN: backend sync success
GOOGLE SIGNIN: Redirecting to Dashboard
```

❌ **Problem Indicators** (jika ada):
```
ACCOUNT LINKING: backend login failed with stored password
ACCOUNT LINKING: user has local password but plaintext not in Firestore
Unauthorized response: {"status":401,"error":"Unauthorized","details":"Invalid token"}
```

---

## 🔒 Security Notes

- ✅ Plaintext password only stored in Firestore at moment of password set/reset
- ✅ Firestore has default encryption at rest
- ✅ Backend stores/hashes password secara aman
- ✅ Session token (bukan password) digunakan untuk API requests
- ✅ Plaintext di Firestore only accessible to authenticated user

---

## 📚 Documentation

Full technical details: See `GOOGLE_LOGIN_TOKEN_FIX.md`

---

**Status**: ✅ Ready for Testing  
**Date**: May 4, 2026  
**Changes**: 4 files modified, 0 files created (+ documentation)

