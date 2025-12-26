import 'dart:convert';

import 'package:classqr/core/config/env.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> refreshToken(String email) async {
  final url = Uri.parse("${Env.apiBaseUrl}/api/auth/refresh");
  final res = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email}),
  );

  if (res.statusCode != 200) {
    throw Exception("Refresh token failed");
  }

  return jsonDecode(res.body);
}
