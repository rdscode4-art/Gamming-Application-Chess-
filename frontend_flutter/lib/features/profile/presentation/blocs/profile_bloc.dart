import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/services/storage_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
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
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
