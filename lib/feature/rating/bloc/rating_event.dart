abstract class RatingEvent {}

class SubmitRatingEvent extends RatingEvent {
  final int projectId;
  final int ratedUserId;
  final int ratingValue;
  final String review;

  SubmitRatingEvent({
    required this.projectId,
    required this.ratedUserId,
    required this.ratingValue,
    required this.review,
  });
}

class FetchProjectRatingsEvent extends RatingEvent {
  final int projectId;

  FetchProjectRatingsEvent(this.projectId);
}

class FetchUserRatingsEvent extends RatingEvent {
  final int userId;

  FetchUserRatingsEvent(this.userId);
}

class FetchAverageRatingEvent extends RatingEvent {
  final int userId;

  FetchAverageRatingEvent(this.userId);
}

