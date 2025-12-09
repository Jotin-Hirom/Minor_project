// import 'package:classqr/models/app_user.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthStorage {
//   static const _keyAccessToken = 'accessToken';
//   static const _keyUser = 'user';

//   Future<void> saveSession({
//     required String accessToken,
//     required AppUser user,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_keyAccessToken, accessToken);
//     await prefs.setString(_keyUser, jsonEncode(user.toJson()));
//   }

//   Future<(String accessToken, AppUser user)?> loadSession() async {
//     final prefs = await SharedPreferences.getInstance();

//     final token = prefs.getString(_keyAccessToken);
//     final userJson = prefs.getString(_keyUser);

//     if (token == null || userJson == null) {
//       return null;
//     }

//     final Map<String, dynamic> userMap = jsonDecode(userJson);
//     final user = AppUser.fromJson(userMap);
//     return (token, user);
//   }

//   Future<void> clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyAccessToken);
//     await prefs.remove(_keyUser);
//   }
// }
