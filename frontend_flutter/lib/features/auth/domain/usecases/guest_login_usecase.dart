import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class GuestLoginUseCase {
  final AuthRepository repository;

  GuestLoginUseCase(this.repository);

  Future<UserModel> execute(String username) {
    return repository.guestLogin(username);
  }
}
