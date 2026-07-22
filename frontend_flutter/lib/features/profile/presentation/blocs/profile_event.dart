import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdatePreferences extends ProfileEvent {
  final Map<String, dynamic> preferences;
  UpdatePreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class UploadAvatar extends ProfileEvent {
  final String filePath;
  UploadAvatar(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
