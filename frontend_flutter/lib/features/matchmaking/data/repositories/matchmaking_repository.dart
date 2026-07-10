import '../../../../../core/services/api_service.dart';
import '../../../../../core/constants/app_constants.dart';

class MatchmakingRepository {
  Future<List<dynamic>> getGameModes() async {
    try {
      final response = await ApiService.get(AppConstants.contestModesUrl);
      if (response != null && response['modes'] != null) {
        return response['modes'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> quickJoin({
    required String timeControl,
    required int entryFee,
    required bool isRated,
  }) async {
    try {
      final response = await ApiService.post(AppConstants.contestQuickJoinUrl, {
        'timeControl': timeControl,
        'entryFee': entryFee,
        'isRated': isRated,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
