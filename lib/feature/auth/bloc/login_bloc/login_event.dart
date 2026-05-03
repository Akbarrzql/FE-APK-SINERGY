import 'package:flutter/cupertino.dart';

@immutable
abstract class LoginPageEvent {}

class LoginButtonPressed extends LoginPageEvent {
  final String email;
  final String password;

  LoginButtonPressed({
    required this.email,
    required this.password,
  });
}

