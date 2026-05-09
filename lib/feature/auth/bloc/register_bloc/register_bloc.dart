import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/service/notification_service.dart';
import 'package:gabungyuk/feature/auth/bloc/register_bloc/register_event.dart';
import 'package:gabungyuk/feature/auth/bloc/register_bloc/register_state.dart';
import 'package:gabungyuk/feature/auth/model/register_model/register_model.dart';
import 'package:gabungyuk/feature/auth/repository/register_repository/register_repository.dart';

class RegisterPageBloc extends Bloc<RegisterPageEvent, RegisterPageState> {
  final RegisterRepository registerRepository;

  RegisterPageBloc({required this.registerRepository})
      : super(InitialRegisterPageState()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  Future<void> _onRegisterButtonPressed(
      RegisterButtonPressed event,
      Emitter<RegisterPageState> emit,
      ) async {
    emit(RegisterPageLoading());

    try {
      final RegisterModel registerModel =
      await registerRepository.registerUser(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      await NotificationService.instance.syncTokenAfterLogin(event.email);

      if (kDebugMode) {
        final token = await NotificationService.instance.getFcmToken();
        print('\n📱 [FCM TOKEN - REGISTER]');
        print(token);
        print('');
      }

      emit(RegisterPageLoaded(registerModel));
    } catch (e) {
      if (e is ApiException) {
        emit(RegisterPageError(e.message));
      } else {
        if (kDebugMode) {
          print('Register BLoC unexpected error: $e');
        }

        emit(RegisterPageError('Terjadi kesalahan. Silakan coba lagi.'));
      }
    }
  }
}