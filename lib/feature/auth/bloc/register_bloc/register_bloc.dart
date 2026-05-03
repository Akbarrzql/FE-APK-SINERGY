import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/feature/auth/bloc/register_bloc/register_event.dart';
import 'package:gabungyuk/feature/auth/bloc/register_bloc/register_state.dart';

import '../../model/register_model/register_model.dart';
import '../../repository/register_repository/register_repository.dart';
import 'package:gabungyuk/core/common/api_exception.dart';

class RegisterPageBloc extends Bloc<RegisterPageEvent, RegisterPageState> {
  late RegisterModel registerModel;
  final RegisterRepository registerRepository;

  RegisterPageBloc({required this.registerRepository}) : super(InitialRegisterPageState()){
    on<RegisterButtonPressed>((event, emit) async {
      emit(RegisterPageLoading());
      try {
        registerModel = await registerRepository.registerUser(
          name: event.name,
          email: event.email,
          password: event.password,
        );
        emit(RegisterPageLoaded(registerModel));
      } catch (e) {
        if (e is ApiException) {
          emit(RegisterPageError(e.message));
        } else {
          if (kDebugMode) print('Register BLoC unexpected error: $e');
          emit(RegisterPageError('Terjadi kesalahan. Silakan coba lagi.'));
        }
      }
    });
  }
}