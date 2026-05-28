import 'package:flutter/cupertino.dart';

@immutable
abstract class RegisterPageEvent {}

class RegisterButtonPressed extends RegisterPageEvent {
  final String name;
  final String email;
  final String password;

  RegisterButtonPressed({
    required this.name,
    required this.email,
    required this.password,
  });
}
