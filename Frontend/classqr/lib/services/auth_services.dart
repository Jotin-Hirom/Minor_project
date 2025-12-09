import 'dart:convert';
import 'package:classqr/core/config/env.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> login(
    String role,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${Env.apiBaseUrl}/api/auth/login');
    dynamic res;
    try {
      final result = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': role, 'email': email, 'password': password}),
      );
      res = result;
    } catch (e) {
      return {'status': 503, 'data': {}};
    }
    Map<String, dynamic>? data;
    try {
      data = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : null;
    } catch (e) {
      data = {'error': 'invalid_response'};
    }

    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> body) async {
    final url = Uri.parse('${Env.apiBaseUrl}/api/auth/signup');
    dynamic res;
    try {
      final result = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      res = result;
    } catch (e) {
      return {'status': 503, 'data': {}};
    }
    Map<String, dynamic>? data;
    try {
      data = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : null;
    } catch (e) {
      data = {'error': 'invalid_response'};
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> sendForgotOtp(String email) async {
    final url = Uri.parse('${Env.apiBaseUrl}/api/auth/forgot-password');
    dynamic res;
    try {
      final result = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      res = result;
    } catch (e) {
      return {'status': 503, 'data': {}};
    }
    Map<String, dynamic>? data;
    try {
      data = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : null;
    } catch (e) {
      data = {'error': 'invalid_response'};
    }
    return {'status': res.statusCode, 'data': data};
  }
}
