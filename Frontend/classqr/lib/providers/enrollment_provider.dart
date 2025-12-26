import 'dart:convert';

import 'package:classqr/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../core/config/env.dart';
import '../models/enrollment_model.dart';

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

  debugPrint('Initializing attendance for course_id: $courseId');

  final res = await http.post(
    Uri.parse('${Env.apiBaseUrl}/api/attendance/init/$courseId'),
    headers: {
      'Authorization': 'Bearer ${auth.token}',
      'Cache-Control': 'no-cache',
    },
  );

  debugPrint('Init Attendance Status: ${res.statusCode}');
  debugPrint('Init Attendance Body: ${res.body}');

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception('Failed to initialize attendance');
  }
});

final enrolledStudentsProvider =
    FutureProvider.family<List<EnrolledStudent>, String>((
      ref,
      course_id,
    ) async {
      await ref.watch(initAttendanceProvider(course_id).future);
      final auth = ref.read(authStateProvider);

      final res = await http.get(
        Uri.parse('${Env.apiBaseUrl}/api/attendance/course/$course_id'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to load enrolled students');
      }

      final List data = jsonDecode(res.body);
      debugPrint(data.toString());
      return data.map((e) => EnrolledStudent.fromJson(e)).toList();
    });
