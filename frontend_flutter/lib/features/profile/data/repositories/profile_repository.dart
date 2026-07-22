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

  Future<String> uploadAvatar(String filePath) async {
    final token = StorageService.getString(AppConstants.tokenKey);
    if (token == null) throw Exception('No token found');

    // Make sure we have the correct base url for the endpoint
    // Fallback to the standard /api/users/avatar if AppConstants doesn't have it
    // Actually we will construct it from AppConstants.myProfileUrl
    final baseUrl = AppConstants.myProfileUrl.replaceAll('/me', '/avatar');
    
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

    var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['avatarUrl'];
    } else {
      throw Exception('Failed to upload avatar');
    }
  }
}
