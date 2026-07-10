import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_service.dart';

class TournamentRepository {
  Future<List<dynamic>> fetchTournaments() async {
    final response = await ApiService.get(AppConstants.tournamentsUrl);
    if (response != null) {
      return response as List<dynamic>;
    }
    throw Exception('Failed to load tournaments');
  }

  Future<Map<String, dynamic>> fetchTournamentDetails(String id) async {
    final response = await ApiService.get(AppConstants.tournamentDetailUrl(id));
    if (response != null) {
      return response as Map<String, dynamic>;
    }
    throw Exception('Failed to load tournament details');
  }

  Future<Map<String, dynamic>> createTournament(Map<String, dynamic> data) async {
    final response = await ApiService.post(AppConstants.tournamentsUrl, data);
    if (response != null) {
      return response as Map<String, dynamic>;
    }
    throw Exception('Failed to create tournament');
  }

  Future<void> registerForTournament(String id) async {
    final response = await ApiService.post(AppConstants.tournamentRegisterUrl(id), {});
    if (response == null) {
      throw Exception('Failed to register for tournament');
    }
  }
}
