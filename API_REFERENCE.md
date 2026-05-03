# API Reference: Profile Update Endpoint

## Endpoint Specification

### Request

**URL:** `PUT /api/v1/update/users/current`

**Authentication:** Bearer Token (from login/register)

**Header:** `Authorization: Bearer <access_token>`

---

## Request Body Format

### Option 1: With Profile Photo (Multipart)

**Content-Type:** `multipart/form-data; boundary=----WebKitFormBoundary...`

**Fields:**
```
Form Field: namaLengkap (text)
Form Field: email (text)
Form Field: institusi (text)
Form Field: bio (text)
Form Field: keahlian (text)
Form Field: lokasi (text)
Form Field: whatsapp (text)
Form Field: profilePicture (binary file)
  - Field name: profilePicture
  - Content-Type: image/jpeg (or image/png, image/webp)
  - Filename: image.jpg (or original filename)
```

**Example curl:**
```bash
curl -X PUT https://api.example.com/api/v1/update/users/current \
  -H "Authorization: Bearer your_token_here" \
  -F "namaLengkap=Marion Herman" \
  -F "email=marion@example.com" \
  -F "institusi=PT ABC" \
  -F "bio=Senior Developer" \
  -F "keahlian=Flutter, Dart" \
  -F "lokasi=Jakarta" \
  -F "whatsapp=62812345678" \
  -F "profilePicture=@/path/to/image.jpg"
```

---

### Option 2: Text Only (JSON)

**Content-Type:** `application/json`

**Body:**
```json
{
  "namaLengkap": "Marion Herman",
  "email": "marion@example.com",
  "institusi": "PT ABC",
  "bio": "Senior Developer",
  "keahlian": "Flutter, Dart",
  "lokasi": "Jakarta",
  "whatsapp": "62812345678",
  "profilePicture": ""
}
```

**When used:**
- User only updates text fields (no photo change)
- User wants to clear photo (empty string)
- No image was selected

---

## Response Format

### Success (200-299)

```json
{
  "success": true,
  "message": "Profil berhasil diperbarui",
  "data": {
    "token": "new_token_here_if_rotated",
    "expiredAt": 1704067200,
    "namaLengkap": "Marion Herman",
    "email": "marion@example.com",
    "institusi": "PT ABC",
    "bio": "Senior Developer",
    "keahlian": "Flutter, Dart",
    "lokasi": "Jakarta",
    "whatsapp": "62812345678",
    "profilePicture": "https://cdn.example.com/profiles/user123.jpg"
  }
}
```

**Field Explanations:**
- `token` (optional): New token if rotated. Client will save it if provided.
- `expiredAt`: Unix timestamp when token expires
- `profilePicture`: URL to uploaded image, or empty string if cleared

---

### Error Responses

#### 400 Bad Request
```json
{
  "success": false,
  "message": "Email tidak valid",
  "errors": {
    "email": ["Email format tidak valid"]
  }
}
```

#### 401 Unauthorized
```json
{
  "success": false,
  "message": "Sesi Anda telah berakhir. Silakan masuk kembali."
}
```
**Client Action:** Clear session, redirect to login

#### 413 Payload Too Large
```json
{
  "success": false,
  "message": "File terlalu besar (max 5MB)"
}
```

#### 500+ Server Error
```json
{
  "success": false,
  "message": "Terjadi kesalahan pada server. Silakan coba lagi nanti."
}
```

---

## Server Implementation Checklist

### 1. Authentication
- [ ] Verify Bearer token in Authorization header
- [ ] Return 401 if token invalid/expired
- [ ] Update token if needed (optionally rotate)

### 2. Multipart Handling
- [ ] Accept multipart/form-data requests
- [ ] Parse text fields: namaLengkap, email, institusi, bio, keahlian, lokasi, whatsapp
- [ ] Handle optional binary file: profilePicture
- [ ] Validate file type (image only: jpeg, png, webp, gif)
- [ ] Validate file size (recommend: max 5MB)
- [ ] Generate unique filename or use userId

### 3. JSON Handling (Fallback)
- [ ] Accept application/json requests
- [ ] Parse all fields (including profilePicture as empty string)
- [ ] Allow partial updates (only send changed fields)

### 4. File Storage
- [ ] Save uploaded image to file storage (S3, local disk, etc.)
- [ ] Return image URL/URI in response
- [ ] Store relative path/URL in database
- [ ] Handle file deletion if profilePicture is empty string

### 5. Database Update
- [ ] Update user record with provided fields
- [ ] If profilePicture provided: save URL/path to DB
- [ ] If profilePicture empty: set to NULL or empty string
- [ ] Update updatedAt timestamp

### 6. Response
- [ ] Return 200+ with updated data
- [ ] Include new token if rotated
- [ ] Include all profile fields in response
- [ ] Include profilePicture as URL or empty string

---

## Sample Server Code

