import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel> guestLogin(String username) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/guest',
        data: {'username': username},
      );

      final token = response.data['token'];
      final userJson = response.data['user'];

      await StorageService.setString(AppConstants.tokenKey, token);
      return UserModel.fromJson(userJson);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
