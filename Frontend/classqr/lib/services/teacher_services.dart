import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subject.dart';
import '../models/attendance.dart';
import '../core/config/env.dart';
import '../views/student/stu.dart' hide Subject;

class TeacherService {
  // Load subjects from subject.json or from backend
  static Future<List<Course>> loadSubjects() async {
    // You can fetch from assets (subject.json) or call backend: GET /api/subjects/teacher/{teacherId}
    // Example: final res = await http.get(Uri.parse('${Env.apiBaseUrl}/api/subjects'));
    // Here we return empty list as placeholder
    return [];
  }

  // Fetch students by filters: semester / programme
  static Future<List<Student>> fetchStudents({
    required String subjectId,
    String? semester,
    String? programme,
  }) async {
    final url = Uri.parse(
      '${Env.apiBaseUrl}/api/teacher/subject/$subjectId/students?semester=${semester ?? ""}&programme=${programme ?? ""}',
    );
    final res = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as List;
      // return body.map((e) => Student.fromJson(e)).toList();
    }
    return [];
  }

  // Enroll a student
  static Future<bool> enrollStudent({
    required String subjectId,
    required String studentId,
  }) async {
    final url = Uri.parse(
      '${Env.apiBaseUrl}/api/teacher/subject/$subjectId/enroll',
    );
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Unenroll
  static Future<bool> unenrollStudent({
    required String subjectId,
    required String studentId,
  }) async {
    final url = Uri.parse(
      '${Env.apiBaseUrl}/api/teacher/subject/$subjectId/unenroll',
    );
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId}),
    );
    return res.statusCode == 200;
  }

  // Get attendance summary for a subject
  static Future<List<AttendanceRecord>> fetchAttendance({
    required String subjectId,
  }) async {
    final url = Uri.parse(
      '${Env.apiBaseUrl}/api/teacher/subject/$subjectId/attendance',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final List body = jsonDecode(res.body);
      return body
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Create attendance records (bulk)
  static Future<bool> submitAttendanceBulk(
    String subjectId,
    List<Map<String, dynamic>> payload,
  ) async {
    final url = Uri.parse(
      '${Env.apiBaseUrl}/api/teacher/subject/$subjectId/attendance/bulk',
    );
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'records': payload}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Generate QR token (server can also issue token to validate)
  static Future<String?> generateQrToken(String subjectId) async {
    final url = Uri.parse(
      '${Env.apiBaseUrl}/api/teacher/subject/$subjectId/qr/generate',
    );
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'expireMinutes': 10}),
    );
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return j['token'] as String?;
    }
    return null;
  }

  // Export attendance (server-side generation recommended)
  static Future<http.Response?> downloadAttendanceCsv(
    String subjectId, {
    String? fromDate,
    String? toDate,
  }) async {
    final url = Uri.parse(
      '${Env.apiBaseUrl}/api/teacher/subject/$subjectId/attendance/export?from=$fromDate&to=$toDate&format=csv',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) return res;
    return null;
  }
}
