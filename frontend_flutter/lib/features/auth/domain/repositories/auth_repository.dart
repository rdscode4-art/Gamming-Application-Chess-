import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> guestLogin(String username);
}
