# Search Feature - TabBar + Profile Updates

## Summary of Changes

Implementasi TabBar untuk search results dan integration dengan ProfileScreen untuk user detail.

## Changes Made

### 1. ✅ Changed search_model.dart
**File:** `/lib/feature/search/model/screen_model.dart`

**Changes:**
- Changed `Project.category` from `List<dynamic>?` to `List<String>?`
- Updated JSON parsing to properly convert to `List<String>`
- Updated `fromJson()` method: `List<String>.from(json["category"]!.map((x) => x.toString()))`

```dart
// Before
List<dynamic>? category;

// After
List<String>? category;
```

### 2. ✅ Updated ProfileScreen
**File:** `/lib/feature/profile/presentation/screens/profile_screen.dart`

**Changes:**
- Added optional parameter `hideMenus` (default: `false`)
- Hide Edit Profile, Reset Password, dan Logout menu items ketika `hideMenus: true`
- When called from search with `hideMenus: true`, user hanya bisa view profile tanpa edit/logout

```dart
// Constructor
const ProfileScreen({
  super.key,
  this.hideMenus = false,
});

// Conditional menu rendering
if (!widget.hideMenus)
  Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // Edit Profile menu
        _menuItem(Icons.person_outline, 'Informasi pribadi', ...),
        // Reset Password menu
        _menuItem(Icons.lock_open_rounded, 'Reset Password', ...),
        // Logout menu
        _menuItem(Icons.logout, 'Keluar', ...),
      ],
    ),
  ),
```

### 3. ✅ Redesigned SearchResultScreen with TabBar
**File:** `/lib/feature/search/presentation/search_result_screen.dart`

**Major Changes:**
- Added `TickerProviderStateMixin` for TabController
- Implemented TabBar dengan 2 tabs: "Proyek" dan "User"
- Split results menjadi separate components: `_ProjectsTab` dan `_UsersTab`
- Real-time search tetap berfungsi (both tabs mendapat update)

**UI Structure:**
```
SearchResultScreen
├── AppBar
├── Search TextField (real-time)
├── TabBar (Proyek | User)
└── TabBarView
    ├── _ProjectsTab (Projects listing)
    └── _UsersTab (Users listing)
```

**Navigation:**
- **Project Tab:** Click card → Navigate to `DetailCollaboration`
- **User Tab:** Click card → Navigate to `ProfileScreen(hideMenus: true)`

### 4. ✅ Fixed SearchProjectCard
**File:** `/lib/feature/search/presentation/widget/search_project_card.dart`

**Changes:**
- Changed category display from `(project.category as List).join(', ')` to `project.category!.join(', ')`
- Now properly handles `List<String>` type

## Detailed Flow

### Project Search & View
```
User types in search field
    ↓
SearchBloc triggers API call
    ↓
Results show in "Proyek" tab
    ↓
Click project card / "Lihat Proyek" button
    ↓
Navigate to DetailCollaboration
    ↓
DetailCollaboration fetches full project data using ID
    ↓
Display project with members, status, etc.
```

### User Search & View
```
User types in search field
    ↓
SearchBloc triggers API call
    ↓
Results show in "User" tab
    ↓
Click user card / "Lihat" button
    ↓
Navigate to ProfileScreen(hideMenus: true)
    ↓
Display profile: Nama, Institusi, Bio (read-only)
    ↓
NO edit button, NO password reset, NO logout
```

## File Structure Update

```
lib/feature/search/
├── bloc/
│   ├── search_bloc.dart          ✅ (unchanged)
│   ├── search_event.dart         ✅ (unchanged)
│   └── search_state.dart         ✅ (unchanged)
├── repository/
│   └── search_repository.dart    ✅ (unchanged)
├── model/
│   └── screen_model.dart         ✅ UPDATED: category List<String>
└── presentation/
    ├── search_result_screen.dart ✅ REDESIGNED: TabBar implementation
    ├── user_detail_view_screen.dart (no longer used)
    └── widget/
        ├── search_user_card.dart ✅ (unchanged)
        └── search_project_card.dart ✅ FIXED: category handling

lib/feature/profile/presentation/screens/
└── profile_screen.dart           ✅ UPDATED: hideMenus parameter
```

## Category Type Change

### Why List<String>?
- Search API returns array of category strings
- More type-safe than `List<dynamic>`
- Easier to work with in UI (no casting needed)
- Better for data manipulation

### Impact on Existing Code
- `SearchProjectCard`: Updated to use direct join() without casting
- `DetailCollaboration`: Expects single category string (takes first from list)

## Testing Checklist

### Project Search
- ✅ Type project name in search
- ✅ Results appear in "Proyek" tab
- ✅ Click card → Navigate to DetailCollaboration
- ✅ DetailCollaboration loads full project data
- ✅ Can see members, status, repository link

### User Search
- ✅ Type user name in search
- ✅ Results appear in "User" tab
- ✅ Click card → Navigate to ProfileScreen
- ✅ ProfileScreen shows user info (read-only)
- ✅ NO edit button visible
- ✅ NO reset password button visible
- ✅ NO logout button visible
- ✅ Back button works to return to search

### Tab Switching
- ✅ Click "Proyek" tab → See project results
- ✅ Click "User" tab → See user results
- ✅ Search real-time updates both tabs
- ✅ Tab state maintained during switching

### Edge Cases
- ✅ Empty search results
- ✅ Loading state in both tabs
- ✅ Error handling in both tabs
- ✅ Retry button functionality

## API Integration

### Category Handling
```dart
// API returns
"category": ["Web Development", "Mobile Dev"]

// Model parses as
List<String>? category

// Display shows
"Web Development, Mobile Dev"

// DetailCollaboration receives first item
category: project.category != null && project.category!.isNotEmpty
  ? project.category![0]  // Takes first category
  : null
```

## Future Enhancements

1. **Profile Detail Screen:** Create dedicated UserDetailScreen with more info
2. **Category Filter:** Add category filter in search
3. **Favorites:** Add favorite/save user or project functionality
4. **Recent Searches:** Store recent search queries
5. **Advanced Filters:** Status, date range, category filters

## Notes

- ProfileScreen reused untuk both own profile dan viewed profiles
- `hideMenus` parameter handles visibility of menu items
- SearchResultScreen sepenuhnya stateful untuk manage TabController
- BLOC pattern maintained untuk search functionality
- Real-time search works across both tabs

Done! 🎉 Search feature dengan TabBar dan Profile viewing selesai!

