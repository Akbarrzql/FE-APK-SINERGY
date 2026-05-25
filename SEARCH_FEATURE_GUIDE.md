# Search Feature Implementation Guide

## Overview
Implementasi fitur search lengkap dengan BLOC pattern, Repository, dan UI yang terintegrasi dengan home screen.

## Arsitektur

### 1. Repository (`search_repository.dart`)
- **Fungsi**: Menangani API request ke endpoint `/api/v1/search?query={query}`
- **Method**: 
  - `searchQuery(String query)` - Mengirim request ke server dan return `SearchModel`
- **Error Handling**: Menangani berbagai status code (400, 401, 500) dengan pesan error yang sesuai

### 2. BLOC (`search_bloc.dart`)
- **Event**:
  - `SearchQuery(String query)` - Trigger pencarian
  - `ClearSearch()` - Clear hasil pencarian
- **State**:
  - `InitialSearchState` - State awal
  - `SearchLoading` - Sedang loading
  - `SearchLoaded` - Data loaded dengan results
  - `SearchError` - Ada error
  - `SearchCleared` - Pencarian cleared

### 3. UI

#### SearchResultScreen (`search_result_screen.dart`)
- **Main Screen**: Menampilkan search bar dan hasil
- **Features**:
  - Real-time search saat user mengetik
  - Loading state dengan shimmer effect
  - Empty state dengan pesan yang jelas
  - Error handling dengan tombol retry
  - Section terpisah untuk Users dan Projects

#### SearchUserCard (`widget/search_user_card.dart`)
- Card untuk menampilkan user hasil search
- Menampilkan: foto profil, nama, institusi, bio
- OnTap callback untuk navigasi ke detail user
- Styling: consistent dengan design system Gabungyuk

#### SearchProjectCard (`widget/search_project_card.dart`)
- Card untuk menampilkan project hasil search
- Menampilkan: foto project, title, status, kategori, deskripsi
- OnTap callback untuk navigasi ke detail project
- Action button "Lihat Proyek"

## Flow Integration

### 1. Home Screen → Search Screen
```
Home Screen (TextField readOnly)
     ↓ (onTap)
SearchResultScreen (dengan initial query)
```

**Code di `home_screen.dart`:**
```dart
SizedBox(
  height: 50,
  child: TextField(
    controller: _searchController,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            initialQuery: _searchController.text,
          ),
        ),
      );
    },
    readOnly: true,
    // ... decoration
  ),
),
```

### 2. Search Screen → Detail Screen (TODO)
```
SearchUserCard/SearchProjectCard (onTap)
     ↓ (onTap callback)
User Profile Detail / Project Detail
```

Current implementation: Menampilkan SnackBar sebagai placeholder.

## User Data Model
Dari endpoint response `/api/v1/search`:

```dart
SearchModel {
  status: int
  message: string
  data: {
    users: [
      User {
        userId: int
        namaLengkap: string
        profilePicture: string (url)
        bio: string
        institusi: string
      }
    ]
    projects: [
      Project {
        id: int
        title: string
        description: string
        category: list
        status: string
        repositoryLink: string
        projectPicture: string (url)
        deadline: datetime
      }
    ]
  }
}
```

## Files Created/Modified

### Created Files:
1. `/lib/feature/search/repository/search_repository.dart` - Repository implementation
2. `/lib/feature/search/bloc/search_event.dart` - BLOC events
3. `/lib/feature/search/bloc/search_state.dart` - BLOC states  
4. `/lib/feature/search/bloc/search_bloc.dart` - BLOC logic
5. `/lib/feature/search/presentation/search_result_screen.dart` - Main search screen
6. `/lib/feature/search/presentation/widget/search_user_card.dart` - User card widget
7. `/lib/feature/search/presentation/widget/search_project_card.dart` - Project card widget

### Modified Files:
1. `/lib/feature/home/presentation/home_screen.dart` - Added search textfield with navigation

## Testing

### Untuk Testing:
1. **Masuk ke Home Screen**
2. **Klik search textfield** → Akan membuka SearchResultScreen
3. **Ketik query pencarian** → Real-time search akan trigger API call
4. **Lihat results** → Akan menampilkan users dan projects terpisah
5. **Klik user/project card** → Placeholder navigation (TODO: implement detail screen)

## Next Steps (TODO)

1. **Implement User Profile Detail Screen**
   - Navigate dari SearchUserCard ke user profile screen
   - Tampilkan detail user dengan semua info

2. **Implement Project Detail Screen**
   - Navigate dari SearchProjectCard ke project detail screen
   - Tampilkan detail project dengan collaboration info

3. **Add Filters**
   - Filter by category, status, etc.
   - Advanced search options

4. **Add Search History**
   - Simpan recent searches
   - Quick access ke previous searches

## API Configuration
Base URL: `${ApiConfig.baseUrl}/api/v1/search`
- Gunakan token dari SharedPreferences (Bearer token)
- Method: GET
- Params: `query` (string)

## Error Scenarios Handled
- ✅ 400 Bad Request - Invalid query
- ✅ 401 Unauthorized - Token expired (trigger logout)
- ✅ 500 Server Error - Server error message
- ✅ Network Error - Connection error message
- ✅ Empty Results - Show "Tidak ada hasil" message

## Notes
- Search dilakukan real-time saat user mengetik (debounce bisa ditambahkan jika perlu)
- Loading state menggunakan shimmer effect
- UI fully responsive dan mengikuti design system Gabungyuk
- State management menggunakan BLoC pattern sesuai project guidelines

