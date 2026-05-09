# 🔐 Arsitektur Autentikasi Gabungyuk

## ⚠️ Masalah yang Dihadapi

### 1. Error "Unauthorized" Setelah Reset Password
**Root Cause:**
- Firebase Auth dan Backend API bisa out-of-sync
- Session token backend bisa expire atau invalid
- Firestore cache belum ter-update untuk `has_local_password`

**Skenario:**
```
1. Google Login → Firebase Auth OK, Backend Login OK, Firestore: has_local_password=false
2. Reset Password → Backend update password, Firebase update, Firestore: has_local_password=true
3. Manual Login → Backend OK, Firebase OK
4. Session expire atau refresh → Bisa mismatch jika token tidak ter-propagate
```

### 2. Duplikasi User saat Google Login ke Email yang Sudah Ada
**Root Cause:**
- Tidak ada cek apakah email sudah terdaftar di backend
- Bisa membuat user baru di backend padahal email sudah ada
- Leads to duplicate accounts dan data inconsistency

**Skenario:**
```
1. Manual Register: email@example.com → Backend User ID: 123
2. Google Login dengan email@example.com
3. Sistem tidak detect bahwa email sudah ada
4. Create new Backend User ID: 456 (DUPLIKAT!)
5. Now ada 2 backend users untuk 1 email
```

### 3. Account Linking Belum Transparan
**Root Cause:**
- Tidak ada mechanism yang jelas untuk link Google + Email/Password
- User experience bingung tentang method mana yang mereka gunakan
- Bisa error kalau user switch method

---

## ✅ Solusi: Architecture yang Benar

### **Level 1: Unique Identifier di Setiap Layer**

```
┌─────────────────────────────────────────────┐
│          Email (Unique Master ID)           │
├─────────────────────────────────────────────┤
│ • Firebase Auth {email, oauth:google}       │
│ • Backend API {user_id, email}              │
│ • Firestore {email as doc_id}               │
│ • Session Token {email, user_id}            │
└─────────────────────────────────────────────┘
```

**Prinsip:**
- Email adalah **universal unique identifier**
- Di setiap layer, gunakan email sebagai referensi linking
- Firestore doc_id = email (sudah implement ✓)
- Backend user_id adalah ID internal, bukan unique identifier di frontend

### **Level 2: Firebase Auth Provider Management**

```dart
// Firebase user bisa memiliki multiple providers linked:
FirebaseUser {
  uid: 'firebase-uuid',
  email: 'user@example.com',
  providers: [
    'google.com',              // OAuth via Google
    'password',                // Email + Password
  ]
}
```

**Flow Yang Benar:**

**Skenario A: Google Login → Manual Reset → Manual Login → Google Login**
```
1️⃣ Google Login
   Firebase: Create user dengan provider=[google.com]
   Backend: Check email, jika tidak ada → create user
   Firestore: {email, provider='google', has_local_password=false}

2️⃣ Reset Password (via ResetPasswordService)
   Backend: Update password untuk email
   Firebase: LinkWithCredential(EmailPassword) → provider=[google.com, password]
   Firestore: provider='multi', has_local_password=true

3️⃣ Manual Login
   Login ke backend dengan email+password ✓
   Firebase: SignInWithEmailAndPassword ✓
   Session: Got backend token ✓

4️⃣ Google Login Again
   Firebase: SignInWithCredential(google) ✓
   Backend: Check email, user sudah ada ✓
   Session: Got backend token ✓
```

**Skenario B: Manual Register → Google Login dengan Email Sama**
```
1️⃣ Manual Register
   Backend: Create user dengan email@example.com
   Firebase: Create dengan EmailPassword provider
   Firestore: {email, provider='email_password', has_local_password=true}

2️⃣ Google Login dengan email@example.com
   CRITICAL: Cek apakah email sudah ada di backend ✓
   Firebase: LinkWithCredential(google) → provider=[password, google.com]
   Backend: Update provider list atau mark as multi-provider
   Firestore: provider='multi', has_local_password=true, google_uid=xxx
```

### **Level 3: Backend Synchronization**

