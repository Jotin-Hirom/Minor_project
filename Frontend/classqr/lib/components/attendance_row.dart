import 'dart:convert';

import 'package:classqr/components/action_chip.dart';
import 'package:classqr/core/config/env.dart';
import 'package:classqr/providers/attendance_provider.dart';
import 'package:classqr/providers/enrollment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/attendance_query.dart';
import '../models/enrollment_model.dart';
import '../providers/auth_provider.dart';

class AttendanceRow extends ConsumerWidget {
  final EnrolledStudent student;
  final String course_id;

  const AttendanceRow({
    super.key,
    required this.student,
    required this.course_id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authStateProvider);
    final selectedDate = ref.watch(selectedAttendanceDateProvider);
    final date =
        "${selectedDate.year.toString().padLeft(4, '0')}-"
        "${selectedDate.month.toString().padLeft(2, '0')}-"
        "${selectedDate.day.toString().padLeft(2, '0')}";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(student.rollNo)),
          Expanded(child: Text(student.name)),

          Expanded(
            child: Text(
              student.present ? "Present" : "Absent",
              style: TextStyle(
                color: student.present ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          CustomActionChip(
            icon: student.present
                ? Icons.person_remove_alt_1_outlined
                : Icons.check_circle_outline,
            label: student.present ? "A" : "P",
            onPressed: () async {
              try {
                await http.post(
                  Uri.parse('${Env.apiBaseUrl}/api/attendance/mark'),
                  headers: {
                    'Authorization': 'Bearer ${auth.token}',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'student_id': student.userId,
                    'course_id': course_id,
                    'attendance_date': date,
                    'present': !student.present,
                  }),
                );
                // invalidate using the AttendanceQuery object expected by the provider
                ref.invalidate(
                  attendanceProvider(
                    AttendanceQuery(course_id: course_id, date: date),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          ),
        ],
      ),
    );
  }
}
