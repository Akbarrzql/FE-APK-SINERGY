# Fix: Manual Register + Google Login Token Issue

## 🎯 Masalah yang Ditemukan

**Scenario**:
1. User register manual (email + password)
2. User logout dan login manual lagi - Works ✓
3. User logout dan Google login dengan email yang sama - 401 Invalid token ❌

**Log menunjukkan**:
```
FIRESTORE SYNC: upserting users/devocta08@gmail.com (...hasLocalPassword=true)
ACCOUNT LINKING: successfully linked Google to devocta08@gmail.com
GOOGLE SIGNIN: backend sync success
GOOGLE SIGNIN: Redirecting to Dashboard
flutter: Unauthorized response: {"status":401,"error":"Unauthorized","details":"Invalid token"}
```

**Root Cause**:
- Ketika user **register manual**, password TIDAK disimpan ke Firestore
- Hanya name, email, dan provider yang disimpan
- Kemudian saat Google login dengan email yang sama, system mencari `plain_password` dari Firestore untuk backend login
- Karena kosong, system tidak bisa login ke backend → tidak mendapat token → 401 error

---

## ✅ Solusi yang Diimplementasikan

### **Ubah flow Register Manual**

**Sebelum** (registerUser → _syncUserToFirestore):
```dart
await _syncUserToFirestore(
  name: name,
  email: email,
  provider: 'email_password',
  // password TIDAK disimpan ← MASALAH!
);
```

**Sesudah**:
```dart
await _syncUserToFirestore(
  name: name,
  email: email,
  provider: 'email_password',
  password: password,  // ← NEW: Simpan password ke Firestore!
);
```

### **Update _syncUserToFirestore method**

**Sebelum**:
```dart
Future<void> _syncUserToFirestore({
  required String name,
  required String email,
  required String provider,
}) async {
  await FirebaseUserSyncHelper.instance.upsertUserDoc(
    uid: uid,
    email: email,
    fullName: name,
    provider: provider,
    hasLocalPassword: true,
    // Password fields: TIDAK ADA
  );
}
```

**Sesudah**:
```dart
Future<void> _syncUserToFirestore({
  required String name,
  required String email,
  required String provider,
  String? password,  // ← NEW parameter
}) async {
  final hashedPassword = password != null 
      ? FirebaseUserSyncHelper.instance.hashPassword(password)
      : null;

  await FirebaseUserSyncHelper.instance.upsertUserDoc(
    uid: uid,
    email: email,
    fullName: name,
    provider: provider,
    hasLocalPassword: true,
    localPassword: hashedPassword,      // ← NEW: Hash
    plainPassword: password,             // ← NEW: Plaintext
  );
}
```

---

## 🔄 Flows yang Sekarang Bekerja

### **Scenario 1: Register Manual First Time**
```
User input: email@example.com + password123
      ↓
Backend Register: Success, get token
      ↓
Firestore Update:
  - provider: 'email_password'
  - hasLocalPassword: true
  - local_password: sha256(password123)  ← Hash
  - plain_password: "password123"        ← Plaintext ✨ NEW!
      ↓
✅ Dashboard (with token)
```

### **Scenario 2: Manual Login Again**
```
User input: email@example.com + password123
      ↓
Backend Login: Success, get token
      ↓
✅ Dashboard (with token)
```

### **Scenario 3: Switch to Google Login (After Manual Register)**
```
User: Google Sign-In dengan email@example.com
      ↓
Firebase Auth: Success
      ↓
Check Firestore: hasLocalPassword=true + plain_password="password123" ✅
      ↓
AccountLinkingService.linkGoogleToExisting():
  - Get plain_password from Firestore
  - Backend Login: email@example.com + password123 ← From Firestore!
      ↓
✅ Backend Login Success - GET TOKEN ✅
      ↓
Update Firestore: provider='multi'
      ↓
✅ Dashboard (with token) ✅
      ↓
✅ API calls WORK ✅
```

---

## 📝 File yang Diubah

### `register_repository.dart`

**Change 1**: Pass password to _syncUserToFirestore
```dart
// Line 50-54
await _syncUserToFirestore(
  name: name,
  email: email,
  provider: 'email_password',
  password: password,  // ← NEW
);
```

