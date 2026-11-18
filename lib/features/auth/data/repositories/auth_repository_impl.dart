import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const AuthFailure(AuthFailureType.userNotFound);
      }

      return UserEntity(id: user.uid, email: user.email ?? email);
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    } on FirebaseException {
      throw const AuthFailure(AuthFailureType.server);
    } catch (_) {
      throw const AuthFailure(AuthFailureType.unknown);
    }
  }

  @override
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const AuthFailure(AuthFailureType.unknown);
      }

      return UserEntity(id: user.uid, email: user.email ?? email);
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    } on FirebaseException {
      throw const AuthFailure(AuthFailureType.server);
    } catch (_) {
      throw const AuthFailure(AuthFailureType.unknown);
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await remoteDataSource.resetPassword(email: email);
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    } on FirebaseException {
      throw const AuthFailure(AuthFailureType.server);
    } catch (_) {
      throw const AuthFailure(AuthFailureType.unknown);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    } on FirebaseException {
      throw const AuthFailure(AuthFailureType.server);
    } catch (_) {
      throw const AuthFailure(AuthFailureType.unknown);
    }
  }

  AuthFailure _mapAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return const AuthFailure(AuthFailureType.emailAlreadyInUse);

      case 'invalid-email':
        return const AuthFailure(AuthFailureType.invalidEmail);

      case 'weak-password':
        return const AuthFailure(AuthFailureType.weakPassword);

      case 'user-not-found':
        return const AuthFailure(AuthFailureType.userNotFound);

      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(AuthFailureType.invalidCredential);

      case 'network-request-failed':
        return const AuthFailure(AuthFailureType.network);

      case 'too-many-requests':
        return const AuthFailure(AuthFailureType.tooManyRequests);

      default:
        return const AuthFailure(AuthFailureType.unknown);
    }
  }
}
