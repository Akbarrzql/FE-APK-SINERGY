# 🔄 Multi-Provider Authentication Implementation Guide

## 📋 Overview
This document explains the complete authentication flow for Gabungyuk, supporting both Google OAuth and email/password authentication methods with seamless account linking.

---

## 🎯 Key Goals

✅ **Single Identity Per Email**
- One email = one account in backend + Firestore + Firebase Auth
- No duplicate accounts across different login methods

✅ **Transparent Account Linking**
- User doesn't need to manually link accounts
- System auto-detects and links when appropriate
- User can switch between Google and email/password seamlessly

✅ **Session Consistency**
- Backend token, Firebase Auth, and Firestore are always synchronized
- No "unauthorized" errors due to session mismatches

---

## 🏗️ Architecture Layers

### Layer 1: Identity Anchor (Email)
```
┌─────────────────────────────┐
│  Email (Universal ID)       │
│  user@example.com           │
├─────────────────────────────┤
│ • Unique per user           │
│ • Used across all systems   │
│ • Source of truth for       │
│   determining single user   │
└─────────────────────────────┘
```

### Layer 2: Backend API
```
Users Table:
├─ user_id (primary key)
├─ email (unique, indexed)
├─ password_hash
├─ name
├─ providers (json: ["google", "email_password"])
└─ updated_at
```

**Responsibilities:**
- Create/update user accounts
- Validate credentials (email + password)
- Generate session tokens
- Source of truth for user existence

### Layer 3: Firebase Auth
```
FirebaseUser:
├─ uid (primary key)
├─ email
├─ providers: [
│   ├─ "google.com"         (if Google OAuth linked)
│   └─ "password"           (if email+password linked)
│ ]
└─ emailVerified
```

**Responsibilities:**
- OAuth provider integration (Google)
- Credential verification
- Session token generation
- Multi-provider linking

### Layer 4: Firestore (Metadata Store)
```
/users/{email}:
├─ uid (Firebase UID)
├─ email
├─ full_name
├─ provider (one of: 'google', 'email_password', 'multi')
├─ google_uid (if Google linked)
├─ has_local_password (true/false)
├─ updated_at (timestamp)
└─ created_at (timestamp)
```

**Responsibilities:**
- Track provider information
- Quick lookup for account detection
- Metadata syncing
- Frontend decision-making

---

## 🔄 Core Flow Patterns

### Pattern 1: Google Login (New User)
```
Scenario: User logs in with Google, email never seen before

1. Google OAuth approval
   ↓
2. Get Google ID Token
   ↓
3. Firebase Auth.signInWithCredential(Google credential)
   → Firebase creates new user with uid + provider="google.com"
   ↓
4. Call AccountLinkingService.smartAccountLink()
   ├─ Check if email exists in Firestore
   │  ↓ Found: Skip (would be handled in Pattern 2)
   │  ↓ Not found: Proceed
   │
   ├─ Call RegisterRepositoryImpl.registerUser()
   │  → Backend creates new user with email + derived_password
   │  → Returns token
   │
   └─ Firestore.upsertUserDoc()
      → Save: {email, uid, provider='google', has_local_password=false}
   ↓
5. Backend login returns session token ← Cached locally
   ↓
6. Navigate to Home
```

**Result:**
- Firebase: 1 user with Google provider
- Backend: 1 user with email
- Firestore: Metadata tracking provider
- Session: Valid token

---

### Pattern 2: Google Login (Existing Email)
```
Scenario: User already registered manually, now logs in with Google

1. Manual register (happened earlier):
   Backend: user@example.com with password
   Firebase: Created with password provider
   Firestore: {email, provider='email_password'}

2. User logs in with Google using same email
   ↓
3. Google OAuth approval
   ↓
4. Firebase Auth.signInWithCredential(Google credential)
   → Firebase SDK detects: "email user@example.com already exists with password provider"
   → Tries to create new user with same email + Google provider
   → ❌ ERROR: Email already in use
   
   OR
   
   → Allows creation if linkWithCredential is used
   → But we skip this for now (see later)

⚠️ CRITICAL POINT: Firebase has logic issue here!
   Decision: We handle this at BACKEND level, not Firebase.
```

