import 'dart:convert';
import 'package:classqr/models/enrollment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/config/env.dart';
import '../models/attendance_query.dart';
import 'auth_provider.dart';

final attendanceProvider =
    FutureProvider.family<List<EnrolledStudent>, AttendanceQuery>((
      ref,
      query,
    ) async {
      final auth = ref.read(authStateProvider);
      final course_id = query.course_id;
      final date = query.date;
      final res = await http.get(
        Uri.parse(
          '${Env.apiBaseUrl}/api/attendance/course/$course_id',
        ).replace(queryParameters: {'date': date}),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );
      if (res.statusCode != 200 || res.statusCode != 304) {
        throw Exception('Failed to load attendance');
      }
      final List data = jsonDecode(res.body);
      debugPrint(data.toString());
      return data.map((e) => EnrolledStudent.fromJson(e)).toList();
    });
