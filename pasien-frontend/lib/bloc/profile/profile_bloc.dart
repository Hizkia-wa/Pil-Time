import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final response = await ApiService.getProfile(pasienId: event.pasienId);
      if (response['success'] == true) {
        emit(ProfileLoaded(profileData: response['data'] ?? {}));
      } else {
        emit(ProfileFailure(response['error'] ?? 'Gagal memuat data profil'));
      }
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    Map<String, dynamic> currentProfileData = {};

    if (currentState is ProfileLoaded) {
      currentProfileData = currentState.profileData;
    } else if (currentState is ProfileUpdateSuccess) {
      currentProfileData = currentState.profileData;
    }

    emit(ProfileUpdating());
    try {
      final response = await ApiService.updateProfile(
        pasienId: event.pasienId,
        data: event.updatedData,
      );

      if (response['success'] == true) {
        // Gabungkan updatedData ke currentProfileData
        final mergedProfileData = Map<String, dynamic>.from(currentProfileData)
          ..addAll(event.updatedData);

        emit(ProfileUpdateSuccess(
          message: 'Profil Anda berhasil diperbarui! 🏆',
          profileData: mergedProfileData,
        ));
        
        // Kembalikan ke state loaded agar widget tetap menampilkan profil
        emit(ProfileLoaded(profileData: mergedProfileData));
      } else {
        emit(ProfileUpdateFailure(response['error'] ?? 'Gagal memperbarui profil'));
        emit(ProfileLoaded(profileData: currentProfileData));
      }
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
      emit(ProfileLoaded(profileData: currentProfileData));
    }
  }
}
