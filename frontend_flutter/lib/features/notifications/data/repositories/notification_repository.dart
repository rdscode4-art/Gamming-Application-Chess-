import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  Future<List<NotificationModel>> fetchNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await ApiClient.instance.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      
      final data = response.data['notifications'] as List;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await ApiClient.instance.put('/notifications/$id/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
