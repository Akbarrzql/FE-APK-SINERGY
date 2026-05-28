# Rating & Review Collaborator Feature Implementation Guide

## 📋 Overview

Fitur Rating & Review Collaborator memungkinkan project owner untuk memberikan rating dan review kepada collaborator setelah project selesai (status = COMPLETED). Rating ini akan ditampilkan di profil collaborator sebagai reputasi dan rekomendasi.

---

## 🏗️ Architecture

### Model Files (Created)
```
lib/feature/rating/model/
├── create_rating_model.dart          # Request payload untuk submit rating
├── user_rating_by_project_model.dart # Response model untuk GET /api/v1/ratings/users/{userId}
└── user_rating_average_model.dart    # Response model untuk GET /api/v1/ratings/users/{userId}/average
```

### Repository (Created)
```
lib/feature/rating/repository/
└── rating_repository.dart             # Handles all rating API calls
```

### BLoC (Created)
```
lib/feature/rating/bloc/
├── rating_event.dart                 # Events: SubmitRating, FetchProjectRatings, etc.
├── rating_state.dart                 # States: Loading, Success, Error, Loaded
└── rating_bloc.dart                  # Business logic for rating operations
```

### UI Components (Created)
```
lib/feature/rating/presentation/
├── rating_collaborators_dialog.dart       # Modal untuk memberikan rating (PageView carousel)
├── collaborator_rating_section.dart       # Widget untuk tampilkan rating di detail project
└── user_review_section.dart               # Widget untuk tampilkan review di profile user
```

### Existing Models Used
```
lib/feature/rating/
└── user_rating_in_project.dart       # Model untuk GET /api/v1/ratings/projects/{projectId}
```

---

## 🔄 Flow Implementasi

### 1. **Project Owner Menyelesaikan Project**

**File: `edit_collaboration.dart` (Updated)**

```dart
// Ketika owner mengubah status ke "Selesai" (COMPLETED)
if (isChangingToCompleted) {
  // 1. Fetch project details untuk get collaborators
  final projectDetail = await CollaborationService().getProjectDetail(projectId);
  final collaborators = projectDetail.data.collaborators;
  
  // 2. Show rating dialog
  _showRatingDialog(collaborators, projectId);
}
```

**Perubahan:**
- Mapping status "Selesai" → "COMPLETED" (bukan "DONE")
- Detect ketika status berubah ke "COMPLETED"
- Fetch collaborators dan tampilkan `RatingCollaboratorsDialog`

### 2. **Rating Dialog (RatingCollaboratorsDialog)**

**File: `rating_collaborators_dialog.dart` (Created)**

Features:
- **PageView Carousel**: User bisa navigate antar collaborators dengan prev/next button
- **Star Rating**: Klik bintang untuk memberikan rating 1-5
- **Optional Review**: Text field untuk menulis review/feedback
- **Progress Indicator**: Menunjukkan progress collaborator mana yang sedang di-review
- **Batch Submit**: Semua rating di-submit sekaligus dengan validasi

UI:
```
┌─────────────────────────────────────┐
│  Beri Rating Collaborator       [X] │
│─────────────────────────────────────│
│                                     │
│         [Avatar]                    │
│      John Doe                       │
│      Backend Developer              │
│                                     │
│      ★★★★★ (Rating)                 │
│                                     │
│      [Review text field]            │
│                                     │
│   [●○○○○] Progress indicators       │
│   [Sebelumnya]  [Selanjutnya]       │
└─────────────────────────────────────┘
```

### 3. **Submit Rating**

**Flow:**
1. Rating dialog di-submit
2. BLoC emit `SubmitRatingEvent` untuk setiap collaborator
3. Repository call `POST /api/v1/ratings` dengan payload:
```json
{
  "projectId": 17,
  "ratedUserId": 36,
  "ratingValue": 5,
  "review": "Bagus, aktif, dan komunikatif."
}
```
4. Setelah sukses, dialog close dan show success message

### 4. **Tampilkan Rating di Detail Project**

**File: `detail_collaboration.dart` (Need Update)**

Tambahkan section untuk menampilkan rating collaborator:

```dart
// Di dalam detail project
final ratings = await RatingBloc().getRatingsByProject(projectId);

// Render section
CollaboratorRatingSection(
  ratings: ratings.data ?? [],
  isLoading: isLoading,
  hasError: hasError,
)
```

Widget `CollaboratorRatingCard` menampilkan:
- ✅ Avatar collaborator
- ✅ Nama collaborator
- ✅ Rating stars (1-5)
- ✅ Review text
- ✅ Owner name & date

### 5. **Tampilkan Rating di Profile User**

**File: `profile_screen.dart` atau dedicated profile view (Need Update)**

Tambahkan section untuk menampilkan user rating:

```dart
// Fetch user ratings & average
final averageRating = await ratingRepository.getAverageRating(userId);
final userReviews = await ratingRepository.getRatingsByUser(userId);

// Render section
UserReviewSection(
  reviews: userReviews.data ?? [],
  averageRating: averageRating.data?.averageRating,
  totalReviews: averageRating.data?.totalReviews,
)
```

