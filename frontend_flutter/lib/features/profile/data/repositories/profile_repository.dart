import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';

class ProfileRepository {
  Future<Map<String, dynamic>> fetchMyProfile() async {
    final token = StorageService.getString(AppConstants.tokenKey);
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(AppConstants.myProfileUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<List<dynamic>> fetchMyGames() async {
    final token = StorageService.getString(AppConstants.tokenKey);
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(AppConstants.myGamesUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load match history');
    }
  }
}
