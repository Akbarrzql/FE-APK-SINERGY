import 'dart:io';
import 'package:flutter/foundation.dart';

@immutable
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> body;
  final File? profileImageFile;

  UpdateProfile({required this.body, this.profileImageFile});
}