Widget `UserReviewCard` menampilkan:
- ✅ Owner avatar & name
- ✅ Project name
- ✅ Rating stars & value
- ✅ Review text
- ✅ Date

---

## 🔌 Integration Points

### 1. **Detail Project (`detail_collaboration.dart`)**

Import & tambahkan:
```dart
import 'package:gabungyuk/feature/rating/presentation/collaborator_rating_section.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_bloc.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_event.dart';
```

Di build method (setelah collaborators list):
```dart
// Fetch project ratings menggunakan BLoC atau repository
BlocProvider(
  create: (_) => RatingBloc(ratingRepository: RatingRepositoryImpl())
    ..add(FetchProjectRatingsEvent(projectId)),
  child: BlocBuilder<RatingBloc, RatingState>(
    builder: (context, state) {
      if (state is ProjectRatingsLoadedState) {
        return CollaboratorRatingSection(
          ratings: state.ratings.data ?? [],
        );
      } else if (state is RatingLoadingState) {
        return CollaboratorRatingSection(
          ratings: [],
          isLoading: true,
        );
      }
      return const SizedBox.shrink();
    },
  ),
)
```

### 2. **Profile Screen (`profile_screen.dart` / User Detail View)**

Import & tambahkan:
```dart
import 'package:gabungyuk/feature/rating/presentation/user_review_section.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_bloc.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_event.dart';
```

Di build method:
```dart
// Use two FutureBuilder atau BLoC untuk fetch ratings
BlocProvider(
  create: (_) => RatingBloc(ratingRepository: RatingRepositoryImpl())
    ..add(FetchAverageRatingEvent(userId))
    ..add(FetchUserRatingsEvent(userId)),
  child: BlocBuilder<RatingBloc, RatingState>(
    builder: (context, state) {
      if (state is AverageRatingLoadedState) {
        // Also get user reviews
      } else if (state is UserRatingsLoadedState) {
        return UserReviewSection(
          reviews: state.ratings.data ?? [],
          averageRating: averageRating,
          totalReviews: totalReviews,
        );
      }
      return const SizedBox.shrink();
    },
  ),
)
```

---

## 📱 UI Components Reference

### RatingCollaboratorsDialog
- **When**: Triggered when project status → COMPLETED
- **Features**: PageView carousel, star rating, review text, batch submit
- **Actions**: Rating submitted via BLoC event

### CollaboratorRatingSection
- **Location**: Detail project screen
- **Displays**: List of rating cards for collaborators
- **Data Source**: `GET /api/v1/ratings/projects/{projectId}`

### UserReviewSection
- **Location**: Profile / User detail screen
- **Displays**: Average rating badge + list of reviews/testimonials
- **Data Source**: 
  - `GET /api/v1/ratings/users/{userId}/average` (rating summary)
  - `GET /api/v1/ratings/users/{userId}` (review details)

---

## 🔐 Access Control

**Features built-in:**
- ✅ Only project owner can submit rating
- ✅ Rating only for collaborators in the project
- ✅ Rating only allowed when project status = "COMPLETED"
- ✅ Any user can view ratings (public display)

---

## 📝 Checklist untuk Completion

- [ ] Integration di `detail_collaboration.dart` untuk tampilkan collaborator ratings
- [ ] Integration di `profile_screen.dart` atau user detail screen untuk tampilkan user ratings
- [ ] Update model `Datum` di `view_project_model.dart` untuk parse deadline (if needed)
- [ ] Test workflow: Project complete → Rating dialog → Submit → Ratings visible
- [ ] Test profile page: View average rating + review list
- [ ] Verify endpoint `GET /api/v1/ratings/projects/{projectId}` tersedia di backend

---

## 🚀 Quick Start

1. **Models & Repository**: ✅ Siap pakai
2. **BLoC**: ✅ Siap pakai
3. **Rating Dialog**: ✅ Siap pakai
4. **Edit Collaboration Flow**: ✅ Sudah integrated
5. **Detail Project Display**: ❌ Perlu integration (Next step)
6. **Profile User Display**: ❌ Perlu integration (Next step)

---

## 📞 API Endpoints Summary

| Method | Endpoint | Purpose | Model |
|--------|----------|---------|-------|
| POST | `/api/v1/ratings` | Submit rating | CreateRatingCollaboratorsModel |
| GET | `/api/v1/ratings/projects/{id}` | Get project ratings | UserRatingInProject |
| GET | `/api/v1/ratings/users/{id}` | Get user reviews | UserRatingByProjectModel |
| GET | `/api/v1/ratings/users/{id}/average` | Get average rating | UserRatingAverageModel |

---

## ✅ Files Created

✅ `create_rating_model.dart`
✅ `user_rating_by_project_model.dart`
✅ `user_rating_average_model.dart`
✅ `rating_repository.dart`
✅ `rating_event.dart`
✅ `rating_state.dart`
✅ `rating_bloc.dart`
✅ `rating_collaborators_dialog.dart`
✅ `collaborator_rating_section.dart`
✅ `user_review_section.dart`

✅ `edit_collaboration.dart` (Updated)

❌ Next: Integrate dalam `detail_collaboration.dart` & profile screens

