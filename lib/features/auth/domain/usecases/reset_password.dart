import '../repositories/auth_repository.dart';

class ResetPassword {
  const ResetPassword(this.repository);

  final AuthRepository repository;

  Future<void> call({required String email}) {
    return repository.resetPassword(email: email);
  }
}
