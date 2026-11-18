import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/signup_user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.loginUser,
    required this.signupUser,
    required this.logoutUser,
    required this.resetPassword,
  }) : super(AuthInitial());

  final LoginUser loginUser;
  final SignupUser signupUser;
  final LogoutUser logoutUser;
  final ResetPassword resetPassword;

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      final UserEntity user = await loginUser(email: email, password: password);

      emit(AuthLoginSuccess(user));
    } on AuthFailure catch (failure) {
      emit(AuthError(_getLocalizationKey(failure.type)));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final UserEntity user = await signupUser(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthSignupSuccess(user));
    } on AuthFailure catch (failure) {
      emit(AuthError(_getLocalizationKey(failure.type)));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(AuthLoading());

    try {
      await resetPassword(email: email);

      emit(AuthPasswordResetSuccess());
    } on AuthFailure catch (failure) {
      emit(AuthError(_getLocalizationKey(failure.type)));
    }
  }

  Future<void> logout() async {
    try {
      await logoutUser();

      emit(AuthInitial());
    } on AuthFailure catch (failure) {
      emit(AuthError(_getLocalizationKey(failure.type)));
    }
  }

  String _getLocalizationKey(AuthFailureType type) {
    switch (type) {
      case AuthFailureType.emailAlreadyInUse:
        return 'authEmailAlreadyInUse';

      case AuthFailureType.invalidEmail:
        return 'authInvalidEmail';

      case AuthFailureType.weakPassword:
        return 'authWeakPassword';

      case AuthFailureType.userNotFound:
        return 'authUserNotFound';

      case AuthFailureType.invalidCredential:
        return 'authInvalidCredential';

      case AuthFailureType.network:
        return 'authNetworkError';

      case AuthFailureType.tooManyRequests:
        return 'authTooManyRequests';

      case AuthFailureType.server:
        return 'authServerError';

      case AuthFailureType.unknown:
        return 'authUnknownError';
    }
  }
}
