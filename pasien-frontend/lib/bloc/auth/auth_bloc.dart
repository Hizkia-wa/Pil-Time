import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<OtpVerificationSubmitted>(_onOtpVerificationSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final session = await AuthService.getPasienSession();
    if (session != null && session['pasien_id'] != null) {
      emit(AuthAuthenticated(session: session));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await AuthService.login(
        email: event.email,
        password: event.password,
      );

      if (result['success'] == true) {
        final session = await AuthService.getPasienSession();
        if (session != null) {
          emit(AuthAuthenticated(session: session));
        } else {
          emit(const AuthFailure(error: 'Sesi tidak dapat dibuat setelah login'));
        }
      } else {
        emit(AuthFailure(error: result['error'] ?? 'Login gagal'));
      }
    } catch (e) {
      emit(AuthFailure(error: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await AuthService.register(
        nama: event.registerData['nama'] ?? '',
        email: event.registerData['email'] ?? '',
        password: event.registerData['password'] ?? '',
        nik: event.registerData['nik'] ?? '',
        tanggalLahir: event.registerData['tanggal_lahir'] ?? '',
        tempatLahir: event.registerData['tempat_lahir'] ?? '',
        telepon: event.registerData['telepon'] ?? '',
        noTeleponPendamping: event.registerData['no_telepon_pendamping'] ?? '',
        jenisKelamin: event.registerData['jenis_kelamin'] ?? 'Laki-laki',
        alamat: event.registerData['alamat'] ?? '',
      );

      if (result['success'] == true) {
        // Auto login setelah pendaftaran sukses
        final loginResult = await AuthService.login(
          email: event.registerData['email'] ?? '',
          password: event.registerData['password'] ?? '',
        );

        if (loginResult['success'] == true) {
          final session = await AuthService.getPasienSession();
          if (session != null) {
            emit(AuthAuthenticated(session: session));
            return;
          }
        }
        
        // Jika auto-login gagal, tetap arahkan ke unauthenticated agar bisa login manual
        emit(AuthUnauthenticated());
      } else {
        emit(AuthFailure(error: result['error'] ?? 'Registrasi gagal'));
      }
    } catch (e) {
      emit(AuthFailure(error: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await AuthService.clearSession();
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.sendOtp(event.email);
      if (result['success'] == true) {
        emit(ForgotPasswordSuccess(email: event.email));
      } else {
        emit(AuthFailure(error: result['error'] ?? 'Gagal mengirim OTP'));
      }
    } catch (e) {
      emit(AuthFailure(error: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onOtpVerificationSubmitted(
    OtpVerificationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.verifyOtp(event.email, event.otp);
      if (result['success'] == true) {
        emit(OtpVerificationSuccess(email: event.email, otp: event.otp));
      } else {
        emit(AuthFailure(error: result['error'] ?? 'OTP tidak valid'));
      }
    } catch (e) {
      emit(AuthFailure(error: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.resetPassword(
        event.email,
        event.password,
        event.otp,
      );
      if (result['success'] == true) {
        emit(ResetPasswordSuccess());
      } else {
        emit(AuthFailure(error: result['error'] ?? 'Gagal mengatur ulang password'));
      }
    } catch (e) {
      emit(AuthFailure(error: ErrorHandler.getErrorMessage(e)));
    }
  }
}
