# FIX: Google Login + Password Sync Error (401/409)

## Problem
- User login dengan Google + set password pertama kali
- Google login kembali → ERROR 401 "Invalid email or password" 
- System coba register → ERROR 409 "Email already exists"

## Root Cause
Backend password berubah dari `googleSecret` (saat register) → `manual password` (saat set password).
Ketika Google login kembali, system masih coba login dengan `googleSecret` yang tidak match dengan backend password baru.

## Solution Overview

### 1️⃣ Store Password Hash di Firestore
```
Firestore user doc:
{
  has_local_password: true,
  local_password: "sha256_hashed_password"  ← NEW
}
```

### 2️⃣ Smart Account Linking
```
if (user.has_local_password == true) {
  // Skip backend login attempt (menghindari 401)
  // Backend sudah punya akun, just update Firestore
} else {
  // Normal flow: login/register dengan googleSecret
}
```

### 3️⃣ When User Sets Password
```
SetPasswordForNewGoogleUserScreen._setPassword():
  1. Update backend password
  2. Update Firestore:
     - hasLocalPassword = true
     - localPassword = hash(password)
```

## Files Modified

| File | Change |
|------|--------|
| `firebase_user_sync_helper.dart` | + `localPassword` param, + `hashPassword()`, + `verifyPassword()` |
| `set_password_for_new_google_user_screen.dart` | Save password hash to Firestore |
| `account_linking_service.dart` | Skip backend login if `hasLocalPassword=true` |
| `firebase_integration_service.dart` | Store localPassword from Firestore |
| `login_repository.dart` | Better fallback Google Secret resolution |

## Expected Behavior After Fix

### First Google Login (New User)
```
Google Login → Backend Register (with googleSecret) 
→ SetPasswordScreen → User Sets Password
→ Backend Updated (password changed)
→ Firestore Updated (hasLocalPassword=true, localPassword=hash)
→ Dashboard
```

### Subsequent Google Login (Has Password)
```
Google Login → Check Firestore (hasLocalPassword=true)
→ SKIP backend login (prevent 401 error) ✅
→ Firestore Updated
→ Dashboard
```

## No Breaking Changes
- Existing Google login flow maintained
- Manual email+password login unaffected
- Backward compatible with existing Firestore records
- Optional `localPassword` field (nullable)

## Testing
- [x] Google login first time works
- [x] Set password works
- [x] Google login again works (no 401/409)
- [x] Manual password login works
- [x] Account linking works

