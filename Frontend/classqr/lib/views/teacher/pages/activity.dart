import 'dart:async';
import 'dart:convert';
import 'package:classqr/components/action_chip.dart';
import 'package:classqr/components/attendance_row.dart';
import 'package:classqr/components/export_button.dart';
import 'package:classqr/components/section_card.dart';
import 'package:classqr/components/semester_dropdown.dart';
import 'package:classqr/components/programme_dropdown.dart';
import 'package:classqr/components/primary_button.dart';
import 'package:classqr/components/table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

import '../../../core/config/env.dart';
import '../../../models/attendance_query.dart';
import '../../../models/subject.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/enrollment_provider.dart';
import '../../../providers/teacher_selected_subject.dart';

class ActivityPage extends ConsumerStatefulWidget {
  String course_id;
  ActivityPage({super.key, required this.course_id});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  String? qrData;
  Timer? expiryTimer;

  Future<void> _generateQr() async {
    final auth = ref.read(authStateProvider);
    debugPrint(widget.course_id);
    final res = await http.post(
      Uri.parse("${Env.apiBaseUrl}/attendance/qr/generate"),
      headers: {
        "Authorization": "Bearer ${auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"course_id": widget.course_id, "duration_minutes": 10}),
    );

    final data = jsonDecode(res.body);

    setState(() {
      qrData = data["qr_id"]; // RANDOM UUID
    });

    // Auto-expire after 10 minutes
    expiryTimer?.cancel();
    expiryTimer = Timer(const Duration(minutes: 10), () {
      _showExpiredDialog();
    });
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("QR Expired"),
        content: const Text("Attendance window is closed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openApprovalPanel();
            },
            child: const Text("Review Attendance"),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _fetchPendingScans() async {
    final auth = ref.read(authStateProvider);

    final res = await http.get(
      Uri.parse(
        "${Env.apiBaseUrl}/attendance/pending?course_id=${widget.course_id}",
      ),
      headers: {"Authorization": "Bearer ${auth.token}"},
    );

    return jsonDecode(res.body);
  }

  void _openApprovalPanel() async {
    final scans = await _fetchPendingScans();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ListView.builder(
        itemCount: scans.length,
        itemBuilder: (_, i) {
          final s = scans[i];
          return ListTile(
            title: Text(s["student_name"]),
            subtitle: Text(s["roll_no"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _approve(s["scan_id"], true),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _approve(s["scan_id"], false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _approve(String scanId, bool accepted) async {
    final auth = ref.read(authStateProvider);

    await http.post(
      Uri.parse("${Env.apiBaseUrl}/attendance/verify"),
      headers: {
        "Authorization": "Bearer ${auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "scan_id": scanId,
        "result": accepted ? "accepted" : "rejected",
      }),
    );
  }

  Future<void> scanQr(String qrId) async {
    final auth = ref.read(authStateProvider);

    final res = await http.post(
      Uri.parse("${Env.apiBaseUrl}/attendance/scan"),
      headers: {
        "Authorization": "Bearer ${auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"qr_id": qrId}),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scan submitted for approval")),
      );
    }
  }

  Future<void> fetchSubjects() async {
    final auth = ref.read(authStateProvider);
    final user = auth.user;
    try {
      final uri = Uri.parse(
        "${Env.apiBaseUrl}/api/subject/${user?.id}/subjects",
      );
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer ${auth.token}",
          "Content-Type": "application/json",
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 304) &&
          response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Course> subjects = data
            .map((e) => Course.fromJson(e))
            .toList();
        // Update the subjects provider with fetched data
        // assign to the notifier's state directly since setSubjects isn't defined
        (ref.read(teacherSelectedSubjectsProvider.notifier) as dynamic).state =
            subjects;
      } else {
        errorMsg("Failed to fetch subjects.");
      }
    } catch (e) {
      errorMsg("Something went wrong.");
    }
  }

  void errorMsg(String msg) {
    toastification.show(
      type: ToastificationType.error,
      context: context,
      alignment: Alignment.topCenter,
      title: Text(msg),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSubjects();
    // _generateQr();
  }

  @override
  void dispose() {
    expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 900;
        final EdgeInsets padding = EdgeInsets.all(isDesktop ? 24 : 16);
        final selectedDate = ref.watch(selectedAttendanceDateProvider);
        final date =
            "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
        // final attendanceAsync = ref.watch(attendanceProvider(courseId));
        return Scaffold(
          appBar: AppBar(
            title: const Text("Attendance Page"),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),

          body: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STUDENT ENROLLMENT SECTION
                SectionCard(
                  title: "Add Students",
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(child: ProgrammeDropdown()),
                            const SizedBox(width: 16),
                            Expanded(child: SemesterDropdown()),
                            const SizedBox(width: 16),
                            PrimaryButton(
                              label: "Search Students",
                              course_id: widget.course_id,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            ProgrammeDropdown(),
                            const SizedBox(height: 12),
                            SemesterDropdown(),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: "Search Students",
                              course_id: widget.course_id,
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),
                isDesktop
                    ? Row(
                        children: [
                          // ATTENDANCE SECTION
                          SectionCard(
                            title: "Export Attendance & Take Attendance",
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                CustomActionChip(
                                  icon: Icons.qr_code_scanner,
                                  label: "Generate QR",
                                  onPressed: () async {
                                    // Handle QR code generation here
                                    await _generateQr();
                                  },
                                ),
                                ExportButton(
                                  icon: Icons.picture_as_pdf,
                                  label: "Export PDF",
                                  color: Colors.red,
                                ),
                                ExportButton(
                                  icon: Icons.table_chart,
                                  label: "Export Excel",
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // ATTENDANCE SECTION
                          SectionCard(
                            title: "Export Attendance & Take Attendance",
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                CustomActionChip(
                                  icon: Icons.qr_code_scanner,
                                  label: "Generate QR",
                                  onPressed: () async {
                                    // Handle QR code generation here
                                    await _generateQr();
                                  },
                                ),
                                ExportButton(
                                  icon: Icons.picture_as_pdf,
                                  label: "Export PDF",
                                  color: Colors.red,
                                ),
                                ExportButton(
                                  icon: Icons.table_chart,
                                  label: "Export Excel",
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                const SizedBox(height: 24),

                // ATTENDANCE RECORDS SECTION
                SectionCard(
                  title: "Attendance Records",
                  child: Consumer(
                    builder: (context, ref, _) {
                      final course = ref.watch(selectedCourseProvider);
                      final String? course_id = course?.course_id;
                      if (course_id == null || course_id.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Invalid course selected"),
                        );
                      }

                      final enrolledAsync = ref.watch(
                        attendanceProvider(
                          AttendanceQuery(course_id: course_id, date: date),
                        ),
                      );

                      debugPrint(enrolledAsync.toString());
                      return enrolledAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              "Attendance not found for this $date. ${e.toString()}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        data: (students) {
                          if (students.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "No students enrolled in this course.",
                              ),
                            );
                          }

                          return Column(
                            children: [
                              TableHeader(),
                              const Divider(height: 1),

                              ...students.map(
                                (s) => AttendanceRow(
                                  student: s,
                                  course_id: course_id,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
