enum AuthFailureType {
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  userNotFound,
  invalidCredential,
  network,
  tooManyRequests,
  server,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.type);

  final AuthFailureType type;
}