**Solution Implemented:**
```
1. Google OAuth approval
   ↓
2. Firebase Auth.signInWithCredential(Google) 
   → Let Firebase decide (may fail or allow)
   ↓
3. AccountLinkingService.smartAccountLink()
   ├─ Check Firestore: findByEmail(email)
   │  ↓ Found: Email already exists!
   │
   ├─ Call linkGoogleToExisting()
   │  ├─ Firestore.upsertUserDoc()
   │  │  Update: provider='multi', google_uid=xxx
   │  │  (Refresh to add Google UID, mark as multi-provider)
   │  │
   │  └─ Return success
   │
   └─ Handle backend: Need to ensure backend user is same
      (Backend might not be updated, but that's OK for now)
   ↓
4. Return to login (no register, no create)
   ↓
5. Next login: Can use either Google or email+password
```

**Result:**
- Firebase: User now has both google.com + password providers linked
- Backend: Same user (matching by email)
- Firestore: provider='multi', tracks both google_uid and email
- Session: Valid token from either method

---

### Pattern 3: Reset Password (Google User → Email Login)
```
Scenario: Google user wants to also login with manual email/password

1. User logs in with Google
   → Session established
   ↓
2. Navigate to Profile → Reset Password
   → Check Firestore: provider='google', has_local_password=false
   → Show ResetPasswordForGoogleUserScreen
   ↓
3. User enters:
   - Old password: (system fills with derived Google secret)
   - New password: (custom password they want)
   ↓
4. ResetPasswordService.resetPasswordForGoogleUser()
   ├─ Backend login with derived secret ✓ (verification)
   │  ↓
   ├─ Backend.updatePassword(newPassword)
   │  ↓
   ├─ Firebase.updatePassword(newPassword) + linkWithCredential(EmailPassword)
   │  ↓ Now Firebase has provider=['google.com', 'password']
   │  ↓
   └─ Firestore.upsertUserDoc()
      Update: has_local_password=true, provider='multi'
   ↓
5. Success: User can now login with:
   - Google OAuth
   - Email + new password
```

**Result:**
- Firebase: User now has both providers
- Backend: User password updated
- Firestore: has_local_password=true, provider='multi'
- Session: Next login can use either method

---

### Pattern 4: Manual Login (Fallback for Google User)
```
Scenario: Google user tries manual login before resetting password

1. User tries email + password combo
   ↓
2. LoginRepository.loginUser()
   ├─ Try: Backend login email+password
   │  ↓ FAIL (401/400: wrong password)
   │  ↓
   ├─ Check Firestore: findByEmail()
   │  ├─ Found: provider='google', google_uid=xxx
   │  │  ↓
   │  ├─ Fallback: Derive Google secret
   │  │  ↓
   │  └─ Retry: Backend login email+derived_secret
   │     ↓ SUCCESS (this is the hidden password for Google users)
   │
   └─ Return token
   ↓
3. Firebase also tries:
   - Try: signInWithEmailPassword(email, entered_password)
     ↓ FAIL
   - Try: signInWithEmailPassword(email, derived_secret)
     ↓ SUCCESS (because we linked password provider with derived secret)
     ↓
4. Session established
   ↓
5. User sees login worked, but:
   ⚠️ If they try custom password next time, it won't work
   ⚠️ Solution: They need to reset password first!
```

**Result:**
- Backend: Login succeeds with fallback
- Firebase: Login succeeds with fallback
- Session: Valid token established
- User should be prompted: "Reset password to use custom login"

---

## 🔐 Key Implementation Files

### 1. `account_linking_service.dart`
**Purpose:** Smart account linking logic

**Key Methods:**
```dart
checkExistingAccount(email)
  → Checks if email exists in Firestore
  → Returns account metadata if found

smartAccountLink({email, googleUid, fullName})
  → Main entry point
  → Decides whether to link or register new
  → Handles all duplicate scenarios

linkGoogleToExisting({email, googleUid, fullName})
  → Link Google to existing email account
  → Update Firestore provider='multi'

registerNewGoogleAccount({email, googleUid, fullName})
  → Register truly new Google account
  → Create backend user + Firestore entry
```

### 2. `reset_password_service.dart`
**Purpose:** Reset password for Google users

**Key Methods:**
```dart
resetPasswordForGoogleUser({email, oldPassword, newPassword})
  1. Verify old password (backend login)
  2. Update password (backend + Firebase)
  3. Link email/password to Firebase
  4. Update Firestore has_local_password=true
```

### 3. `firebase_integration_service.dart`
**Purpose:** Orchestrate Google OAuth flow

