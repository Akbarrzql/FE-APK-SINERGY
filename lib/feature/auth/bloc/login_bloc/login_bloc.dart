import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_event.dart';
import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_state.dart';
import 'package:gabungyuk/feature/auth/repository/login_repository/login_repository.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/auth/model/login_model/login_model.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  late LoginModel loginModel;
  final LoginRepository loginRepository;

  LoginPageBloc({required this.loginRepository})
      : super(InitialLoginPageState()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginPageLoading());
      try {
        loginModel = await loginRepository.loginUser(
          email: event.email,
          password: event.password,
        );
        emit(LoginPageLoaded(loginModel));
      } catch (e) {
        if (e is ApiException) {
          emit(LoginPageError(e.message));
        } else {
          if (kDebugMode) print('Login BLoC unexpected error: $e');
          emit(LoginPageError('Terjadi kesalahan. Silakan coba lagi.'));
        }
      }
    });
  }
}


