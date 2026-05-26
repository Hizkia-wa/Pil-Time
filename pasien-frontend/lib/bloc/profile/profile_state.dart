import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;

  const ProfileLoaded({required this.profileData});

  ProfileLoaded copyWith({Map<String, dynamic>? profileData}) {
    return ProfileLoaded(
      profileData: profileData ?? this.profileData,
    );
  }

  @override
  List<Object?> get props => [profileData];
}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  final Map<String, dynamic> profileData;

  const ProfileUpdateSuccess({
    required this.message,
    required this.profileData,
  });

  @override
  List<Object?> get props => [message, profileData];
}

class ProfileUpdateFailure extends ProfileState {
  final String error;

  const ProfileUpdateFailure(this.error);

  @override
  List<Object?> get props => [error];
}
