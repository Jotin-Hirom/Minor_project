// import 'package:classqr/auth/api_auth.dart';
// import 'package:classqr/auth/auth_storage.dart';
// import 'package:classqr/models/app_user.dart';
// import 'package:http/http.dart' as http;

// class AuthService {
//   final AuthApi api;
//   final AuthStorage storage;

//   AuthService({required this.api, required this.storage});

//   Future<(String accessToken, AppUser user)> login({
//     required String role,
//     required String email,
//     required String password,
//   }) async {
//     final http.Response res = await api.login(
//       role: role,
//       email: email,
//       password: password,
//     );
 
//     final statusCode = res.statusCode;
//     final String rawBody = res.body;

//     Map<String, dynamic> data = {};
//     if (rawBody.isNotEmpty) {
//       data = jsonDecode(rawBody) as Map<String, dynamic>;
//     }

//     if (statusCode != 200 || data['success'] != true) {
//       final message = data['message'] ?? 'Login failed';
//       throw AuthException(statusCode: statusCode, message: message);
//     }

//     final accessToken = data['accessToken'] as String;
//     final userJson = data['user'] as Map<String, dynamic>;
//     final user = AppUser.fromJson(userJson);

//     await storage.saveSession(accessToken: accessToken, user: user);

//     return (accessToken, user);
//   }

//   Future<(String accessToken, AppUser user)?> tryRestoreSession() async {
//     return storage.loadSession();
//   }

//   Future<void> logout() async {
//     // Optional: call backend.logout() to revoke refresh token
//     // await api.logout();
//     await storage.clearSession();
//   }
// }

// class AuthException implements Exception {
//   final int statusCode;
//   final String message;

//   AuthException({required this.statusCode, required this.message});

//   @override
//   String toString() => 'AuthException($statusCode, $message)';
// }
