import 'package:flutter/cupertino.dart';

import 'package:gabungyuk/feature/auth/repository/login_repository/login_repository.dart';

@immutable
abstract class LoginPageState {}

class InitialLoginPageState extends LoginPageState {}

class LoginPageLoading extends LoginPageState {}

class LoginPageLoaded extends LoginPageState {
  final FirebaseLoginResult loginResult;

  LoginPageLoaded(this.loginResult);
}

class LoginPageError extends LoginPageState {
  final String errorMessage;

  LoginPageError(this.errorMessage);
}