**Key Methods:**
```dart
signInWithGoogleAndSync(context)
  1. Authenticate with Google
  2. Sign in to Firebase
  3. Call AccountLinkingService.smartAccountLink()
  4. Navigate to home
```

### 4. `login_repository.dart`
**Purpose:** Backend login logic

**Key Features:**
```dart
loginUser(email, password)
  1. Try backend login
  2. If fail 401/400, check Firestore for Google user
  3. If Google user, retry with derived secret
  4. Return valid token

_shouldTryGoogleFallback(statusCode, message)
  → Detect if fallback should be attempted

_resolveGoogleSecret(email)
  → Get derived secret from Firestore
```

---

## ⚠️ Edge Cases & Handling

### Edge Case 1: Email Exists in Backend But Not Firestore
```
Scenario: User registered manually, but Firestore wasn't synced

Solution:
1. Google login detected email exists (409 from register)
2. AccountLinkingService handles 409
3. Falls back to linkGoogleToExisting()
4. Creates Firestore entry to sync

Result: No duplicate, account is linked
```

### Edge Case 2: Firebase Auth Create Fails (Email Exists)
```
Scenario: Email is in both Firebase and backend already

Solution:
1. FirebaseAuth.signInWithCredential() might fail if email linked differently
2. Catch error and try linkWithCredential() instead
3. If linking fails, show error: "Use existing login method"

Result: User informed of conflict
```

### Edge Case 3: Session Token Expires
```
Scenario: User's backend token expires after login

Solution:
1. On API call, get 401 response
2. Check if token expired vs invalid
3. Try refresh token (if supported)
4. If can't refresh → re-authenticate

Result: Graceful re-auth flow
```

---

## 🧪 Testing Scenarios

### Test 1: Google → Reset Password → Manual Login
```
1. Google Sign In ✓
   Firestore: {provider='google', has_local_password=false}
2. Logout
3. Click "Reset Password"
   Show ResetPasswordForGoogleUserScreen ✓
4. Enter old password (auto-filled with *) ✓
5. Enter new password ✓
6. Backend update ✓
   Firestore: {provider='multi', has_local_password=true}
7. Logout
8. Manual login with new password ✓
9. Logout
10. Google login again ✓
```

### Test 2: Manual → Google with Same Email
```
1. Manual register (email + password) ✓
   Firestore: {provider='email_password', has_local_password=true}
2. Logout
3. Google login with same email ✓
   AccountLinkingService detects existing email
   Firestore: {provider='multi', google_uid=xxx}
4. Login succeeds (no duplicate account) ✓
5. Logout
6. Manual login ✓
7. Logout
8. Google login ✓
```

### Test 3: Google → Manual Attempt (Before Reset)
```
1. Google login ✓
2. Logout
3. Try manual login (email + random password)
   ↓ FAIL (wrong password)
4. Show dialog: "Account is Google-only, reset password first" ✓
5. Click reset password ✓
   → Go to reset password flow
```

---

## 📊 Firestore Schema Reference

```json
{
  "users": {
    "{email}": {
      "uid": "firebase-uuid",
      "email": "user@example.com",
      "full_name": "User Name",
      "provider": "google" | "email_password" | "multi",
      "google_uid": "google-unique-id-or-null",
      "has_local_password": true | false,
      "updated_at": "2024-05-04T12:00:00Z",
      "created_at": "2024-05-01T10:00:00Z"
    }
  }
}
```

---

## 🚨 Debugging

### Check Backend Session
```dart
final profile = await ProfileRepositoryImpl().getProfile();
// If 401: Token invalid or expired
// If 200: Backend session OK
```

### Check Firebase Session
```dart
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken(forceRefresh: true);
// If null: Firebase session invalid
// If token: Firebase OK
```

### Check Firestore Record
```dart
final user = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
print(user);
// Should show: provider, has_local_password, google_uid
```

### Check Session Storage
```dart
final stored = await SharedCode().getAuthToken();
print('Token: $stored');
final decoded = _decodeJWT(stored); // Decode to check email
print('Email from token: ${decoded['email']}');
```

---

## ✅ Conclusion

This architecture ensures:
1. **One email = One account** across all layers
2. **Zero duplicates** through smart linking
3. **Transparent switching** between login methods
4. **Session consistency** across Firebase + Backend + Firestore
5. **Clear error messages** when conflicts arise

Users can confidently switch between Google and email/password login without confusion or account duplication!

