import 'dart:convert';

import 'package:classqr/core/config/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> refreshToken(String email, String token) async {
  debugPrint(token);
  final url = Uri.parse("${Env.apiBaseUrl}/api/auth/refresh");
  final res = await http.post(
    url,
    headers: {"Content-Type": "application/json",
    "Authorization": "Bearer $token",
    },
    body: jsonEncode({"email": email}),
  );

  debugPrint(res.body);

  if (res.statusCode != 200) {
    throw Exception("Refresh token failed");
  }

  return jsonDecode(res.body);
}
