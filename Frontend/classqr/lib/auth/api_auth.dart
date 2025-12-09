import 'dart:convert';
import 'package:classqr/core/config/env.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  Future<http.Response> login({
    required String role,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${Env.apiBaseUrl}/api/auth/login');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'role': role.toLowerCase(),
        'email': email.toLowerCase(),
        'password': password,
      }),
    );

    return res;
  }

  Future<void> logout() async {
    // final url = Uri.parse('${Env.apiBaseUrl}/api/auth/logout');
    // await http.post(url, headers: {...});
  }
}
