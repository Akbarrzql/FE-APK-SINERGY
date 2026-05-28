import 'package:flutter/cupertino.dart';

import '../../repository/register_repository/register_repository.dart';

@immutable
abstract class RegisterPageState {}

class InitialRegisterPageState extends RegisterPageState {}

class RegisterPageLoading extends RegisterPageState {}

class RegisterPageLoaded extends RegisterPageState {
  final FirebaseRegisterResult registerResult;

  RegisterPageLoaded(this.registerResult);
}

class RegisterPageError extends RegisterPageState {
  final String errorMessage;

  RegisterPageError(this.errorMessage);
}
