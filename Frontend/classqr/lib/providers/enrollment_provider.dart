import 'package:classqr/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../core/config/env.dart';

final selectedAttendanceDateProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

final attendanceSearchQueryProvider = StateProvider<String>((ref) => '');

final initAttendanceProvider = FutureProvider.family<void, String>((
  ref,
  courseId,
) async {
  final auth = ref.read(authStateProvider);
  if (courseId.isEmpty) {
    throw Exception('Invalid course_id');
  }

  final res = await http.post(
    Uri.parse('${Env.apiBaseUrl}/api/attendance/init/$courseId'),
    headers: {
      'Authorization': 'Bearer ${auth.token}',
      'Cache-Control': 'no-cache',
    },
  );

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception('Failed to initialize attendance');
  }
});
