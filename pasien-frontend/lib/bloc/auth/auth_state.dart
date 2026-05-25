abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> session;

  const AuthAuthenticated({required this.session});
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});
}

class ForgotPasswordSuccess extends AuthState {
  final String email;

  const ForgotPasswordSuccess({required this.email});
}

class OtpVerificationSuccess extends AuthState {
  final String email;
  final String otp;

  const OtpVerificationSuccess({required this.email, required this.otp});
}

class ResetPasswordSuccess extends AuthState {}