**Change 2**: Update _syncUserToFirestore method signature and implementation
```dart
// Line 149-171
Future<void> _syncUserToFirestore({
  required String name,
  required String email,
  required String provider,
  String? password,  // ← NEW
}) async {
  // ... calculate hashed password ...
  
  await FirebaseUserSyncHelper.instance.upsertUserDoc(
    // ... existing fields ...
    localPassword: hashedPassword,      // ← NEW
    plainPassword: password,             // ← NEW
  );
}
```

---

## 🧪 Testing the Fix

### **Test Case 1: Fresh Manual Register**
```
1. Clear app cache
2. Register Manual
   - Email: test@example.com
   - Password: TestPass123
   ✓ Backend registration success
   ✓ Token obtained
   ✓ Firestore has plain_password = "TestPass123"
   ✓ Dashboard loads
```

### **Test Case 2: Manual Login Again**
```
1. Logout
2. Login Manual: test@example.com + TestPass123
   ✓ Login success
   ✓ Token obtained
   ✓ API calls work
```

### **Test Case 3: Google Login After Manual Register** ← MAIN TEST
```
1. Logout
2. Google Sign-In (same email: test@example.com)
   ✓ NO 401 error ✅
   ✓ Backend token obtained ✅
   ✓ API calls work ✅
3. Get Profile
   ✓ Success (200 OK) ✅
```

### **Test Case 4: Mix Scenarios**
```
1. Register Manual (email: user@example.com, password: Pass123)
   ✓ Success
2. Logout
3. Google Login (same email)
   ✓ Success - auto-linked
4. Logout
5. Manual Login (email + Pass123)
   ✓ Success
6. Logout
7. Google Login again
   ✓ Success (same token flow)
```

---

## 📊 Updated Data Model (Firestore)

After manual register, Firestore now stores:

```json
{
  "uid": "managed-by-firestore",
  "email": "devocta08@gmail.com",
  "full_name": "User Name",
  "provider": "email_password",  // First time
  "has_local_password": true,
  "local_password": "sha256hash...",
  "plain_password": "ActualPassword123",  // ← NEW: Plain password for Google login
  "created_at": "2026-05-04T...",
  "updated_at": "2026-05-04T..."
}
```

When Google login happens later:
```json
{
  "provider": "multi",  // ← Changed
  "google_uid": "google-id",  // ← Added
  "plain_password": "ActualPassword123",  // ← USED for backend login
  // ... other fields unchanged
}
```

---

## 🔑 Key Points

1. **Manual Register Now Stores Password**: When user registers manually, both hashed and plaintext passwords are saved to Firestore
2. **Account Linking Uses Stored Password**: When same email logs in via Google, AccountLinkingService retrieves plaintext password from Firestore
3. **Backend Login Success**: With plaintext password, backend login succeeds and token is obtained
4. **Multi-Provider Seamless**: User can now seamlessly switch between manual and Google login without token errors

---

## 🚀 Expected Log Output

### Before Fix:
```
ACCOUNT LINKING: user has local password, skipping backend login
ACCOUNT LINKING: successfully linked Google
GOOGLE SIGNIN: backend sync success
═ PROBLEM: No token obtained ═
Unauthorized response: 401 Invalid token
```

### After Fix:
```
ACCOUNT LINKING: user has local password, attempting backend login with stored password
ACCOUNT LINKING: backend login success with stored password
ACCOUNT LINKING: backend token=eyJ0eXAiOiJKV1QiLCJhbGc...
ACCOUNT LINKING: successfully linked Google
GOOGLE SIGNIN: backend sync success
✅ Dashboard loads with token
✅ API calls work!
```

---

## ✨ Summary

| Scenario | Before | After |
|----------|--------|-------|
| Register Manual | ✓ Works | ✓ Works + saves password |
| Login Manual | ✓ Works | ✓ Works |
| Google Login (new) | ✓ Works | ✓ Works |
| Google Login (after manual) | ❌ 401 Error | ✅ Works with token |
| Switch providers | ❌ Breaks | ✅ Seamless |

---

**Version**: 1.0  
**Date**: May 4, 2026  
**Status**: ✅ Implemented & Ready for Testing

**Related Documentation**:
- `GOOGLE_LOGIN_TOKEN_FIX.md` - Google login token fix
- `GOOGLE_LOGIN_TOKEN_FIX_SUMMARY.md` - Summary of changes
- `AUTHENTICATION_ARCHITECTURE.md` - Overall auth system

