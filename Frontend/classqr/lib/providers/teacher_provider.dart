import 'package:flutter_riverpod/legacy.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../services/teacher_services.dart';
import '../views/student/stu.dart';

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>(
  (ref) => SubjectsNotifier(),
);
final studentsProvider = StateNotifierProvider<StudentsNotifier, List<Student>>(
  (ref) => StudentsNotifier(),
);
final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>(
      (ref) => AttendanceNotifier(),
    );

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  SubjectsNotifier() : super([]);

  Future<void> load() async {
    final s = await TeacherService.loadSubjects();
    state = s.cast<Subject>();
  }
}

class StudentsNotifier extends StateNotifier<List<Student>> {
  StudentsNotifier() : super([]);

  Future<void> loadForSubject(
    String subjectId, {
    String? semester,
    String? programme,
  }) async {
    final s = await TeacherService.fetchStudents(
      subjectId: subjectId,
      semester: semester,
      programme: programme,
    );
    state = s;
  }

  Future<bool> enroll(String subjectId, String studentId) async {
    final ok = await TeacherService.enrollStudent(
      subjectId: subjectId,
      studentId: studentId,
    );
    if (ok) {
      await loadForSubject(subjectId);
    }
    return ok;
  }

  Future<bool> unenroll(String subjectId, String studentId) async {
    final ok = await TeacherService.unenrollStudent(
      subjectId: subjectId,
      studentId: studentId,
    );
    // if (ok) {
    //   state = state.where((s) => s. != studentId).toList();
    // }
    return ok;
  }
}

class AttendanceNotifier extends StateNotifier<List<AttendanceRecord>> {
  AttendanceNotifier() : super([]);

  Future<void> load(String subjectId) async {
    final a = await TeacherService.fetchAttendance(subjectId: subjectId);
    state = a;
  }

  Future<bool> submitBulk(
    String subjectId,
    List<AttendanceRecord> records,
  ) async {
    final payload = records.map((r) => r.toJson()).toList();
    final ok = await TeacherService.submitAttendanceBulk(
      subjectId,
      payload.cast<Map<String, dynamic>>(),
    );
    if (ok) await load(subjectId);
    return ok;
  }
}
