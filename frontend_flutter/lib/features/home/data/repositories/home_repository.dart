import '../../../../core/network/api_client.dart';

class HomeRepository {
  Future<List<Map<String, dynamic>>> getBanners() async {
    final response = await ApiClient.instance.get('/api/banners');
    return List<Map<String, dynamic>>.from(response.data['banners'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getLiveMatches() async {
    final response = await ApiClient.instance.get('/api/contests/live');
    return List<Map<String, dynamic>>.from(response.data['matches'] ?? []);
  }
}