### Python (Flask)
```python
from flask import request, jsonify
from werkzeug.utils import secure_filename
from functools import wraps
import os

UPLOAD_FOLDER = '/var/uploads/profiles'
ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png', 'webp', 'gif'}

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        if not token or not verify_token(token):
            return jsonify({'message': 'Sesi Anda telah berakhir. Silakan masuk kembali.'}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/api/v1/update/users/current', methods=['PUT'])
@token_required
def update_profile():
    user_id = get_user_from_token(request.headers['Authorization'])
    
    # Get form fields
    nama_lengkap = request.form.get('namaLengkap', '').strip()
    email = request.form.get('email', '').strip()
    institusi = request.form.get('institusi', '').strip()
    bio = request.form.get('bio', '').strip()
    keahlian = request.form.get('keahlian', '').strip()
    lokasi = request.form.get('lokasi', '').strip()
    whatsapp = request.form.get('whatsapp', '').strip()
    
    # Validate
    if not nama_lengkap:
        return jsonify({'message': 'Nama lengkap tidak boleh kosong'}), 400
    
    # Handle file
    profile_picture_url = None
    if 'profilePicture' in request.files:
        file = request.files['profilePicture']
        if file and allowed_file(file.filename):
            filename = secure_filename(f"{user_id}_{int(time.time())}_{file.filename}")
            file.save(os.path.join(UPLOAD_FOLDER, filename))
            profile_picture_url = f"/uploads/profiles/{filename}"
        else:
            return jsonify({'message': 'File tipe tidak valid atau kosong'}), 400
    elif request.form.get('profilePicture') == '':
        # Explicitly clear photo
        profile_picture_url = ''
    
    # Update database
    user = User.query.get(user_id)
    user.nama_lengkap = nama_lengkap
    user.email = email
    user.institusi = institusi
    user.bio = bio
    user.keahlian = keahlian
    user.lokasi = lokasi
    user.whatsapp = whatsapp
    if profile_picture_url is not None:
        user.profile_picture = profile_picture_url if profile_picture_url else None
    
    db.session.commit()
    
    return jsonify({
        'success': True,
        'message': 'Profil berhasil diperbarui',
        'data': {
            'token': generate_new_token(user_id) if should_rotate_token() else '',
            'expiredAt': get_token_expiry(),
            'namaLengkap': user.nama_lengkap,
            'email': user.email,
            'institusi': user.institusi,
            'bio': user.bio,
            'keahlian': user.keahlian,
            'lokasi': user.lokasi,
            'whatsapp': user.whatsapp,
            'profilePicture': user.profile_picture or ''
        }
    }), 200

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
```

### Node.js (Express + Multer)
```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, '/var/uploads/profiles');
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    cb(null, `${req.userId}_${timestamp}${path.extname(file.originalname)}`);
  }
});

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('File tipe tidak valid'));
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

app.put('/api/v1/update/users/current', 
  authMiddleware,
  upload.single('profilePicture'),
  async (req, res) => {
    try {
      const { namaLengkap, email, institusi, bio, keahlian, lokasi, whatsapp } = req.body;
      
      if (!namaLengkap) {
        return res.status(400).json({ message: 'Nama lengkap tidak boleh kosong' });
      }
      
      const user = await User.findById(req.userId);
      
      user.namaLengkap = namaLengkap;
      user.email = email;
      user.institusi = institusi;
      user.bio = bio;
      user.keahlian = keahlian;
      user.lokasi = lokasi;
      user.whatsapp = whatsapp;
      
      if (req.file) {
        user.profilePicture = `/uploads/profiles/${req.file.filename}`;
      } else if (req.body.profilePicture === '') {
        user.profilePicture = null;
      }
      
      await user.save();
      
      res.json({
        success: true,
        message: 'Profil berhasil diperbarui',
        data: {
          token: generateNewToken(user._id),
          expiredAt: getTokenExpiry(),
          namaLengkap: user.namaLengkap,
          email: user.email,
          institusi: user.institusi,
          bio: user.bio,
          keahlian: user.keahlian,
          lokasi: user.lokasi,
          whatsapp: user.whatsapp,
          profilePicture: user.profilePicture || ''
        }
      });
    } catch (error) {
      res.status(500).json({ message: 'Terjadi kesalahan pada server' });
    }
  }
);
```

---

## Important Notes

### File Size & Performance
- Recommended max file size: **5MB**
- Recommended image dimensions: **maxWidth: 1200px** (already done on client)
- Consider implementing image compression on server

### Database Storage
- Store file path or CDN URL, not binary data in DB
- Use separate file storage (S3, local disk, etc.)
- Implement cleanup for old/unused files

### Security
- Validate file MIME type on server
- Check file size on server (don't trust client limit)
- Sanitize filenames (use secure_filename)
- Store in directory outside web root if possible
- Implement rate limiting on upload endpoint

### Token Rotation
- Optionally rotate token on profile update
- Return new token in response if rotated
- Client will automatically save new token via SharedCode

### Edge Cases to Handle
- User clears ~~all~~ one field (send empty string in JSON)
- User clears photo (send empty string for profilePicture)
- User uploads large file (reject with 413)
- User uploads non-image file (reject with 400)
- Concurrent profile updates (use transaction/locking)

---

## Testing the Endpoint

### Using Postman
1. Set request to **PUT** `/api/v1/update/users/current`
2. Authorization tab → Bearer Token → paste token
3. Body tab → form-data
4. Add form fields (name/value pairs)
5. Add file field "profilePicture" → select image
6. Send

### Using curl
```bash
curl -X PUT "http://localhost:5000/api/v1/update/users/current" \
  -H "Authorization: Bearer your_token_here" \
  -F "namaLengkap=Marion Herman" \
  -F "email=marion@example.com" \
  -F "profilePicture=@/path/to/image.jpg"
```

### Using HTTPie
```bash
http PUT localhost:5000/api/v1/update/users/current \
  Authorization:"Bearer your_token_here" \
  namaLengkap="Marion Herman" \
  email="marion@example.com" \
  profilePicture@/path/to/image.jpg
```

---

## Client-Side Testing

After implementing server, test with:

```bash
# Build and run Flutter app
flutter run

# Navigate to Profile → Edit Profile
# 1. Test text-only update (no photo)
# 2. Test photo upload + text update
# 3. Test clearing photo (empty string)
# 4. Monitor network traffic to verify multipart request format
```

---

**Client is ready! 🚀 Your server just needs to implement multipart endpoint.**

