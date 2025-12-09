import 'dart:convert';
import 'package:classqr/models/app_user.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier()..loadUserFromLocal();
});

class AuthState {
  final bool isLoggedIn;
  final String? role;
  final User? user;
  final String token;

  const AuthState({
    required this.isLoggedIn,
    required this.token,
    this.role,
    this.user,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
    String? role,
    User? user,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState(isLoggedIn: false, token: ''));

  Future<void> loadUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final role = prefs.getString('role');
    final userStr = prefs.getString('user');

    if (token != null && role != null && userStr != null) {
      final map = jsonDecode(userStr) as Map<String, dynamic>;
      final user = User.fromJson(map);
      state = AuthState(isLoggedIn: true, role: role, user: user, token: token);
    }
  }

  Future<void> login(String role, User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    await prefs.setString('role', role);
    await prefs.setString('user', jsonEncode(user.toJson()));
    state = AuthState(
      isLoggedIn: true,
      token: token,
      role: role,
      user: user,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState(isLoggedIn: false, token: '');
  } 
}
