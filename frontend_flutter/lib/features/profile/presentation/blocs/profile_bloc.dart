import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdatePreferences>(_onUpdatePreferences);
    on<UploadAvatar>(_onUploadAvatar);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final userProfile = await _repository.fetchMyProfile();
      
      final user = userProfile['user'] ?? userProfile;
      if (user['userId'] != null) {
        await StorageService.setString('USER_ID', user['userId']);
      }

      List<dynamic> matchHistory = [];
      try {
        matchHistory = await _repository.fetchMyGames();
      } catch (_) {}

      emit(state.copyWith(
        isLoading: false,
        userProfile: user,
        matchHistory: matchHistory,
      ));

      // Attempt to register FCM token
      try {
        final token = await FCMService().getToken();
        if (token != null) {
          await ApiClient.instance.post('/users/fcm-token', data: {'token': token});
        }
      } catch (_) {
        // Silently fail if FCM token update fails
      }

    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdatePreferences(UpdatePreferences event, Emitter<ProfileState> emit) async {
    if (state.userProfile == null) return;
    
    // Optimistic update
    final updatedProfile = Map<String, dynamic>.from(state.userProfile!);
    final currentPrefs = Map<String, dynamic>.from(updatedProfile['preferences'] ?? {});
    
    currentPrefs.addAll(event.preferences);
    updatedProfile['preferences'] = currentPrefs;
    
    emit(state.copyWith(userProfile: updatedProfile));

    try {
      await ApiClient.instance.put('/users/me', data: {
        'preferences': currentPrefs,
      });
    } catch (e) {
      // Background failure - could revert here if needed, but keeping it simple
    }
  }

  Future<void> _onUploadAvatar(UploadAvatar event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final avatarUrl = await _repository.uploadAvatar(event.filePath);
      
      final updatedProfile = Map<String, dynamic>.from(state.userProfile ?? {});
      updatedProfile['avatarUrl'] = avatarUrl;
      
      emit(state.copyWith(isLoading: false, userProfile: updatedProfile, error: 'SUCCESS: $avatarUrl'));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'FAIL: ${e.toString()}'));
    }
  }
}
