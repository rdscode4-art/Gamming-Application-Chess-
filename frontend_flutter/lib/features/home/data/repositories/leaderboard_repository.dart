import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

class LeaderboardRepository {
  Future<List<dynamic>> fetchLeaderboard({int limit = 100}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.leaderboardUrl}?limit=$limit'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }
}