```
┌─────────────────────────────────────────────────────┐
│  Backend Repository Pattern (Login + Register)      │
├─────────────────────────────────────────────────────┤
│ 1. Try login dengan email+password                  │
│    ↓ SUCCESS: Return token                          │
│    ↓ FAIL (400/401): Check jika error kredensial    │
│                                                      │
│ 2. Try dengan derived Google secret (fallback)      │
│    ↓ SUCCESS: User adalah Google-only, linking...   │
│    ↓ FAIL: Truly invalid credentials                │
│                                                      │
│ 3. Register (hanya jika truly baru):                │
│    ↓ Check duplikat email dulu                      │
│    ↓ Jika ada, link ke existing, jangan buat baru  │
└─────────────────────────────────────────────────────┘
```

### **Level 4: Session Token Management**

```dart
// Token harus konsisten di semua login method
SessionToken {
  token: 'jwt-token-dari-backend',
  email: 'user@example.com',         // ← Master identifier
  user_id: 123,                      // ← Backend ID
  expires_at: 1683....,
  last_login_method: 'google',       // Track method terakhir
  providers: ['email_password', 'google'],
}
```

**Di Profile Screen, bisa tahu:**
```dart
// User bisa login via apa saja?
final hasGoogle = session.providers.contains('google');
final hasPassword = session.providers.contains('email_password');

// Kalo mau reset password:
if (hasGoogle && !hasPassword) → Show ResetPasswordForGoogleUserScreen
if (hasPassword) → Show ForgotPasswordScreen
```

---

## 🛠️ Implementation Checklist

### **Phase 1: Account Linking Logic (Priority 1)**
- [ ] Update `firebase_integration_service.dart`:
  - [ ] Cek email di backend sebelum create Google user
  - [ ] Jika email ada → Link ke existing account (tidak buat baru)
  - [ ] Update Firestore `provider='multi'` setelah linking

- [ ] Update `login_repository.dart`:
  - [ ] Add `checkEmailExists()` method
  - [ ] Add `linkGoogleToExistingAccount()` method
  - [ ] Better error differentiation (duplicate vs invalid cred)

- [ ] Add `account_linking_service.dart`:
  - [ ] Centralized logic untuk link multiple providers
  - [ ] Handle conflicts (email sudah ada di Firebase tapi beda UID)

### **Phase 2: Session Token Propagation (Priority 2)**
- [ ] Ensure session token selalu include email + providers list
- [ ] Add token refresh mechanism
- [ ] Handle token expire scenario

### **Phase 3: UI/UX Improvements (Priority 3)**
- [ ] Show user: "Akun ini bisa login via Google + Email/Password"
- [ ] In profile, show which providers are linked
- [ ] Option to unlink providers (advanced)

---

## 🔍 Debugging Checklist

Ketika user report error "unauthorized" setelah reset password:

1. **Check Backend:**
   ```
   GET /api/v1/profile (dengan new token)
   Expected: 200 OK
   If 401: Token tidak ter-update atau expired
   ```

2. **Check Firebase:**
   ```dart
   await FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh: true);
   Expected: Valid token
   If error: Firebase session corrupt
   ```

3. **Check Firestore:**
   ```
   Doc: users/{email}
   Should have: has_local_password=true, provider='google' or 'multi'
   ```

4. **Check Session Storage:**
   ```dart
   final token = await SharedCode().getAuthToken();
   print('Token exists: $token');
   print('Token email: dari decoding JWT');
   ```

---

## 📊 Comparison: Sebelum vs Sesudah

| Aspek | Sebelum | Sesudah |
|-------|--------|--------|
| **Account Linking** | Manual, tidak transparan | Auto-detect, explicit linking |
| **Duplicate Accounts** | Mungkin terjadi | Cegah dengan email check |
| **Session Consistency** | Bisa out-of-sync | Synchronized across layers |
| **Reset Password Flow** | Bisa error "unauthorized" | Guaranteed success |
| **Multi-Provider** | Not supported | Fully supported |
| **User Experience** | Confusing | Clear, guided flow |

---

## 🚀 Next Steps

1. Implement `account_linking_service.dart` (Phase 1)
2. Update Firebase integration to check existing accounts
3. Add comprehensive logging untuk debugging
4. Test all scenarios dengan unit tests
5. Add UI to show linked providers

