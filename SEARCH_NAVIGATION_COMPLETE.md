# Search Feature - Complete Navigation Implementation

## Overview
Fitur search sudah fully integrated dengan proper navigation ke detail screens.

## Navigation Flow

### 1. Search User Card → UserDetailViewScreen
```
Home Screen (search textfield)
    ↓ (tap)
SearchResultScreen 
    ↓ (search & real-time results)
SearchUserCard (user result item)
    ↓ (tap card)
UserDetailViewScreen (view-only profile)
```

**Features di UserDetailViewScreen:**
- ✅ Display user profile dengan foto
- ✅ Display fields (read-only): Nama Lengkap, Institusi, Bio
- ✅ Clean UI dengan back button
- ✅ Tidak ada edit button, password reset, atau logout
- ✅ Semua fields adalah read-only (tidak bisa diedit)

### 2. Search Project Card → DetailCollaboration Screen
```
Home Screen (search textfield)
    ↓ (tap)
SearchResultScreen
    ↓ (search & real-time results)
SearchProjectCard (project result item)
    ↓ (tap card / tombol "Lihat Proyek")
DetailCollaboration (existing project detail screen)
    ↓ (automatic fetch full project details menggunakan project ID)
Display project info dengan kolaborator, status, dll
```

**Features di DetailCollaboration:**
- ✅ Automatic fetch full project details saat screen dibuka
- ✅ Display project info lengkap
- ✅ Display kolaborator & members
- ✅ Request join functionality
- ✅ Edit functionality (jika user adalah owner)
- ✅ Status management

## Implementation Details

### File Changes

#### 1. search_result_screen.dart (Updated)
```dart
// Import DetailCollaboration & models
import 'package:gabungyuk/feature/home/presentation/detail_collaboration.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'user_detail_view_screen.dart';

// Navigation untuk user
SearchUserCard(
  user: user,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailViewScreen(user: user),
      ),
    );
  },
)

// Navigation untuk project
SearchProjectCard(
  project: project,
  onTap: () {
    // Convert Project (search model) ke Datum (expected by DetailCollaboration)
    final datum = Datum(
      id: project.id ?? 0,
      title: project.title ?? 'Untitled',
      description: project.description ?? '',
      category: project.category is List 
        ? (project.category as List).isNotEmpty 
          ? (project.category as List)[0].toString() 
          : null
        : null,
      status: project.status,
      repositoryLink: project.repositoryLink,
      projectPicture: project.projectPicture,
      owner: Owner(
        id: 0,
        fullName: 'Unknown',
        email: '',
        profilePicture: null,
      ),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailCollaboration(
          project: datum,
          owner: null,
        ),
      ),
    );
  },
)
```

#### 2. user_detail_view_screen.dart (Created)
- **Location:** `/lib/feature/search/presentation/user_detail_view_screen.dart`
- **Features:**
  - Display user profile info (read-only)
  - Show fields: Nama Lengkap, Institusi, Bio
  - Display user avatar/profile picture
  - Back button untuk kembali ke search results
  - No edit, password reset, atau logout buttons

**UI Components:**
- AppBar dengan back button
- Profile picture display (circular avatar)
- TextFormField read-only untuk: Nama Lengkap, Institusi, Bio
- Styling konsisten dengan Gabungyuk design system

## Model Conversion Logic

### Project → Datum Conversion
Karena search result menggunakan `Project` model (dari SearchModel) tetapi DetailCollaboration menggunakan `Datum` model (dari ViewProjectModel), saya membuat implicit conversion di navigation callback:

```dart
// Project model (dari search)
class Project {
  int? id;
  String? title;
  String? description;
  List<dynamic>? category;    // bisa jadi List
  String? status;
  String? repositoryLink;
  String? projectPicture;
  dynamic deadline;           // Optional
  // Tidak ada: owner, collaborators
}

// Datum model (expected by DetailCollaboration)
class Datum {
  int id;                      // Required
  String title;                // Required
  String description;          // Required
  String? category;            // Optional (single value)
  String? status;              // Optional
  String? repositoryLink;      // Optional
  String? projectPicture;      // Optional
  Owner owner;                 // Required (bisa minimal)
  List<CollaboratorShort>? collaborators; // Optional
}

// Conversion:
Datum(
  id: project.id ?? 0,
  title: project.title ?? 'Untitled',
  description: project.description ?? '',
  category: project.category is List 
    ? (project.category as List).isNotEmpty 
      ? (project.category as List)[0].toString() 
      : null
    : null,  // Convert List category ke single category
  status: project.status,
  repositoryLink: project.repositoryLink,
  projectPicture: project.projectPicture,
  owner: Owner(
    id: 0,
    fullName: 'Unknown',
    email: '',
    profilePicture: null,  // Minimal owner, akan di-override saat fetch detail
  ),
)
```

