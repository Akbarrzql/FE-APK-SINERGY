import 'package:flutter/foundation.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';

@immutable
abstract class ProfileState {}

class InitialProfileState extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}

