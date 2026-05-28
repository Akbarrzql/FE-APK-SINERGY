import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_event.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_state.dart';
import 'package:gabungyuk/feature/rating/model/create_rating_model.dart';
import 'package:gabungyuk/feature/rating/repository/rating_repository.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepository ratingRepository;

  RatingBloc({required this.ratingRepository}) : super(RatingInitialState()) {
    on<SubmitRatingEvent>((event, emit) async {
      emit(RatingLoadingState());
      try {
        final rating = CreateRatingCollaboratorsModel(
          projectId: event.projectId,
          ratedUserId: event.ratedUserId,
          ratingValue: event.ratingValue,
          review: event.review,
        );
        await ratingRepository.submitRating(rating);
        emit(RatingSuccessState('Rating berhasil disimpan'));
      } catch (e) {
        final message = e is ApiException ? e.message : 'Gagal menyimpan rating';
        emit(RatingErrorState(message));
      }
    });

    on<FetchProjectRatingsEvent>((event, emit) async {
      emit(RatingLoadingState());
      try {
        final ratings = await ratingRepository.getRatingsByProject(event.projectId);
        emit(ProjectRatingsLoadedState(ratings));
      } catch (e) {
        final message = e is ApiException ? e.message : 'Gagal memuat rating project';
        emit(RatingErrorState(message));
      }
    });

    on<FetchUserRatingsEvent>((event, emit) async {
      emit(RatingLoadingState());
      try {
        final ratings = await ratingRepository.getRatingsByUser(event.userId);
        emit(UserRatingsLoadedState(ratings));
      } catch (e) {
        final message = e is ApiException ? e.message : 'Gagal memuat rating user';
        emit(RatingErrorState(message));
      }
    });

    on<FetchAverageRatingEvent>((event, emit) async {
      emit(RatingLoadingState());
      try {
        final average = await ratingRepository.getAverageRating(event.userId);
        emit(AverageRatingLoadedState(average));
      } catch (e) {
        final message = e is ApiException ? e.message : 'Gagal memuat average rating';
        emit(RatingErrorState(message));
      }
    });
  }
}

