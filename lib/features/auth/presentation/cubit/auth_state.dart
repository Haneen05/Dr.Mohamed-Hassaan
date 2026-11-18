import '../../domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  AuthLoginSuccess(this.user);

  final UserEntity user;
}

class AuthSignupSuccess extends AuthState {
  AuthSignupSuccess(this.user);

  final UserEntity user;
}

class AuthPasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  AuthError(this.localizationKey);

  final String localizationKey;
}
