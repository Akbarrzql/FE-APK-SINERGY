import 'package:gabungyuk/feature/rating/user_rating_in_project.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_by_project_model.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_average_model.dart';

abstract class RatingState {}

class RatingInitialState extends RatingState {}

class RatingLoadingState extends RatingState {}

class RatingSuccessState extends RatingState {
  final String message;

  RatingSuccessState(this.message);
}

class RatingErrorState extends RatingState {
  final String message;

  RatingErrorState(this.message);
}

class ProjectRatingsLoadedState extends RatingState {
  final UserRatingInProject ratings;

  ProjectRatingsLoadedState(this.ratings);
}

class UserRatingsLoadedState extends RatingState {
  final UserRatingByProjectModel ratings;

  UserRatingsLoadedState(this.ratings);
}

class AverageRatingLoadedState extends RatingState {
  final UserRatingAverageModel averageData;

  AverageRatingLoadedState(this.averageData);
}

