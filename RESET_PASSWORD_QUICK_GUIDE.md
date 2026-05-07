# 🚀 Reset Password Flow - Quick Reference

## ✨ Apa yang Berubah?

### ❌ DIHAPUS:
- Dynamic Link integration (`firebase_dynamic_links`)
- Deep Link Service (`deep_link_service.dart`)
- Manual password sync form di Forgot Password Screen
- Complex deep link handling di `main.dart`

### ✅ DITAMBAH:
- **Password Sync Helper** (`password_sync_helper.dart`) - Auto-sync password saat login
- **Auto-verify** - Pengecekan password hash saat login

---

## 📍 4 Langkah Flow (User Perspective)

```
1️⃣  INPUT EMAIL
    User buka ForgotPasswordScreen
    └─> Input email → Click "Kirim Email Reset"

2️⃣  RESET DI EMAIL
    User buka email dari Firebase
    └─> Klik link → Ubah password di Firebase

3️⃣  LOGIN ULANG
    User login menggunakan password baru
    └─> Email + password baru → Click "Masuk"

4️⃣  AUTO-SYNC ✨
    App otomatis:
    ├─> Detect password berbeda
    ├─> Sync ke backend
    ├─> Update Firestore
    └─> Login success → Dashboard
```

---

## 🔧 Technical Flow

### Manual Login Path:
```
Login Button
  └─> LoginBloc: SignInWithBackend
      └─> Backend: Login Success
          └─> _safeFirebaseSignIn(email, password)
              └─> FirebaseAuth.signInWithEmailAndPassword()
                  └─> PasswordSyncHelper.checkAndSyncPasswordIfChanged()
                      ├─> Compare: Firestore hash vs new password hash
                      ├─> If different: Call backend /api/v1/users/firebase
                      ├─> Update Firestore with new hash
                      └─> Return success/fail
              └─> BlocConsumer: Navigate to Dashboard
```

### Google Login Path:
```
Google Sign-In Button
  └─> FirebaseIntegrationService.signInWithGoogleAndSync()
      └─> GoogleSignIn.authenticate()
          └─> FirebaseAuth.signInWithCredential()
              └─> AccountLinkingService.smartAccountLink()
                  └─> Backend: Account Linking
                      └─> If hasLocalPassword == true:
                          └─> PasswordSyncHelper.syncGoogleUserPassword()
                              ├─> Derive password dari googleUid
                              ├─> Call backend /api/v1/users/firebase
                              ├─> Update Firestore
                              └─> Return
                      └─> Navigate to Dashboard
```

---

## 📁 Files Summary

| File | Change | Purpose |
|------|--------|---------|
| `password_sync_helper.dart` | ✨ NEW | Auto-sync password on login |
| `login_screen.dart` | ✏️ MODIFIED | Call password sync after Firebase signIn |
| `firebase_integration_service.dart` | ✏️ MODIFIED | Call password sync for Google users |
| `forgot_password_screen.dart` | ✏️ MODIFIED | Removed manual sync form |
| `main.dart` | ✏️ MODIFIED | Removed dynamic link logic |
| `splash_screen.dart` | ✏️ MODIFIED | Removed deep_link_service reference |

---

## 🎯 Key Methods

### 1. PasswordSyncHelper.checkAndSyncPasswordIfChanged()
Used by: Manual login flow
```dart
// Called in login_screen.dart after Firebase success
await PasswordSyncHelper.instance.checkAndSyncPasswordIfChanged(
  email: email,
  currentPassword: password,
);
```

**What it does**:
1. Get user dari Firestore
2. Hash password login
3. Compare dengan hash di Firestore
4. Jika berbeda: sync ke backend + update Firestore
5. Return true/false

---

### 2. PasswordSyncHelper.syncGoogleUserPassword()
Used by: Google login flow
```dart
// Called in firebase_integration_service.dart after Google signIn
if (hasLocalPassword) {
  await PasswordSyncHelper.instance.syncGoogleUserPassword(
    email: email,
    googleUid: googleUid,
    fullName: fullName,
  );
}
```

**What it does**:
1. Derive password dari googleUid
2. Call backend /api/v1/users/firebase
3. Update Firestore dengan hash
4. Silent operation (tidak interrupt user flow)

---

## 🐛 Error Handling

**Password sync fail** → App tetap berjalan ✓
- Reason: Backend login sudah sukses
- Next login: Will retry sync

**Firestore update fail** → Password tetap di backend ✓
- Reason: Backend data bersih
- Next login: Will retry Firestore update

**Backend endpoint error** → App tetap berjalan ✓
- Reason: Password tetap di local Firebase
- Next login: Will retry backend sync

---

## 🧪 Test Scenarios

### ✅ Scenario 1: Reset Password (Manual Login)
1. User forgot password → Send reset email
2. User ubah password di Firebase
3. User login dengan password baru
4. **Expected**: Password sync, login success

### ✅ Scenario 2: Google User with Password
1. User sudah punya Google account + password
2. User login dengan Google
3. **Expected**: Auto-sync derived password to backend & Firestore

### ✅ Scenario 3: Network Problem During Sync
1. User login dengan password baru
2. Backend sync fail (network error)
3. **Expected**: Login success, sync akan retry di login berikutnya

---

## 📊 Debug Logs

Look for these in console:

```
PASSWORD_SYNC: Password tidak berubah
PASSWORD_SYNC: Password berubah, melakukan sync
PASSWORD_SYNC: Calling backend POST /api/v1/users/firebase
PASSWORD_SYNC: Backend response status=200
PASSWORD_SYNC: Firestore updated successfully
PASSWORD_SYNC: Google user password synced
PASSWORD_SYNC ERROR: ...
```

---

## 🚀 Production Checklist

Before deploying:

- [ ] Backend endpoint `/api/v1/users/firebase` implemented
- [ ] Firebase email template configured
- [ ] Test manual reset flow end-to-end
- [ ] Test Google login with password
- [ ] Test offline scenario (password will retry)
- [ ] Monitor logs for sync errors
- [ ] Backup your database

---

## 📞 Support

If password sync not working:

1. **Check Firebase email**: Verify email was received
2. **Check backend logs**: Look for `/api/v1/users/firebase` errors
3. **Check Firestore**: Verify user doc exists with correct structure
4. **Check app logs**: Look for `PASSWORD_SYNC ERROR` messages

---

## 🎓 Understanding Password Hash

All passwords stored in Firestore are **hashed** using SHA256:

```dart
// Hash formula:
sha256('gabungyuk_pwd_$password')

// Example:
password = "MyPassword123"
hash = sha256('gabungyuk_pwd_MyPassword123') 
    = "a1b2c3d4e5..." (64 char hex string)
```

**Compare**: New login password hashed → compared to Firestore hash
**If different** → Password has changed → Sync needed

For Google users, special derived password:
```dart
sha256('gabungyuk_google_$googleUid').substring(0, 24) + 'Ab@1'
```

---

## 🔐 Security Notes

✅ Passwords **never stored in plain text** in Firestore
✅ Passwords **transmitted over HTTPS** only
✅ Firebase handles password reset securely
✅ Backend verifies idToken before accepting new password

---

## 💡 Why No Dynamic Link?

Old way (Dynamic Link):
- Firebase sends email with magic link
- App opens with `oobCode`
- App shows reset form directly
- Too complex for this requirement

New way (Simple Email Reset):
- Firebase sends standard reset email
- User resets password anywhere (browser, email app, etc.)
- App detects change automatically on next login
- **Simpler, more reliable, better UX**

