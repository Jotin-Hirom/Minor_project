import 'package:classqr/core/config/env.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ------------------------------------------------------
// MODEL
// ------------------------------------------------------
class OtpState {
  final bool verifying;
  final bool resending;
  final bool success;
  final String? error;

  const OtpState({
    this.verifying = false,
    this.resending = false,
    this.success = false,
    this.error,
  });

  OtpState copyWith({
    bool? verifying,
    bool? resending,
    bool? success,
    String? error,
  }) {
    return OtpState(
      verifying: verifying ?? this.verifying,
      resending: resending ?? this.resending,
      success: success ?? this.success,
      error: error,
    );
  }
}

// ------------------------------------------------------
// PROVIDER
// ------------------------------------------------------
class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(const OtpState()); 
  // VERIFY OTP
  Future<bool> verifyOTP(String email, String otp, String from) async {
    state = state.copyWith(verifying: true, error: null);

    final url = Uri.parse(
      from == "forgotPassword"
          ? "${Env.apiBaseUrl}/api/auth/verify-forgot"
          : "${Env.apiBaseUrl}/api/auth/verify",
    );

    try {
      final response = await http.post(
        url, 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final ok = response.statusCode == 200;

      state = state.copyWith(
        verifying: false,
        success: ok,
        error: ok ? null : "Invalid OTP",
      );

      return ok;
    } catch (e) {
      state = state.copyWith(verifying: false, error: "Network error");
      return false;
    }
  }

  // RESEND OTP
  Future<bool> resendOTP(String email, String from) async {
    state = state.copyWith(resending: true);

    final url = Uri.parse(
      from == "forgotPassword"
          ? "${Env.apiBaseUrl}/api/auth/forgot-password"
          : "${Env.apiBaseUrl}/api/auth/resend-otp",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final ok = response.statusCode == 200;

      state = state.copyWith(
        resending: false,
        error: ok ? null : "Failed to resend",
      );

      return ok;
    } catch (e) {
      state = state.copyWith(resending: false, error: "Network error");
      return false;
    }
  }

  void reset() {
    state = const OtpState();
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>(
  (ref) => OtpNotifier(),
);
