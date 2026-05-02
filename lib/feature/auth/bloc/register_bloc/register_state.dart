import 'package:flutter/cupertino.dart';

import '../../model/register_model/register_model.dart';

@immutable
abstract class RegisterPageState {}

class InitialRegisterPageState extends RegisterPageState {}

class RegisterPageLoading extends RegisterPageState {}

class RegisterPageLoaded extends RegisterPageState {
  final RegisterModel registerModel;

  RegisterPageLoaded(this.registerModel);
}

class RegisterPageError extends RegisterPageState {
  final String errorMessage;

  RegisterPageError(this.errorMessage);
}