**Why This Works:**
1. DetailCollaboration di-init dengan project ID & minimal owner
2. Di `initState`, DetailCollaboration langsung call `_fetchProjectDetail()`
3. `_fetchProjectDetail()` fetch full project details dari API menggunakan project ID
4. Full details (termasuk real owner & collaborators) akan override data yang dikirim
5. UI akan re-render dengan data lengkap

## User Data Flow

### UserDetailViewScreen Usage
```dart
UserDetailViewScreen(user: user)
  ↓
user: User {
  userId: 1,
  namaLengkap: "John Doe",
  profilePicture: "https://...",
  bio: "Software Developer",
  institusi: "PT Tekno Indonesia"
}
  ↓
Display di read-only fields
```

## Testing Scenarios

### Test Case 1: Search & Open User Profile
1. ✅ Home screen → Click search field
2. ✅ Type user name → See user in results
3. ✅ Click user card → Navigate to UserDetailViewScreen
4. ✅ See user info: name, institusi, bio (read-only)
5. ✅ Click back → Return to search results

### Test Case 2: Search & Open Project Detail
1. ✅ Home screen → Click search field
2. ✅ Type project name → See project in results
3. ✅ Click project card / "Lihat Proyek" button → Navigate to DetailCollaboration
4. ✅ DetailCollaboration fetch full project data
5. ✅ See project info: title, description, members, status
6. ✅ Can request join, accept/reject requests (if owner)
7. ✅ Click back → Return to search results

## Error Handling

### User Detail View
- ✅ Handle missing profile picture (show default icon)
- ✅ Handle empty bio/institusi (show empty state)
- ✅ Handle network errors gracefully

### Project Detail
- ✅ DetailCollaboration handles fetch errors
- ✅ Shows loading state
- ✅ Retry button available on error

## Performance Considerations

### Optimization
1. **Lazy Loading:** Project details fetched only when user clicks on project
2. **Minimal Owner:** Not fetching full owner data upfront (will be updated on detail fetch)
3. **Reuse Existing Screen:** DetailCollaboration sudah optimized, tidak perlu duplicate

### Future Enhancements
1. Add caching untuk user profiles (detail fetch)
2. Add pagination untuk projects dengan banyak collaborators
3. Add favorite/bookmark functionality

## Files Created/Modified

### Created Files:
1. `/lib/feature/search/presentation/user_detail_view_screen.dart` - User profile view-only screen

### Modified Files:
1. `/lib/feature/search/presentation/search_result_screen.dart` - Updated navigation

### Existing Files Used:
1. `/lib/feature/home/presentation/detail_collaboration.dart` - Project detail
2. `/lib/feature/home/model/view_project_model.dart` - Datum & Owner models

## API Integration

### DetailCollaboration Auto-Fetches:
```
Project ID dari Search Result
    ↓
DetailCollaboration._fetchProjectDetail()
    ↓
API: GET /api/v1/collaboration/detail/project/{projectId}
    ↓
Returns: DetailProjectModel dengan full project data
    ↓
UI re-renders dengan data lengkap
```

## Architecture Diagram

```
┌─ HomeScreen
│  └─ Search TextField (read-only, onTap navigation)
│
├─ SearchResultScreen (BlocProvider + SearchBloc)
│  ├─ Search Field (real-time input)
│  ├─ BlocBuilder (StateManagement)
│  │
│  ├─ Users Section
│  │  └─ SearchUserCard[]
│  │     └─ onTap → UserDetailViewScreen
│  │
│  └─ Projects Section
│     └─ SearchProjectCard[]
│        └─ onTap → DetailCollaboration
│
├─ UserDetailViewScreen (view-only)
│  ├─ Profile Picture
│  ├─ Nama Lengkap (read-only field)
│  ├─ Institusi (read-only field)
│  └─ Bio (read-only field)
│
└─ DetailCollaboration (dengan Datum dari Project converter)
   ├─ Fetch full details menggunakan project.id
   ├─ Project Info
   ├─ Members/Collaborators
   ├─ Status Management
   └─ Join Request (jika user bukan owner)
```

## Summary

✅ **User Search Result:**
- Click card → Navigate ke UserDetailViewScreen
- Display user profile (read-only)
- Show: name, institusi, bio
- No edit/password/logout buttons

✅ **Project Search Result:**
- Click card / button → Navigate ke DetailCollaboration
- DetailCollaboration auto-fetch full project details
- Display: project info, members, status, etc.
- Full functionality (join, edit, etc.)

✅ **Real-Time Integration:**
- Search triggers API call real-time
- Results update as user types
- Navigation seamless ke detail screens

✅ **Error Handling:**
- Graceful fallbacks
- Retry mechanisms
- User-friendly error messages

Done! 🎉 Complete navigation implementation dengan proper detail screens!

