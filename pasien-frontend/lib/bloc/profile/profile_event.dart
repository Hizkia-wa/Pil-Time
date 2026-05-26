import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {
  final int pasienId;

  const FetchProfile({required this.pasienId});

  @override
  List<Object?> get props => [pasienId];
}

class UpdateProfileEvent extends ProfileEvent {
  final int pasienId;
  final Map<String, dynamic> updatedData;

  const UpdateProfileEvent({
    required this.pasienId,
    required this.updatedData,
  });

  @override
  List<Object?> get props => [pasienId, updatedData];
}
