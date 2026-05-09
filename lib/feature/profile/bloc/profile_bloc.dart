import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_event.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_state.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/auth_session_manager.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(InitialProfileState()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await profileRepository.getProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
          if (e is ApiException) {
            if (e.statusCode == 401) {
              await AuthSessionManager.instance.forceLogout();
              return;
            }
            emit(ProfileError(e.message));
          } else {
            emit(ProfileError('Terjadi kesalahan. Silakan coba lagi.'));
          }
      }
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileUpdating());
      try {
        final response = await profileRepository.updateProfile(
          event.body,
          profileImageFile: event.profileImageFile,
        );
        emit(ProfileUpdateSuccess(response.message));
        // Reload profile after success
        add(LoadProfile());
      } catch (e) {
        if (e is ApiException) {
          if (e.statusCode == 401) {
            await AuthSessionManager.instance.forceLogout();
            return;
          }
          emit(ProfileError(e.message));
        } else {
          emit(ProfileError('Gagal memperbarui profil.'));
        }
      }
    });
  }
}

