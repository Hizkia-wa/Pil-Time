abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});
}

class RegisterSubmitted extends AuthEvent {
  final Map<String, dynamic> registerData;

  const RegisterSubmitted({required this.registerData});
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});
}

class OtpVerificationSubmitted extends AuthEvent {
  final String email;
  final String otp;

  const OtpVerificationSubmitted({required this.email, required this.otp});
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String otp;

  const ResetPasswordSubmitted({
    required this.email,
    required this.password,
    required this.otp,
  });
}
